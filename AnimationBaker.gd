extends Node

@export var character_root_path: NodePath = ^"Ranger"

@export_global_file("*.res") var transition_save_path: String = \
	"res://Project/Characters/Components/Animation/Resources_Animation/Sprint_Start.res"
@export_global_file("*.res") var loop_save_path: String = \
	"res://Project/Characters/Components/Animation/Resources_Animation/Sprint_Loop.res"

@export var frames_per_phase: int = 24 # 24 transition + 24 loop = 48 total
@export var sprint_add_amount: float = 0.75

func _ready() -> void:
	await get_tree().process_frame

	var character := get_node(character_root_path)
	var anim_player: AnimationPlayer = character.get_node("AnimationPlayer")
	var anim_tree: AnimationTree = character.get_node("AnimationTree")
	var skeleton: Skeleton3D = character.get_node("Rig_Medium/Skeleton3D")

	if anim_player == null or anim_tree == null or skeleton == null:
		push_error("AnimationBaker: could not find AnimationPlayer/AnimationTree/Skeleton3D.")
		get_tree().quit()
		return

	var base_anim: Animation = anim_player.get_animation("Movement/Running_B")
	if base_anim == null:
		push_error("AnimationBaker: 'Movement/Running_B' not found on AnimationPlayer.")
		get_tree().quit()
		return

	# 24 frames = exactly one Running_B stride, so the loop phase is seamless.
	var fps: float = float(frames_per_phase) / base_anim.length
	var step: float = 1.0 / fps

	anim_tree.callback_mode_process = AnimationTree.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	anim_tree.active = true
	anim_tree.set("parameters/SprintTimeScale/scale", 1.0)
	anim_tree.set("parameters/OutputMode/transition_request", &"Sprint")
	anim_tree.set("parameters/SprintAdd/add_amount", 0.0) # start pure Running_B
	anim_tree.advance(0.0)

	var bone_count := skeleton.get_bone_count()
	var transition_anim := _make_bone_animation(skeleton, bone_count, frames_per_phase * step, false)
	var loop_anim := _make_bone_animation(skeleton, bone_count, frames_per_phase * step, true)

	var t_tracks := _add_bone_tracks(transition_anim, skeleton, bone_count)
	var l_tracks := _add_bone_tracks(loop_anim, skeleton, bone_count)

	# --- Phase 1: transition (add_amount ramps 0 -> target over the cycle) ---
	for i in range(frames_per_phase):
		var blend: float = float(i + 1) / float(frames_per_phase)
		anim_tree.set("parameters/SprintAdd/add_amount", blend * sprint_add_amount)
		anim_tree.advance(step)
		_capture_frame(skeleton, bone_count, t_tracks, transition_anim, i * step)

	# --- Phase 2: loop (add_amount held at full — Dash has already finished
	# and its held pose stays constant, which is what makes this loop clean) ---
	anim_tree.set("parameters/SprintAdd/add_amount", sprint_add_amount)
	for i in range(frames_per_phase):
		anim_tree.advance(step)
		_capture_frame(skeleton, bone_count, l_tracks, loop_anim, i * step)

	ResourceSaver.save(transition_anim, transition_save_path)
	ResourceSaver.save(loop_anim, loop_save_path)
	print("AnimationBaker: saved ", transition_save_path, " and ", loop_save_path,
		" (", frames_per_phase, " frames each, ", fps, " fps)")

	get_tree().quit()

func _make_bone_animation(skeleton: Skeleton3D, bone_count: int, length: float, loop: bool) -> Animation:
	var anim := Animation.new()
	anim.length = length
	anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	return anim

func _add_bone_tracks(anim: Animation, skeleton: Skeleton3D, bone_count: int) -> Dictionary:
	var tracks := {}
	for bone_idx in range(bone_count):
		var path := NodePath("Rig_Medium/Skeleton3D:%s" % skeleton.get_bone_name(bone_idx))
		var pos_track := anim.add_track(Animation.TYPE_POSITION_3D)
		anim.track_set_path(pos_track, path)
		var rot_track := anim.add_track(Animation.TYPE_ROTATION_3D)
		anim.track_set_path(rot_track, path)
		var scl_track := anim.add_track(Animation.TYPE_SCALE_3D)
		anim.track_set_path(scl_track, path)
		tracks[bone_idx] = {"pos": pos_track, "rot": rot_track, "scl": scl_track}
	return tracks

func _capture_frame(skeleton: Skeleton3D, bone_count: int, tracks: Dictionary, anim: Animation, t: float) -> void:
	for bone_idx in range(bone_count):
		var idx = tracks[bone_idx]
		anim.position_track_insert_key(idx.pos, t, skeleton.get_bone_pose_position(bone_idx))
		anim.rotation_track_insert_key(idx.rot, t, skeleton.get_bone_pose_rotation(bone_idx))
		anim.scale_track_insert_key(idx.scl, t, skeleton.get_bone_pose_scale(bone_idx))

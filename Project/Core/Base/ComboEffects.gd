extends RefCounted
class_name CombatEffects

static func play_vfx(scene: PackedScene, position: Vector3, tree: SceneTree) -> void:

	if scene == null or tree == null or tree.current_scene == null:
		return

	var vfx := scene.instantiate() as Node3D

	if vfx == null:
		return

	tree.current_scene.add_child(vfx)
	vfx.global_position = position

static func play_sfx(stream: AudioStream, position: Vector3, tree: SceneTree) -> void:

	if stream == null or tree == null or tree.current_scene == null:
		return

	var player := AudioStreamPlayer3D.new()
	tree.current_scene.add_child(player)
	player.stream = stream
	player.global_position = position
	player.play()
	player.finished.connect(player.queue_free)

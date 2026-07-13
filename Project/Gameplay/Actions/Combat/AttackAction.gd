extends CharacterAction
class_name AttackAction

#==============================================================================
# Runtime
#==============================================================================

var _weapon: WeaponComponent
var _attack: AttackDefinition

var _watched_clip: StringName = &""

#==============================================================================
# Validation
#==============================================================================

func can_execute() -> bool:

	_weapon = context.weapon

	if _weapon == null:
		return false

	if not _weapon.has_weapon():
		return false

	_attack = _weapon.select_next_attack()

	if _attack == null:
		return false

	return true

#==============================================================================
# Lifecycle
#==============================================================================

func on_start() -> void:

	super.on_start()
	
	if _weapon != null:
		_weapon.commit_attack(_attack)
		
	context.combat.begin_attack()
	
	_apply_attack_data()
	_apply_motion()
	_face_target()
	_play_attack_animation()

func on_update(_delta: float) -> int:
	_face_target()
	return ActionExecutionStatus.Id.RUNNING
		
func on_finish_requested() -> void:
	context.combat.finish_attack()
	_clear_attack_data()
	_clear_motion()

func get_recovery_time() -> float:
	if _attack == null or _attack.timing == null:
		return 0.0
	return _attack.timing.recovery_time

func open_interrupt_window() -> void:
	super.open_interrupt_window()
	context.action.release_locks(
		ActionLock.Id.MOVEMENT
		| ActionLock.Id.ROTATION
		| ActionLock.Id.INPUT
	)

func on_finish() -> void:
	context.combat.finish_attack()
	_clear_attack_data()
	_clear_motion()
	super.on_finish()

#==============================================================================
# Internal
#==============================================================================

func _play_attack_animation() -> void:

	if _attack == null:
		return

	if _attack.animation.is_empty():
		animation.play_attack()
		return

	animation.play(
		_attack.animation,
		true
	)

	_watch_for_completion(_attack.animation)

func _watch_for_completion(clip_name: StringName) -> void:
	_watched_clip = clip_name
	if not animation.animation_finished.is_connected(_on_watched_animation_finished):
		animation.animation_finished.connect(_on_watched_animation_finished, CONNECT_ONE_SHOT)

func _on_watched_animation_finished(finished_name: StringName) -> void:
	if finished_name != _watched_clip:
		return
	request_finish()

func _play_attack_effects() -> void:
	if _attack == null or _attack.effects == null:
		return
	CombatEffects.play_vfx(
	_attack.effects.slash_vfx,
	context.character.global_position,
	context.character.get_tree()
	)

	CombatEffects.play_sfx(
	_attack.effects.attack_sfx,
	context.character.global_position,
	context.character.get_tree()
	)
	
func _apply_attack_data() -> void:

	if _attack == null:
		return

	var hitbox := context.combat.get_hitbox()

	if hitbox != null:
		hitbox.set_active_attack_data(_attack.attack_data)
		hitbox.set_active_effects(_attack.effects)
		
	context.combat.set_active_projectile(_attack.projectile_scene, _attack.attack_data)

func _clear_attack_data() -> void:
	var hitbox := context.combat.get_hitbox()

	if hitbox != null:
		hitbox.clear_active_attack_data()
		hitbox.clear_active_effects()

	context.combat.clear_active_projectile()

func _apply_motion() -> void:

	if _attack == null or _attack.motion == null:
		return

	var movement := context.movement

	if movement == null:
		return

	if _attack.motion.move_distance > 0.0 and _attack.motion.move_speed > 0.0:
		movement.apply_attack_motion(
			_attack.motion.move_distance,
			_attack.motion.move_speed
		)

func _clear_motion() -> void:

	var movement := context.movement

	if movement != null:
		movement.clear_attack_motion()

func _face_target() -> void:

	if context.targeting == null or _weapon == null:
		return

	var target := context.targeting.get_target_within_range(_weapon.get_attack_range())

	if target == null:
		return

	context.movement.face_point(target.global_position)

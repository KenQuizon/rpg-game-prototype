extends CharacterAction
class_name AttackAction

#==============================================================================
# Runtime
#==============================================================================

var _weapon: WeaponComponent
var _attack: AttackDefinition

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

	context.combat.begin_attack()

	_apply_attack_data()
	_apply_motion()
	_play_attack_animation()

func on_update(_delta: float) -> int:
	return ActionExecutionStatus.Id.RUNNING

# Fires immediately when FINISH_ACTION (or the duration safety net) asks
# this action to wind down — stops dealing damage and stops forced motion
# right away, while get_recovery_time() below holds the action's locks a
# bit longer.
func on_finish_requested() -> void:
	context.combat.finish_attack()
	_clear_attack_data()
	_clear_motion()

func get_recovery_time() -> float:
	if _attack == null or _attack.timing == null:
		return 0.0
	return _attack.timing.recovery_time

func on_finish() -> void:
	# Safety net — idempotent, guarantees clean state even if
	# on_finish_requested() never ran (e.g. duration timeout with no
	# FINISH_ACTION event at all).
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

	if hitbox == null:
		return

	hitbox.set_active_attack_data(_attack.attack_data)

	hitbox.set_active_attack_data(_attack.attack_data)
	hitbox.set_active_effects(_attack.effects)
	
func _clear_attack_data() -> void:

	var hitbox := context.combat.get_hitbox()

	if hitbox != null:
		hitbox.clear_active_attack_data()
		
	hitbox.clear_active_attack_data()
	hitbox.clear_active_effects()

# Wires AttackMotion.move_distance/move_speed only — allow_rotation and
# stop_movement_input are superseded by ActionDefinition.locks (ROTATION/
# MOVEMENT, built in Phase 4) and are intentionally left unwired to avoid
# two competing switches for the same behavior.
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

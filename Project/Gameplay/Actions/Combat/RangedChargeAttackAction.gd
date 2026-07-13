extends AttackAction
class_name RangedChargeAttackAction

const MAX_CHARGE_TIME: float = 1.5


var _charging := false
var _release_requested := false
var _charge_time := 0.0

var _aiming := true

func can_execute() -> bool:

	_weapon = context.weapon

	if _weapon == null or not _weapon.has_weapon():
		return false

	# Heavy attacks aren't part of the light combo cycle — use whatever
	# definition the command actually submitted (see ChargedAttackCommand)
	# instead of select_next_attack().
	_attack = request.definition as AttackDefinition

	return _attack != null

func _play_attack_animation() -> void:

	if _attack == null:
		return

	if _attack.draw_animation.is_empty():
		super._play_attack_animation()
		return

	animation.set_aiming(true)
	
	if not animation.animation_finished.is_connected(_on_draw_finished):
		animation.animation_finished.connect(_on_draw_finished, CONNECT_ONE_SHOT)

	animation.play(_attack.draw_animation, true)

func _on_draw_finished(finished_name: StringName) -> void:

	if finished_name != _attack.draw_animation:
		return

	if _release_requested or _attack.aim_animation.is_empty():
		_release()
		return

	_charging = true
	_charge_time = 0.0
	
	animation.set_aim_pose(&"AimIdle")
	
	UIEvents.charge_started.emit()

func on_update(delta: float) -> int:

	if _aiming and context.input != null:
		context.movement.face_point(context.input.aim_world_position)

	if not context.input.charged_attack_held:
		_release_requested = true

	if _charging:
		_charge_time = min(_charge_time + delta, MAX_CHARGE_TIME)
		UIEvents.charge_updated.emit(_get_charge_percent())

	if _charging and _release_requested:
		_release()

	return ActionExecutionStatus.Id.RUNNING

func _get_charge_percent() -> float:
	if MAX_CHARGE_TIME <= 0.0:
		return 1.0

	return clamp(_charge_time / MAX_CHARGE_TIME, 0.0, 1.0)
	
func _release() -> void:

	_charging = false
	# _aiming is intentionally NOT cleared here anymore — it needs to stay
	# true until the projectile actually spawns, or the shot can drag with
	# whatever direction movement input has turned toward by then.

	var charge_percent := _get_charge_percent()

	UIEvents.charge_released.emit(charge_percent)

	var scaled_data := _attack.attack_data.duplicate() as AttackData
	scaled_data.damage *= lerp(1.0, 2.5, charge_percent)
	context.combat.set_active_projectile(_attack.projectile_scene, scaled_data)

	animation.play(_attack.animation, true, 0.15)
	_watch_for_completion(_attack.animation)

# Fires at the exact frame the arrow leaves the bow (see
# SpawnProjectileHandler). This is what actually ends aim control — not
# button-release. Between this and open_interrupt_window(), facing is
# simply frozen (ROTATION is still locked), which is correct: the shot
# already committed to its aimed direction, and movement input shouldn't
# start turning the character mid-recovery either.
func on_projectile_spawned() -> void:
	_aiming = false
	animation.set_aiming(false)
# Safety net only — normal authoring should never reach this while still
# aiming, since spawn_projectile should always be keyed earlier on the
# clip than open_interrupt_window.
func open_interrupt_window() -> void:
	_aiming = false
	super.open_interrupt_window()

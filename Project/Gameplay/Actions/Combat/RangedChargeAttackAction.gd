extends AttackAction
class_name RangedChargeAttackAction

const MAX_CHARGE_TIME: float = 1.5

var _charging := false
var _release_requested := false
var _charge_time := 0.0

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
	animation.play(_attack.aim_animation, false, 0.2)   # small cross-fade into the hold pose

	UIEvents.charge_started.emit()

func on_update(delta: float) -> int:

	# Mouse-aim — runs every frame this action is active (draw, hold, and
	# release), not just while charging, so the shot always faces the
	# cursor. Movement stays fully live throughout: this attack's locks
	# never include MOVEMENT, and MovementComponent only skips updating
	# facing_direction from move input while ROTATION is locked — it
	# never stops applying velocity. That's what lets you strafe freely
	# while aiming without fighting this call for control of the facing.
	if context.input != null:
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

	var charge_percent := _get_charge_percent()

	UIEvents.charge_released.emit(charge_percent)

	# Scale the shot by charge — duplicate first so the shared .tres
	# AttackData resource is never mutated for every future shot.
	var scaled_data := _attack.attack_data.duplicate() as AttackData
	scaled_data.damage *= lerp(1.0, 2.5, charge_percent)
	context.combat.set_active_projectile(_attack.projectile_scene, scaled_data)

	animation.play(_attack.animation, true, 0.15)
	_watch_for_completion(_attack.animation)

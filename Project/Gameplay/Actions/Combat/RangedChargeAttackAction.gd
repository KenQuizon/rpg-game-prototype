extends AttackAction
class_name RangedChargeAttackAction

const MAX_CHARGE_TIME: float = 1.5

var _charging := false
var _release_requested := false
var _charge_time := 0.0

# Overrides AttackAction._play_attack_animation() — instead of jumping
# straight to the release clip, start with the draw.
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
	animation.play(_attack.aim_animation)   # looping clip — see editor note below

func on_update(_delta: float) -> int:

	if not Input.is_action_pressed("attack"):
		_release_requested = true

	if _charging:
		_charge_time = min(_charge_time + _delta, MAX_CHARGE_TIME)
		
	if _charging and _release_requested:
		_release()

	return ActionExecutionStatus.Id.RUNNING

func _release() -> void:

	_charging = false

	var charge_percent := 0.0

	if MAX_CHARGE_TIME > 0.0:
		charge_percent = clamp(_charge_time / MAX_CHARGE_TIME, 0.0, 1.0)

	# THE FIX: Set the active projectile with scaled damage BEFORE playing release animation
	# This ensures the projectile data is ready when the spawn_projectile animation event fires
	if _attack != null:
		var scaled := _attack.attack_data.duplicate()
		scaled.damage *= lerp(1.0, 2.5, charge_percent)
		context.combat.set_active_projectile(_attack.projectile_scene, scaled)
		print("[RANGED CHARGE] Projectile set: scene=", _attack.projectile_scene, " damage=", scaled.damage)

	if not animation.animation_finished.is_connected(_on_release_finished):
		animation.animation_finished.connect(_on_release_finished, CONNECT_ONE_SHOT)

	animation.play(_attack.animation, true)   # Ranged_Bow_Release — already has
												  # your spawn_projectile + finish_action
												  # call-method tracks

func _on_release_finished(finished_name: StringName) -> void:
	if finished_name != _attack.animation:
		return
	request_finish()

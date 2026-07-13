extends AttackAction
class_name RangedAttackAction

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

	animation.play(_attack.animation, true)
	_watch_for_completion(_attack.animation)

extends CharacterState
class_name CharacterDeadState

func get_state_name() -> StringName:
	return &"Dead"

func enter() -> void:

	var movement := context.movement

	if movement:
		movement.set_move_input(Vector2.ZERO)

	if context.animation != null:
		context.animation.play_death()

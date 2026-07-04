extends CharacterState
class_name CharacterIdleState

func get_state_name() -> StringName:
	return &"Idle"

func process_update(_delta: float) -> void:

	var movement := context.movement

	if movement == null:
		return

	movement.set_move_input(context.input.move_vector)

	if movement.move_input != Vector2.ZERO:
		context.character.state_machine.change_state(
			CharacterMoveState.new()
		)

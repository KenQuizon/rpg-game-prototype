extends CharacterState
class_name CharacterMoveState

func get_state_name() -> StringName:
	return &"Move"

func process_update(_delta: float) -> void:

	var movement := context.movement

	if movement == null:
		return

	movement.set_move_input(context.input.move_vector)

	if movement.move_input == Vector2.ZERO:

		# Duck-typed against get_character_state_machine() — see the
		# identical note in CharacterIdleState.gd (roadmap 7.2).
		if context.character.has_method("get_character_state_machine"):

			var state_machine: CharacterStateMachine = context.character.get_character_state_machine()

			if state_machine != null:
				state_machine.change_state(CharacterIdleState.new())

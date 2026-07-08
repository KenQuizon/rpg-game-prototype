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

		# Duck-typed against get_character_state_machine() (see
		# CombatComponent._on_died() for the same pattern) rather than a
		# hard `.state_machine` property access — context.character is
		# typed Node, not Character (roadmap 7.2), so any host implementing
		# the framework's contract can drive its own state transitions.
		if context.character.has_method("get_character_state_machine"):

			var state_machine: CharacterStateMachine = context.character.get_character_state_machine()

			if state_machine != null:
				state_machine.change_state(CharacterMoveState.new())

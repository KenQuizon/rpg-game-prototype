extends BaseController
class_name PlayerController

#==============================================================================
# Cached Components
#==============================================================================

var _movement: MovementComponent = null

var _interaction: InteractionComponent

var _action: ActionComponent

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:
	_movement = context.movement
	
	_interaction = context.interaction
	
	_action = context.action

#==============================================================================
# Updates
#==============================================================================

func physics_update(_delta: float) -> void:

	var movement := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	context.input.move_vector = movement

	if _movement:
		_movement.set_move_input(movement)

	context.input.interact_pressed = Input.is_action_just_pressed("interact")
	context.input.attack_pressed = Input.is_action_just_pressed("attack")
	context.input.dash_pressed = Input.is_action_just_pressed("dash")

	if context.input.attack_pressed:
		if _action:
			_action.execute_action(AttackAction.new())

	if context.input.interact_pressed:
		if _interaction:
			_interaction.interact()

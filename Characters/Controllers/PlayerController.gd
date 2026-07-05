extends BaseController
class_name PlayerController

#==============================================================================
# Updates
#==============================================================================

func physics_update(_delta: float) -> void:

	#--------------------------------------------------------------------------
	# Capture Input
	#--------------------------------------------------------------------------

	context.input.move_vector = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	context.input.attack_pressed = Input.is_action_just_pressed("attack")
	context.input.interact_pressed = Input.is_action_just_pressed("interact")
	context.input.dash_pressed = Input.is_action_just_pressed("dash")

	#--------------------------------------------------------------------------
	# Movement
	#--------------------------------------------------------------------------

	if context.movement:
		context.movement.set_move_input(
			context.input.move_vector
		)

	#--------------------------------------------------------------------------
	# Commands
	#--------------------------------------------------------------------------

	if context.input.attack_pressed:

		var attack := AttackCommand.new()

		attack.initialize(context)

		attack.execute()

	if context.input.interact_pressed:

		var interact := InteractCommand.new()

		interact.initialize(context)

		interact.execute()

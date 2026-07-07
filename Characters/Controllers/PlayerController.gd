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

	# Raw input is always captured above (harmless, and useful for UI/state
	# tracking even while locked). If INPUT is locked, movement input is
	# explicitly zeroed here rather than left at its last value — otherwise
	# a status that locks INPUT without also locking MOVEMENT (e.g. a
	# silence that blocks commands but shouldn't root the character) would
	# leave MovementComponent driving stale, pre-lock input indefinitely,
	# since nothing else would ever call set_move_input() again until the
	# lock clears.
	if context.is_locked(ActionLock.Id.INPUT):
		if context.movement:
			context.movement.set_move_input(Vector2.ZERO)
		return

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

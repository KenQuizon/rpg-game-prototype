extends CharacterState
class_name CharacterDeadState

func get_state_name() -> StringName:
	return &"Dead"


func enter() -> void:

	print("[DEATH STATE] Character entering dead state")

	#--------------------------------------------------------------------------
	# Cancel the current action immediately
	#--------------------------------------------------------------------------

	if context.action != null:
		context.action.cancel_current()

	#--------------------------------------------------------------------------
	# Stop movement
	#--------------------------------------------------------------------------

	if context.movement != null:
		context.movement.set_move_input(Vector2.ZERO)

	#--------------------------------------------------------------------------
	# Disable gameplay systems
	#--------------------------------------------------------------------------

	if context.targeting != null:
		context.targeting.set_enabled(false)

	# If your ActionComponent eventually supports set_enabled(),
	# replace cancel_current() with:
	#
	# context.action.set_enabled(false)

	#--------------------------------------------------------------------------
	# Disable combat hitbox
	#--------------------------------------------------------------------------

	if context.combat != null:
		var hitbox := context.combat.get_hitbox()

		if hitbox != null:
			hitbox.deactivate()

	#--------------------------------------------------------------------------
	# Disable controller (PlayerController / AIController)
	#--------------------------------------------------------------------------

	_disable_controller()

	#--------------------------------------------------------------------------
	# Play death animation
	#--------------------------------------------------------------------------

	if context.animation != null:
		context.animation.play_death()


func exit() -> void:

	# Dead is normally a terminal state.
	# If the character respawns, re-enable systems here.

	if context.targeting != null:
		context.targeting.set_enabled(true)

	_enable_controller()


# CharacterDeadState.gd
func _disable_controller() -> void:
	if context.character != null:
		context.character.set_controller_active(false)

func _enable_controller() -> void:

	var owner_character: Node = null

	if context.movement != null:
		owner_character = context.movement.owner_character
	elif context.action != null:
		owner_character = context.action.owner_character
	elif context.combat != null:
		owner_character = context.combat.owner_character

	if owner_character == null:
		return

	var controller := owner_character.get_node_or_null("Systems/Controller")

	if controller == null:
		return

	controller.set_process(true)
	controller.set_physics_process(true)

	print("[DEATH STATE] Controller enabled")

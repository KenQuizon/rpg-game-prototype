extends BaseController
class_name AIController

#==============================================================================
# Export Variables
#==============================================================================

@export var attack_range: float = 2.0

#==============================================================================
# Updates
#==============================================================================

# Deliberately minimal — idle / chase / engage, not a general AI framework.
# The point of this class is that every line below only ever writes
# CharacterInput or submits a CharacterCommand, exactly PlayerController's
# contract — never touching ActionComponent, MovementComponent, or the
# state machine directly. That's what makes this a proof of Controller
# Abstraction rather than just another way to move a character.
func physics_update(_delta: float) -> void:

	if context.is_locked(ActionLock.Id.INPUT):
		_write_input(Vector2.ZERO, false)
		return

	var targeting := context.targeting
	var navigation := context.navigation

	if targeting == null or not targeting.has_target():
		_write_input(Vector2.ZERO, false)
		return

	var target := targeting.current_target as Node3D

	if target == null:
		_write_input(Vector2.ZERO, false)
		return

	var distance: float = character.global_position.distance_to(target.global_position)

	if distance > attack_range:
		_chase(target, navigation)
	else:
		_engage(navigation)

#==============================================================================
# Behavior
#==============================================================================

func _chase(target: Node3D, navigation: NavigationComponent) -> void:

	if navigation == null:
		_write_input(Vector2.ZERO, false)
		return

	navigation.set_target_position(target.global_position)

	var direction := navigation.get_move_direction()

	_write_input(
		Vector2(direction.x, direction.z),
		false
	)

	# Deliberately not gated on ActionLock.MOVEMENT here — MovementComponent
	# already zeroes velocity itself while that lock is held (e.g. mid
	# attack-recovery). Writing chase input during a lock is harmless: it's
	# simply ignored downstream until the lock clears, at which point
	# movement resumes toward the target with no special-casing needed here.


func _engage(navigation: NavigationComponent) -> void:

	if navigation != null:
		navigation.clear_target()

	_write_input(Vector2.ZERO, true)

#==============================================================================
# Internal
#==============================================================================

# Mirrors PlayerController's contract exactly: CharacterInput is written
# first (CharacterIdleState/CharacterMoveState read it directly), then
# commands are submitted the same way a human player's input would trigger
# them. attack_requested acts as this frame's "just pressed" edge so
# AttackCommand isn't resubmitted every physics tick while already
# attacking — submit() would reject it anyway while busy, but gating here
# keeps both controllers structurally identical rather than relying on
# that rejection to paper over the difference.
func _write_input(move_vector: Vector2, attack_requested: bool) -> void:

	context.input.move_vector = move_vector

	if context.movement:
		context.movement.set_move_input(move_vector)

	if attack_requested and not context.action.is_busy():

		var attack := AttackCommand.new()

		attack.initialize(context)

		attack.execute()

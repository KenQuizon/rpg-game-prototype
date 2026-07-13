extends BaseController
class_name AIController

#==============================================================================
# Runtime State
#==============================================================================

var _was_in_range := false

#==============================================================================
# Updates
#==============================================================================

func physics_update(_delta: float) -> void:

	if context.is_locked(ActionLock.Id.INPUT):
		_write_input(Vector2.ZERO, false)
		return

	var targeting := context.targeting
	var navigation := context.navigation

	if targeting == null or not targeting.has_target():
		_write_input(Vector2.ZERO, false)
		_was_in_range = false
		return

	var target := targeting.current_target as Node3D

	if target == null:
		_write_input(Vector2.ZERO, false)
		_was_in_range = false
		return

	var distance: float = character.global_position.distance_to(target.global_position)
	var attack_range := context.weapon.get_attack_range() if context.weapon != null else 1.5

	if distance > attack_range:
		# Out of range: chase
		_chase(target, navigation)
		_was_in_range = false
	else:
		# In range: engage
		_engage(navigation)
		_was_in_range = true

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

extends BaseComponent
class_name NavigationComponent

#==============================================================================
# Export Variables
#==============================================================================

@export var target_reached_distance: float = 0.25

#==============================================================================
# Cached Nodes
#==============================================================================

@onready var agent: NavigationAgent3D = $NavigationAgent3D

#==============================================================================
# Runtime
#==============================================================================

var _has_target := false

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:

	if agent == null:
		push_error("NavigationComponent requires a NavigationAgent3D child.")
		return

	agent.target_desired_distance = target_reached_distance

#==============================================================================
# Public API
#==============================================================================

func set_target_position(position: Vector3) -> void:

	if agent == null:
		return

	agent.target_position = position
	_has_target = true


func clear_target() -> void:
	_has_target = false


func has_target() -> bool:
	return _has_target


func is_navigation_finished() -> bool:

	if agent == null:
		return true

	return agent.is_navigation_finished()


func distance_to_target() -> float:

	if agent == null:
		return INF

	return agent.distance_to_target()

# Returns a normalized, ground-plane (Y=0) world-space direction toward the
# next point on the current path — the same shape MovementComponent already
# expects from CharacterInput.move_vector (X->world X, Y->world Z), so
# AIController can pass this straight through with no conversion beyond
# dropping the Y component.
func get_move_direction() -> Vector3:

	if agent == null or not _has_target:
		return Vector3.ZERO

	if agent.is_navigation_finished():
		return Vector3.ZERO

	# Node3D, not Character — only world position is needed here, so any 3D
	# entity (NPC, boss, non-Character actor) can navigate with this component.
	var character := owner_character as Node3D

	if character == null:
		return Vector3.ZERO

	var next_position := agent.get_next_path_position()

	var direction := next_position - character.global_position
	direction.y = 0.0

	if direction.is_zero_approx():
		return Vector3.ZERO

	return direction.normalized()

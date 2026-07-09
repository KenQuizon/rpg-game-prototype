extends BaseComponent
class_name TargetingComponent

#==============================================================================
# Signals
#==============================================================================

signal target_changed(previous: Node, new_target: Node)

#==============================================================================
# Export Variables
#==============================================================================

@export var target_group: StringName = &"enemies"

#==============================================================================
# Cached Nodes
#==============================================================================

var _detection_area: Area3D

#==============================================================================
# Runtime
#==============================================================================

var _nearby: Array[Node] = []
var _current_target: Node = null

#==============================================================================
# Public Properties
#==============================================================================

var current_target: Node:
	get:
		return _current_target


func has_target() -> bool:
	return _current_target != null and is_instance_valid(_current_target)

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:

	_detection_area = owner_character.get_node_or_null("TargetingArea") as Area3D

	if _detection_area == null:
		push_error("TargetingComponent requires a TargetingArea Area3D child on the character.")
		return

	if not _detection_area.body_entered.is_connected(_on_body_entered):
		_detection_area.body_entered.connect(_on_body_entered)

	if not _detection_area.body_exited.is_connected(_on_body_exited):
		_detection_area.body_exited.connect(_on_body_exited)

#==============================================================================
# Updates
#==============================================================================

func physics_update(_delta: float) -> void:

	_prune_invalid()

	if _current_target != null and _is_dead(_current_target):
		_nearby.erase(_current_target)
		_refresh_target()
		return

	if not has_target():
		_refresh_target()
	elif not _nearby.has(_current_target):
		_refresh_target()

#==============================================================================
# Area Events
#==============================================================================

func _on_body_entered(body: Node) -> void:

	if not body.is_in_group(target_group):
		return

	if _nearby.has(body):
		return

	_nearby.append(body)

	if not has_target():
		_refresh_target()


func _on_body_exited(body: Node) -> void:

	if not _nearby.has(body):
		return

	_nearby.erase(body)

	if _current_target == body:
		_refresh_target()

#==============================================================================
# Internal
#==============================================================================

func _prune_invalid() -> void:
	_nearby = _nearby.filter(
		func(body: Node): return is_instance_valid(body)
	)


func _refresh_target() -> void:

	var previous := _current_target

	_current_target = _select_best_target()

	if previous != _current_target:

		target_changed.emit(
			previous,
			_current_target
		)


func _select_best_target() -> Node:

	if _nearby.is_empty():
		return null

	# Node3D, not Character — only world position is needed here, so any 3D
	# entity can be the targeting origin, not just Character.
	var character := owner_character as Node3D

	if character == null:
		return _nearby[0]

	var best: Node = null
	var best_distance := INF

	for candidate in _nearby:

		if not is_instance_valid(candidate):
			continue

		var candidate_3d := candidate as Node3D

		if candidate_3d == null:
			continue

		if _is_dead(candidate):
			continue

		var distance := character.global_position.distance_squared_to(
			candidate_3d.global_position
		)

		if distance < best_distance:
			best_distance = distance
			best = candidate

	return best

# Candidates without a get_component() method (or with no CombatComponent)
# are treated as always-valid — duck-typed rather than requiring the
# candidate to be a Character, so any host implementing the same framework
# contract (an NPC, a boss, a destructible) can be targeted correctly.
func _is_dead(candidate: Node) -> bool:

	if not candidate.has_method("get_component"):
		return false

	var combat := candidate.get_component(CombatComponent) as CombatComponent

	if combat == null:
		return false

	return combat.is_dead()

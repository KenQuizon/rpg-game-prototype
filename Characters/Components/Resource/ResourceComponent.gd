extends BaseComponent
class_name ResourceComponent

#==============================================================================
# Signals
#==============================================================================

signal resource_changed(resource_type: int, previous: float, current: float)
signal resource_depleted(resource_type: int)

#==============================================================================
# Export Variables
#==============================================================================

@export var pools: Array[ResourcePoolProfile] = []

#==============================================================================
# Runtime
#==============================================================================

var _current: Dictionary = {} # ResourceType.Id -> float
var _max: Dictionary = {}
var _regen: Dictionary = {}

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:

	for pool in pools:

		if pool == null:
			continue

		_max[pool.resource_type] = pool.max_value
		_regen[pool.resource_type] = pool.regen_per_second
		_current[pool.resource_type] = pool.max_value if pool.start_full else 0.0

#==============================================================================
# Queries
#==============================================================================

func get_current(resource_type: int) -> float:
	return _current.get(resource_type, 0.0)

func get_max(resource_type: int) -> float:
	return _max.get(resource_type, 0.0)

func has_resource(resource_type: int, amount: float) -> bool:
	return get_current(resource_type) >= amount

#==============================================================================
# Public API
#==============================================================================

func spend(resource_type: int, amount: float) -> bool:

	if amount <= 0.0:
		return true

	if not has_resource(resource_type, amount):
		return false

	var previous := get_current(resource_type)

	_current[resource_type] = previous - amount

	resource_changed.emit(resource_type, previous, _current[resource_type])

	if _current[resource_type] <= 0.0:
		resource_depleted.emit(resource_type)

	return true


func restore(resource_type: int, amount: float) -> void:

	if amount <= 0.0:
		return

	var previous := get_current(resource_type)
	var max_value := get_max(resource_type)

	var new_value: float = min(max_value, previous + amount)

	if new_value == previous:
		return

	_current[resource_type] = new_value

	resource_changed.emit(resource_type, previous, new_value)

#==============================================================================
# Updates
#==============================================================================

func process_update(delta: float) -> void:

	for resource_type in _regen.keys():

		var regen: float = _regen[resource_type]

		if regen <= 0.0:
			continue

		restore(resource_type, regen * delta)

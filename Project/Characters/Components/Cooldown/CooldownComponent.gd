extends BaseComponent
class_name CooldownComponent

#==============================================================================
# Signals
#==============================================================================

signal cooldown_started(group: StringName, duration: float)
signal cooldown_finished(group: StringName)

#==============================================================================
# Runtime
#==============================================================================

var _cooldowns: Dictionary = {} # StringName -> remaining seconds

#==============================================================================
# Queries
#==============================================================================

func is_on_cooldown(group: StringName) -> bool:

	if group == &"":
		return false

	return _cooldowns.get(group, 0.0) > 0.0


func get_remaining(group: StringName) -> float:
	return _cooldowns.get(group, 0.0)

#==============================================================================
# Public API
#==============================================================================

func start_cooldown(group: StringName, duration: float) -> void:

	if group == &"" or duration <= 0.0:
		return

	_cooldowns[group] = duration

	cooldown_started.emit(group, duration)

#==============================================================================
# Updates
#==============================================================================

func process_update(delta: float) -> void:

	if _cooldowns.is_empty():
		return

	var finished: Array[StringName] = []

	for group in _cooldowns.keys():

		var remaining: float = _cooldowns[group] - delta

		if remaining <= 0.0:
			finished.append(group)
		else:
			_cooldowns[group] = remaining

	for group in finished:
		_cooldowns.erase(group)
		cooldown_finished.emit(group)

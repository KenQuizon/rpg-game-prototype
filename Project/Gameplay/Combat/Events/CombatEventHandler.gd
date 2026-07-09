extends RefCounted
class_name CombatEventHandler

#==============================================================================
# Public API
#==============================================================================

func handle_event(
	event_name: StringName,
	context: CharacterContext
) -> void:
	pass

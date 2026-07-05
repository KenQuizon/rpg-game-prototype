extends RefCounted
class_name CombatEventDispatcher

#==============================================================================
# Private
#==============================================================================

var _handlers: Dictionary = {}

#==============================================================================
# Registration
#==============================================================================

func register_handler(
	event_name: StringName,
	handler: CombatEventHandler
) -> void:

	if handler == null:
		return

	_handlers[event_name] = handler


func unregister_handler(
	event_name: StringName
) -> void:

	_handlers.erase(event_name)

#==============================================================================
# Dispatch
#==============================================================================

func dispatch(
	event_name: StringName,
	context: CharacterContext
) -> void:

	var handler: CombatEventHandler = _handlers.get(event_name)

	if handler == null:
		return

	handler.handle_event(
		event_name,
		context
	)

extends CombatEventHandler
class_name FinishActionHandler


func handle_event(
	event_name: StringName,
	context: CharacterContext
) -> void:

	if context == null:
		return

	if context.action == null:
		return

	context.action.stop_current_action()

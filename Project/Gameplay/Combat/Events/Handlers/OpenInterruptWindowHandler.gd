extends CombatEventHandler
class_name OpenInterruptWindowHandler


func handle_event(
	event_name: StringName,
	context: CharacterContext
) -> void:

	if context == null:
		return

	if context.action == null:
		return

	context.action.open_interrupt_window()

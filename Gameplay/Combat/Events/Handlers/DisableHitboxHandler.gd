extends CombatEventHandler
class_name DisableHitboxHandler


func handle_event(
	event_name: StringName,
	context: CharacterContext
) -> void:

	if context == null:
		return

	if context.combat == null:
		return

	var hitbox := context.combat.get_hitbox()

	if hitbox == null:
		return

	hitbox.deactivate()

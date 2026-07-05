extends CharacterCommand
class_name AttackCommand

func execute() -> bool:

	if context.action == null:
		return false

	if context.action.is_busy():
		return false

	var action := ActionFactory.create_attack()

	return context.action.execute(action)

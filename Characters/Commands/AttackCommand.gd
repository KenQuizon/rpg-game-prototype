extends CharacterCommand
class_name AttackCommand

func execute() -> bool:

	if context.action == null:
		return false

	if context.action.is_busy():
		return false

	return context.action.execute(
		AttackAction.new()
	)

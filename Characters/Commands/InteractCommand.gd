extends CharacterCommand
class_name InteractCommand

func execute() -> bool:

	if context.interaction == null:
		return false

	if not context.interaction.has_target():
		return false

	context.interaction.interact()

	return true

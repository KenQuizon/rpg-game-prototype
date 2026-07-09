extends CharacterCommand
class_name EvadeCommand

func execute() -> bool:

	if context.evade_definition == null:
		return false

	var request := ActionRequest.new(
		context,
		context.evade_definition
	)

	return context.action.submit(request).succeeded()

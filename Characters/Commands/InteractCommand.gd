extends CharacterCommand
class_name InteractCommand

func execute() -> bool:

	if context.interaction == null:
		return false

	var target := context.interaction.current_target

	if target == null:
		return false

	var definition := context.interaction.get_interact_definition(target)

	if definition == null:
		return false

	var request := ActionRequest.new(
		context,
		definition
	)

	request.target = target

	return context.action.submit(request).succeeded()

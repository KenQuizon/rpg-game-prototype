extends CharacterCommand
class_name AttackCommand

func execute() -> bool:

	var definition := context.weapon.get_attack_definition()

	if definition == null:
		return false

	var request := ActionRequest.new(
		context,
		definition
	)

	return context.action.submit(request).succeeded()

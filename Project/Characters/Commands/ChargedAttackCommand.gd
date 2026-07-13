extends CharacterCommand
class_name ChargedAttackCommand

func execute() -> bool:

	var attack_set := context.weapon.get_attack_set() if context.weapon else null

	if attack_set == null or not attack_set.has_heavy_attack():
		return false

	var request := ActionRequest.new(
		context,
		attack_set.heavy_attack
	)

	return context.action.submit(request).succeeded()

extends CharacterCommand
class_name CastSkillCommand

#==============================================================================
# Configuration
#==============================================================================

var skill_id: StringName = &""

#==============================================================================
# Execution
#==============================================================================

func execute() -> bool:

	if context.skills == null:
		return false

	var definition := context.skills.get_skill(skill_id)

	if definition == null:
		return false

	var request := ActionRequest.new(
		context,
		definition
	)

	return context.action.submit(request).succeeded()

extends RefCounted
class_name ActionFactory

#==============================================================================
# Factory
#==============================================================================

func create(
	request: ActionRequest
) -> ActionExecution:

	if request == null:
		return null

	var definition := request.definition as ActionDefinition

	if definition == null:
		return null

	if definition.action_script == null:
		return null

	var action := definition.action_script.new() as CharacterAction

	if action == null:
		return null

	var runtime := ActionRuntimeContext.new()

	action.initialize(
		request,
		runtime
	)

	return ActionExecution.new(
		request,
		action,
		runtime
	)

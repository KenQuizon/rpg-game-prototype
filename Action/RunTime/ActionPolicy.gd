extends Resource
class_name ActionPolicy

#==============================================================================
# Evaluation
#==============================================================================

func evaluate(
	_request: ActionRequest,
	_runtime: ActionRuntimeContext
) -> ActionResult:

	return ActionResult.success()

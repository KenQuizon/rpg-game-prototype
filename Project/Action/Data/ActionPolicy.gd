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

#==============================================================================
# Commitment
#==============================================================================

# Fires once, from CharacterAction.start(), only for an action that actually
# begins running (not one that's REJECTED or sitting QUEUED). This is where
# a policy should apply its side effect — spend a resource, start a
# cooldown — as opposed to evaluate(), which must stay side-effect-free
# since it can run multiple times against the same request during
# submission without anything actually starting.
func commit(
	_request: ActionRequest,
	_runtime: ActionRuntimeContext
) -> void:
	pass

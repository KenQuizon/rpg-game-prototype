extends ActionPolicy
class_name ResourceCostPolicy

#==============================================================================
# Export Variables
#==============================================================================

@export var resource_type: ResourceType.Id = ResourceType.Id.MANA

@export_range(0.0, 9999.0)
var amount: float = 0.0

#==============================================================================
# Evaluation
#==============================================================================

func evaluate(
	request: ActionRequest,
	_runtime: ActionRuntimeContext
) -> ActionResult:

	if amount <= 0.0:
		return ActionResult.success()

	var resources := request.context.resources

	# No ResourceComponent on this character at all — treat the action as
	# free rather than blocking it, so this policy only matters for
	# characters that actually authored a resource pool.
	if resources == null:
		return ActionResult.success()

	if not resources.has_resource(resource_type, amount):
		return ActionResult.new(
			ActionResultCode.Id.REJECTED,
			ActionCompletionReason.Id.NO_RESOURCES
		)

	return ActionResult.success()

#==============================================================================
# Commitment
#==============================================================================

func commit(
	request: ActionRequest,
	_runtime: ActionRuntimeContext
) -> void:

	if amount <= 0.0:
		return

	var resources := request.context.resources

	if resources == null:
		return

	resources.spend(resource_type, amount)

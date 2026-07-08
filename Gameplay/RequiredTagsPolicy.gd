extends ActionPolicy
class_name RequiredTagsPolicy

#==============================================================================
# Purpose
#==============================================================================
# The ActionPolicy-side consumer of GameplayTags (roadmap 7.6) — data-driven,
# same authoring pattern as CooldownPolicy/ResourceCostPolicy: add one of
# these to an ActionDefinition's policies array and fill in the fields,
# no code changes needed per action. Reads StatusComponent.has_tag(),
# added alongside this policy, rather than ActionLock, since "can't cast
# while silenced" is a semantic condition check, not a suppress-this-
# category-of-input check — see GameplayTags.gd for the full reasoning.

#==============================================================================
# Export Variables
#==============================================================================

# If the actor currently has ANY of these tags active, the action is
# rejected. Empty (default) means this policy allows everything — same
# "no-op until configured" convention as ResourceCostPolicy's amount = 0.0.
@export var forbidden_tags: Array[StringName] = []

#==============================================================================
# Evaluation
#==============================================================================

func evaluate(
	request: ActionRequest,
	_runtime: ActionRuntimeContext
) -> ActionResult:

	if forbidden_tags.is_empty():
		return ActionResult.success()

	var status := request.context.status

	# No StatusComponent on this character at all — treat the action as
	# unrestricted rather than blocking it, mirroring
	# ResourceCostPolicy/CooldownPolicy's identical "component absent is
	# not a failure" convention.
	if status == null:
		return ActionResult.success()

	for tag in forbidden_tags:
		if status.has_tag(tag):
			return ActionResult.new(
				ActionResultCode.Id.REJECTED,
				ActionCompletionReason.Id.FORBIDDEN_TAG
			)

	return ActionResult.success()

#==============================================================================
# Commitment
#==============================================================================

# No side effect on commit — this policy only gates, it doesn't spend or
# start anything (unlike CooldownPolicy/ResourceCostPolicy). Base
# ActionPolicy.commit() no-op is correct as-is; overridden here only to
# document that this is intentional, not an oversight.
func commit(
	_request: ActionRequest,
	_runtime: ActionRuntimeContext
) -> void:
	pass

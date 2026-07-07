extends ActionPolicy
class_name CooldownPolicy

#==============================================================================
# Evaluation
#==============================================================================

# Deliberately stateless — reads cooldown_group/cooldown straight off the
# ActionDefinition being submitted rather than duplicating them as export
# fields on this policy, so any ActionDefinition (skill, attack, future
# action type) gets cooldown gating just by adding one CooldownPolicy to
# its policies array and filling in the fields it already has.
func evaluate(
	request: ActionRequest,
	_runtime: ActionRuntimeContext
) -> ActionResult:

	var definition := request.definition as ActionDefinition

	if not _has_cooldown(definition):
		return ActionResult.success()

	var cooldowns := request.context.cooldowns

	if cooldowns == null:
		return ActionResult.success()

	if cooldowns.is_on_cooldown(definition.cooldown_group):
		return ActionResult.new(
			ActionResultCode.Id.REJECTED,
			ActionCompletionReason.Id.COOLDOWN
		)

	return ActionResult.success()

#==============================================================================
# Commitment
#==============================================================================

func commit(
	request: ActionRequest,
	_runtime: ActionRuntimeContext
) -> void:

	var definition := request.definition as ActionDefinition

	if not _has_cooldown(definition):
		return

	var cooldowns := request.context.cooldowns

	if cooldowns == null:
		return

	cooldowns.start_cooldown(definition.cooldown_group, definition.cooldown)

#==============================================================================
# Internal
#==============================================================================

static func _has_cooldown(definition: ActionDefinition) -> bool:

	if definition == null:
		return false

	return definition.cooldown_group != &"" and definition.cooldown > 0.0

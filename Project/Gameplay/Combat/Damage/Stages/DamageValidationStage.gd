extends DamageStage
class_name DamageValidationStage

#==============================================================================
# Purpose
#==============================================================================
# First stage in the default pipeline. Cancels outright for a missing
# target. Future invulnerability / friendly-fire / can_be_blocked /
# can_be_evaded checks (see the architectural review, Objective 3) belong
# here once those systems exist — this stage is the place they plug in,
# not a reason to add speculative checks now.

#==============================================================================
# DamageStage
#==============================================================================

func process(context: DamagePipelineContext) -> void:

	if context.target == null:
		context.cancel()
		return

	if context.request == null:
		context.cancel()

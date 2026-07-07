extends DamageStage
class_name DamageApplicationStage

#==============================================================================
# Purpose
#==============================================================================
# Applies final_damage to the target's health and records the kill flag.
# Logic unchanged from the old DamageSystem.apply_damage() — including the
# early cancellation for zero/negative final_damage, which previously
# skipped stagger resolution and event emission via an early return.

#==============================================================================
# DamageStage
#==============================================================================

func process(context: DamagePipelineContext) -> void:

	var result := context.result

	if result.final_damage <= 0.0:
		# Matches the old apply_damage() early return: nothing to apply,
		# and stagger/gameplay-events stages should not run either.
		context.cancel()
		return

	context.target.apply_damage(result)

	result.killed = context.target.is_dead()

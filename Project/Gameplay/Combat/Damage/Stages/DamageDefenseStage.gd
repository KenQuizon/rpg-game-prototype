extends DamageStage
class_name DamageDefenseStage

#==============================================================================
# Purpose
#==============================================================================
# Resolves Block/Evade against the target's current defensive state, before
# Critical/Mitigation run. Evade fully negates the hit (cancels the
# pipeline outright — no crit calc, no mitigation, nothing to mitigate).
# Block reduces incoming damage but lets the rest of the pipeline continue
# on the reduced amount, so a blocked crit still hurts, just less.

#==============================================================================
# Tuning
#==============================================================================

const BLOCK_DAMAGE_REDUCTION: float = 0.5 # 50% reduction while blocking

#==============================================================================
# DamageStage
#==============================================================================

func process(context: DamagePipelineContext) -> void:

	var request := context.request
	var result := context.result
	var target := context.target

	if request.can_be_evaded and target.is_evading:
		result.evaded = true
		result.mitigated_damage = 0.0
		result.final_damage = 0.0
		context.cancel()
		return

	if request.can_be_blocked and target.is_blocking:
		result.blocked = true
		result.mitigated_damage = result.mitigated_damage * (1.0 - BLOCK_DAMAGE_REDUCTION)

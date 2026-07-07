extends DamageStage
class_name DamageMitigationStage

#==============================================================================
# Purpose
#==============================================================================
# Applies flat defense mitigation. Logic unchanged from the old
# DamageSystem.calculate_damage(). Runs after critical resolution (and,
# once they exist, after equipment resistance / buff-debuff stages) so it
# always mitigates whatever damage those earlier stages have produced.

#==============================================================================
# DamageStage
#==============================================================================

func process(context: DamagePipelineContext) -> void:

	var request := context.request
	var result := context.result

	var damage := result.mitigated_damage

	if request.damage_type != DamageType.Id.TRUE_DAMAGE:
		damage -= context.target.get_defense()
		damage = max(damage, 1.0)

	result.mitigated_damage = damage
	result.final_damage = damage

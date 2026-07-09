extends DamageStage
class_name DamageCriticalResolutionStage

#==============================================================================
# Purpose
#==============================================================================
# Resolves whether the hit is a critical and applies the critical
# multiplier. Logic unchanged from the old DamageSystem.calculate_damage() /
# _roll_critical() — only the random roll now goes through RandomSource
# instead of a bare randf() call, for determinism.

#==============================================================================
# DamageStage
#==============================================================================

func process(context: DamagePipelineContext) -> void:

	var request := context.request
	var result := context.result

	var critical := request.critical

	if not critical and request.attacker != null:
		critical = _roll_critical(request.attacker)

	result.critical = critical

	var damage := request.base_damage

	if critical:
		damage *= request.critical_multiplier

	# Running total — DamageMitigationStage adjusts this further. Equipment
	# resistance / buff-debuff stages, once they exist, insert between this
	# stage and DamageMitigationStage and should read/write this same field.
	result.mitigated_damage = damage

#==============================================================================
# Internal
#==============================================================================

func _roll_critical(attacker: CombatComponent) -> bool:

	if attacker.context == null:
		return false

	var stats := attacker.context.stats

	if stats == null:
		return false

	var chance := stats.get_stat(StatType.Id.CRITICAL_CHANCE)

	return RandomSource.get_default().roll_chance(chance)

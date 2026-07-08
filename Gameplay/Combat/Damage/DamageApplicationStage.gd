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

	print("[Damage] final_damage: ", result.final_damage)

	if result.final_damage <= 0.0:
		context.cancel()
		return

	context.target.apply_damage(result)

	result.killed = context.target.is_dead()

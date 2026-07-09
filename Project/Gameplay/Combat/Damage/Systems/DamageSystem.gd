extends RefCounted
class_name DamageSystem

#==============================================================================
# Purpose
#==============================================================================
# Thin, stable entry point kept for backward compatibility. The actual
# stage-by-stage resolution now lives in DamagePipeline/DamageStage (see
# the architectural review, Objective 3, and DamagePipeline.gd for the
# default stage order). CombatComponent.receive_damage() calls
# apply_damage() exactly as before — nothing outside this file needed to
# change for this migration.

#==============================================================================
# Damage Resolution
#==============================================================================

static func apply_damage(
	target: CombatComponent,
	request: DamageRequest
) -> DamageResult:
	return DamagePipeline.get_default().execute(request, target)

#==============================================================================
# Calculation-Only (Preview)
#==============================================================================

# Runs validation, critical resolution, and mitigation only — no
# application, stagger, or event emission. Useful for callers that want a
# damage preview (e.g. a UI tooltip showing "~42 dmg") without actually
# dealing the damage. Not used internally by apply_damage(); provided as a
# convenience built from the same stages.
static func calculate_damage(
	target: CombatComponent,
	request: DamageRequest
) -> DamageResult:

	var context := DamagePipelineContext.new(request, target)

	DamageValidationStage.new().process(context)

	if context.cancelled:
		return context.result

	DamageCriticalResolutionStage.new().process(context)
	DamageMitigationStage.new().process(context)

	return context.result

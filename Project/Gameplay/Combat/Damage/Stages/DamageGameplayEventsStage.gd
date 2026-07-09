extends DamageStage
class_name DamageGameplayEventsStage

#==============================================================================
# Purpose
#==============================================================================
# Emits the combat signals every damage resolution has always ended with.
# Logic unchanged from the old DamageSystem.apply_damage(). This is also
# the extension point for future analytics/achievement hooks (see the
# architectural review, Objective 5) and, once it exists, for publishing
# onto the GameplayEventBus instead of/alongside these signals.

#==============================================================================
# DamageStage
#==============================================================================

func process(context: DamagePipelineContext) -> void:

	var target := context.target
	var request := context.request
	var result := context.result

	target.damage_received.emit(result)

	if request.attacker != null:
		request.attacker.damage_dealt.emit(result)

extends DamageStage
class_name DamageStaggerStage

#==============================================================================
# Purpose
#==============================================================================
# Resolves poise/stagger. Logic unchanged from the old
# DamageSystem._resolve_stagger().

#==============================================================================
# DamageStage
#==============================================================================

func process(context: DamagePipelineContext) -> void:

	var target := context.target
	var request := context.request
	var result := context.result

	# A killing blow already ran CombatComponent._on_died() ->
	# StatusComponent.clear_all() synchronously inside
	# DamageApplicationStage above. Resolving stagger afterward would
	# interrupt/apply a status effect to a character that's already dead
	# and whose statuses were just cleared — skip it entirely.
	if result.killed:
		return

	if not request.can_stagger:
		return

	if request.stagger_damage <= 0.0:
		return

	if target.context == null:
		return

	var poise := target.context.poise

	if poise == null:
		return

	var broke := poise.apply_stagger_damage(request.stagger_damage)

	result.staggered = broke

	if not broke:
		return

	if target.context.action != null:
		target.context.action.interrupt_current()

	if request.stagger_effect != null and target.context.status != null:
		target.context.status.apply_status(
			request.stagger_effect,
			request.attacker
		)

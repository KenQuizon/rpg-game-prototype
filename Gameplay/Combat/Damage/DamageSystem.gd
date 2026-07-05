extends RefCounted
class_name DamageSystem
#==============================================================================
# Damage Resolution
#==============================================================================
static func apply_damage(
	target: CombatComponent,
	request: DamageRequest
) -> DamageResult:
	var result := calculate_damage(
		target,
		request
	)
	if result.final_damage <= 0.0:
		return result
	target.apply_damage(result)
	target.damage_received.emit(result)
	if request.attacker != null:
		request.attacker.damage_dealt.emit(result)
	return result
#==============================================================================
# Calculation
#==============================================================================
static func calculate_damage(
	target: CombatComponent,
	request: DamageRequest
) -> DamageResult:
	var result := DamageResult.new()
	result.request = request
	result.incoming_damage = request.base_damage
	
	var damage := request.base_damage
	
	# Critical hits: honor an explicitly forced request.critical, otherwise
	# roll against the attacker's CRITICAL_CHANCE stat.
	var critical := request.critical
	if not critical and request.attacker != null:
		critical = _roll_critical(request.attacker)
	if critical:
		damage *= request.critical_multiplier
	result.critical = critical
	
	# True damage bypasses defense entirely.
	if request.damage_type != DamageType.Id.TRUE_DAMAGE:
		damage -= target.get_defense()
		damage = max(
			damage,
			1.0
		)
	
	# NOTE: request.can_be_blocked / can_be_evaded are carried through so a
	# future Block/Dodge component can consult them, but this framework does
	# not yet contain a component that resolves blocking or evasion, so
	# result.blocked / result.evaded are left at their default `false` here
	# rather than faking a probability with no underlying system.
	
	result.mitigated_damage = damage
	result.final_damage = damage
	return result
#==============================================================================
# Internal
#==============================================================================
static func _roll_critical(attacker: CombatComponent) -> bool:
	if attacker.context == null:
		return false
	var stats := attacker.context.stats
	if stats == null:
		return false
	var chance := stats.get_stat(StatType.Id.CRITICAL_CHANCE)
	return randf() < chance

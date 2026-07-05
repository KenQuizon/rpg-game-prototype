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

	damage -= target.get_defense()

	damage = max(
		damage,
		1.0
	)

	result.mitigated_damage = damage

	result.final_damage = damage

	return result

extends RefCounted
class_name DamageRequestBuilder
#==============================================================================
# Internal
#==============================================================================
var _request := DamageRequest.new()
#==============================================================================
# Fluent API
#==============================================================================
func attacker(value: CombatComponent) -> DamageRequestBuilder:
	_request.attacker = value
	return self
func source(value: Object) -> DamageRequestBuilder:
	_request.source = value
	return self
func damage(value: float) -> DamageRequestBuilder:
	_request.base_damage = value
	return self
func damage_type(value: DamageType.Id) -> DamageRequestBuilder:
	_request.damage_type = value
	return self
func critical(value: bool) -> DamageRequestBuilder:
	_request.critical = value
	return self
func critical_multiplier(value: float) -> DamageRequestBuilder:
	_request.critical_multiplier = value
	return self
func can_be_blocked(value: bool) -> DamageRequestBuilder:
	_request.can_be_blocked = value
	return self
func can_be_evaded(value: bool) -> DamageRequestBuilder:
	_request.can_be_evaded = value
	return self
func can_stagger(value: bool) -> DamageRequestBuilder:
	_request.can_stagger = value
	return self
func stagger_damage(value: float) -> DamageRequestBuilder:
	_request.stagger_damage = value
	return self
func stagger_effect(value: StatusEffectData) -> DamageRequestBuilder:
	_request.stagger_effect = value
	return self
func add_tag(tag: StringName) -> DamageRequestBuilder:
	_request.tags.append(tag)
	return self
func hit_position(value: Vector3) -> DamageRequestBuilder:
	_request.hit_position = value
	return self
func hit_normal(value: Vector3) -> DamageRequestBuilder:
	_request.hit_normal = value
	return self
func build() -> DamageRequest:
	return _request

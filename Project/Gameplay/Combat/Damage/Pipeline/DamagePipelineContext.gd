extends RefCounted
class_name DamagePipelineContext

#==============================================================================
# Purpose
#==============================================================================
# Ferries a single damage resolution through a DamagePipeline. Stages read
# and mutate `result` in place; `cancel()` short-circuits any remaining
# stages (e.g. a null target, a blocked/evaded hit once those exist, or
# final_damage dropping to zero after mitigation — mirroring the early
# return the old DamageSystem.apply_damage() used to do).

#==============================================================================
# State
#==============================================================================

var request: DamageRequest
var target: CombatComponent
var result: DamageResult
var cancelled: bool = false

#==============================================================================
# Initialization
#==============================================================================

func _init(damage_request: DamageRequest, damage_target: CombatComponent) -> void:
	request = damage_request
	target = damage_target
	result = DamageResult.new()
	result.request = damage_request
	if damage_request != null:
		result.incoming_damage = damage_request.base_damage

#==============================================================================
# Public API
#==============================================================================

func cancel() -> void:
	cancelled = true

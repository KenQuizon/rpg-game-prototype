extends RefCounted
class_name DamageResult

#==============================================================================
# Request
#==============================================================================

var request: DamageRequest

#==============================================================================
# Damage Values
#==============================================================================

var incoming_damage: float = 0.0

var mitigated_damage: float = 0.0

var final_damage: float = 0.0

#==============================================================================
# Combat Outcomes
#==============================================================================

var critical: bool = false

var blocked: bool = false

var evaded: bool = false

var killed: bool = false

#==============================================================================
# Future Combat Data
#==============================================================================

var staggered: bool = false

var knockback: Vector3 = Vector3.ZERO

var applied_effects: Array[StringName] = []

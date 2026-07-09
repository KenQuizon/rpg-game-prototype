extends RefCounted
class_name StatusEffectInstance

#==============================================================================
# Definition
#==============================================================================

var data: StatusEffectData

# Whoever applied this effect — typically the attacker's CombatComponent,
# used as both the DoT damage source and the StatModifier source so all of
# an instance's modifiers can be removed together via
# StatsComponent.remove_modifiers_from_source(instance).
var source: Object

#==============================================================================
# Runtime State
#==============================================================================

var stacks: int = 1

var remaining_duration: float = 0.0

var time_since_tick: float = 0.0

#==============================================================================
# Construction
#==============================================================================

func _init(
	p_data: StatusEffectData,
	p_source: Object = null
) -> void:

	data = p_data
	source = p_source

	if data != null:
		remaining_duration = data.duration

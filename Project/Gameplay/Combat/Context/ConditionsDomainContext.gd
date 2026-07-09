extends RefCounted
class_name ConditionsDomainContext

#==============================================================================
# Purpose
#==============================================================================
# Groups StatusComponent and PoiseComponent — the "can this character
# currently act" vocabulary — separately from CombatDomainContext. Kept
# distinct on purpose: AI perception (Phase 3) and Gameplay Tags (roadmap
# 7.6) both need to query conditions (stunned/rooted/staggered/...) without
# pulling in combat-specific concepts. StatusComponent already grants
# ActionLock bitflags directly (see StatusEffectData.locks), so this domain
# is the natural home for a future GameplayTags query surface too — new
# tag-reading APIs belong here, not on CombatDomainContext.

#==============================================================================
# Private
#==============================================================================

var _registry: ComponentRegistry

#==============================================================================
# Initialization
#==============================================================================

func _init(registry: ComponentRegistry) -> void:
	_registry = registry

#==============================================================================
# Typed Components
#==============================================================================

var status: StatusComponent:
	get:
		return _registry.get_component(StatusComponent) as StatusComponent

var poise: PoiseComponent:
	get:
		return _registry.get_component(PoiseComponent) as PoiseComponent

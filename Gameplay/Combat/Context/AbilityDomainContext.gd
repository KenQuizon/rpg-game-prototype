extends RefCounted
class_name AbilityDomainContext

#==============================================================================
# Purpose
#==============================================================================
# Groups SkillComponent as its own domain, distinct from CombatDomainContext,
# matching the roadmap's explicit framing of "combat/ability/inventory" as
# three separate domains. Currently a single-member domain — intentionally
# not merged into Combat, since skill/ability content (cast economy, skill
# trees — Phase 4 Progression) is expected to grow independently of the
# melee attack loop.

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

var skills: SkillComponent:
	get:
		return _registry.get_component(SkillComponent) as SkillComponent

extends RefCounted
class_name CombatDomainContext

#==============================================================================
# Purpose
#==============================================================================
# Groups the attack/hit-loop components (CombatComponent, WeaponComponent,
# ComboComponent) behind one accessor instead of three flat properties on
# CharacterContext. See roadmap 7.4 — this is the "combat" domain the
# CharacterContext flat-accessor-growth fix calls for.
#
# Deliberately excludes StatusComponent/PoiseComponent (see
# ConditionsDomainContext) even though they're combat-adjacent today —
# conditions need to be queryable by AI perception and future Gameplay
# Tags work (roadmap 7.6) without depending on the combat domain.

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

var combat: CombatComponent:
	get:
		return _registry.get_component(CombatComponent) as CombatComponent

var weapon: WeaponComponent:
	get:
		return _registry.get_component(WeaponComponent) as WeaponComponent

var combo: ComboComponent:
	get:
		return _registry.get_component(ComboComponent) as ComboComponent

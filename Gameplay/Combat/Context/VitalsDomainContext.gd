extends RefCounted
class_name VitalsDomainContext

#==============================================================================
# Purpose
#==============================================================================
# Groups a character's numeric state and economy: base attributes
# (StatsComponent), hit points (HealthComponent), and spendable pools with
# their timers (ResourceComponent, CooldownComponent). These four are the
# components every ActionPolicy gate (CooldownPolicy, ResourceCostPolicy)
# and every damage stage reads from — grouping them here gives future
# systems (progression, UI stat panels) one place to depend on instead of
# four separate CharacterContext properties.

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

var stats: StatsComponent:
	get:
		return _registry.get_component(StatsComponent) as StatsComponent

var health: HealthComponent:
	get:
		return _registry.get_component(HealthComponent) as HealthComponent

var resources: ResourceComponent:
	get:
		return _registry.get_component(ResourceComponent) as ResourceComponent

var cooldowns: CooldownComponent:
	get:
		return _registry.get_component(CooldownComponent) as CooldownComponent

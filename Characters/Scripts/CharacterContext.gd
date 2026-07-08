extends RefCounted
class_name CharacterContext
#==============================================================================
# Private Variables
#==============================================================================
var _character: Node
var _registry: ComponentRegistry
var _input := CharacterInput.new()

# Domain sub-contexts (roadmap 7.4) — the source of truth for grouped
# component access. New gameplay code should reach for these first (e.g.
# `context.combat_domain.weapon`) and add new members to the relevant
# domain class rather than as a new flat property below. The flat
# properties under "Typed Components" further down are kept as permanent,
# zero-cost forwarding shims so every existing call site in the codebase
# (AttackAction, AIController, DamageStaggerStage, ...) keeps working
# completely unchanged.
var _combat_domain: CombatDomainContext
var _conditions_domain: ConditionsDomainContext
var _vitals_domain: VitalsDomainContext
var _mobility_domain: MobilityDomainContext
var _ability_domain: AbilityDomainContext
var _interaction_domain: InteractionDomainContext
var _items_domain: ItemsDomainContext
#==============================================================================
# Initialization
#==============================================================================
# `character` is typed Node, not Character (roadmap 7.2) — any host
# implementing the framework's get_character_*() duck-typed contract
# (see BaseComponent.owner_character / Character.get_character_visual(),
# etc.) can drive a full component stack through this context, not just
# the concrete Character class. Consumers that need a Character-specific
# capability (e.g. CharacterAction's is_on_floor() ground check, or a
# state machine) must duck-type or defensively cast, exactly as
# BaseComponent's own owner_character accessors already do.
func _init(
	character: Node,
	component_registry: ComponentRegistry
) -> void:
	_character = character
	_registry = component_registry

	_combat_domain = CombatDomainContext.new(_registry)
	_conditions_domain = ConditionsDomainContext.new(_registry)
	_vitals_domain = VitalsDomainContext.new(_registry)
	_mobility_domain = MobilityDomainContext.new(_registry)
	_ability_domain = AbilityDomainContext.new(_registry)
	_interaction_domain = InteractionDomainContext.new(_registry)
	_items_domain = ItemsDomainContext.new(_registry)
#==============================================================================
# Public Properties
#==============================================================================
var character: Node:
	get:
		return _character
var input: CharacterInput:
	get:
		return _input
#==============================================================================
# Generic Component Access
#==============================================================================
func get_component(component_class: GDScript) -> BaseComponent:
	return _registry.get_component(component_class)
func has_component(component_class: GDScript) -> bool:
	return _registry.has_component(component_class)
#==============================================================================
# Domain Sub-Contexts
#==============================================================================
var combat_domain: CombatDomainContext:
	get:
		return _combat_domain
var conditions_domain: ConditionsDomainContext:
	get:
		return _conditions_domain
var vitals_domain: VitalsDomainContext:
	get:
		return _vitals_domain
var mobility_domain: MobilityDomainContext:
	get:
		return _mobility_domain
var ability_domain: AbilityDomainContext:
	get:
		return _ability_domain
var interaction_domain: InteractionDomainContext:
	get:
		return _interaction_domain
var items_domain: ItemsDomainContext:
	get:
		return _items_domain
#==============================================================================
# Typed Components — Forwarding Shims
#==============================================================================
# Every property below is a one-line delegate to a domain object above.
# Behavior and call signature are identical to before this refactor; only
# the internal storage moved. Do not add new members here — add them to
# the relevant domain class instead (see note above _combat_domain).

# -- Core / framework plumbing (not domain-grouped; see roadmap 7.4 notes) --
var movement: MovementComponent:
	get:
		return _mobility_domain.movement
var animation: AnimationComponent:
	get:
		return get_component(AnimationComponent) as AnimationComponent
var action: ActionComponent:
	get:
		return get_component(ActionComponent) as ActionComponent

# -- Combat --
var combat: CombatComponent:
	get:
		return _combat_domain.combat
var weapon: WeaponComponent:
	get:
		return _combat_domain.weapon
var combo: ComboComponent:
	get:
		return _combat_domain.combo

# -- Conditions --
var status: StatusComponent:
	get:
		return _conditions_domain.status
var poise: PoiseComponent:
	get:
		return _conditions_domain.poise

# -- Vitals --
var stats: StatsComponent:
	get:
		return _vitals_domain.stats
var health: HealthComponent:
	get:
		return _vitals_domain.health
var resources: ResourceComponent:
	get:
		return _vitals_domain.resources
var cooldowns: CooldownComponent:
	get:
		return _vitals_domain.cooldowns

# -- Mobility --
var navigation: NavigationComponent:
	get:
		return _mobility_domain.navigation
var targeting: TargetingComponent:
	get:
		return _mobility_domain.targeting

# -- Ability --
var skills: SkillComponent:
	get:
		return _ability_domain.skills

# -- Interaction --
var interaction: InteractionComponent:
	get:
		return _interaction_domain.interaction

# -- Items --
var equipment: EquipmentComponent:
	get:
		return _items_domain.equipment
#==============================================================================
# Locks
#==============================================================================

# Single entry point for "is this category of behavior currently
# suppressed" — checked by MovementComponent, AnimationComponent, and
# PlayerController instead of each one separately querying
# context.action.has_lock(...). New lock sources (a cutscene lock, a
# network-authority hold, etc.) plug in here once, rather than requiring
# every consuming component to be revisited again.
func is_locked(lock: int) -> bool:

	if action != null and action.has_lock(lock):
		return true

	if status != null and status.has_lock(lock):
		return true

	return false

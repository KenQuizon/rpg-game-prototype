extends RefCounted
class_name CharacterContext
#==============================================================================
# Private Variables
#==============================================================================
var _character: Character
var _registry: ComponentRegistry
var _input := CharacterInput.new()
#==============================================================================
# Initialization
#==============================================================================
func _init(
	character: Character,
	component_registry: ComponentRegistry
) -> void:
	_character = character
	_registry = component_registry
#==============================================================================
# Public Properties
#==============================================================================
var character: Character:
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
# Typed Components
#==============================================================================
var movement: MovementComponent:
	get:
		return get_component(MovementComponent) as MovementComponent
var animation: AnimationComponent:
	get:
		return get_component(AnimationComponent) as AnimationComponent
var interaction: InteractionComponent:
	get:
		return get_component(InteractionComponent) as InteractionComponent
var stats: StatsComponent:
	get:
		return get_component(StatsComponent) as StatsComponent
var health: HealthComponent:
	get:
		return get_component(HealthComponent) as HealthComponent
var action: ActionComponent:
	get:
		return get_component(ActionComponent) as ActionComponent
var combat: CombatComponent:
	get:
		return get_component(CombatComponent) as CombatComponent
var weapon: WeaponComponent:
	get:
		return get_component(WeaponComponent) as WeaponComponent
		
var combo: ComboComponent:
	get:
		return get_component(ComboComponent) as ComboComponent

var status: StatusComponent:
	get:
		return get_component(StatusComponent) as StatusComponent

var poise: PoiseComponent:
	get:
		return get_component(PoiseComponent) as PoiseComponent
		
var equipment: EquipmentComponent:
	get:
		return get_component(EquipmentComponent) as EquipmentComponent

var skills: SkillComponent:
	get:
		return get_component(SkillComponent) as SkillComponent

var resources: ResourceComponent:
	get:
		return get_component(ResourceComponent) as ResourceComponent

var cooldowns: CooldownComponent:
	get:
		return get_component(CooldownComponent) as CooldownComponent
		
var targeting: TargetingComponent:
	get:
		return get_component(TargetingComponent) as TargetingComponent

var navigation: NavigationComponent:
	get:
		return get_component(NavigationComponent) as NavigationComponent
		
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

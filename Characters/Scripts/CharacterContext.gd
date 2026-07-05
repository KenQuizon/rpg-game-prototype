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
		return get_component(MovementComponent)


var animation: AnimationComponent:
	get:
		return get_component(AnimationComponent)


var interaction: InteractionComponent:
	get:
		return get_component(InteractionComponent)


var stats: StatsComponent:
	get:
		return get_component(StatsComponent)


var health: HealthComponent:
	get:
		return get_component(HealthComponent)


var action: ActionComponent:
	get:
		return get_component(ActionComponent)


var combat: CombatComponent:
	get:
		return get_component(CombatComponent)


var weapon: WeaponComponent:
	get:
		return get_component(WeaponComponent)
		
var combo: ComboComponent:
	get:
		return get_component(ComboComponent) as ComboComponent

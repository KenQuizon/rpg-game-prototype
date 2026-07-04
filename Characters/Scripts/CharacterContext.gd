extends RefCounted
class_name CharacterContext

#==============================================================================
# Private Variables
#==============================================================================

var _character: Character
var _registry: ComponentRegistry

#==============================================================================
# Initialization
#==============================================================================

func _init(character: Character, component_registry: ComponentRegistry) -> void:

	_character = character
	_registry = component_registry

#==============================================================================
# Public Properties
#==============================================================================

var character: Character:
	get:
		return _character

#==============================================================================
# Generic Component Access
#==============================================================================

func get_component(component_class: GDScript) -> BaseComponent:
	return _registry.get_component(component_class)


func has_component(component_class: GDScript) -> bool:
	return _registry.has_component(component_class)

#==============================================================================
# Typed Component Access
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
		
		
var _input := CharacterInput.new()

var input: CharacterInput:
	get:
		return _input
		
var action: ActionComponent:
	get:
		return get_component(ActionComponent) as ActionComponent

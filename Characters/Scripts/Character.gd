extends CharacterBody3D
class_name Character

#==============================================================================
# Cached Nodes
#==============================================================================

@onready var components_root: Node = $Components

@onready var controller: BaseController = $Systems/Controller
@onready var state_machine: CharacterStateMachine = $Systems/CharacterStateMachine

@onready var model: Node3D = $Model
@onready var visual_root: Node3D = $Model/VisualRoot

@onready var camera_target: Node3D = $CameraTarget
@onready var interaction_origin: Node3D = $InteractionOrigin

@onready var animation_player: AnimationPlayer = $Model/VisualRoot/Ranger/AnimationPlayer

@onready var interaction_area: Area3D = $InteractionOrigin/InteractionArea

#==============================================================================
# Camera API
#==============================================================================

func get_camera_follow_target() -> Node3D:
	return camera_target
	
#==============================================================================
# Public Scene API
#==============================================================================

var character_model: Node3D:
	get:
		return model

var character_visual: Node3D:
	get:
		return visual_root

var character_camera_target: Node3D:
	get:
		return camera_target

var character_interaction_origin: Node3D:
	get:
		return interaction_origin
		
var character_animation_player: AnimationPlayer:
	get:
		return animation_player
		
var character_interaction_area: Area3D:
	get:
		return interaction_area
		
var character_state_machine: CharacterStateMachine:
	get:
		return state_machine

#==============================================================================
# Public Framework API
#==============================================================================

func get_component(component_script: GDScript) -> BaseComponent:
	return context.get_component(component_script)
	
#==============================================================================
# Framework
#==============================================================================

var registry: ComponentRegistry
var context: CharacterContext

#==============================================================================
# Components
#==============================================================================

var _components: Array[BaseComponent] = []

#==============================================================================
# Godot Lifecycle
#==============================================================================

func _ready() -> void:
	_initialize_framework()


func _physics_process(delta: float) -> void:

	if controller:
		controller.physics_update(delta)

	for component in _components:
		component.physics_update(delta)

	if state_machine:
		state_machine.physics_update(delta)


func _process(delta: float) -> void:

	if controller:
		controller.process_update(delta)

	for component in _components:
		component.process_update(delta)

	if state_machine:
		state_machine.process_update(delta)

#==============================================================================
# Framework Initialization
#==============================================================================

func _initialize_framework() -> void:

	registry = ComponentRegistry.new()
	context = CharacterContext.new(self, registry)

	_discover_components()

	_register_components()

	_initialize_components()
	
	_initialize_controller()

	_initialize_state_machine()

#==============================================================================
# Internal
#==============================================================================

func _discover_components() -> void:

	_components.clear()

	_discover_components_recursive(components_root)


func _discover_components_recursive(node: Node) -> void:

	for child in node.get_children():

		if child is BaseComponent:
			_components.append(child)
			
		_discover_components_recursive(child)

func _register_components() -> void:

	for component in _components:
		component.register_component(
			self,
			context,
			registry
		)
		
func _initialize_components() -> void:

	for component in _components:
		component.initialize()


func _initialize_controller() -> void:

	if controller:
		controller.initialize(self, context)


func _initialize_state_machine() -> void:

	if state_machine:
		state_machine.initialize(context)
		
	state_machine.change_state(
	CharacterIdleState.new()
)

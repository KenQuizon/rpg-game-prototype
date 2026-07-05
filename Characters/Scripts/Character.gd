extends CharacterBody3D
class_name Character
#==============================================================================
# Model-Dependent Node Paths
#==============================================================================
# These point INSIDE whatever model/rig is placed under VisualRoot, which
# varies per character. Defaults match the framework's reference model so
# existing character scenes keep working unchanged; point these at your own
# model's nodes in the Inspector for any new character scene.
@export_group("Model-Dependent Node Paths")
@export var animation_player_path: NodePath = NodePath("Model/VisualRoot/Ranger/AnimationPlayer")
@export var weapon_socket_path: NodePath = NodePath("Model/VisualRoot/Ranger/WeaponSocket")
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
@onready var interaction_area: Area3D = $InteractionOrigin/InteractionArea
var animation_player: AnimationPlayer
var weapon_socket: WeaponSocket
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
		
var character_weapon_socket: WeaponSocket:
	get:
		return weapon_socket
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
	_resolve_model_dependent_nodes()
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
func _resolve_model_dependent_nodes() -> void:
	animation_player = get_node_or_null(animation_player_path) as AnimationPlayer
	if animation_player == null:
		push_error(
			"Character: animation_player_path '%s' did not resolve to an AnimationPlayer." % animation_player_path
		)
	weapon_socket = get_node_or_null(weapon_socket_path) as WeaponSocket
	if weapon_socket == null:
		push_error(
			"Character: weapon_socket_path '%s' did not resolve to a WeaponSocket." % weapon_socket_path
		)
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

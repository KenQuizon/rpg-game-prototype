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
@export var off_hand_socket_path: NodePath = NodePath("Model/VisualRoot/Ranger/Rig_Medium/Skeleton3D/Off_Hand/WeaponSocket")
@export var evade_definition: ActionDefinition
@export var projectile_spawn_point: Marker3D

@export var attack_range_area: Area3D
@export var attack_range_indicator: AttackRangeIndicator

# Any Node3D that visually marks this character as targeted — a Sprite3D,
# a ring decal, whatever you build. Left null on characters that never
# need to show one. Toggled by TargetIndicatorComponent on whichever
# character is attacking this one, not by this character itself — see
# get_character_target_marker() below.
@export var target_marker: Node3D

# Swappable body-part meshes for equipment that replaces the base body
# mesh (armor covering the torso/arms) rather than attaching an external
# visual at a socket — see EquipmentSlotSocket for that case instead.
# skeleton_path is needed alongside these because replacement meshes must
# be reparented directly under the real Skeleton3D for their own skin
# binding to resolve correctly (see Stage 3). Add more part paths here as
# more parts become swappable (legs, hands, ...).
@export var skeleton_path: NodePath = NodePath("Model/VisualRoot/Ranger/Rig_Medium/Skeleton3D")
@export var arm_left_mesh_path: NodePath = NodePath("Model/VisualRoot/Ranger/Rig_Medium/Skeleton3D/Body/Ranger_ArmLeft")
@export var arm_right_mesh_path: NodePath = NodePath("Model/VisualRoot/Ranger/Rig_Medium/Skeleton3D/Body/Ranger_ArmRight")
@export var body_mesh_path: NodePath = NodePath("Model/VisualRoot/Ranger/Rig_Medium/Skeleton3D/Body/Ranger_Body")
@export var leg_left_mesh_path: NodePath = NodePath("Model/VisualRoot/Ranger/Rig_Medium/Skeleton3D/Legs/Ranger_LegLeft")
@export var leg_right_mesh_path: NodePath = NodePath("Model/VisualRoot/Ranger/Rig_Medium/Skeleton3D/Legs/Ranger_LegRight")
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
var off_hand_weapon_socket: WeaponSocket

var skeleton: Skeleton3D

# part name (e.g. "arm_left", "arm_right", "body") -> the base MeshInstance3D
# for that part. Stage 3's mesh-replacement equip pathway hides/shows
# these by key.
var _body_part_meshes: Dictionary = {}

# part name -> the MeshInstance3D currently showing for that part: the
# base mesh by default, swapped to point at a replacement mesh while
# armor covering that part is equipped (see EquipmentComponent). Material
# overrides (Stage 5) always target whichever mesh is active here, never
# a node reference cached elsewhere — so they keep working correctly
# across mesh swaps.
var _active_body_part_meshes: Dictionary = {}
#==============================================================================
# Camera API
#==============================================================================
func get_camera_follow_target() -> Node3D:
	return camera_target
	
#==============================================================================
# Public Scene API
#==============================================================================
# Exposed as methods rather than properties so Gameplay-layer components can
# duck-type against them with has_method() instead of hard-casting the owner
# to Character. Any Node — a trap, a projectile, a destructible — can
# implement this same set of get_character_*() methods and be usable by
# AnimationComponent / WeaponComponent / EquipmentComponent / etc. without
# being a Character or subclassing it. See BaseComponent.owner_character.
func get_character_model() -> Node3D:
	return model
func get_character_visual() -> Node3D:
	return visual_root
func get_character_camera_target() -> Node3D:
	return camera_target
func get_character_interaction_origin() -> Node3D:
	return interaction_origin
func get_character_animation_player() -> AnimationPlayer:
	return animation_player
func get_character_interaction_area() -> Area3D:
	return interaction_area
func get_character_state_machine() -> CharacterStateMachine:
	return state_machine
func get_character_weapon_socket() -> WeaponSocket:
	return weapon_socket
func get_character_off_hand_socket() -> WeaponSocket:
	return off_hand_weapon_socket
func get_character_projectile_spawn_point() -> Marker3D:
	return projectile_spawn_point
func get_character_evade_definition() -> ActionDefinition:
	return evade_definition
func get_character_attack_range_area() -> Area3D:
	return attack_range_area
func get_character_attack_range_indicator() -> AttackRangeIndicator:
	return attack_range_indicator
func get_character_target_marker() -> Node3D:
	return target_marker
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
	off_hand_weapon_socket = get_node_or_null(off_hand_socket_path) as WeaponSocket
	if off_hand_weapon_socket == null:
		push_error(
			"Character: off_hand_socket_path '%s' did not resolve to a WeaponSocket." % off_hand_socket_path
		)

	skeleton = get_node_or_null(skeleton_path) as Skeleton3D
	if skeleton == null:
		push_error(
			"Character: skeleton_path '%s' did not resolve to a Skeleton3D." % skeleton_path
		)

	_resolve_body_part_mesh("arm_left", arm_left_mesh_path)
	_resolve_body_part_mesh("arm_right", arm_right_mesh_path)
	_resolve_body_part_mesh("body", body_mesh_path)
	_resolve_body_part_mesh("leg_left", leg_left_mesh_path)
	_resolve_body_part_mesh("leg_right", leg_right_mesh_path)
	
	_active_body_part_meshes = _body_part_meshes.duplicate()
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

func save_state() -> Dictionary:

	var data := {
		"position": {"x": global_position.x, "y": global_position.y, "z": global_position.z}
	}

	if context.health != null:
		data["health"] = context.health.save_state()

	if context.resources != null:
		data["resources"] = context.resources.save_state()

	if context.equipment != null:
		data["equipment"] = context.equipment.save_state()

	if context.inventory != null:
		data["inventory"] = context.inventory.save_state()

	return data

func load_state(data: Dictionary) -> void:

	if data.has("position"):
		var pos: Dictionary = data["position"]
		global_position = Vector3(pos["x"], pos["y"], pos["z"])

	if data.has("health") and context.health != null:
		context.health.load_state(data["health"])

	if data.has("resources") and context.resources != null:
		context.resources.load_state(data["resources"])

	if data.has("equipment") and context.equipment != null:
		context.equipment.load_state(data["equipment"])

	if data.has("inventory") and context.inventory != null:
		context.inventory.load_state(data["inventory"])

#==============================================================================
# Death and Controller Management
#==============================================================================

func set_controller_active(active: bool) -> void:
	"""Enable or disable the controller's update processing"""
	if not has_node("Systems/Controller"):
		return
	
	var ctrl = get_node("Systems/Controller")
	if ctrl == null:
		return
	
	if active:
		ctrl.set_physics_process(true)
		ctrl.set_process(true)
		print("[Character] Controller enabled")
	else:
		ctrl.set_physics_process(false)
		ctrl.set_process(false)
		print("[Character] Controller disabled")


func is_controller_active() -> bool:
	"""Check if controller is currently active"""
	if not has_node("Systems/Controller"):
		return false
	
	var ctrl = get_node("Systems/Controller")
	if ctrl == null:
		return false
	
	return ctrl.is_physics_processing()

func _resolve_body_part_mesh(part_name: String, path: NodePath) -> void:

	var mesh := get_node_or_null(path) as MeshInstance3D

	if mesh == null:
		push_error(
			"Character: body part mesh path '%s' for part '%s' did not resolve to a MeshInstance3D." % [path, part_name]
		)
		return

	_body_part_meshes[part_name] = mesh
	
func get_character_skeleton() -> Skeleton3D:
	return skeleton
	
func get_character_body_part_mesh(part_name: String) -> MeshInstance3D:
	return _body_part_meshes.get(part_name)

func get_character_active_body_part_mesh(part_name: String) -> MeshInstance3D:
	return _active_body_part_meshes.get(part_name)

# Called by EquipmentComponent right after reparenting a replacement mesh
# onto the skeleton, so subsequent material overrides (and anything else
# that looks up the "active" mesh) target the new mesh, not the hidden
# base one.
func set_character_active_body_part_mesh(part_name: String, mesh: MeshInstance3D) -> void:
	_active_body_part_meshes[part_name] = mesh

# Called by EquipmentComponent on unequip to point part_name back at the
# original base mesh.
func reset_character_active_body_part_mesh(part_name: String) -> void:
	var base_mesh: MeshInstance3D = _body_part_meshes.get(part_name)
	if base_mesh != null:
		_active_body_part_meshes[part_name] = base_mesh

func apply_character_material_override(part_name: String, material: Material, surface_index: int = -1) -> void:

	var mesh: MeshInstance3D = get_character_active_body_part_mesh(part_name)

	if mesh == null:
		push_error("Character: no active mesh for part '%s' — cannot apply material override." % part_name)
		return

	if surface_index < 0:
		mesh.material_override = material
	else:
		mesh.set_surface_override_material(surface_index, material)

func clear_character_material_override(part_name: String, surface_index: int = -1) -> void:

	var mesh: MeshInstance3D = get_character_active_body_part_mesh(part_name)

	if mesh == null:
		return

	if surface_index < 0:
		mesh.material_override = null
	else:
		mesh.set_surface_override_material(surface_index, null)

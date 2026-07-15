extends BaseComponent
class_name WeaponComponent

#==============================================================================
# Signals
#==============================================================================

signal weapon_equipped(item: ItemDefinition, slot: WeaponSlot.Id)
signal weapon_unequipped(item: ItemDefinition, slot: WeaponSlot.Id)

#==============================================================================
# Export Variables
#==============================================================================

@export var default_weapon: ItemDefinition
@export var default_off_hand: ItemDefinition

#==============================================================================
# Cached References
#==============================================================================

var _main_socket: WeaponSocket
var _off_socket: WeaponSocket

#==============================================================================
# Runtime
#==============================================================================

var _main_instance: WeaponInstance
var _off_instance: WeaponInstance

var _attack_runtime: AttackRuntime = AttackRuntime.new()

#==============================================================================
# Properties
#==============================================================================

var current_instance: WeaponInstance:
	get:
		return _active_instance()

var current_item: ItemDefinition:
	get:
		var instance := _active_instance()
		return instance.item if instance != null else null

func has_weapon() -> bool:
	return _active_instance() != null

func _active_instance() -> WeaponInstance:
	if _main_instance != null:
		return _main_instance
	return _off_instance

func _current_payload() -> WeaponPayload:
	var item := current_item
	if item == null:
		return null
	return item.payload as WeaponPayload

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:

	if owner_character.has_method("get_character_weapon_socket"):
		_main_socket = owner_character.get_character_weapon_socket()

	if owner_character.has_method("get_character_off_hand_socket"):
		_off_socket = owner_character.get_character_off_hand_socket()

	_attack_runtime.initialize(self)

	if default_weapon != null:
		equip(default_weapon, WeaponSlot.Id.MAIN_HAND)

	if default_off_hand != null:
		equip(default_off_hand, WeaponSlot.Id.OFF_HAND)

#==============================================================================
# Equipment
#==============================================================================

func equip(item: ItemDefinition, slot: WeaponSlot.Id = WeaponSlot.Id.MAIN_HAND) -> bool:

	if item == null:
		return false

	var payload := item.payload as WeaponPayload

	if payload == null:
		push_error("ItemDefinition '%s' has no WeaponPayload." % item.display_name)
		return false

	if payload.weapon_scene == null:
		push_error("WeaponPayload has no weapon_scene.")
		return false

	unequip(slot)

	var scene := payload.weapon_scene.instantiate()

	if scene == null:
		return false

	if scene is not WeaponInstance:
		push_error("Weapon scene must inherit WeaponInstance.")
		scene.queue_free()
		return false

	var instance := scene as WeaponInstance
	var socket := _socket_for(slot)

	if socket != null:
		socket.attach(instance)

	instance.initialize(context, item)

	_set_instance_for(slot, instance)

	weapon_equipped.emit(item, slot)

	_sync_attack_range_visual()

	return true

func unequip(slot: WeaponSlot.Id = WeaponSlot.Id.MAIN_HAND) -> void:

	var instance := _instance_for(slot)

	if instance == null:
		return

	var item := instance.item
	var socket := _socket_for(slot)

	if socket != null:
		socket.clear()

	_set_instance_for(slot, null)

	weapon_unequipped.emit(item, slot)

	_sync_attack_range_visual()

#==============================================================================
# Slot Helpers
#==============================================================================

func get_equipped_item(slot: WeaponSlot.Id) -> ItemDefinition:
	var instance := _instance_for(slot)
	return instance.item if instance != null else null

func has_weapon_in_slot(slot: WeaponSlot.Id) -> bool:
	return _instance_for(slot) != null

func _instance_for(slot: WeaponSlot.Id) -> WeaponInstance:
	return _off_instance if slot == WeaponSlot.Id.OFF_HAND else _main_instance

func _set_instance_for(slot: WeaponSlot.Id, instance: WeaponInstance) -> void:
	if slot == WeaponSlot.Id.OFF_HAND:
		_off_instance = instance
	else:
		_main_instance = instance

func _socket_for(slot: WeaponSlot.Id) -> WeaponSocket:
	return _off_socket if slot == WeaponSlot.Id.OFF_HAND else _main_socket

#==============================================================================
# Queries
#==============================================================================

func get_weapon_type() -> WeaponType.Id:
	var payload := _current_payload()
	return payload.weapon_type if payload != null else WeaponType.Id.UNARMED

func is_weapon_type(type: WeaponType.Id) -> bool:
	return get_weapon_type() == type

func get_hitbox() -> HitboxComponent:
	var instance := _active_instance()
	if instance == null:
		return null
	return instance.get_hitbox()

func get_attack_set() -> AttackSet:
	var payload := _current_payload()
	return payload.attack_set if payload != null else null

func get_attack_range() -> float:
	var payload := _current_payload()
	return payload.attack_range if payload != null else 1.5

#------------------------------------------------------------------------------
# Action Framework API
#------------------------------------------------------------------------------

func get_attack_definition(index: int = 0) -> ActionDefinition:
	var attack_set := get_attack_set()
	if attack_set == null:
		return null
	return attack_set.get_light_attack(index)

func get_attack(index: int = 0) -> AttackDefinition:
	return get_attack_definition(index)

func get_light_attack_count() -> int:
	var attack_set := get_attack_set()
	if attack_set == null:
		return 0
	return attack_set.get_light_attack_count()

func reset_combo() -> void:
	if context.combo:
		context.combo.reset_combo()
	_attack_runtime.reset_combo()

func select_next_attack() -> AttackDefinition:
	return _attack_runtime.select_next_attack()

func commit_attack(attack: AttackDefinition) -> void:
	_attack_runtime.commit_attack(attack)

func _sync_attack_range_visual() -> void:

	if not owner_character.has_method("get_character_attack_range_area"):
		return

	var area: Area3D = owner_character.get_character_attack_range_area()

	if area == null:
		return

	var shape_node := area.get_node_or_null("CollisionShape3D") as CollisionShape3D

	if shape_node == null or shape_node.shape == null:
		return

	var sphere := shape_node.shape as SphereShape3D

	if sphere != null:
		sphere.radius = get_attack_range()

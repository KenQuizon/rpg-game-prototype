extends BaseComponent
class_name WeaponComponent

#==============================================================================
# Signals
#==============================================================================

signal weapon_equipped(profile: WeaponProfile, slot: WeaponSlot.Id)
signal weapon_unequipped(profile: WeaponProfile, slot: WeaponSlot.Id)

#==============================================================================
# Export Variables
#==============================================================================

@export var default_weapon: WeaponProfile          # main hand — unchanged name/behavior
@export var default_off_hand: WeaponProfile

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
# Properties — unchanged, now explicitly "main hand" under the hood
#==============================================================================

#==============================================================================
# Properties — resolves to whichever hand currently holds a weapon,
# preferring main hand when both are equipped. An off-hand-only weapon
# (e.g. a bow with nothing in main hand) now drives attacks/range exactly
# like a main-hand-only setup did before this fix.
#==============================================================================

var current_instance: WeaponInstance:
	get:
		return _active_instance()

var current_profile: WeaponProfile:
	get:
		var instance := _active_instance()
		return instance.profile if instance != null else null

func has_weapon() -> bool:
	return _active_instance() != null

func _active_instance() -> WeaponInstance:
	if _main_instance != null:
		return _main_instance
	return _off_instance
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

func equip(profile: WeaponProfile, slot: WeaponSlot.Id = WeaponSlot.Id.MAIN_HAND) -> bool:

	if profile == null:
		return false

	if profile.weapon_scene == null:
		push_error("WeaponProfile has no weapon_scene.")
		return false

	unequip(slot)

	var scene := profile.weapon_scene.instantiate()

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

	instance.initialize(context, profile)

	_set_instance_for(slot, instance)

	weapon_equipped.emit(profile, slot)

	_sync_attack_range_visual()
	
	return true

func unequip(slot: WeaponSlot.Id = WeaponSlot.Id.MAIN_HAND) -> void:

	var instance := _instance_for(slot)

	if instance == null:
		return

	var profile := instance.profile
	var socket := _socket_for(slot)

	if socket != null:
		socket.clear()

	_set_instance_for(slot, null)

	weapon_unequipped.emit(profile, slot)
	
	_sync_attack_range_visual()

#==============================================================================
# Slot Helpers
#==============================================================================

func get_profile(slot: WeaponSlot.Id) -> WeaponProfile:
	var instance := _instance_for(slot)
	return instance.profile if instance != null else null

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
# Queries — unchanged signatures, main hand only (attacks/combos are a
# main-hand concept for now; off-hand is equip-only until a dual-wield or
# shield-block mechanic is built on top of it)
#==============================================================================

func get_weapon_type() -> WeaponType.Id:
	if current_profile == null:
		return WeaponType.Id.UNARMED
	return current_profile.weapon_type

func is_weapon_type(type: WeaponType.Id) -> bool:
	return get_weapon_type() == type

func get_hitbox() -> HitboxComponent:
	var instance := _active_instance()
	if instance == null:
		return null
	return instance.get_hitbox()
	
func get_attack_set() -> AttackSet:
	if current_profile == null:
		return null
	return current_profile.attack_set

func get_attack_range() -> float:
	if current_profile == null:
		return 1.5 # unarmed default — matches WeaponProfile's own default range
	return current_profile.attack_range

#------------------------------------------------------------------------------
# Action Framework API
#------------------------------------------------------------------------------

func get_attack_definition(index: int = 0) -> ActionDefinition:
	var attack_set := get_attack_set()
	if attack_set == null:
		return null
	return attack_set.get_light_attack(index)

#------------------------------------------------------------------------------
# Legacy Compatibility
#------------------------------------------------------------------------------

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

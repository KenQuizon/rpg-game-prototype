extends BaseComponent
class_name WeaponComponent

#==============================================================================
# Signals
#==============================================================================

signal weapon_equipped(profile: WeaponProfile)
signal weapon_unequipped(profile: WeaponProfile)

#==============================================================================
# Export Variables
#==============================================================================

@export var default_weapon: WeaponProfile

#==============================================================================
# Cached References
#==============================================================================

var _socket: WeaponSocket

#==============================================================================
# Runtime
#==============================================================================

var _instance: WeaponInstance

var _attack_runtime := AttackRuntime.new()

#==============================================================================
# Properties
#==============================================================================

var current_instance: WeaponInstance:
	get:
		return _instance


var current_profile: WeaponProfile:
	get:
		if _instance == null:
			return null
		return _instance.profile


func has_weapon() -> bool:
	return _instance != null

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:

	var character := owner_character as Character

	if character == null:
		return

	_socket = character.character_weapon_socket
	
	_attack_runtime.initialize(self)

	if default_weapon != null:
		equip(default_weapon)

#==============================================================================
# Equipment
#==============================================================================

func equip(profile: WeaponProfile) -> bool:

	if profile == null:
		return false

	if profile.weapon_scene == null:
		push_error("WeaponProfile has no weapon_scene.")
		return false

	unequip()

	var scene := profile.weapon_scene.instantiate()

	if scene == null:
		return false

	if scene is not WeaponInstance:
		push_error("Weapon scene must inherit WeaponInstance.")
		scene.queue_free()
		return false

	_instance = scene as WeaponInstance

	_instance.initialize(
		context,
		profile
	)

	if _socket != null:
		_socket.attach(_instance)

	weapon_equipped.emit(profile)

	return true


func unequip() -> void:

	if _instance == null:
		return

	var profile := _instance.profile

	if _socket != null:
		_socket.clear()

	_instance = null

	weapon_unequipped.emit(profile)

#==============================================================================
# Queries
#==============================================================================

func get_weapon_type() -> WeaponType.Id:

	if current_profile == null:
		return WeaponType.Id.UNARMED

	return current_profile.weapon_type


func is_weapon_type(type: WeaponType.Id) -> bool:
	return get_weapon_type() == type


func get_hitbox() -> HitboxComponent:

	if _instance == null:
		return null

	return _instance.get_hitbox()


func get_attack(index: int = 0) -> WeaponAttack:

	if current_profile == null:
		return null

	if current_profile.attacks.is_empty():
		return null

	index = clamp(
		index,
		0,
		current_profile.attacks.size() - 1
	)

	return current_profile.attacks[index]

func get_attack_set() -> AttackSet:

	if current_profile == null:
		return null

	return current_profile.attack_set
	
func get_light_attack_count() -> int:

	var set := get_attack_set()

	if set == null:
		return 0

	return set.get_light_attack_count()
	

func reset_combo() -> void:

	if context.combo:
		context.combo.reset_combo()
		
	_attack_runtime.reset_combo()
		
func select_next_attack() -> AttackDefinition:

	return _attack_runtime.select_next_attack()

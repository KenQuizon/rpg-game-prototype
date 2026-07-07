extends BaseComponent
class_name EquipmentComponent

#==============================================================================
# Signals
#==============================================================================

signal equipment_equipped(slot: int, profile: EquipmentProfile)
signal equipment_unequipped(slot: int, profile: EquipmentProfile)

#==============================================================================
# Export Variables
#==============================================================================

@export var default_equipment: Array[EquipmentProfile] = []

#==============================================================================
# Runtime
#==============================================================================

var _equipped: Dictionary = {} # EquipmentSlotType.Id -> EquippedItem
var _sockets: Dictionary = {} # EquipmentSlotType.Id -> EquipmentSlotSocket

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:

	if not owner_character.has_method("get_character_visual"):
		return

	_discover_sockets(owner_character.get_character_visual())

	for profile in default_equipment:
		equip(profile)

func _discover_sockets(node: Node) -> void:

	if node == null:
		return

	for child in node.get_children():

		if child is EquipmentSlotSocket:
			_sockets[child.slot] = child

		_discover_sockets(child)

#==============================================================================
# Public API
#==============================================================================

func equip(profile: EquipmentProfile) -> bool:

	if profile == null:
		return false

	unequip(profile.slot)

	var item := EquippedItem.new(profile, profile.slot)

	_equipped[profile.slot] = item

	_apply_modifiers(item)

	_attach_visual(item)

	equipment_equipped.emit(profile.slot, profile)

	return true

func unequip(slot: int) -> void:

	if not _equipped.has(slot):
		return

	var item: EquippedItem = _equipped[slot]

	_remove_modifiers(item)

	_detach_visual(item)

	_equipped.erase(slot)

	equipment_unequipped.emit(slot, item.profile)

func unequip_all() -> void:
	for slot in _equipped.keys().duplicate():
		unequip(slot)

func get_equipped(slot: int) -> EquipmentProfile:

	if not _equipped.has(slot):
		return null

	var item: EquippedItem = _equipped[slot]

	return item.profile

func has_equipped(slot: int) -> bool:
	return _equipped.has(slot)

#==============================================================================
# Internal — Stat Modifiers
#==============================================================================

func _apply_modifiers(item: EquippedItem) -> void:

	var stats := context.stats

	if stats == null:
		return

	if item.profile.stat_modifiers.is_empty():
		return

	for entry: StatModifierEntry in item.profile.stat_modifiers:
		stats.add_modifier(
			entry.stat,
			StatModifier.new(item, entry.value)
		)

func _remove_modifiers(item: EquippedItem) -> void:

	var stats := context.stats

	if stats == null:
		return

	stats.remove_modifiers_from_source(item)

#==============================================================================
# Internal — Visuals
#==============================================================================

func _attach_visual(item: EquippedItem) -> void:

	if item.profile.visual_scene == null:
		return

	var socket: EquipmentSlotSocket = _sockets.get(item.slot)

	if socket == null:
		return

	var visual := item.profile.visual_scene.instantiate() as Node3D

	if visual == null:
		return

	socket.attach(visual)

func _detach_visual(item: EquippedItem) -> void:

	var socket: EquipmentSlotSocket = _sockets.get(item.slot)

	if socket != null:
		socket.clear()

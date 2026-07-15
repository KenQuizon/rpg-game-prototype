extends BaseComponent
class_name EquipmentComponent

#==============================================================================
# Signals
#==============================================================================

signal equipment_equipped(slot: int, item: ItemDefinition)
signal equipment_unequipped(slot: int, item: ItemDefinition)

#==============================================================================
# Export Variables
#==============================================================================

@export var default_equipment: Array[ItemDefinition] = []

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

	for item in default_equipment:
		equip(item)

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

func equip(item: ItemDefinition) -> bool:

	if item == null:
		return false

	var slot: int
	var payload: ItemPayload

	if item.payload is ArmorPayload:
		var armor := item.payload as ArmorPayload
		slot = armor.equipment_slot
		payload = armor
	elif item.payload is AccessoryPayload:
		var accessory := item.payload as AccessoryPayload
		slot = accessory.equipment_slot
		payload = accessory
	else:
		push_error("ItemDefinition '%s' has no Armor/Accessory payload." % item.display_name)
		return false

	unequip(slot)

	var equipped := EquippedItem.new(item, payload, slot)

	_equipped[slot] = equipped

	_apply_modifiers(equipped)

	_attach_visual(equipped)

	equipment_equipped.emit(slot, item)

	return true

func unequip(slot: int) -> void:

	if not _equipped.has(slot):
		return

	var equipped: EquippedItem = _equipped[slot]

	_remove_modifiers(equipped)

	_detach_visual(equipped)

	_equipped.erase(slot)

	equipment_unequipped.emit(slot, equipped.item)

func unequip_all() -> void:
	for slot in _equipped.keys().duplicate():
		unequip(slot)

func get_equipped(slot: int) -> ItemDefinition:

	if not _equipped.has(slot):
		return null

	var equipped: EquippedItem = _equipped[slot]

	return equipped.item

func has_equipped(slot: int) -> bool:
	return _equipped.has(slot)

#==============================================================================
# Internal — Stat Modifiers
#==============================================================================

func _apply_modifiers(equipped: EquippedItem) -> void:

	var stats := context.stats

	if stats == null:
		return

	var modifiers: Array = equipped.payload.get("stat_modifiers")

	if modifiers == null or modifiers.is_empty():
		return

	for entry: StatModifierEntry in modifiers:
		stats.add_modifier(
			entry.stat,
			StatModifier.new(equipped, entry.value)
		)

func _remove_modifiers(equipped: EquippedItem) -> void:

	var stats := context.stats

	if stats == null:
		return

	stats.remove_modifiers_from_source(equipped)

#==============================================================================
# Internal — Visuals
#==============================================================================

func _attach_visual(equipped: EquippedItem) -> void:

	var visual_scene: PackedScene = equipped.payload.get("visual_scene")

	if visual_scene == null:
		return

	var socket: EquipmentSlotSocket = _sockets.get(equipped.slot)

	if socket == null:
		return

	var visual := visual_scene.instantiate() as Node3D

	if visual == null:
		return

	socket.attach(visual)

func _detach_visual(equipped: EquippedItem) -> void:

	var socket: EquipmentSlotSocket = _sockets.get(equipped.slot)

	if socket != null:
		socket.clear()

func save_state() -> Dictionary:
	var data := {}
	for slot in _equipped.keys():
		var equipped: EquippedItem = _equipped[slot]
		data[str(slot)] = equipped.item.resource_path
	return data

func load_state(data: Dictionary) -> void:
	unequip_all()
	for key in data.keys():
		var item := load(data[key]) as ItemDefinition
		if item != null:
			equip(item)

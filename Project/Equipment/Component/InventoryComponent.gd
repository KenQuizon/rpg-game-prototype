extends BaseComponent
class_name InventoryComponent

#==============================================================================
# Signals
#==============================================================================

signal inventory_changed()
signal item_added(item: Resource, quantity: int)

#==============================================================================
# Export Variables
#==============================================================================

@export var starting_items: Array[Resource] = []

@export var max_slots: int = 20

#==============================================================================
# Runtime
#==============================================================================

var _slots: Dictionary = {} # resource_path (String) -> InventorySlot

#==============================================================================
# Lifecycle
#==============================================================================

var _initializing: bool = false

func on_initialize() -> void:
	_initializing = true
	for item in starting_items:
		add_item(item, 1)
	_initializing = false

	
#==============================================================================
# Public API
#==============================================================================

func add_item(item: Resource, quantity: int = 1) -> bool:

	if item == null or quantity <= 0:
		return false

	var path := item.resource_path

	if _slots.has(path):
		_slots[path].quantity += quantity
	else:
		if _slots.size() >= max_slots:
			return false
		_slots[path] = InventorySlot.new(item, quantity)

	inventory_changed.emit()

	if not _initializing:

		item_added.emit(item, quantity)

		var definition := item as ItemDefinition

		if definition != null:
			UIEvents.item_picked_up.emit(definition, quantity)

	return true

func remove_item(item: Resource, quantity: int = 1) -> bool:

	if item == null or quantity <= 0:
		return false

	var path := item.resource_path

	if not _slots.has(path):
		return false

	var slot: InventorySlot = _slots[path]

	if slot.quantity < quantity:
		return false

	slot.quantity -= quantity

	if slot.quantity <= 0:
		_slots.erase(path)

	inventory_changed.emit()
	return true

func get_quantity(item: Resource) -> int:
	if item == null or not _slots.has(item.resource_path):
		return 0
	return _slots[item.resource_path].quantity

func has_item(item: Resource, quantity: int = 1) -> bool:
	return get_quantity(item) >= quantity

func get_all_slots() -> Array[InventorySlot]:
	var result: Array[InventorySlot] = []
	for slot in _slots.values():
		result.append(slot)
	return result
	
func save_state() -> Array:
	var data: Array = []
	for slot in get_all_slots():
		data.append({"path": slot.item.resource_path, "quantity": slot.quantity})
	return data

func load_state(data: Array) -> void:
	_slots.clear()
	for entry in data:
		var item := load(entry["path"]) as Resource
		if item != null:
			add_item(item, entry["quantity"])

extends Control
class_name InventoryPanel

signal item_info_requested(name: String, description: String, stat_lines: PackedStringArray)

@onready var grid: GridContainer = $VBoxContainer/ScrollContainer/ItemGrid
@onready var weight_label: Label = $VBoxContainer/Weight

@export var inventory_slot_scene: PackedScene
@export var grid_columns: int = 5

var character: Character
var inventory_component: InventoryComponent
var selected_item: ItemDefinition

func setup(bound_character: Character) -> void:

	character = bound_character

	if character == null or character.context == null or character.context.inventory == null:
		return

	inventory_component = character.context.inventory
	inventory_component.inventory_changed.connect(_on_inventory_changed)

	grid.columns = grid_columns
	_populate_inventory()
	_update_capacity_display()

func _populate_inventory() -> void:
	for child in grid.get_children():
		child.queue_free()

	for slot in inventory_component.get_all_slots():
		var item := slot.item as ItemDefinition
		if item == null:
			continue

		var slot_ui = inventory_slot_scene.instantiate()
		grid.add_child(slot_ui)
		slot_ui.set_item(item, slot.quantity)
		slot_ui.item_selected.connect(func(): _on_item_selected(item))
		slot_ui.item_activated.connect(func(): _on_item_activated(item))

func _on_item_activated(item: ItemDefinition) -> void:

	if character == null or character.context == null:
		return

	if item.category == ItemCategory.Id.WEAPON and character.context.weapon:
		character.context.weapon.equip(item, item.weapon_slot)

	elif (item.category == ItemCategory.Id.ARMOR or item.category == ItemCategory.Id.ACCESSORY) and character.context.equipment:
		character.context.equipment.equip(item)

	elif item.consumable:
		if item.heal_amount > 0.0 and character.context.health:
			character.context.health.heal(item.heal_amount)
		if item.restore_amount > 0.0 and character.context.resources:
			character.context.resources.restore(item.restore_resource_type, item.restore_amount)
		inventory_component.remove_item(item, 1)

func _on_item_selected(item: ItemDefinition) -> void:
	selected_item = item
	item_info_requested.emit(item.display_name, item.description, PackedStringArray())

func _on_inventory_changed() -> void:
	_populate_inventory()
	_update_capacity_display()

func _update_capacity_display() -> void:
	weight_label.text = "Slots: %d/%d" % [inventory_component.get_all_slots().size(), inventory_component.max_slots]

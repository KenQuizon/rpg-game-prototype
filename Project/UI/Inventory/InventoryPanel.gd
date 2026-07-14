extends BaseUIPanel
class_name InventoryPanel

signal item_selected(item: ItemDefinition)

@onready var grid: GridContainer = $VBoxContainer/ItemGrid
@onready var item_info: Label = $VBoxContainer/ItemInfo
@onready var weight_label: Label = $VBoxContainer/Weight

@export var inventory_slot_scene: PackedScene
@export var grid_columns: int = 5

var character: Character
var inventory_component: InventoryComponent
var selected_item: ItemDefinition

func _ready() -> void:
	layer = UILayerType.Id.SCREEN
	super._ready()

	UIManager.register_panel("inventory", self)

	character = CharacterRef.get_player()

	if character and character.context and character.context.inventory:
		inventory_component = character.context.inventory
		inventory_component.inventory_changed.connect(_on_inventory_changed)

		grid.columns = grid_columns
		_populate_inventory()
		_update_capacity_display()
		print("InventoryPanel initialized")

	if not InputMap.has_action("toggle_inventory"):
		InputMap.add_action("toggle_inventory")
		var event = InputEventKey.new()
		event.keycode = KEY_I
		InputMap.action_add_event("toggle_inventory", event)

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

	if item.weapon_profile != null and character.context.weapon:
		character.context.weapon.equip(item.weapon_profile, item.weapon_slot)
		print("Equipped weapon: %s" % item.display_name)

	elif item.equipment_profile != null and character.context.equipment:
		character.context.equipment.equip(item.equipment_profile)
		print("Equipped: %s" % item.display_name)

	elif item.consumable:
		if item.heal_amount > 0.0 and character.context.health:
			character.context.health.heal(item.heal_amount)
		if item.restore_amount > 0.0 and character.context.resources:
			character.context.resources.restore(item.restore_resource_type, item.restore_amount)
		inventory_component.remove_item(item, 1)
		
func _on_item_selected(item: ItemDefinition) -> void:
	selected_item = item
	item_info.text = "[b]%s[/b]\n%s" % [item.display_name, item.description]
	item_selected.emit(item)

func _on_inventory_changed() -> void:
	_populate_inventory()
	_update_capacity_display()

func _update_capacity_display() -> void:
	# No weight system exists — capacity is tracked by slot count.
	weight_label.text = "Slots: %d/%d" % [inventory_component.get_all_slots().size(), inventory_component.max_slots]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		UIManager.toggle_panel("inventory")
		get_viewport().set_input_as_handled()

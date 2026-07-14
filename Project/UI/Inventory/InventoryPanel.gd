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
		get_tree().set_input_as_handled()

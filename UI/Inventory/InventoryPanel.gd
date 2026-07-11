extends BaseUIPanel
class_name InventoryPanel

signal item_selected(item: ItemDefinition)

@onready var grid: GridContainer = $VBoxContainer/ItemGrid
@onready var item_info: Label = $VBoxContainer/ItemInfo
@onready var weight_label: Label = $VBoxContainer/Weight

@export var inventory_slot_scene: PackedScene
@export var grid_columns: int = 5

var character: Character
var inventory_component: Node
var selected_item: ItemDefinition

func _ready() -> void:
	super._ready()
	
	# Register with UIManager
	UIManager.register_panel("inventory", self)
	
	# Get character and inventory
	character = CharacterRef.get_player()
	
	if character and character.has_method("get_character_inventory"):
		inventory_component = character.get_character_inventory()
		inventory_component.inventory_changed.connect(_on_inventory_changed)
		
		grid.columns = grid_columns
		_populate_inventory()
		print("InventoryPanel initialized")
	
	# Setup hotkey
	if not InputMap.has_action("toggle_inventory"):
		InputMap.add_action("toggle_inventory")
		var event = InputEventKey.new()
		event.keycode = KEY_I
		InputMap.action_add_event("toggle_inventory", event)

func _populate_inventory() -> void:
	"""Refresh inventory grid display"""
	# Clear
	for child in grid.get_children():
		child.queue_free()
	
	# Get all items
	var items = inventory_component.get_all_items()
	
	# Add to grid
	for item in items:
		var slot = inventory_slot_scene.instantiate()
		slot.set_item(item)
		slot.item_selected.connect(func(): _on_item_selected(item))
		grid.add_child(slot)

func _on_item_selected(item: ItemDefinition) -> void:
	"""Player selected an item"""
	selected_item = item
	
	var desc = item.get_meta("description", "No description")
	item_info.text = "[b]%s[/b]\n%s" % [item.name, desc]
	item_selected.emit(item)

func _on_inventory_changed() -> void:
	"""Inventory contents changed"""
	_populate_inventory()
	_update_weight_display()

func _update_weight_display() -> void:
	"""Update weight indicator"""
	var current = inventory_component.get_total_weight()
	var max_weight = inventory_component.max_weight
	weight_label.text = "Weight: %.1f/%.1f" % [current, max_weight]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		toggle()
		get_tree().set_input_as_handled()

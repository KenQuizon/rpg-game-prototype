extends PanelContainer
class_name InventorySlotUI

signal item_selected
signal item_activated

@onready var icon: TextureRect = $VBoxContainer/Icon
@onready var quantity: Label = $VBoxContainer/Quantity

var item: ItemDefinition
var item_quantity: int = 1

func _ready() -> void:
	gui_input.connect(_on_gui_input)

func set_item(new_item: ItemDefinition, qty: int = 1) -> void:
	item = new_item
	item_quantity = qty

	if item:
		icon.texture = item.icon
		quantity.text = str(qty) if qty > 1 else ""
		tooltip_text = item.display_name

func _on_gui_input(event: InputEvent) -> void:
	if not item:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if event.double_click:
			item_activated.emit()
		else:
			item_selected.emit()

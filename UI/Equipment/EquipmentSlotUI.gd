extends PanelContainer
class_name EquipmentSlotUI

signal slot_selected

@onready var icon: TextureRect = $Icon
@onready var slot_name_label: Label = $SlotName

var slot_name: String
var equipped_item: EquippedItem

func _ready() -> void:
	gui_input.connect(_on_gui_input)

func set_equipment(item: EquippedItem) -> void:
	equipped_item = item
	
	if item:
		icon.texture = item.item_profile.icon if item.item_profile.has_meta("icon") else null
	else:
		icon.texture = null

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		slot_selected.emit()

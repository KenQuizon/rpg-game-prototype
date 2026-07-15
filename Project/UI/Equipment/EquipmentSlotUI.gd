extends PanelContainer
class_name EquipmentSlotUI

signal slot_selected

@onready var icon: TextureRect = $Icon
@onready var slot_name_label: Label = $SlotName

@export var slot: EquipmentSlotType.Id

var equipped_item: ItemDefinition

func _ready() -> void:
	gui_input.connect(_on_gui_input)

	var names := EquipmentSlotType.Id.keys()

	if slot < 0 or slot >= names.size():
		push_error("%s has invalid slot value %d" % [get_path(), slot])
		return

	slot_name_label.text = names[slot].capitalize()

func set_equipment(item: ItemDefinition) -> void:
	equipped_item = item
	icon.texture = item.icon if item else null
	slot_name_label.visible = item == null

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		slot_selected.emit()

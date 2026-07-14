extends PanelContainer
class_name EquipmentSlotUI

signal slot_selected

@onready var icon: TextureRect = $Icon
@onready var slot_name_label: Label = $SlotName

@export var slot: EquipmentSlotType.Id

var equipped_profile: EquipmentProfile

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	slot_name_label.text = EquipmentSlotType.Id.keys()[slot].capitalize()

func set_equipment(profile: EquipmentProfile) -> void:
	equipped_profile = profile
	icon.texture = profile.icon if profile else null

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		slot_selected.emit()

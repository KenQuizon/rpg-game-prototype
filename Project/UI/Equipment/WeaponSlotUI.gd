extends PanelContainer
class_name WeaponSlotUI

signal slot_selected

@onready var icon: TextureRect = $Icon
@onready var slot_name_label: Label = $SlotName

@export var slot: WeaponSlot.Id

var equipped_profile: WeaponProfile

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	slot_name_label.text = "Main Hand" if slot == WeaponSlot.Id.MAIN_HAND else "Off Hand"

func set_weapon(profile: WeaponProfile) -> void:
	equipped_profile = profile

	# WeaponProfile doesn't contain an icon.
	# Clear the icon for now instead of causing an error.
	icon.texture = null

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		slot_selected.emit()

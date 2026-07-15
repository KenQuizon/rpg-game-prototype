extends Control
class_name CharacterScreen

@onready var character_model: SubViewportContainer = $CharacterPreview

var character: Character

func setup(bound_character: Character) -> void:
	character = bound_character

	if character == null or character.context == null:
		return

	_refresh_preview()

	if character.context.equipment:
		character.context.equipment.equipment_equipped.connect(func(_a, _b): _refresh_preview())
		character.context.equipment.equipment_unequipped.connect(func(_a, _b): _refresh_preview())

	if character.context.weapon:
		character.context.weapon.weapon_equipped.connect(func(_a, _b): _refresh_preview())
		character.context.weapon.weapon_unequipped.connect(func(_a, _b): _refresh_preview())

func _refresh_preview() -> void:
	var viewport := character_model.get_node("SubViewport")

	for child in viewport.get_children():
		if child.name != "Camera3D":
			child.queue_free()

	var model := character.get_character_model()
	if model:
		viewport.add_child(model.duplicate())

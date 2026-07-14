extends Control
class_name CharacterScreen

@onready var character_model: SubViewportContainer = $CharacterPreview
@onready var character_name: Label = $Info/Name
@onready var stats_panel: VBoxContainer = $Info/Stats

var character: Character

func setup(bound_character: Character) -> void:
	character = bound_character
	if character:
		_update_character_display()
		_create_character_preview()

func _create_character_preview() -> void:
	var model := character.get_character_model()
	if model:
		character_model.get_node("SubViewport").add_child(model.duplicate())

func _update_character_display() -> void:
	character_name.text = character.name

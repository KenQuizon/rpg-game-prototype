extends BaseUIPanel
class_name CharacterScreen

@onready var character_model: Node3D = $CharacterPreview
@onready var character_name: Label = $Info/Name
@onready var stats_panel: VBoxContainer = $Info/Stats
@onready var perks_panel: VBoxContainer = $Info/Perks
@onready var equipment_panel: VBoxContainer = $Info/Equipment

var character: Character

func _ready() -> void:
	super._ready()
	character = CharacterRef.get_player()

	if character:
		_update_character_display()
		_create_character_preview()

func _create_character_preview() -> void:
	var model := character.get_character_model()
	if model:
		character_model.add_child(model.duplicate())

func _update_character_display() -> void:
	character_name.text = character.name

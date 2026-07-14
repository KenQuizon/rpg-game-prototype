extends BaseUIPanel
class_name CharacterScreen

@onready var character_model: Node3D = $CharacterPreview
@onready var character_name: Label = $Info/Name
@onready var stats_panel: VBoxContainer = $Info/Stats
@onready var perks_panel: VBoxContainer = $Info/Perks
@onready var equipment_panel: VBoxContainer = $Info/Equipment

var character: Character

func _ready() -> void:
	layer = UILayerType.Id.SCREEN
	super._ready()

	UIManager.register_panel("character", self)

	character = CharacterRef.get_player()

	if character:
		_update_character_display()
		_create_character_preview()

	if not InputMap.has_action("toggle_character"):
		InputMap.add_action("toggle_character")
		var event = InputEventKey.new()
		event.keycode = KEY_C
		InputMap.action_add_event("toggle_character", event)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_character"):
		UIManager.toggle_panel("character")
		get_tree().set_input_as_handled()

func _create_character_preview() -> void:
	var model := character.get_character_model()
	if model:
		character_model.add_child(model.duplicate())

func _update_character_display() -> void:
	character_name.text = character.name

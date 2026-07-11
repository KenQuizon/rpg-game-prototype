extends CanvasLayer
class_name DialogManager

@onready var dialog_box: PanelContainer = $DialogBox
@onready var character_name: Label = $DialogBox/Character
@onready var dialog_text: RichTextLabel = $DialogBox/Text

var is_dialog_open: bool = false

func show_dialog(character: String, text: String, choices: Array[String] = []) -> void:
	is_dialog_open = true
	character_name.text = character
	dialog_text.text = text
	dialog_box.visible = true
	
	# Add choice buttons if any
	if choices.size() > 0:
		_add_choice_buttons(choices)

func hide_dialog() -> void:
	is_dialog_open = false
	dialog_box.visible = false

func _add_choice_buttons(choices: Array[String]) -> void:
	# Create buttons for each choice
	pass

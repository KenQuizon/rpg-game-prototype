extends CanvasLayer
class_name DialogManager

signal choice_selected(index: int)

@onready var dialog_box: PanelContainer = $DialogBox
@onready var character_name: Label = $DialogBox/Character
@onready var dialog_text: RichTextLabel = $DialogBox/Text
@onready var choice_container: VBoxContainer = $DialogBox/Choices

var is_dialog_open: bool = false

func show_dialog(character: String, text: String, choices: Array[String] = []) -> void:
	is_dialog_open = true
	character_name.text = character
	dialog_text.text = text
	dialog_box.visible = true

	_clear_choices()
	if choices.size() > 0:
		_add_choice_buttons(choices)

func hide_dialog() -> void:
	is_dialog_open = false
	dialog_box.visible = false
	_clear_choices()

func _add_choice_buttons(choices: Array[String]) -> void:
	for i in range(choices.size()):
		var button := Button.new()
		button.text = choices[i]
		var choice_index := i
		button.pressed.connect(func(): _on_choice_pressed(choice_index))
		choice_container.add_child(button)

func _on_choice_pressed(index: int) -> void:
	choice_selected.emit(index)
	hide_dialog()

func _clear_choices() -> void:
	for child in choice_container.get_children():
		child.queue_free()

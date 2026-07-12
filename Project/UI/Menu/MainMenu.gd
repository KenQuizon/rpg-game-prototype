extends BaseUIPanel
class_name MainMenu

const GAME_SCENE_PATH := "res://Project/World/World.tscn"

@onready var button_container: VBoxContainer = $VBoxContainer

var menu_buttons: Array[Button] = []

func _ready() -> void:
	super._ready()
	visible = true   # this is the boot/title screen, not a toggled panel

	var play_btn = _create_button("New Game")
	play_btn.pressed.connect(_on_new_game_pressed)

	var continue_btn = _create_button("Continue")
	continue_btn.disabled = not SaveSystem.has_save()
	continue_btn.pressed.connect(_on_continue_pressed)

	var settings_btn = _create_button("Settings")
	settings_btn.pressed.connect(func(): UIManager.open_panel("settings"))

	var quit_btn = _create_button("Quit")
	quit_btn.pressed.connect(func(): get_tree().quit())

func _create_button(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(200, 50)
	button_container.add_child(btn)
	menu_buttons.append(btn)
	return btn

func _on_new_game_pressed() -> void:
	CharacterRef.clear_player()
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_continue_pressed() -> void:
	if not SaveSystem.has_save():
		return

	CharacterRef.clear_player()
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

	await get_tree().process_frame
	await get_tree().process_frame

	var character := CharacterRef.get_player()
	if character:
		SaveSystem.load_game(character)

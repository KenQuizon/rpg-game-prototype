extends BaseUIPanel
class_name MainMenu

@onready var button_container: VBoxContainer = $VBoxContainer

var menu_buttons: Array[Button] = []

func _ready() -> void:
	super._ready()
	
	# Create menu buttons
	var play_btn = _create_button("New Game")
	play_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/Game.tscn"))
	
	var continue_btn = _create_button("Continue")
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

func _on_continue_pressed() -> void:
	# Load saved game
	pass

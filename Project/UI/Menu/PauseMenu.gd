extends BaseUIPanel
class_name PauseMenu

@onready var button_container: VBoxContainer = $VBoxContainer

func _ready() -> void:
	layer = UILayerType.Id.MODAL
	super._ready()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	UIManager.register_panel("pause_menu", self)

	var resume_btn := _create_button("Resume")
	resume_btn.pressed.connect(UICoordinator.unpause_game)

	var settings_btn := _create_button("Settings")
	settings_btn.pressed.connect(func(): UIManager.open_panel("settings"))

	var quit_btn := _create_button("Quit to Main Menu")
	quit_btn.pressed.connect(_on_quit_to_menu_pressed)

func _create_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(200, 50)
	button_container.add_child(btn)
	return btn

func _on_quit_to_menu_pressed() -> void:
	UICoordinator.unpause_game()
	CharacterRef.clear_player()
	get_tree().change_scene_to_file("res://UI/Menu/MainMenu.tscn")

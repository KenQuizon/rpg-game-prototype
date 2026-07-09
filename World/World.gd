extends Node3D

@onready var player: Character = $Character
@onready var camera_rig: CameraRig = $CameraRig
@onready var hud: HUD = $HUD


func _ready() -> void:
	camera_rig.set_target(
		player.get_camera_follow_target()
	)

	hud.bind_to_character(player)

func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("ui_page_up"): # F5-equivalent; bind explicitly if you prefer
		SaveSystem.save_game(player)

	if event.is_action_pressed("ui_page_down"):
		SaveSystem.load_game(player)

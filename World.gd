extends Node3D

@onready var player: Character = $Character
@onready var camera_rig: CameraRig = $CameraRig


func _ready() -> void:
	camera_rig.set_target(
		player.get_camera_follow_target()
	)

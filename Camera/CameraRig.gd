extends Node3D
class_name CameraRig

#==============================================================================
# Export Variables
#==============================================================================

@export var follow_speed: float = 8.0
@export var camera_offset: Vector3 = Vector3(0.0, 18.0, 0.0)

#==============================================================================
# Cached Nodes
#==============================================================================

@onready var camera: Camera3D = $Camera3D

#==============================================================================
# Private Variables
#==============================================================================

var _target: Node3D = null

#==============================================================================
# Public API
#==============================================================================

func set_target(target: Node3D) -> void:

	_target = target

	if _target == null:
		return

	global_position = _target.global_position + camera_offset


func clear_target() -> void:
	_target = null

#==============================================================================
# Godot Lifecycle
#==============================================================================

func _ready() -> void:
	camera.position = Vector3.ZERO

var _shake_strength: float = 0.0
var _shake_remaining: float = 0.0

func shake(strength: float, duration: float = 0.2) -> void:
	_shake_strength = strength
	_shake_remaining = duration

func _process(delta: float) -> void:
	if _target == null:
		return
	var desired_position := _target.global_position + camera_offset
	if _shake_remaining > 0.0:
		_shake_remaining -= delta
		var offset := Vector3(randf_range(-1,1), randf_range(-1,1), 0.0) * _shake_strength
		desired_position += offset
	global_position = global_position.lerp(desired_position, follow_speed * delta)

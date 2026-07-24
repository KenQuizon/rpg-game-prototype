extends Node3D
class_name AttackRangeIndicator

const PLANE_SIZE: float = 2.0

@export var outline_world_width: float = 0.05
@export var fade_world_width: float = 0.3
@export var inactive_alpha_scale: float = 0.25

@onready var ring: MeshInstance3D = $MeshInstance3D

var _material: ShaderMaterial
var _base_outline_color: Color
var _base_fill_color: Color


func _ready() -> void:

	var mat := ring.material_override as ShaderMaterial

	if mat == null:
		return

	# Duplicate so each indicator instance gets its own material — two
	# rings with different ranges/active-states can't share one Resource,
	# or setting a shader parameter on one would bleed into the other.
	_material = mat.duplicate() as ShaderMaterial
	ring.material_override = _material

	_base_outline_color = _material.get_shader_parameter("outline_color")
	_base_fill_color = _material.get_shader_parameter("fill_color")


func set_range(attack_range: float) -> void:

	scale = Vector3(attack_range, 1.0, attack_range)

	if _material == null:
		return

	# outline_width/fade_width are UV-space fractions, so scaling this
	# node's transform (our sizing trick) also scales their apparent
	# world-space thickness. To hold a constant world thickness
	# regardless of range, both need to shrink proportionally as scale
	# grows — see the math note below.
	var safe_range: float = max(attack_range, 0.01)

	_material.set_shader_parameter("outline_width", outline_world_width / (PLANE_SIZE * safe_range))
	_material.set_shader_parameter("fade_width", fade_world_width / safe_range)


func set_active(is_active: bool) -> void:

	if _material == null:
		return

	var alpha_scale := 1.0 if is_active else inactive_alpha_scale

	var outline := _base_outline_color
	outline.a *= alpha_scale

	var fill := _base_fill_color
	fill.a *= alpha_scale

	_material.set_shader_parameter("outline_color", outline)
	_material.set_shader_parameter("fill_color", fill)

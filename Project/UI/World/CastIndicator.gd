extends Node3D
class_name CastIndicator

# Concrete indicator scenes (direction/arrow now, range-only and
# location-circle types later) name their shader-driven mesh "Mesh" and
# extend this script. This base only handles what all of them share:
# starting hidden, and giving each instance its own material so multiple
# indicators (or multiple casters) never fight over shared shader state
# — same reasoning AttackRangeIndicator already uses.

@onready var mesh: MeshInstance3D = $Mesh

var _material: ShaderMaterial


func _ready() -> void:
	visible = false
	_material = _duplicate_material()


func show_indicator() -> void:
	visible = true


func hide_indicator() -> void:
	visible = false


func _duplicate_material() -> ShaderMaterial:

	var mat := mesh.material_override as ShaderMaterial

	if mat == null:
		return null

	var unique := mat.duplicate() as ShaderMaterial
	mesh.material_override = unique

	return unique


# Concrete subclasses call this rather than touching _material directly,
# so a missing/misconfigured material fails quietly instead of crashing
# a skill cast over a cosmetic issue.
func _set_param(param_name: StringName, value: Variant) -> void:

	if _material != null:
		_material.set_shader_parameter(param_name, value)

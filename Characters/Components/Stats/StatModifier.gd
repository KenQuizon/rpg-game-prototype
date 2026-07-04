extends RefCounted
class_name StatModifier

var source: Object

var value: float

func _init(
	modifier_source: Object,
	modifier_value: float
) -> void:

	source = modifier_source
	value = modifier_value

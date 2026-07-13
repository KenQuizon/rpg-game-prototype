extends BaseComponent
class_name TargetIndicatorComponent

var _marked_target: Node = null

func physics_update(_delta: float) -> void:

	if context.targeting == null:
		_clear_marked()
		return

	var target := context.targeting.current_target

	if target == _marked_target:
		return

	_set_marked(_marked_target, false)
	_marked_target = target
	_set_marked(_marked_target, true)


func _clear_marked() -> void:

	if _marked_target == null:
		return

	_set_marked(_marked_target, false)
	_marked_target = null


func _set_marked(node: Node, is_marked: bool) -> void:

	if node == null or not is_instance_valid(node):
		return

	if not node.has_method("get_character_target_marker"):
		return

	var marker: Node3D = node.get_character_target_marker()

	if marker != null:
		marker.visible = is_marked

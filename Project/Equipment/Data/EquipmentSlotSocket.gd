extends Node3D
class_name EquipmentSlotSocket

#==============================================================================
# Export Variables
#==============================================================================

@export var slot: EquipmentSlotType.Id = EquipmentSlotType.Id.HEAD

#==============================================================================
# Runtime
#==============================================================================

var _current_visual: Node3D

#==============================================================================
# Public API
#==============================================================================

func attach(visual: Node3D) -> void:

	if visual == null:
		return

	clear()

	add_child(visual)

	visual.transform = Transform3D.IDENTITY

	_current_visual = visual

func detach() -> Node3D:

	if _current_visual == null:
		return null

	var removed := _current_visual

	remove_child(removed)

	_current_visual = null

	return removed

func clear() -> void:

	var visual := detach()

	if visual != null:
		visual.queue_free()

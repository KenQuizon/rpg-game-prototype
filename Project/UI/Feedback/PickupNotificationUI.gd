extends VBoxContainer
class_name PickupNotificationUI

const ROW_SCENE: PackedScene = preload("res://Project/UI/Feedback/PickupNotificationRow.tscn")

# item resource_path -> PickupNotificationRow. Mirrors the exact key
# InventoryComponent._slots already uses internally, so stacking here
# always agrees with stacking there.
var _rows: Dictionary = {}


func _ready() -> void:
	UIEvents.item_picked_up.connect(_on_item_picked_up)


func _on_item_picked_up(item: ItemDefinition, quantity: int) -> void:

	if item == null:
		return

	var path := item.resource_path

	if _rows.has(path) and is_instance_valid(_rows[path]):
		var existing: PickupNotificationRow = _rows[path]
		existing.add_quantity(quantity)
		return

	var row: PickupNotificationRow = ROW_SCENE.instantiate() as PickupNotificationRow

	add_child(row)
	move_child(row, 0)  # newest on top, per your earlier decision

	row.setup(item, quantity)
	row.tree_exited.connect(_on_row_freed.bind(path))

	_rows[path] = row


func _on_row_freed(path: String) -> void:
	if _rows.has(path):
		_rows.erase(path)

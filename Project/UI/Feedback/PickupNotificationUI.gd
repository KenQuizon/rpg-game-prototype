extends VBoxContainer
class_name PickupNotificationUI

const ROW_SCENE: PackedScene = preload("res://Project/UI/Feedback/PickupNotificationRow.tscn")
const FADE_DURATION: float = 0.3

# item resource_path -> PickupNotificationRow. Mirrors the exact key
# InventoryComponent._slots already uses internally, so stacking here
# always agrees with stacking there.
var _rows: Dictionary = {}
var _tween: Tween


func _ready() -> void:
	UIEvents.item_picked_up.connect(_on_item_picked_up)

	visible = false
	modulate.a = 0.0


func _on_item_picked_up(item: ItemDefinition, quantity: int) -> void:

	if item == null:
		return

	var path := item.resource_path

	if _rows.has(path) and is_instance_valid(_rows[path]):
		var existing: PickupNotificationRow = _rows[path]
		existing.add_quantity(quantity)
		return

	var was_empty := _rows.is_empty()

	var row: PickupNotificationRow = ROW_SCENE.instantiate() as PickupNotificationRow

	add_child(row)

	row.setup(item, quantity)
	row.tree_exited.connect(_on_row_freed.bind(path))

	_rows[path] = row

	if was_empty:
		_fade_in()


func _on_row_freed(path: String) -> void:

	if _rows.has(path):
		_rows.erase(path)

	if _rows.is_empty():
		_fade_out()


func _fade_in() -> void:

	if _tween:
		_tween.kill()

	visible = true

	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)


func _fade_out() -> void:

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	await _tween.finished

	# A new pickup could have arrived mid-fade and re-filled _rows — don't
	# hide the panel out from under a row that's already fading back in.
	if _rows.is_empty():
		visible = false

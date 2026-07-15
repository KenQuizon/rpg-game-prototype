extends Control
class_name InteractionPromptUI

const ROW_SCENE: PackedScene = preload("res://Project/World/InteractionRowUI.tscn")

@onready var key_glyph_label: Label = $Root/Header/KeyGlyph
@onready var action_label: Label = $Root/Header/ActionLabel
@onready var row_list: VBoxContainer = $Root/RowList

# Node (interactable) -> InteractionRowUI
var _rows: Dictionary = {}
var _interaction: InteractionComponent = null


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var character: Character = CharacterRef.get_player()

	if character == null or character.context == null:
		return

	_interaction = character.context.interaction

	if _interaction == null:
		return

	_interaction.interaction_list_changed.connect(_on_list_changed)
	_interaction.interaction_target_changed.connect(_on_target_changed)


# Stage 3 will call this while a gather-hold is charging.
# Currently unused until a progress indicator is added.
func set_hold_progress(_percent: float) -> void:
	pass


func _on_list_changed(ordered: Array[Node]) -> void:
	_rebuild_rows(ordered)
	_update_selection(_interaction.current_target)
	visible = not ordered.is_empty()


func _on_target_changed(_previous: Node, new_target: Node) -> void:
	_update_selection(new_target)
	visible = new_target != null


func _rebuild_rows(ordered: Array[Node]) -> void:

	for child: Node in row_list.get_children():
		child.queue_free()

	_rows.clear()

	for target: Node in ordered:

		var info: InteractableInfo = _interaction.get_interactable_info(target)

		var row: InteractionRowUI = ROW_SCENE.instantiate() as InteractionRowUI

		row_list.add_child(row)
		row.set_data(info)

		_rows[target] = row


func _update_selection(selected: Node) -> void:

	for target: Node in _rows.keys():

		var row: InteractionRowUI = _rows[target] as InteractionRowUI
		var is_selected: bool = target == selected

		row.set_selected(is_selected)

		if is_selected:
			action_label.text = _interaction.get_interactable_info(target).label

extends Control
class_name ResourceBar

@export var resource_type: ResourceType.Id = ResourceType.Id.MANA
@export var hide_when_full: bool = false

@onready var progress_bar: Range = _find_progress_bar()
@onready var label: Label = get_node_or_null("Label")
@onready var icon: TextureRect = get_node_or_null("Icon")

var resource_component: ResourceComponent

func _ready() -> void:
	if progress_bar == null:
		print("ERROR: ResourceBar has no ProgressBar/TextureProgressBar child")
		return

	resource_component = CharacterRef.get_player_resources()

	if resource_component:
		var max_val := resource_component.get_max(resource_type)
		var current_val := resource_component.get_current(resource_type)

		progress_bar.max_value = max_val
		progress_bar.value = current_val
		_update_label(current_val, max_val)
		_update_visibility(current_val, max_val)

		resource_component.resource_changed.connect(_on_resource_changed)
		print("ResourceBar (%s) connected" % ResourceType.Id.keys()[resource_type])
	else:
		print("ERROR: Could not connect resource bar for %s" % ResourceType.Id.keys()[resource_type])

func _on_resource_changed(changed_type: int, _previous: float, current: float) -> void:
	if changed_type != resource_type:
		return

	var max_val := resource_component.get_max(resource_type)
	progress_bar.max_value = max_val
	progress_bar.value = current
	_update_label(current, max_val)
	_update_visibility(current, max_val)

func _update_label(current: float, max_val: float) -> void:
	if label:
		label.text = "%d/%d" % [int(current), int(max_val)]

func _update_visibility(current: float, max_val: float) -> void:
	if hide_when_full:
		visible = current < max_val

func _find_progress_bar() -> Range:
	for child in get_children():
		if child is Range:
			return child
	return null

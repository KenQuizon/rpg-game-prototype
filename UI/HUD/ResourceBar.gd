extends Control
class_name ResourceBar

@export var resource_type: ResourceType.Id = ResourceType.Id.MANA

@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var label: Label = $VBoxContainer/Label
@onready var icon: TextureRect = $VBoxContainer/Icon

var resource_component: ResourceComponent

func _ready() -> void:
	resource_component = CharacterRef.get_player_resources()

	if resource_component:
		var max_val := resource_component.get_max(resource_type)
		var current_val := resource_component.get_current(resource_type)

		progress_bar.max_value = max_val
		progress_bar.value = current_val
		label.text = "%d/%d" % [int(current_val), int(max_val)]

		resource_component.resource_changed.connect(_on_resource_changed)
		print("ResourceBar (%s) connected" % ResourceType.Id.keys()[resource_type])
	else:
		print("ERROR: Could not connect resource bar for %s" % ResourceType.Id.keys()[resource_type])

func _on_resource_changed(changed_type: int, _previous: float, current: float) -> void:
	"""Called when any resource changes"""
	if changed_type != resource_type:
		return

	progress_bar.max_value = resource_component.get_max(resource_type)
	progress_bar.value = current
	label.text = "%d/%d" % [int(current), int(progress_bar.max_value)]

extends Control
class_name ResourceBar

@export var resource_type: String = "mana"  # "mana", "stamina", etc.

@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var label: Label = $VBoxContainer/Label
@onready var icon: TextureRect = $VBoxContainer/Icon

var resource_component: Node

func _ready() -> void:
	resource_component = CharacterRef.get_player_skills()
	
	if resource_component and resource_component.has_method("get_resource_current"):
		# Initial setup
		var max_val = resource_component.get_resource_max(resource_type)
		var current_val = resource_component.get_resource_current(resource_type)
		
		progress_bar.max_value = max_val
		progress_bar.value = current_val
		label.text = "%d/%d" % [int(current_val), int(max_val)]
		
		# Listen to changes
		resource_component.resource_changed.connect(_on_resource_changed)
		print("ResourceBar (%s) connected" % resource_type)
	else:
		print("ERROR: Could not connect resource bar for %s" % resource_type)

func _on_resource_changed(resource_name: String, current: float, max_value: float) -> void:
	"""Called when any resource changes"""
	if resource_name != resource_type:
		return
	
	progress_bar.max_value = max_value
	progress_bar.value = current
	label.text = "%d/%d" % [int(current), int(max_value)]

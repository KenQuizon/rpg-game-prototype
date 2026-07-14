extends PanelContainer
class_name ItemStatPanel

@onready var name_label: Label = $VBox/Name
@onready var description_label: Label = $VBox/Description
@onready var stats_label: Label = $VBox/Stats

func _ready() -> void:
	visible = false

func show_item_info(item_name: String, description: String, stat_lines: PackedStringArray) -> void:
	visible = true
	name_label.text = item_name
	description_label.text = description
	stats_label.text = "\n".join(stat_lines)

func hide_info() -> void:
	visible = false

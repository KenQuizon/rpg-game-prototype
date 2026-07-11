extends Control
class_name TooltipManager

var tooltip_label: Label
var current_tooltip: String = ""
var hover_timer: Timer

func _ready() -> void:
	tooltip_label = Label.new()
	tooltip_label.add_theme_stylebox_override("normal", StyleBoxFlat.new())
	add_child(tooltip_label)
	tooltip_label.visible = false

func show_tooltip(text: String, position: Vector2) -> void:
	current_tooltip = text
	tooltip_label.text = text
	tooltip_label.position = position + Vector2(10, 10)
	tooltip_label.visible = true

func hide_tooltip() -> void:
	tooltip_label.visible = false
	current_tooltip = ""

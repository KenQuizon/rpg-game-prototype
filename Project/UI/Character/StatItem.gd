extends PanelContainer
class_name StatItem

@onready var stat_name: Label = $HBoxContainer/Name
@onready var stat_value: Label = $HBoxContainer/Value
@onready var modifier_label: Label = $HBoxContainer/Modifier

func set_stat(name: String, value: float, modifier: float = 0.0) -> void:
	stat_name.text = name.to_pascal_case()
	stat_value.text = str(int(value))
	
	if modifier != 0:
		modifier_label.text = "+%d" % int(modifier) if modifier > 0 else "%d" % int(modifier)
		modifier_label.add_theme_color_override("font_color", Color.GREEN if modifier > 0 else Color.RED)

extends PanelContainer
class_name InteractionRowUI

@export var glyph_text: String = "F"

@onready var glyph_label: Label = $HBoxContainer/InteractButton/Glyph
@onready var icon_rect: TextureRect = $HBoxContainer/Icon
@onready var name_label: Label = $HBoxContainer/NameLabel


func set_data(info: InteractableInfo) -> void:
	name_label.text = info.label
	icon_rect.texture = info.icon
	icon_rect.visible = info.icon != null


func set_selected(is_selected: bool) -> void:

	glyph_label.text = glyph_text if is_selected else ""

	modulate = Color(1, 1, 1, 1) if is_selected else Color(1, 1, 1, 0.55)
	name_label.add_theme_font_size_override("font_size", 20 if is_selected else 16)

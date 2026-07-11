extends Label
class_name FeedbackItem

var feedback_type: String

func set_message(message: String, type: String = "default") -> void:
	text = message
	feedback_type = type
	
	match type:
		"miss":
			add_theme_color_override("font_color", Color.GRAY)
		"blocked":
			add_theme_color_override("font_color", Color.BLUE)
		"resisted":
			add_theme_color_override("font_color", Color.PURPLE)
		"ability":
			add_theme_color_override("font_color", Color.YELLOW)
		"cooldown":
			add_theme_color_override("font_color", Color.RED)
	
	animate_out()

func animate_out() -> void:
	var tween = create_tween()
	await tween.tween_property(self, "modulate:a", 0.0, 2.0)
	queue_free()

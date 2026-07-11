extends Label
class_name DamageNumber

var damage: float
var is_critical: bool = false

func _ready() -> void:
	# Random offset
	position.x += randf_range(-20, 20)
	
	# Color and size based on type
	if is_critical:
		add_theme_color_override("font_color", Color.RED)
		add_theme_font_size_override("font_size", 32)
		text = "CRIT %d" % int(damage)
	else:
		add_theme_color_override("font_color", Color.WHITE)
		add_theme_font_size_override("font_size", 24)
		text = str(int(damage))
	
	animate()

func animate() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move upward
	tween.tween_property(self, "position:y", position.y - 60, 1.0)
	
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	
	await tween.finished
	queue_free()

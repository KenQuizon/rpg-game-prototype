extends Label
class_name DamageNumber

var damage: float
var is_critical: bool = false

func setup(damage_value: float, critical: bool) -> void:
	damage = damage_value
	is_critical = critical
	position.x += randf_range(-20, 20)
	modulate.a = 1.0

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
	tween.tween_property(self, "position:y", position.y - 60, 1.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	queue_free()

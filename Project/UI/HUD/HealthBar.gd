extends Control
class_name HealthBar

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var damage_bar: ProgressBar = $DamageBar
@onready var label: Label = $ProgressBar/Label
@onready var damage_timer: Timer = $DamageTimer

var health_component: HealthComponent

func _ready() -> void:
	health_component = CharacterRef.get_player_health()

	if health_component:
		var max_health := health_component.max_health
		var current := health_component.current_health

		progress_bar.max_value = max_health
		progress_bar.value = current

		damage_bar.max_value = max_health
		damage_bar.value = current

		label.text = "%d/%d" % [int(current), int(max_health)]

		health_component.health_changed.connect(_on_health_changed)
		health_component.died.connect(_on_died)

		damage_timer.timeout.connect(_on_damage_timer_timeout)
	else:
		print("ERROR: Could not find player health component")

func _on_health_changed(previous: float, current: float) -> void:

	var max_health := health_component.max_health
	progress_bar.max_value = max_health
	damage_bar.max_value = max_health

	# Health bar snaps immediately now — the damage bar underneath is
	# what shows "how much did I just lose."
	progress_bar.value = current

	label.text = "%d/%d" % [int(current), int(max_health)]

	var health_percent := current / max_health if max_health > 0.0 else 0.0
	if health_percent <= 0.25:
		progress_bar.self_modulate = Color.RED
	elif health_percent <= 0.5:
		progress_bar.self_modulate = Color.ORANGE
	else:
		progress_bar.self_modulate = Color.WHITE

	if current < previous:
		# Damage taken — leave the damage bar at its current (higher)
		# value and (re)start the catch-up timer. Repeated hits during a
		# combo keep restarting it, so it only starts closing the gap
		# once the flurry actually stops — same effect as the reference.
		damage_timer.start()
	else:
		# Healing — no lag, catch up immediately.
		damage_bar.value = current

func _on_damage_timer_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(damage_bar, "value", health_component.current_health, 0.3)

func _on_died() -> void:
	label.text = "DEAD"
	progress_bar.self_modulate = Color.GRAY
	damage_bar.value = 0.0
	UIEvents.character_died.emit()

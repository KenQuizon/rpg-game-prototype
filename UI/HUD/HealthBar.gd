extends Control
class_name HealthBar

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $ProgressBar/Label

var health_component: HealthComponent
var tween: Tween

func _ready() -> void:
	health_component = CharacterRef.get_player_health()

	if health_component:
		progress_bar.max_value = health_component.max_health
		progress_bar.value = health_component.current_health
		label.text = "%d/%d" % [int(health_component.current_health), int(health_component.max_health)]

		health_component.health_changed.connect(_on_health_changed)
		health_component.died.connect(_on_died)
		print("HealthBar connected to player health")
	else:
		print("ERROR: Could not find player health component")

func _on_health_changed(_previous: float, current: float) -> void:
	"""Called when player health changes"""
	var max_health := health_component.max_health
	progress_bar.max_value = max_health

	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(progress_bar, "value", current, 0.5)

	label.text = "%d/%d" % [int(current), int(max_health)]

	var health_percent := current / max_health if max_health > 0.0 else 0.0
	if health_percent <= 0.25:
		progress_bar.self_modulate = Color.RED
	elif health_percent <= 0.5:
		progress_bar.self_modulate = Color.ORANGE
	else:
		progress_bar.self_modulate = Color.WHITE

func _on_died() -> void:
	"""Called when player dies"""
	label.text = "DEAD"
	progress_bar.self_modulate = Color.GRAY
	UIEvents.character_died.emit()

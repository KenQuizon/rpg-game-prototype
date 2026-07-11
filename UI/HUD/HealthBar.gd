extends Control
class_name HealthBar

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $ProgressBar/Label

var health_component: Node
var tween: Tween

func _ready() -> void:
	# Connect to player health component
	health_component = CharacterRef.get_player_health()
	
	if health_component:
		# Initial setup
		progress_bar.max_value = health_component.max_health
		progress_bar.value = health_component.current_health
		label.text = "%d/%d" % [int(health_component.current_health), int(health_component.max_health)]
		
		# Listen to changes
		health_component.health_changed.connect(_on_health_changed)
		health_component.died.connect(_on_died)
		print("HealthBar connected to player health")
	else:
		print("ERROR: Could not find player health component")

func _on_health_changed(current: float, max_health: float) -> void:
	"""Called when player health changes"""
	progress_bar.max_value = max_health
	
	# Animate bar smoothly
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(progress_bar, "value", current, 0.5)
	
	# Update label
	label.text = "%d/%d" % [int(current), int(max_health)]
	
	# Change color based on health percentage
	var health_percent = current / max_health
	if health_percent <= 0.25:
		progress_bar.self_modulate = Color.RED
	elif health_percent <= 0.5:
		progress_bar.self_modulate = Color.ORANGE
	else:
		progress_bar.self_modulate = Color.WHITE
	
	# Emit global event
	UIEvents.damage_applied.emit(max_health - current, false)

func _on_died() -> void:
	"""Called when player dies"""
	label.text = "DEAD"
	progress_bar.self_modulate = Color.GRAY
	UIEvents.character_died.emit()

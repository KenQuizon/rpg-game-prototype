extends Control
class_name EnemyHealthBar

const HEAD_HEIGHT_OFFSET: float = 2.5  # tune to sit just above the model's head

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var damage_bar: ProgressBar = $DamageBar
@onready var damage_timer: Timer = $DamageTimer

var _character: Character
var _health: HealthComponent

func _ready() -> void:

	visible = false

	# Deferred because this node's _ready() runs before its own parent's
	# (Godot readies children bottom-up) — the parent Character hasn't
	# built context/components yet at this exact point. call_deferred
	# pushes this to right after the current _ready() batch finishes,
	# by which point the parent is guaranteed fully initialized.
	call_deferred("_bind_to_character")

func _bind_to_character() -> void:

	_character = get_parent() as Character

	if _character == null or _character.context == null:
		return

	_health = _character.context.health

	if _health == null:
		return

	progress_bar.max_value = _health.max_health
	progress_bar.value = _health.current_health

	damage_bar.max_value = _health.max_health
	damage_bar.value = _health.current_health

	_health.health_changed.connect(_on_health_changed)
	_health.died.connect(_on_died)

	damage_timer.timeout.connect(_on_damage_timer_timeout)

func _process(_delta: float) -> void:

	if _character == null or not is_instance_valid(_character):
		visible = false
		return

	var camera := get_viewport().get_camera_3d()

	if camera == null:
		return

	var world_pos := _character.global_position + Vector3.UP * HEAD_HEIGHT_OFFSET
	var screen_pos := camera.unproject_position(world_pos)

	global_position = screen_pos - size * 0.5

func _on_health_changed(previous: float, current: float) -> void:

	var max_health := _health.max_health
	progress_bar.max_value = max_health
	damage_bar.max_value = max_health

	progress_bar.value = current

	if current < previous:
		# Only damage reveals the bar — and nothing here ever sets
		# visible back to false, so full-health healing later leaves it
		# exactly where it is, per your spec.
		visible = true
		damage_timer.start()
	else:
		damage_bar.value = current

func _on_damage_timer_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(damage_bar, "value", _health.current_health, 0.3)

func _on_died() -> void:
	visible = false

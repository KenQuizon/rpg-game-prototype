extends Control
class_name CastBar

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label
@onready var icon: TextureRect = $Icon

var current_action: ActionExecution
var total_duration: float

func _ready() -> void:
	visible = false
	set_process(false)

func start_cast(action: ActionExecution, duration: float, ability_icon: Texture2D = null) -> void:
	current_action = action
	total_duration = duration
	progress_bar.max_value = duration
	progress_bar.value = 0
	
	label.text = action.definition.name if action.definition else "Casting..."
	if ability_icon:
		icon.texture = ability_icon
	
	visible = true
	set_process(true)

func _process(delta: float) -> void:
	if not current_action:
		return
	
	var elapsed = Time.get_ticks_msec() / 1000.0 - current_action.created_at / 1000.0
	progress_bar.value = elapsed
	
	if elapsed >= total_duration:
		finish_cast()

func finish_cast() -> void:
	visible = false
	set_process(false)
	current_action = null

func cancel_cast() -> void:
	finish_cast()

extends Control
class_name CastBar

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label
@onready var icon: TextureRect = $Icon

var _action_component: ActionComponent
var _current_execution: ActionExecution

func _ready() -> void:
	visible = false
	set_process(false)

	var player := CharacterRef.get_player()
	if player and player.context:
		_action_component = player.context.action
		if _action_component:
			_action_component.execution_started.connect(_on_execution_started)
			_action_component.execution_finished.connect(_on_execution_finished)

func _on_execution_started(execution: ActionExecution) -> void:
	var definition := execution.request.definition as ActionDefinition
	if definition == null or definition.duration <= 0.0:
		return   # instant actions have nothing to show a bar for

	_current_execution = execution
	progress_bar.max_value = definition.duration
	progress_bar.value = 0.0
	label.text = definition.display_name if not definition.display_name.is_empty() else "Casting..."

	visible = true
	set_process(true)

func _on_execution_finished(execution: ActionExecution) -> void:
	if execution == _current_execution:
		_finish()

func _process(_delta: float) -> void:
	if _current_execution == null:
		return
	progress_bar.value = _current_execution.runtime.elapsed_time
	if _current_execution.runtime.elapsed_time >= progress_bar.max_value:
		_finish()

func _finish() -> void:
	visible = false
	set_process(false)
	_current_execution = null

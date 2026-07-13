extends Control
class_name ChargeBar

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label

func _ready() -> void:
	visible = false

	UIEvents.charge_started.connect(_on_charge_started)
	UIEvents.charge_updated.connect(_on_charge_updated)
	UIEvents.charge_released.connect(_on_charge_released)

func _on_charge_started() -> void:
	visible = true
	progress_bar.value = 0.0
	label.text = "0%"

func _on_charge_updated(percent: float) -> void:
	progress_bar.value = percent * 100.0
	label.text = "%d%%" % int(percent * 100.0)
	progress_bar.self_modulate = Color.ORANGE if percent >= 1.0 else Color.WHITE

func _on_charge_released(_percent: float) -> void:
	visible = false

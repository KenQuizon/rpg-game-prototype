extends PanelContainer
class_name StatusEffectIndicator

@onready var icon: TextureRect = $VBoxContainer/Icon
@onready var label: Label = $VBoxContainer/Label
@onready var stack_label: Label = $VBoxContainer/StackLabel

var status_effect: StatusEffectInstance

func set_status_effect(effect: StatusEffectInstance) -> void:
	status_effect = effect
	if effect == null or effect.data == null:
		return

	icon.texture = effect.data.icon
	label.text = effect.data.display_name
	stack_label.text = "x%d" % effect.stacks if effect.stacks > 1 else ""

	tooltip_text = "%s\n%s\n%.1fs" % [
		effect.data.display_name,
		effect.data.description,
		effect.remaining_duration
	]

func _process(_delta: float) -> void:
	if status_effect and status_effect.remaining_duration > 0:
		label.text = "%.1f" % status_effect.remaining_duration

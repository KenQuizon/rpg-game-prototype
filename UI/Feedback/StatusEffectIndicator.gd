extends PanelContainer
class_name StatusEffectIndicator

@onready var icon: TextureRect = $VBoxContainer/Icon
@onready var label: Label = $VBoxContainer/Label
@onready var stack_label: Label = $VBoxContainer/StackLabel

var status_effect: StatusEffectInstance

func _ready() -> void:
	set_process(true)

func set_status_effect(effect: StatusEffectInstance) -> void:
	"""Display a status effect"""
	status_effect = effect
	
	if effect:
		icon.texture = effect.status_data.icon if effect.status_data.has_meta("icon") else null
		label.text = effect.status_data.name
		stack_label.text = "x%d" % effect.stack_count if effect.stack_count > 1 else ""
		
		tooltip_text = "[b]%s[/b]\n%s\n%.1fs" % [
			effect.status_data.name,
			effect.status_data.get_meta("description", ""),
			effect.remaining_duration
		]

func _process(delta: float) -> void:
	if status_effect and status_effect.remaining_duration > 0:
		label.text = "%.1f" % status_effect.remaining_duration

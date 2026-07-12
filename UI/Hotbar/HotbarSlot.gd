extends PanelContainer
class_name HotbarSlot

signal skill_activated(skill: SkillDefinition)

@onready var icon: TextureRect = $VBoxContainer/Icon
@onready var key_label: Label = $VBoxContainer/KeyLabel
@onready var cooldown_label: Label = $CooldownLabel

var skill: SkillDefinition
var hotkey: String = ""

var is_on_cooldown: bool = false
var cooldown_remaining: float = 0.0

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	set_process(true)

func set_skill(new_skill: SkillDefinition, key: String = "") -> void:
	skill = new_skill
	hotkey = key
	key_label.text = key.to_upper()
	icon.texture = skill.icon if skill else null

func start_cooldown(duration: float) -> void:
	is_on_cooldown = true
	cooldown_remaining = duration
	modulate = Color.GRAY

func clear_cooldown() -> void:
	is_on_cooldown = false
	cooldown_remaining = 0.0
	modulate = Color.WHITE
	cooldown_label.text = ""

func _process(delta: float) -> void:
	if is_on_cooldown:
		cooldown_remaining -= delta

		if cooldown_remaining <= 0:
			clear_cooldown()
		else:
			cooldown_label.text = "%.1f" % cooldown_remaining if cooldown_remaining < 10 else ""

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		activate_skill()

func activate_skill() -> void:
	if skill and not is_on_cooldown:
		skill_activated.emit(skill)

extends PanelContainer
class_name HotbarSlot

signal skill_activated(skill: SkillDefinition)

@onready var icon: TextureRect = $Icon
@onready var key_label: Label = $KeyLabel
@onready var cooldown_label: Label = $CooldownLabel
@onready var cooldown_overlay: TextureProgressBar = $CooldownOverlay

var skill: SkillDefinition
var hotkey: String = ""

var is_on_cooldown: bool = false
var cooldown_remaining: float = 0.0
var cooldown_duration: float = 0.0

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	set_process(true)

	_setup_cooldown_overlay()

# Generates a plain white 4x4 texture at runtime and assigns it as the
# TextureProgressBar's fill texture — the radial wipe just needs *a*
# texture to mask with, not anything from your art set, so this keeps
# the cooldown visual independent of whatever icon atlas you're using.
func _setup_cooldown_overlay() -> void:

	if cooldown_overlay == null:
		return

	var image := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)

	cooldown_overlay.texture_progress = ImageTexture.create_from_image(image)
	cooldown_overlay.min_value = 0.0
	cooldown_overlay.max_value = 1.0
	cooldown_overlay.value = 0.0

func set_skill(new_skill: SkillDefinition, key: String = "") -> void:
	skill = new_skill
	hotkey = key
	key_label.text = key.to_upper()
	icon.texture = skill.icon if skill else null

func start_cooldown(duration: float) -> void:
	is_on_cooldown = true
	cooldown_remaining = duration
	cooldown_duration = duration
	modulate = Color.GRAY

func clear_cooldown() -> void:
	is_on_cooldown = false
	cooldown_remaining = 0.0
	cooldown_duration = 0.0
	modulate = Color.WHITE
	cooldown_label.text = ""

	if cooldown_overlay != null:
		cooldown_overlay.value = 0.0

func _process(delta: float) -> void:
	if is_on_cooldown:
		cooldown_remaining -= delta

		if cooldown_remaining <= 0:
			clear_cooldown()
		else:
			cooldown_label.text = "%.1f" % cooldown_remaining if cooldown_remaining < 10 else ""

			if cooldown_overlay != null and cooldown_duration > 0.0:
				# Counts DOWN from full (1.0) to empty (0.0) as the
				# cooldown elapses — the radial wipe shrinks away to
				# reveal the icon right as the skill becomes castable
				# again, matching the text/tint clearing at the same
				# moment in clear_cooldown().
				cooldown_overlay.value = cooldown_remaining / cooldown_duration

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		activate_skill()

func activate_skill() -> void:
	if skill and not is_on_cooldown:
		skill_activated.emit(skill)

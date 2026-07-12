extends HBoxContainer
class_name Hotbar

@export var hotbar_slot_scene: PackedScene
@export var slot_count: int = 6
@export var hotkeys: PackedStringArray = ["1", "2", "3", "4", "5", "6"]

var slots: Array[HotbarSlot] = []
var character: Character

func _ready() -> void:
	self.custom_minimum_size.y = 80

	character = CharacterRef.get_player()

	if character and character.context and character.context.cooldowns:
		character.context.cooldowns.cooldown_started.connect(_on_cooldown_started)
		character.context.cooldowns.cooldown_finished.connect(_on_cooldown_finished)

	for i in range(slot_count):
		var slot = hotbar_slot_scene.instantiate() as HotbarSlot
		slot.set_skill(null, hotkeys[i] if i < hotkeys.size() else "")
		slot.skill_activated.connect(_on_skill_activated)
		add_child(slot)
		slots.append(slot)

	_setup_hotkey_inputs()
	print("Hotbar initialized with %d slots" % slot_count)

func assign_skill(slot_index: int, skill: SkillDefinition) -> void:
	if slot_index < slots.size():
		slots[slot_index].set_skill(skill, hotkeys[slot_index])

func _on_skill_activated(skill: SkillDefinition) -> void:
	if character == null or character.context == null:
		return

	var command := CastSkillCommand.new()
	command.initialize(character.context)
	command.skill_id = skill.id

	if command.execute():
		UIEvents.skill_used.emit(String(skill.id))

func _on_cooldown_started(group: StringName, duration: float) -> void:
	for slot in slots:
		if slot.skill and slot.skill.cooldown_group == group:
			slot.start_cooldown(duration)

func _on_cooldown_finished(group: StringName) -> void:
	for slot in slots:
		if slot.skill and slot.skill.cooldown_group == group:
			slot.clear_cooldown()

func _unhandled_input(event: InputEvent) -> void:
	for i in range(slots.size()):
		if event.is_action_pressed("hotbar_%d" % i):
			slots[i].activate_skill()

func _setup_hotkey_inputs() -> void:
	for i in range(hotkeys.size()):
		var action_name = "hotbar_%d" % i
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			var event = InputEventKey.new()
			event.keycode = OS.find_keycode_from_string(hotkeys[i])
			InputMap.action_add_event(action_name, event)

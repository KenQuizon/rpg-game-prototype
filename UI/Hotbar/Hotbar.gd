extends HBoxContainer
class_name Hotbar

@export var hotbar_slot_scene: PackedScene
@export var slot_count: int = 6
@export var hotkeys: PackedStringArray = ["1", "2", "3", "4", "5", "6"]

var slots: Array[HotbarSlot] = []
var character: Character
var skill_component: Node

func _ready() -> void:
	self.custom_minimum_size.y = 80
	
	character = CharacterRef.get_player()
	
	if character and character.has_method("get_character_skills"):
		skill_component = character.get_character_skills()
		skill_component.cooldown_updated.connect(_on_cooldown_updated)
	
	# Create hotbar slots
	for i in range(slot_count):
		var slot = hotbar_slot_scene.instantiate() as HotbarSlot
		slot.set_skill(null, hotkeys[i] if i < hotkeys.size() else "")
		slot.skill_activated.connect(_on_skill_activated)
		add_child(slot)
		slots.append(slot)
	
	# Setup hotkey input
	_setup_hotkey_inputs()
	print("Hotbar initialized with %d slots" % slot_count)

func assign_skill(slot_index: int, skill: SkillDefinition) -> void:
	"""Assign a skill to a hotbar slot"""
	if slot_index < slots.size():
		slots[slot_index].set_skill(skill, hotkeys[slot_index])

func _on_skill_activated(skill: SkillDefinition) -> void:
	"""Player activated a skill"""
	if skill_component:
		skill_component.use_skill(skill)
		UIEvents.skill_used.emit(skill.name)

func _on_cooldown_updated(skill_id: String, remaining: float, total: float) -> void:
	"""Update cooldown display"""
	for slot in slots:
		if slot.skill and slot.skill.name == skill_id:
			slot.start_cooldown(remaining)

func _setup_hotkey_inputs() -> void:
	"""Setup input map for hotkeys"""
	for i in range(hotkeys.size()):
		var action_name = "hotbar_%d" % i
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			var event = InputEventKey.new()
			event.keycode = OS.find_keycode_from_string(hotkeys[i])
			InputMap.action_add_event(action_name, event)

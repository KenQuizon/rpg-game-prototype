extends CanvasLayer
class_name HUD

#==============================================================================
# Cached Nodes
#==============================================================================

@onready var health_bar: ProgressBar = $Root/VitalsPanel/HealthBar
@onready var mana_bar: ProgressBar = $Root/VitalsPanel/ManaBar
@onready var stamina_bar: ProgressBar = $Root/VitalsPanel/StaminaBar

@onready var fireball_cooldown: Control = $Root/CooldownPanel/FireballCooldown
@onready var fireball_label: Label = $Root/CooldownPanel/FireballCooldown/CooldownLabel

@onready var inventory_panel: VBoxContainer = $Root/InventoryPanel

#==============================================================================
# Runtime
#==============================================================================

var _character: Character
var _context: CharacterContext

var _watching_cooldown: StringName = &""

#==============================================================================
# Public API
#==============================================================================
# Called once by World.gd after the player Character is ready — the HUD
# has no knowledge of Character until bound, same "wire it from outside"
# pattern CameraRig.set_target() already uses.

func bind_to_character(character: Character) -> void:

	_character = character
	_context = character.context

	if _context.health != null:
		_context.health.health_changed.connect(_on_health_changed)
		_update_health(_context.health.current_health, _context.health.max_health)

	if _context.resources != null:
		_context.resources.resource_changed.connect(_on_resource_changed)
		_update_resource(ResourceType.Id.MANA, _context.resources.get_current(ResourceType.Id.MANA), _context.resources.get_max(ResourceType.Id.MANA))
		_update_resource(ResourceType.Id.STAMINA, _context.resources.get_current(ResourceType.Id.STAMINA), _context.resources.get_max(ResourceType.Id.STAMINA))

	if _context.cooldowns != null:
		_context.cooldowns.cooldown_started.connect(_on_cooldown_started)
		_context.cooldowns.cooldown_finished.connect(_on_cooldown_finished)

	if _context.inventory != null:
		_context.inventory.inventory_changed.connect(_rebuild_inventory_panel)
		_rebuild_inventory_panel()

	fireball_cooldown.visible = false

#==============================================================================
# Vitals
#==============================================================================

func _on_health_changed(_previous: float, current: float) -> void:
	_update_health(current, _context.health.max_health)

func _update_health(current: float, max_value: float) -> void:
	health_bar.max_value = max_value
	health_bar.value = current

func _on_resource_changed(resource_type: int, _previous: float, current: float) -> void:
	_update_resource(resource_type, current, _context.resources.get_max(resource_type))

func _update_resource(resource_type: int, current: float, max_value: float) -> void:

	match resource_type:

		ResourceType.Id.MANA:
			mana_bar.max_value = max_value
			mana_bar.value = current

		ResourceType.Id.STAMINA:
			stamina_bar.max_value = max_value
			stamina_bar.value = current

#==============================================================================
# Cooldown
#==============================================================================
# Single hardcoded indicator for `fireball` for now — a real hotbar (N
# skill slots, each bound to whichever skill occupies it) is loadout UI
# that depends on a skill-selection system that doesn't exist yet. This
# proves the signal wiring end-to-end without building that speculatively.

func _on_cooldown_started(group: StringName, _duration: float) -> void:

	if group != &"fireball":
		return

	_watching_cooldown = group
	fireball_cooldown.visible = true

func _on_cooldown_finished(group: StringName) -> void:

	if group != _watching_cooldown:
		return

	_watching_cooldown = &""
	fireball_cooldown.visible = false

func _process(_delta: float) -> void:

	if _watching_cooldown == &"" or _context == null or _context.cooldowns == null:
		return

	var remaining := _context.cooldowns.get_remaining(_watching_cooldown)

	fireball_label.text = "%.1f" % remaining

#==============================================================================
# Inventory
#==============================================================================

func _rebuild_inventory_panel() -> void:

	for child in inventory_panel.get_children():
		child.queue_free()

	if _context.inventory == null:
		return

	for slot in _context.inventory.get_all_slots():

		var button := Button.new()
		button.text = "%s x%d" % [slot.item.display_name, slot.quantity]
		button.pressed.connect(_on_item_button_pressed.bind(slot.item))

		inventory_panel.add_child(button)

func _on_item_button_pressed(item: Resource) -> void:

	if item is EquipmentProfile:

		if _context.inventory.remove_item(item, 1):
			_context.equipment.equip(item as EquipmentProfile)

	elif item is ItemDefinition and (item as ItemDefinition).consumable:

		# No consumable-effect system yet (potion healing, buffs, etc.) —
		# this just removes the item to prove the click-to-use path works.
		# A real effect hook is its own small system, not HUD work.
		_context.inventory.remove_item(item, 1)
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		inventory_panel.visible = not inventory_panel.visible

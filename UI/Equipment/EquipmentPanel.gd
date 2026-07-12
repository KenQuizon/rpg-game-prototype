extends BaseUIPanel
class_name EquipmentPanel

@onready var equipment_slots: Dictionary = {}
@onready var stat_bonuses: Label = $VBoxContainer/StatBonuses
@onready var total_armor: Label = $VBoxContainer/Armor

@export var equipment_slot_scene: PackedScene

@export var slot_positions: Dictionary = {
	EquipmentSlotType.Id.HEAD: Vector2(200, 50),
	EquipmentSlotType.Id.CHEST: Vector2(200, 150),
	EquipmentSlotType.Id.HANDS: Vector2(100, 150),
	EquipmentSlotType.Id.LEGS: Vector2(200, 250),
	EquipmentSlotType.Id.FEET: Vector2(200, 350),
	EquipmentSlotType.Id.RING_1: Vector2(100, 250),
	EquipmentSlotType.Id.RING_2: Vector2(300, 250),
	EquipmentSlotType.Id.AMULET: Vector2(300, 150),
}

var character: Character
var equipment_component: EquipmentComponent
var selected_slot: EquipmentSlotType.Id

func _ready() -> void:
	super._ready()
	character = CharacterRef.get_player()

	if character and character.context and character.context.equipment:
		equipment_component = character.context.equipment
		equipment_component.equipment_equipped.connect(_on_equipment_changed)
		equipment_component.equipment_unequipped.connect(_on_equipment_changed)

		for slot in slot_positions.keys():
			var slot_ui = equipment_slot_scene.instantiate() as EquipmentSlotUI
			slot_ui.slot = slot
			slot_ui.slot_selected.connect(func(): _on_slot_selected(slot))
			add_child(slot_ui)
			slot_ui.position = slot_positions[slot]
			equipment_slots[slot] = slot_ui

		_update_equipment_display()

func _on_slot_selected(slot: EquipmentSlotType.Id) -> void:
	selected_slot = slot

func _on_equipment_changed(_slot: int, _profile: EquipmentProfile) -> void:
	_update_equipment_display()

func _update_equipment_display() -> void:
	for slot in equipment_slots.keys():
		equipment_slots[slot].set_equipment(equipment_component.get_equipped(slot))

	_update_stat_display()

func _update_stat_display() -> void:
	var stat_totals: Dictionary = {}

	for slot in slot_positions.keys():
		var profile := equipment_component.get_equipped(slot)
		if profile == null:
			continue

		for entry: StatModifierEntry in profile.stat_modifiers:
			stat_totals[entry.stat] = stat_totals.get(entry.stat, 0.0) + entry.value

	var lines: PackedStringArray = []
	for stat in stat_totals.keys():
		lines.append("%s: +%d" % [StatType.Id.keys()[stat], int(stat_totals[stat])])

	stat_bonuses.text = "Stats: %s" % ("\n".join(lines) if not lines.is_empty() else "None")
	total_armor.text = "Defense: +%d" % int(stat_totals.get(StatType.Id.DEFENSE, 0.0))

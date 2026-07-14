extends BaseUIPanel
class_name EquipmentPanel

@onready var equipment_slots: Dictionary = {}
@onready var stat_bonuses: Label = $VBoxContainer/StatBonuses
@onready var total_armor: Label = $VBoxContainer/Armor

@export var equipment_slot_scene: PackedScene
@export var weapon_slot_scene: PackedScene

@export var equipment_slot_order: Array[EquipmentSlotType.Id] = [
	EquipmentSlotType.Id.HEAD,
	EquipmentSlotType.Id.RING_1,
	EquipmentSlotType.Id.CHEST,
	EquipmentSlotType.Id.RING_2,
	EquipmentSlotType.Id.FEET,
]

var character: Character
var equipment_component: EquipmentComponent
var selected_slot: EquipmentSlotType.Id

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

	for slot in equipment_slots.keys():
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

func setup(bound_character: Character) -> void:
	character = bound_character
	if character == null or character.context == null:
		return

	equipment_component = character.context.equipment
	var weapon_component := character.context.weapon

	if equipment_component:
		equipment_component.equipment_equipped.connect(_on_equipment_changed)
		equipment_component.equipment_unequipped.connect(_on_equipment_changed)

		for slot in equipment_slot_order:
			var slot_ui = equipment_slot_scene.instantiate() as EquipmentSlotUI
			slot_ui.slot = slot
			slot_ui.slot_selected.connect(func(): _on_slot_selected(slot))
			add_child(slot_ui)
			equipment_slots[slot] = slot_ui

	if weapon_component:
		for hand in [WeaponSlot.Id.MAIN_HAND, WeaponSlot.Id.OFF_HAND]:
			var weapon_ui = weapon_slot_scene.instantiate() as WeaponSlotUI
			weapon_ui.slot = hand
			add_child(weapon_ui)
			weapon_ui.set_weapon(weapon_component.get_profile(hand))

	_update_equipment_display()

extends Control
class_name EquipmentPanel

signal item_info_requested(item_name: String, description: String, stat_lines: PackedStringArray)

@onready var slot_grid: GridContainer = $SlotGrid
@onready var stat_bonuses: Label = $VBoxContainer/StatBonuses
@onready var total_armor: Label = $VBoxContainer/Armor

var character: Character
var equipment_component: EquipmentComponent
var weapon_component: WeaponComponent
var equipment_slots: Dictionary = {}
var weapon_slots: Dictionary = {}

func setup(bound_character: Character) -> void:

	character = bound_character

	if character == null or character.context == null:
		return

	equipment_component = character.context.equipment
	weapon_component = character.context.weapon

	# Reads whatever slots you placed in SlotGrid yourself — nothing is
	# created in code. Each slot already knows what it is because you set
	# its "Slot" dropdown in the Inspector.
	for child in slot_grid.get_children():
		if child is EquipmentSlotUI:
			child.slot_selected.connect(func(): _on_equipment_slot_selected(child.slot))
			equipment_slots[child.slot] = child
		elif child is WeaponSlotUI:
			child.slot_selected.connect(func(): _on_weapon_slot_selected(child.slot))
			weapon_slots[child.slot] = child

	if equipment_component:
		equipment_component.equipment_equipped.connect(_on_equipment_changed)
		equipment_component.equipment_unequipped.connect(_on_equipment_changed)

	if weapon_component:
		weapon_component.weapon_equipped.connect(_on_weapon_changed)
		weapon_component.weapon_unequipped.connect(_on_weapon_changed)

	_update_equipment_display()
	_update_weapon_display()

func _on_equipment_slot_selected(slot: EquipmentSlotType.Id) -> void:

	var profile := equipment_component.get_equipped(slot) if equipment_component else null

	if profile == null:
		item_info_requested.emit(EquipmentSlotType.Id.keys()[slot].capitalize(), "Empty slot.", PackedStringArray())
		return

	var lines: PackedStringArray = []
	for entry: StatModifierEntry in profile.stat_modifiers:
		lines.append("%s: +%d" % [StatType.Id.keys()[entry.stat], int(entry.value)])

	item_info_requested.emit(profile.display_name, "", lines)

func _on_weapon_slot_selected(slot: WeaponSlot.Id) -> void:

	var profile := weapon_component.get_profile(slot) if weapon_component else null
	var label := "Main Hand" if slot == WeaponSlot.Id.MAIN_HAND else "Off Hand"

	if profile == null:
		item_info_requested.emit(label, "Empty slot.", PackedStringArray())
		return

	item_info_requested.emit(profile.display_name, "", PackedStringArray())

func _on_equipment_changed(_slot: int, _profile: EquipmentProfile) -> void:
	_update_equipment_display()

func _on_weapon_changed(_profile: WeaponProfile, _slot: WeaponSlot.Id) -> void:
	_update_weapon_display()

func _update_equipment_display() -> void:

	for slot in equipment_slots.keys():
		equipment_slots[slot].set_equipment(equipment_component.get_equipped(slot))

	_update_stat_display()

func _update_weapon_display() -> void:

	for slot in weapon_slots.keys():
		weapon_slots[slot].set_weapon(weapon_component.get_profile(slot))

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

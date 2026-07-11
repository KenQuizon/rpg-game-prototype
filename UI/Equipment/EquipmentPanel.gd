extends BaseUIPanel
class_name EquipmentPanel

@onready var equipment_slots: Dictionary = {}
@onready var stat_bonuses: Label = $VBoxContainer/StatBonuses
@onready var total_armor: Label = $VBoxContainer/Armor

@export var equipment_slot_scene: PackedScene
@export var slot_positions: Dictionary = {
	"head": Vector2(200, 50),
	"chest": Vector2(200, 150),
	"hands": Vector2(200, 250),
	"legs": Vector2(200, 350),
	"feet": Vector2(200, 450),
	"main_hand": Vector2(100, 250),
	"off_hand": Vector2(300, 250)
}

var character: Character
var equipment_component: Node
var selected_slot: String

func _ready() -> void:
	super._ready()
	character = get_tree().root.get_node("World/Player")
	
	if character and character.has_method("get_character_equipment"):
		equipment_component = character.get_character_equipment()
		equipment_component.equipment_changed.connect(_on_equipment_changed)
		
		# Create equipment slots UI
		for slot_name in slot_positions.keys():
			var slot_ui = equipment_slot_scene.instantiate() as EquipmentSlotUI
			slot_ui.position = slot_positions[slot_name]
			slot_ui.slot_name = slot_name
			slot_ui.slot_selected.connect(func(): _on_slot_selected(slot_name))
			add_child(slot_ui)
			equipment_slots[slot_name] = slot_ui
		
		_update_equipment_display()

func _on_slot_selected(slot_name: String) -> void:
	selected_slot = slot_name
	var equipped_item = equipment_component.get_equipped_item(slot_name)
	if equipped_item:
		# Show equipment details
		pass

func _on_equipment_changed() -> void:
	_update_equipment_display()

func _update_equipment_display() -> void:
	for slot_name in equipment_slots.keys():
		var equipped_item = equipment_component.get_equipped_item(slot_name)
		var slot_ui = equipment_slots[slot_name]
		slot_ui.set_equipment(equipped_item)
	
	_update_stat_display()

func _update_stat_display() -> void:
	var total_armor = 0.0
	var stat_mods = {}
	
	for equipped in equipment_component.equipped_items:
		# Sum up armor and stat bonuses
		pass
	
	stat_bonuses.text = "Stats: %s" % str(stat_mods)
	total_armor.text = "Armor: %.1f" % total_armor

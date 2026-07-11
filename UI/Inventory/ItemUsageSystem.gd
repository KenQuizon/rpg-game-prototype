extends Node
class_name ItemUsageSystem

var character: Character
var inventory_component: Node

func _ready() -> void:
	character = get_tree().root.get_node("World/Player")
	if character and character.has_method("get_character_inventory"):
		inventory_component = character.get_character_inventory()

func use_item(item: ItemDefinition) -> void:
	match item.get_meta("type", "consumable"):
		"consumable":
			_use_consumable(item)
		"equipment":
			_equip_item(item)
		"quest":
			_use_quest_item(item)

func _use_consumable(item: ItemDefinition) -> void:
	# Apply item effects
	var effects = item.get_meta("effects", [])
	for effect in effects:
		_apply_effect(effect)
	
	# Remove from inventory
	inventory_component.remove_item(item)

func _apply_effect(effect: Dictionary) -> void:
	match effect.get("type", ""):
		"heal":
			var health_comp = character.get_character_health()
			health_comp.heal(effect.get("amount", 0))
		"restore_resource":
			var resource_comp = character.get_character_resources()
			resource_comp.restore(effect.get("resource", "mana"), effect.get("amount", 0))

func _equip_item(item: ItemDefinition) -> void:
	var equipment_comp = character.get_character_equipment()
	equipment_comp.equip(item)

func _use_quest_item(item: ItemDefinition) -> void:
	# Trigger quest-related logic
	pass

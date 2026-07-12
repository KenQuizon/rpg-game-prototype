extends Node
class_name ItemUsageSystem

var character: Character
var inventory_component: InventoryComponent

func _ready() -> void:
	character = CharacterRef.get_player()
	if character and character.context and character.context.inventory:
		inventory_component = character.context.inventory

func use_item(item: ItemDefinition) -> void:
	if not item.consumable:
		return

	_apply_effects(item)
	inventory_component.remove_item(item, 1)

func _apply_effects(item: ItemDefinition) -> void:
	if item.heal_amount > 0.0 and character.context.health:
		character.context.health.heal(item.heal_amount)

	if item.restore_amount > 0.0 and character.context.resources:
		character.context.resources.restore(item.restore_resource_type, item.restore_amount)

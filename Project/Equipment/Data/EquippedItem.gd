extends RefCounted
class_name EquippedItem

var item: ItemDefinition

var payload: ItemPayload   # cached ArmorPayload or AccessoryPayload — see EquipmentComponent.equip()

var slot: int

func _init(
	p_item: ItemDefinition,
	p_payload: ItemPayload,
	p_slot: int
) -> void:

	item = p_item
	payload = p_payload
	slot = p_slot

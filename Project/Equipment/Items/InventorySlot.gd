extends RefCounted
class_name InventorySlot

var item: Resource
var quantity: int = 0

func _init(item_resource: Resource, item_quantity: int) -> void:
	item = item_resource
	quantity = item_quantity

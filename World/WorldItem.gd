extends StaticBody3D
class_name WorldItem

@export var item: Resource
@export var quantity: int = 1

func _ready() -> void:
	add_to_group("interactable")

func interact(interactor: Node) -> void:

	if item == null:
		return

	if not interactor.has_method("get_component"):
		return

	var inventory := interactor.get_component(InventoryComponent) as InventoryComponent

	if inventory == null:
		return

	if inventory.add_item(item, quantity):
		queue_free()

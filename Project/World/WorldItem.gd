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


# Duck-typed contract InteractionComponent.get_interactable_info() looks
# for — see InteractableInfo.gd. is_gatherable is left at its default
# (false) for now; Stage 3 promotes that flag onto ItemDefinition and
# this will read it from there instead of hardcoding it here.
func get_interact_info() -> InteractableInfo:

	var definition := item as ItemDefinition

	if definition == null:
		return InteractableInfo.new()

	var label := definition.display_name

	if quantity > 1:
		label = "%s x%d" % [definition.display_name, quantity]

	return InteractableInfo.new(label, definition.icon)

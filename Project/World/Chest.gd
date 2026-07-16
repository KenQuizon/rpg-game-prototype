extends RigidBody3D

@export var loot: Array[ItemDefinition] = []

func _ready():

	add_to_group(
		"interactable"
	)

func get_interact_info() -> InteractableInfo:
	return InteractableInfo.new("Open Chest")
	
func interact(
	interactor: Node
) -> void:

	# Same duck-typed access WorldItem.interact() already uses — Chest
	# doesn't need its own inventory lookup logic, it reuses the exact
	# same contract.
	if not interactor.has_method(
		"get_component"
	):
		return

	var inventory := interactor.get_component(
		InventoryComponent
	) as InventoryComponent

	if inventory == null:
		return

	for item in loot:
		inventory.add_item(item, 1)

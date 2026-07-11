extends Control
class_name ItemPickupUI

signal item_picked_up(item: ItemDefinition)

@export var pickup_distance: float = 5.0

var nearby_items: Array[WorldItem] = []
var inventory_component: Node

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	# Find nearby items
	var world = get_tree().root.get_node("World")
	if not world:
		return
	
	var player = world.get_node("Player")
	nearby_items.clear()
	
	for item in world.get_tree().get_nodes_in_group("items"):
		if item is WorldItem:
			var distance = player.global_position.distance_to(item.global_position)
			if distance <= pickup_distance:
				nearby_items.append(item)
	
	# Show pickup prompt if items nearby
	if nearby_items.size() > 0:
		show_pickup_prompt()

func show_pickup_prompt() -> void:
	# Display "Press E to pickup" UI
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and nearby_items.size() > 0:
		# Pickup first item
		var item = nearby_items[0]
		inventory_component.add_item(item.item_definition)
		item.queue_free()
		item_picked_up.emit(item.item_definition)

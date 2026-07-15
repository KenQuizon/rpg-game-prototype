extends Node3D
class_name WeaponInstance

var item: ItemDefinition

var _context: CharacterContext

@onready var hitbox: HitboxComponent = get_node_or_null("HitboxComponent")

func initialize(
	character_context: CharacterContext,
	weapon_item: ItemDefinition
) -> void:

	_context = character_context
	item = weapon_item

	_initialize_children()

func _initialize_children() -> void:

	if hitbox == null:
		return

	hitbox.initialize()

	hitbox.set_combat_owner(_context.combat)

func get_hitbox() -> HitboxComponent:
	return hitbox

func get_context() -> CharacterContext:
	return _context

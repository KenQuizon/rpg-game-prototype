extends Node3D
class_name WeaponInstance

#==============================================================================
# Runtime
#==============================================================================

var profile: WeaponProfile

var _context: CharacterContext

#==============================================================================
# Cached Nodes
#==============================================================================

@onready var hitbox: HitboxComponent = get_node_or_null("HitboxComponent")

#==============================================================================
# Initialization
#==============================================================================

func initialize(
	character_context: CharacterContext,
	weapon_profile: WeaponProfile
) -> void:

	_context = character_context
	profile = weapon_profile

	_initialize_children()

#==============================================================================
# Internal
#==============================================================================

# WeaponInstance.gd
func _initialize_children() -> void:

	print("hitbox =", hitbox)

	if hitbox == null:
		print("[WeaponInstance] hitbox is NULL")
		return

	hitbox.initialize()

	hitbox.set_combat_owner(_context.combat)

	print("[WeaponInstance] initialized")

#==============================================================================
# Public API
#==============================================================================

func get_hitbox() -> HitboxComponent:
	return hitbox


func get_context() -> CharacterContext:
	return _context

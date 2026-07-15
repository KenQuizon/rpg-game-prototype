extends ItemPayload
class_name WeaponPayload

#==============================================================================
# Identity
#==============================================================================

# Which hand this weapon equips into. Lives here (not on ItemDefinition)
# for the same reason ArmorPayload owns equipment_slot: it's identity info
# specific to the weapon category, not a generic item property.
@export var weapon_slot: WeaponSlot.Id = WeaponSlot.Id.MAIN_HAND

#==============================================================================
# Combat
#==============================================================================

@export var weapon_type: WeaponType.Id = WeaponType.Id.UNARMED

@export_range(0.0, 10000.0)
var base_damage: float = 10.0

@export_range(0.1, 10.0)
var attack_speed: float = 1.0

@export_range(0.1, 20.0)
var attack_range: float = 1.5

#==============================================================================
# Resources
#==============================================================================

@export var hitbox_scene: PackedScene

@export var weapon_scene: PackedScene

#==============================================================================
# Attack Set
#==============================================================================

@export var attack_set: AttackSet

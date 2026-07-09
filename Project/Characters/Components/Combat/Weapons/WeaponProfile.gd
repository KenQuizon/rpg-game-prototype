extends Resource
class_name WeaponProfile

#==============================================================================
# Identity
#==============================================================================

@export var display_name: String = ""

@export var weapon_type: WeaponType.Id = WeaponType.Id.UNARMED

#==============================================================================
# Combat
#==============================================================================

@export_range(0.0,10000.0)
var base_damage: float = 10.0

@export_range(0.1,10.0)
var attack_speed: float = 1.0

@export_range(0.1,20.0)
var attack_range: float = 1.5

#==============================================================================
# Resources
#==============================================================================

@export var hitbox_scene: PackedScene

#==============================================================================
# Weapon Scene
#==============================================================================

@export var weapon_scene: PackedScene

#==============================================================================
# Attack Set
#==============================================================================

@export var attack_set: AttackSet

#==============================================================================
# Future Expansion
#==============================================================================

# AnimationProfile override
# ComboSet
# ProjectileProfile
# SkillSet
# VFX Profile
# Audio Profile
# Attribute Requirements
# Durability

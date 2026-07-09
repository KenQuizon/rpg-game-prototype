extends RefCounted
class_name EquippedItem

#==============================================================================
# Data
#==============================================================================

# Exists so StatsComponent.remove_modifiers_from_source() can target exactly
# this equip instance, not the EquipmentProfile resource itself — the same
# profile Resource can be equipped in two slots at once (e.g. one RingProfile
# in both RING_1 and RING_2), and using the shared Resource as the modifier
# source would mean unequipping one slot strips both. Mirrors
# StatusEffectInstance wrapping StatusEffectData for the identical reason.

var profile: EquipmentProfile

var slot: int

func _init(
	p_profile: EquipmentProfile,
	p_slot: int
) -> void:

	profile = p_profile
	slot = p_slot

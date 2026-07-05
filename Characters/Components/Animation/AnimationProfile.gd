extends Resource
class_name AnimationProfile

#==============================================================================
# Animation Clips
#==============================================================================

@export var idle: StringName = &"Movement/Idle_B"
@export var walk: StringName = &"Movement/Walking_B"

@export var attack_primary: StringName = &"Combat/Melee_1H_Attack_Slice_Diagonal"
@export var hurt: StringName = &"Movement/Hit_B"
@export var death: StringName = &"Movement/Death_B"

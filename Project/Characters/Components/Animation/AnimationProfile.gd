extends Resource
class_name AnimationProfile

#==============================================================================
# Animation Clips
#==============================================================================

@export var idle: StringName = &"Movement/Idle_B"
@export var walk: StringName = &"Movement/Walking_B"
@export var dash: StringName = &"Movement/Dodge_Forward"
@export var sprint: StringName = &"Movement/Sprint_Loop"

@export var attack_primary: StringName = &"Combat/Melee_1H_Attack_Slice_Diagonal"
@export var hurt: StringName = &"Movement/Hit_B"
@export var death: StringName = &"Movement/Death_B"
@export var block_idle: StringName = &"Combat/Melee_Blocking"
@export var block_hit: StringName = &"Combat/Melee_Block_Hit"

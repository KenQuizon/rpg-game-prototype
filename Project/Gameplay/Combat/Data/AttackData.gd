extends Resource
class_name AttackData

#==============================================================================
# Damage
#==============================================================================

@export var damage: float = 10.0

@export var damage_type: DamageType.Id = DamageType.Id.PHYSICAL

#==============================================================================
# Critical
#==============================================================================

@export var critical_multiplier: float = 1.5

#==============================================================================
# Combat Rules
#==============================================================================

@export var can_be_blocked := true
@export var can_be_evaded := true
@export var can_stagger := true

#==============================================================================
# Stagger
#==============================================================================

# Poise damage this hit deals, separate from HP damage. 0.0 (default) means
# this attack never contributes to stagger even if can_stagger is true —
# both must be set for a hit to be able to break poise.
@export var stagger_damage: float = 0.0

# Status effect applied to the target only when this hit actually breaks
# their poise (see PoiseComponent). Leave null for a hit that can break
# poise but shouldn't apply any follow-up effect beyond the interrupt.
@export var stagger_effect: StatusEffectData

#==============================================================================
# Tags
#==============================================================================

@export var tags: Array[StringName] = [
	GameplayTags.MELEE
]

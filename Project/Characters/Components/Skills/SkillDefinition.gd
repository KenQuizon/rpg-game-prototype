extends ActionDefinition
class_name SkillDefinition

#==============================================================================
# Presentation
#==============================================================================

@export var cast_animation: StringName = &""

@export var effects: AttackEffects = AttackEffects.new()

#==============================================================================
# Timing
#==============================================================================

# Held after completion (FINISH_ACTION event, or the duration safety net)
# before the scheduler frees this cast's locks — the same recovery concept
# AttackTiming provides for attacks, without pulling in combo-specific
# fields (combo_open_time/combo_close_time) that don't apply to a skill.
@export var recovery_time: float = 0.15

#==============================================================================
# Optional — Not Yet Wired
#==============================================================================

# CAST_COMPLETE / SPAWN_PROJECTILE animation events exist in AnimationEvents
# but there is no handler or spawn-point convention yet (aim direction,
# spawn socket, target-lock). Left as authored-but-inert data rather than
# guessing at a spawn mechanism before a concrete skill needs one — same
# treatment AttackDefinition.projectile_scene already received.
@export var projectile_scene: PackedScene

@export var custom_events: Array[StringName] = []

#==============================================================================
# Notes
#==============================================================================

# Remember to set action_script to CastAction.gd, and to attach a
# CooldownPolicy and/or ResourceCostPolicy to `policies` (inherited from
# ActionDefinition) if this skill should have a cooldown or a mana/stamina
# cost — neither is automatic.

#==============================================================================
# Combat Data
#==============================================================================

@export var attack_data: AttackData = AttackData.new()

#==============================================================================
# Targeting
#==============================================================================

# Distance within which this skill can be cast at a target — deliberately
# separate from WeaponPayload.attack_range, since a skill's effective
# range (a melee smash vs. a fireball) doesn't have to match whatever
# weapon happens to be equipped. Used by PlayerController's skill-move
# flow and by CastAction to decide whether/who to face.
@export var skill_range: float = 6.0

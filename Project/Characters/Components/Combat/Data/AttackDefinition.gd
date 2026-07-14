extends ActionDefinition
class_name AttackDefinition

#==============================================================================
# Presentation
#==============================================================================

@export var animation: StringName = &""

@export var draw_animation: StringName = &""
@export var aim_animation: StringName = &""   # only used by charge-capable actions

#==============================================================================
# Combat Data
#==============================================================================

@export var attack_data: AttackData = AttackData.new()

@export var motion: AttackMotion = AttackMotion.new()

@export var timing: AttackTiming = AttackTiming.new()

@export var effects: AttackEffects = AttackEffects.new()

#==============================================================================
# Gameplay
#==============================================================================

@export var stamina_cost: float = 0.0

@export var attack_speed: float = 1.0

#==============================================================================
# Optional
#==============================================================================

@export var projectile_scene: PackedScene

@export var custom_events: Array[StringName] = []

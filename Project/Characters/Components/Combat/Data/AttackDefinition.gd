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

# Fraction (0–1) of the "commit" animation's length at which this attack
# opens its interrupt window automatically — no animation Call Method
# Track needed. 0 (default) disables this and preserves prior behavior
# exactly (window only opens via an explicit animation event, if ever).
@export var interrupt_window_percent: float = 0.0

#==============================================================================
# Optional
#==============================================================================

@export var projectile_scene: PackedScene

@export var custom_events: Array[StringName] = []

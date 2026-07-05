extends Resource
class_name WeaponAttack

@export var animation : StringName

@export var damage_multiplier := 1.0

@export var attack_speed := 1.0

@export var combo_index := 0

@export var opens_combo := false

@export var root_motion := false

@export var stamina_cost := 0.0

@export var can_rotate := true

@export var can_move := false

@export var projectile_scene : PackedScene

@export var vfx_scene : PackedScene

@export var sfx : AudioStream

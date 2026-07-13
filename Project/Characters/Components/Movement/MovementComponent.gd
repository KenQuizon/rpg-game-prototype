extends BaseComponent
class_name MovementComponent

#==============================================================================
# Export Variables
#==============================================================================

@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

#==============================================================================
# Private Variables
#==============================================================================

var _movement_input: Vector2 = Vector2.ZERO
var _move_direction: Vector3 = Vector3.ZERO
var _facing_direction: Vector3 = Vector3.FORWARD
var _is_moving: bool = false

# Forced motion (e.g. an attack lunge) overrides input-driven movement and
# the MOVEMENT lock entirely — it's a distinct, higher-priority velocity
# source, not something the lock should suppress.
var _forced_motion_active := false
var _forced_motion_direction := Vector3.ZERO
var _forced_motion_speed := 0.0
var _forced_motion_remaining_distance := 0.0

#==============================================================================
# Public Properties
#==============================================================================

var move_input: Vector2:
	get:
		return _movement_input

var move_direction: Vector3:
	get:
		return _move_direction

var facing_direction: Vector3:
	get:
		return _facing_direction

var is_moving: bool:
	get:
		return _is_moving

#==============================================================================
# Public API
#==============================================================================

func set_move_input(input: Vector2) -> void:
	_movement_input = input.normalized()

# Drives the character forward along its current facing for `distance`
# meters at `speed` m/s, overriding input and the MOVEMENT lock. Used by
# AttackAction for AttackMotion.move_distance/move_speed.
func apply_attack_motion(distance: float, speed: float) -> void:

	if speed <= 0.0 or distance <= 0.0:
		return

	_forced_motion_active = true
	_forced_motion_direction = _facing_direction
	_forced_motion_speed = speed
	_forced_motion_remaining_distance = distance

func clear_attack_motion() -> void:
	_forced_motion_active = false
	_forced_motion_remaining_distance = 0.0

# Directly overrides facing_direction — used to snap the character toward
# a target when initiating an attack (see AttackAction._face_target()).
# Deliberately NOT gated by ROTATION lock itself (this IS the attack's
# own facing decision, not player input trying to sneak a turn in) —
# what matters is that _update_direction() below won't immediately
# overwrite it with stale movement input on the very next physics frame.
func face_direction(direction: Vector3) -> void:

	var flat := Vector3(direction.x, 0.0, direction.z)

	if flat.is_zero_approx():
		return

	_facing_direction = flat.normalized()

func face_point(world_position: Vector3) -> void:

	var character := owner_character as Node3D

	if character == null:
		return

	face_direction(world_position - character.global_position)

#==============================================================================
# Updates
#==============================================================================

func physics_update(delta: float) -> void:

	# CharacterBody3D, not Character — movement only needs velocity /
	# move_and_slide() / is_on_floor(), which is a physics-body capability,
	# not something specific to the Character class. Any CharacterBody3D
	# host (an NPC, a boss, a non-Character actor) can use this component.
	var character := owner_character as CharacterBody3D

	if character == null:
		return

	_update_direction()

	_apply_gravity(character, delta)

	if _forced_motion_active:
		_apply_forced_motion(character, delta)
	elif _is_movement_locked():
		character.velocity.x = 0.0
		character.velocity.z = 0.0
	else:
		_apply_horizontal_velocity(character)

	character.move_and_slide()

#==============================================================================
# Internal
#==============================================================================

func _update_direction() -> void:

	_move_direction = Vector3(
		_movement_input.x,
		0.0,
		_movement_input.y
	)

	_is_moving = not _move_direction.is_zero_approx()

	# Rotation is owned by the MovementComponent.
	#
	# Priority:
	#
	# 1. ROTATION lock
	#      Current action (attack, hit, dash, etc.) owns facing.
	#
	# 2. Aim Mode
	#      Mouse owns facing.
	#
	# 3. Normal Movement
	#      WASD owns facing.
	#
	# Physical movement is completely independent from facing.
	# Even while aiming, WASD continues updating _move_direction and
	# velocity normally—the only thing that changes is where the
	# character is looking.

	if _is_rotation_locked():
		return

	# Bow aiming / future ranged weapons.
	if context.input != null and context.input.aim_mode:
		face_point(context.input.aim_world_position)
		return

	# Default movement-based facing.
	if _is_moving:
		_facing_direction = _move_direction.normalized()

func _apply_horizontal_velocity(character: CharacterBody3D) -> void:

	var stats := context.stats

	var speed := 0.0

	if stats != null:
		speed = stats.get_stat(StatType.Id.MOVE_SPEED)

	character.velocity.x = _move_direction.x * speed
	character.velocity.z = _move_direction.z * speed

func _apply_forced_motion(character: CharacterBody3D, delta: float) -> void:

	character.velocity.x = _forced_motion_direction.x * _forced_motion_speed
	character.velocity.z = _forced_motion_direction.z * _forced_motion_speed

	_forced_motion_remaining_distance -= _forced_motion_speed * delta

	if _forced_motion_remaining_distance <= 0.0:
		_forced_motion_active = false

func _apply_gravity(character: CharacterBody3D, delta: float) -> void:

	if character.is_on_floor():
		return

	character.velocity.y -= gravity * delta

func _is_movement_locked() -> bool:
	return context.is_locked(ActionLock.Id.MOVEMENT)

func _is_rotation_locked() -> bool:
	return context.is_locked(ActionLock.Id.ROTATION)

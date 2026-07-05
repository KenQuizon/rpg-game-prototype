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

#==============================================================================
# Updates
#==============================================================================

func physics_update(delta: float) -> void:

	var character := owner_character as Character

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

	if _is_moving:
		_facing_direction = _move_direction.normalized()

func _apply_horizontal_velocity(character: Character) -> void:

	var stats := context.stats

	var speed := 0.0

	if stats != null:
		speed = stats.get_stat(StatType.Id.MOVE_SPEED)

	character.velocity.x = _move_direction.x * speed
	character.velocity.z = _move_direction.z * speed

func _apply_forced_motion(character: Character, delta: float) -> void:

	character.velocity.x = _forced_motion_direction.x * _forced_motion_speed
	character.velocity.z = _forced_motion_direction.z * _forced_motion_speed

	_forced_motion_remaining_distance -= _forced_motion_speed * delta

	if _forced_motion_remaining_distance <= 0.0:
		_forced_motion_active = false

func _apply_gravity(character: Character, delta: float) -> void:

	if character.is_on_floor():
		return

	character.velocity.y -= gravity * delta

func _is_movement_locked() -> bool:
	if context.action == null:
		return false
	return context.action.has_lock(ActionLock.Id.MOVEMENT)

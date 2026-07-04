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

#==============================================================================
# Updates
#==============================================================================

func physics_update(delta: float) -> void:

	var character := owner_character as Character

	if character == null:
		return

	_update_direction()

	_apply_gravity(character, delta)

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

func _apply_gravity(character: Character, delta: float) -> void:

	if character.is_on_floor():
		return

	character.velocity.y -= gravity * delta

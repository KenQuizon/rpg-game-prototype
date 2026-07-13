extends BaseController
class_name PlayerController

#==============================================================================
# Updates
#==============================================================================

func physics_update(_delta: float) -> void:

	#--------------------------------------------------------------------------
	# Capture Input
	#--------------------------------------------------------------------------

	context.input.move_vector = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	context.input.attack_pressed = Input.is_action_just_pressed("attack")
	context.input.attack_held = Input.is_action_pressed("attack")
	context.input.interact_pressed = Input.is_action_just_pressed("interact")
	context.input.dash_pressed = Input.is_action_just_pressed("dash")
	context.input.skill_1_pressed = Input.is_action_just_pressed("skill_1")
	context.combat.set_blocking(Input.is_action_pressed("block")and not context.is_locked(ActionLock.Id.ATTACK))
	context.input.charged_attack_pressed = Input.is_action_just_pressed("charged_attack")
	context.input.charged_attack_held = Input.is_action_pressed("charged_attack")
	context.input.aim_mode = context.input.charged_attack_held
	context.input.aim_world_position = _get_mouse_world_position()

	if context.is_locked(ActionLock.Id.INPUT):
		if context.movement:
			context.movement.set_move_input(Vector2.ZERO)
		return

	#--------------------------------------------------------------------------
	# Attack-Move — attack input beats movement input. Holding attack with
	# a target out of range walks you toward it instead of swinging;
	# once in range, it attacks instead of walking. With no target at
	# all, this is a no-op and the normal move+attack flow below runs
	# exactly as before (single click, single swing, in place).
	#--------------------------------------------------------------------------

	if context.input.attack_held and _try_attack_move():
		return

	#--------------------------------------------------------------------------
	# Movement
	#--------------------------------------------------------------------------

	if context.movement:
		context.movement.set_move_input(
			context.input.move_vector
		)

	#--------------------------------------------------------------------------
	# Commands
	#--------------------------------------------------------------------------

	if context.input.attack_pressed:

		var attack := AttackCommand.new()

		attack.initialize(context)

		attack.execute()

	if context.input.interact_pressed:

		var interact := InteractCommand.new()

		interact.initialize(context)

		interact.execute()

	if context.input.dash_pressed:

		var evade := EvadeCommand.new()

		evade.initialize(context)
		evade.execute()
		
	if context.input.skill_1_pressed:

		var cast := CastSkillCommand.new()

		cast.initialize(context)
		cast.skill_id = &"fireball"

		cast.execute()

	if context.input.charged_attack_pressed:

		var charged := ChargedAttackCommand.new()

		charged.initialize(context)
		charged.execute()
#==============================================================================
# Internal
#==============================================================================

# Returns true if attack input took over this frame (either closing
# distance to a target or attacking it in range) — false means there's
# no target at all, so the caller falls through to normal movement.
func _try_attack_move() -> bool:

	if context.targeting == null or context.weapon == null:
		return false

	var character: Node3D = context.character as Node3D

	if character == null:
		return false

	var target: Node3D = context.targeting.current_target as Node3D

	if target == null or not is_instance_valid(target):
		return false

	var attack_range: float = context.weapon.get_attack_range()

	var distance: float = character.global_position.distance_to(
		target.global_position
	)

	if distance > attack_range:
		_move_toward(target.global_position)
		return true

	# In range — stop walking, face the target, and attack.
	# Submitting every held frame is safe: ActionScheduler rejects it while
	# an attack is already running and immediately accepts another once the
	# action finishes, giving attack-hold auto-repeat behavior.
	if context.movement != null:
		context.movement.set_move_input(Vector2.ZERO)
		context.movement.face_point(target.global_position)

	var attack := AttackCommand.new()

	attack.initialize(context)
	attack.execute()

	return true


func _move_toward(position: Vector3) -> void:

	if context.movement == null:
		return

	var character: Node3D = context.character as Node3D

	if character == null:
		return

	var direction: Vector3 = position - character.global_position

	direction.y = 0.0

	if direction.is_zero_approx():
		context.movement.set_move_input(Vector2.ZERO)
		return

	direction = direction.normalized()

	# MovementComponent expects CharacterInput's shape:
	# X -> world X
	# Y -> world Z
	context.movement.set_move_input(
		Vector2(direction.x, direction.z)
	)

func _get_mouse_world_position() -> Vector3:

	var character: Node3D = context.character as Node3D

	if character == null:
		return Vector3.ZERO

	var viewport: Viewport = character.get_viewport()
	var camera: Camera3D = viewport.get_camera_3d()

	if camera == null:
		return character.global_position

	var mouse_pos: Vector2 = viewport.get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_pos)

	var ground_plane: Plane = Plane(Vector3.UP, character.global_position.y)

	var hit: Variant = ground_plane.intersects_ray(
		ray_origin,
		ray_direction
	)

	if hit is Vector3:
		return hit

	return character.global_position

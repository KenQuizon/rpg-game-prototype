extends BaseController
class_name PlayerController

#==============================================================================
# Runtime
#==============================================================================

var _attack_move_target: Node3D = null

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
	context.combat.set_blocking(Input.is_action_pressed("block") and not context.is_locked(ActionLock.Id.ATTACK))
	context.input.charged_attack_pressed = Input.is_action_just_pressed("charged_attack")
	context.input.charged_attack_held = Input.is_action_pressed("charged_attack")
	context.input.aim_mode = context.input.charged_attack_held
	context.input.aim_world_position = _get_mouse_world_position()

	if context.is_locked(ActionLock.Id.INPUT):
		if context.movement:
			context.movement.set_move_input(Vector2.ZERO)
		return

	#--------------------------------------------------------------------------
	# Attack-Move — a single click starts a standing order that keeps
	# running on its own every frame (no more spam-clicking): walk to the
	# target, attack once in range, then keep attacking it. Real movement
	# input cancels the order immediately and hands control straight back
	# to WASD — that's the "interruptible" part.
	#--------------------------------------------------------------------------

	if context.input.move_vector != Vector2.ZERO:
		_attack_move_target = null

	if context.input.attack_pressed:

		var clicked_target: Node3D = context.targeting.current_target as Node3D if context.targeting else null

		if clicked_target != null and is_instance_valid(clicked_target):
			_attack_move_target = clicked_target

	if _attack_move_target != null:

		if not is_instance_valid(_attack_move_target):
			_attack_move_target = null
		elif _try_attack_move(_attack_move_target):
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

func _try_attack_move(target: Node3D) -> bool:

	if context.weapon == null:
		return false

	var character: Node3D = context.character as Node3D

	if character == null:
		return false

	var attack_range: float = context.weapon.get_attack_range()

	var distance: float = character.global_position.distance_to(
		target.global_position
	)

	if distance > attack_range:
		_move_toward(target.global_position)
		return true

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

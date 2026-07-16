extends BaseController
class_name PlayerController

#==============================================================================
# Runtime
#==============================================================================

var _attack_move_target: Node3D = null

# Same standing-order shape as _attack_move_target, but for skills — see
# _try_skill_move(). _pending_skill_id travels alongside the target since,
# unlike attack (always "whatever the weapon's next attack is"), a skill
# button press needs to remember *which* skill it was moving toward
# casting.
var _skill_move_target: Node3D = null
var _pending_skill_id: StringName = &""

#==============================================================================
# Updates
#==============================================================================

func physics_update(delta: float) -> void:

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
	context.input.interact_held = Input.is_action_pressed("interact")
	context.input.scroll_up_pressed = Input.is_action_just_pressed("interact_scroll_up")
	context.input.scroll_down_pressed = Input.is_action_just_pressed("interact_scroll_down")
	
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
	#
	# Skill-Move below follows the same walk-to-range shape, but is
	# single-shot rather than a repeating standing order — a skill cast is
	# a deliberate, cooldown-gated action, not an auto-attack.
	#--------------------------------------------------------------------------

	if context.input.move_vector != Vector2.ZERO:
		_attack_move_target = null
		_skill_move_target = null

	if context.input.attack_pressed:

		var clicked_target: Node3D = context.targeting.current_target as Node3D if context.targeting else null

		if clicked_target != null and is_instance_valid(clicked_target):
			_attack_move_target = clicked_target

	if context.input.skill_1_pressed:

		var clicked_skill_target: Node3D = context.targeting.current_target as Node3D if context.targeting else null

		if clicked_skill_target != null and is_instance_valid(clicked_skill_target):
			_skill_move_target = clicked_skill_target
			_pending_skill_id = &"fireball"

	if _attack_move_target != null:

		if not is_instance_valid(_attack_move_target):
			_attack_move_target = null
		elif _try_attack_move(_attack_move_target):
			return

	if _skill_move_target != null:

		if not is_instance_valid(_skill_move_target):
			_skill_move_target = null
		elif _try_skill_move(_skill_move_target, _pending_skill_id):
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
		
	if context.input.scroll_up_pressed and context.interaction:
		context.interaction.select_previous()

	if context.input.scroll_down_pressed and context.interaction:
		context.interaction.select_next()

	if context.interaction:

		var gather_ready := context.interaction.update_gather_hold(
			context.input.interact_held,
			delta
		)

		if gather_ready:

			var gather := GatherCommand.new()

			gather.initialize(context)
			gather.execute()

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

# Single-shot version of _try_attack_move: walks toward target while out
# of skill_range, then — once in range — stops, faces the target, submits
# the cast exactly once, and clears the standing order so it doesn't
# re-fire every frame. If the cast is rejected by the scheduler (on
# cooldown, insufficient resource, etc.) the order still clears rather
# than looping in place waiting for it to become valid — press the skill
# again once it's actually available.
func _try_skill_move(target: Node3D, skill_id: StringName) -> bool:

	if context.skills == null:
		return false

	var skill := context.skills.get_skill(skill_id)

	if skill == null:
		return false

	var character: Node3D = context.character as Node3D

	if character == null:
		return false

	var skill_range: float = skill.skill_range

	var distance: float = character.global_position.distance_to(
		target.global_position
	)

	if distance > skill_range:
		_move_toward(target.global_position)
		return true

	if context.movement != null:
		context.movement.set_move_input(Vector2.ZERO)
		context.movement.face_point(target.global_position)

	var cast := CastSkillCommand.new()

	cast.initialize(context)
	cast.skill_id = skill_id

	cast.execute()

	_skill_move_target = null

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

extends CombatEventHandler
class_name SpawnProjectileHandler

func handle_event(
	event_name: StringName,
	context: CharacterContext
) -> void:

	if context == null or context.combat == null:
		push_error("Invalid context in SpawnProjectileHandler")
		return
	
	var scene := context.combat.get_active_projectile_scene()
	if scene == null:
		push_error("Active projectile scene is null!")
		# Debug: why is it null?
		var data = context.combat.get_active_projectile_data()
		print("Projectile data:", data)
		return

	var owner_char := context.character

	if owner_char == null or not owner_char.has_method("get_character_projectile_spawn_point"):
		return

	var spawn_point: Marker3D = owner_char.get_character_projectile_spawn_point()

	if spawn_point == null:
		return

	var projectile := scene.instantiate() as Projectile

	if projectile == null:
		return

	owner_char.get_tree().current_scene.add_child(projectile)
	projectile.global_position = spawn_point.global_position

	var direction := Vector3.FORWARD

	if context.movement != null:
		direction = context.movement.facing_direction

	# Same query as AttackAction._face_target() — deliberately NOT
	# TargetingComponent.current_target, which tracks the nearest enemy
	# anywhere in the (larger) awareness radius and could be well outside
	# this weapon's actual attack range. Using the same range-scoped query
	# here guarantees the projectile can never aim somewhere different
	# from where the character visually faced to attack.
	if context.targeting != null and context.weapon != null:

		var target := context.targeting.get_target_within_range(
			context.weapon.get_attack_range()
		) as Node3D

		if target != null:
			direction = target.global_position - spawn_point.global_position
			direction.y = 0.0 # keep it horizontal for now — vertical aim is a later refinement

	projectile.launch(
		direction,
		context.combat,
		context.combat.get_active_projectile_data()
	)
	
	if context.action != null:
		context.action.notify_projectile_spawned()

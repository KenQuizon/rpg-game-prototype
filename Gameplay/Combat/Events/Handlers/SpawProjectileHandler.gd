extends CombatEventHandler
class_name SpawnProjectileHandler

func handle_event(
	event_name: StringName,
	context: CharacterContext
) -> void:

	if context == null or context.combat == null:
		return

	var scene := context.combat.get_active_projectile_scene()

	if scene == null:
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

	projectile.launch(
		direction,
		context.combat,
		context.combat.get_active_projectile_data()
	)

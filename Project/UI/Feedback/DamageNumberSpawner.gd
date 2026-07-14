extends CanvasLayer
class_name DamageNumberSpawner

@export var damage_number_scene: PackedScene

func _ready() -> void:
	self.layer = 100  # Above HUD
	UIEvents.damage_applied.connect(_on_damage_applied)

func spawn_damage_number(world_pos: Vector3, damage: float, is_critical: bool = false) -> void:

	if not damage_number_scene:
		return

	var number := damage_number_scene.instantiate() as DamageNumber

	var camera := get_viewport().get_camera_3d()

	if camera:
		var screen_pos := camera.unproject_position(world_pos)
		number.global_position = screen_pos

	add_child(number)
	number.setup(damage, is_critical)

func _on_damage_applied(amount: float, is_critical: bool, world_position: Vector3) -> void:
	spawn_damage_number(world_position, amount, is_critical)

extends CanvasLayer
class_name DamageNumberSpawner

@export var damage_number_scene: PackedScene
@export var max_pool_size: int = 20

var damage_number_pool: Array[Label] = []

func _ready() -> void:
	self.layer = 100  # Above HUD
	
	# Pre-create pool for performance
	for i in range(max_pool_size):
		var number = damage_number_scene.instantiate()
		damage_number_pool.append(number)
	
	# Listen for damage events
	UIEvents.damage_applied.connect(_on_damage_applied)
	print("DamageNumberSpawner ready")

func spawn_damage_number(world_pos: Vector3, damage: float, is_critical: bool = false) -> void:
	"""Spawn a damage number at world position"""
	if not damage_number_scene:
		return
	
	# Get or create number
	var number: Label
	if damage_number_pool.size() > 0:
		number = damage_number_pool.pop_front()
	else:
		number = damage_number_scene.instantiate()
	
	# Configure
	number.damage = damage if "damage" in number else damage
	number.is_critical = is_critical if "is_critical" in number else false
	
	# Position (3D to 2D conversion)
	var camera = get_viewport().get_camera_3d()
	if camera:
		var screen_pos = camera.unproject_position(world_pos)
		number.global_position = screen_pos
	
	# Add to display
	add_child(number)
	
	# Return to pool when done
	await number.tree_exited
	damage_number_pool.append(number)

func _on_damage_applied(amount: float, is_critical: bool) -> void:
	"""Listen for damage events from UIEvents"""
	var player = CharacterRef.get_player()
	if player:
		spawn_damage_number(player.global_position, amount, is_critical)

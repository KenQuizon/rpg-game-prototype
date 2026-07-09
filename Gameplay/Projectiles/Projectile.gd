extends Node3D
class_name Projectile

#==============================================================================
# Tuning
#==============================================================================

@export var speed: float = 15.0
@export var lifetime: float = 3.0

#==============================================================================
# Cached Nodes
#==============================================================================

@onready var hitbox: HitboxComponent = $HitboxComponent

#==============================================================================
# Runtime
#==============================================================================

var _direction: Vector3 = Vector3.FORWARD
var _elapsed: float = 0.0

#==============================================================================
# Public API
#==============================================================================
# Called immediately after instantiate() + add_child() by whatever spawns
# this projectile (SpawnProjectileHandler) — mirrors WeaponInstance's own
# initialize()-after-attach ordering, for the same @onready-safety reason.
func _ready() -> void:
	hitbox.area.area_entered.connect(_on_area_entered)
	
func launch(direction: Vector3, combat_owner: CombatComponent, attack_data: AttackData) -> void:

	_direction = direction.normalized()

	hitbox.set_combat_owner(combat_owner)
	hitbox.set_active_attack_data(attack_data)
	hitbox.activate()

	if _direction.length_squared() > 0.0:
		look_at(global_position + _direction, Vector3.UP)

#==============================================================================
# Lifecycle
#==============================================================================

func _physics_process(delta: float) -> void:

	_elapsed += delta

	if _elapsed >= lifetime:
		queue_free()
		return

	global_position += _direction * speed * delta

func _on_area_entered(_other: Area3D) -> void:
	# Simplification for a first pass: destroys on any overlap at all
	# (including a stray TargetingArea), not just a confirmed damage hit.
	# Fine for now since the hurtbox side already gates real damage
	# correctly — this only controls when the projectile despawns.
	queue_free()

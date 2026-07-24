extends Node3D
class_name Projectile

#==============================================================================
# Tuning
#==============================================================================

@export var speed: float = 15.0
@export var lifetime: float = 3.0
@export var model_faces_positive_z: bool = true

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
	hitbox.initialize()
	hitbox.area.area_entered.connect(_on_area_entered)
	
func launch(direction: Vector3, combat_owner: CombatComponent, attack_data: AttackData) -> void:

	_direction = direction.normalized()

	hitbox.set_combat_owner(combat_owner)
	hitbox.set_active_attack_data(attack_data)
	hitbox.activate()

	if _direction.length_squared() > 0.0:

		# look_at() always points this node's local -Z at the target —
		# that part's fixed. What varies is which way the Arrow model
		# was actually authored to face. If it looks backwards again
		# after a future asset re-import, flip this in the Inspector
		# rather than touching this code.
		var look_target := global_position - _direction if model_faces_positive_z else global_position + _direction

		look_at(look_target, Vector3.UP)
#==============================================================================
# Lifecycle
#==============================================================================

func _physics_process(delta: float) -> void:

	_elapsed += delta

	if _elapsed >= lifetime:
		queue_free()
		return

	global_position += _direction * speed * delta

func _on_area_entered(other: Area3D) -> void:

	if not other.has_meta("hurtbox_component"):
		return # ignore anything that isn't a real hurtbox — other hitboxes, TargetingAreas, etc.

	var hurtbox := other.get_meta("hurtbox_component") as HurtboxComponent

	if hurtbox == null:
		return

	if hurtbox.get_combat_owner() == hitbox.get_combat_owner():
		return # don't destroy on overlapping your own caster's hurtbox

	queue_free()

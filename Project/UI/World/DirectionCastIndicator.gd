extends CastIndicator
class_name DirectionCastIndicator

const PLANE_LENGTH: float = 1.0
const PLANE_WIDTH: float = 1.0

@export var world_width: float = 1.0
@export var world_head_length: float = 0.75
@export var world_outline_width: float = 0.05


func _ready() -> void:
	super._ready()

	# Width never varies per-cast (only length/range does), so this
	# correction only needs to happen once, here.
	scale.x = world_width / PLANE_WIDTH
	_set_param(&"outline_width", world_outline_width / world_width)


# direction is expected already-flattened/normalized by the caller —
# see how this gets called in Stage 3/4, where it's derived from
# aim_world_position.
func update_aim(direction: Vector3, max_range: float) -> void:

	if direction.length_squared() < 0.0001:
		return

	direction = direction.normalized()

	# The mesh is centered on this node's own origin, so push the node
	# forward by half the range — that puts the near edge exactly at the
	# caster (local origin) and the tip at max_range forward, rather
	# than centering the whole arrow on the caster.
	position = direction * (max_range * 0.5)
	basis = Basis.looking_at(direction, Vector3.UP)

	scale.z = max_range / PLANE_LENGTH

	var safe_range: float = max(max_range, 0.01)
	_set_param(&"head_length", world_head_length / safe_range)

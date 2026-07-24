extends CharacterAction
class_name EvadeAction

#==============================================================================
# Tuning
#==============================================================================

const INVULNERABLE_TIME: float = 0.3
const STAMINA_COST: float = 20.0

#==============================================================================
# Runtime
#==============================================================================

var _invulnerable_timer: float = 0.0
var _travel_time: float = 0.0

#==============================================================================
# Validation
#==============================================================================

func can_execute() -> bool:
	if context.is_locked(ActionLock.Id.MOVEMENT):
		return false

	if context.resources != null and not context.resources.has_resource(ResourceType.Id.STAMINA, STAMINA_COST):
		return false

	return true

#==============================================================================
# Lifecycle
#==============================================================================

func on_start() -> void:
	super.on_start()

	if context.resources != null:
		context.resources.spend(ResourceType.Id.STAMINA, STAMINA_COST)

	context.combat.set_evading(true)
	_invulnerable_timer = INVULNERABLE_TIME

	var evade_def := _definition as EvadeDefinition
	var distance := evade_def.evade_distance if evade_def != null else 3.0
	var speed := evade_def.evade_speed if evade_def != null else 12.0

	# The dash's actual length is however long it takes to cover
	# distance at speed — not a separately-authored number that has to
	# be kept in sync by hand. EvadeDefinition.duration (inherited from
	# ActionDefinition) is left at 0 for this action — see the .tres
	# change below — so the base class's own duration-based auto-finish
	# never fires; this is the only thing that decides when the dash ends.
	_travel_time = distance / speed if speed > 0.0 else 0.0

	if context.movement != null:
		context.movement.apply_attack_motion(distance, speed)

	animation.play_dash(_travel_time)

func on_update(delta: float) -> int:

	_invulnerable_timer -= delta

	if _invulnerable_timer <= 0.0:
		context.combat.set_evading(false)

	if _travel_time > 0.0 and _runtime.elapsed_time >= _travel_time:
		request_finish()

	return ActionExecutionStatus.Id.RUNNING

# No override needed — the base class's default (0.0) is exactly right:
# movement should resume the instant the dash's own duration ends, not
# hold locks for any additional time afterward.

func on_finish_requested() -> void:
	context.combat.set_evading(false)
	animation.reset_animation_speed()

	if context.action != null:
		context.action.release_locks(ActionLock.Id.MOVEMENT)

	if context.movement != null:
		context.movement.clear_attack_motion()
		context.movement.try_start_sprint()

func on_finish() -> void:
	context.combat.set_evading(false)
	animation.reset_animation_speed()

	if context.movement != null:
		context.movement.clear_attack_motion()

	super.on_finish()

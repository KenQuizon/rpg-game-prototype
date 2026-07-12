extends CharacterAction
class_name EvadeAction

#==============================================================================
# Tuning
#==============================================================================

const EVADE_DISTANCE: float = 3.0
const EVADE_SPEED: float = 12.0
const INVULNERABLE_TIME: float = 0.3
const STAMINA_COST: float = 20.0

#==============================================================================
# Runtime
#==============================================================================

var _invulnerable_timer: float = 0.0

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

	if context.movement != null:
		context.movement.apply_attack_motion(EVADE_DISTANCE, EVADE_SPEED)
		
	animation.play_dash()

func on_update(delta: float) -> int:

	_invulnerable_timer -= delta

	if _invulnerable_timer <= 0.0:
		context.combat.set_evading(false)

	return ActionExecutionStatus.Id.RUNNING

func get_recovery_time() -> float:
	return _definition.duration

func on_finish_requested() -> void:
	context.combat.set_evading(false)

	if context.movement != null:
		context.movement.clear_attack_motion()

func on_finish() -> void:
	context.combat.set_evading(false)

	if context.movement != null:
		context.movement.clear_attack_motion()

	super.on_finish()

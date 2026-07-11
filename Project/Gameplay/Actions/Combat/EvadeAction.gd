extends CharacterAction
class_name EvadeAction

#==============================================================================
# Tuning
#==============================================================================
# Kept here rather than on a new EvadeDefinition resource type — a plain
# ActionDefinition is sufficient for evade's needs (id/locks/flags/cooldown
# already cover it), so no new Resource subclass is introduced for one
# constant pair. Revisit as an exported field on a dedicated definition if
# multiple evade variants (roll vs. blink) are ever needed.

const EVADE_DISTANCE: float = 3.0
const EVADE_SPEED: float = 12.0
const INVULNERABLE_TIME: float = 0.3

#==============================================================================
# Runtime
#==============================================================================

var _invulnerable_timer: float = 0.0

#==============================================================================
# Validation
#==============================================================================

func can_execute() -> bool:
	return not context.is_locked(ActionLock.Id.MOVEMENT)

#==============================================================================
# Lifecycle
#==============================================================================

func on_start() -> void:
	super.on_start()

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

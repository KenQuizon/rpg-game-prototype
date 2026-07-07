extends CharacterAction
class_name CastAction

#==============================================================================
# Runtime
#==============================================================================

var _skill: SkillDefinition

#==============================================================================
# Initialization
#==============================================================================

func on_initialize() -> void:
	_skill = _definition as SkillDefinition

#==============================================================================
# Validation
#==============================================================================

func can_execute() -> bool:

	if _skill == null:
		return false

	# Mirrors InteractAction's own INTERACTION check — lets a status effect
	# or another action's locks suppress skill casting specifically,
	# independent of whatever the scheduler's priority-based preemption
	# would otherwise decide between two competing actions.
	if context.is_locked(ActionLock.Id.SKILLS):
		return false

	return true

#==============================================================================
# Lifecycle
#==============================================================================

func on_start() -> void:

	super.on_start()

	_play_cast_animation()

func on_update(_delta: float) -> int:
	return ActionExecutionStatus.Id.RUNNING

func get_recovery_time() -> float:

	if _skill == null:
		return 0.0

	return _skill.recovery_time

# Nothing needs to stop mid-cast by default for an instant-effect skill —
# a channeled skill (a beam, a charge-up heal) would be a CastAction
# subclass overriding this to end whatever effect it started in on_start().
func on_finish_requested() -> void:
	pass

func on_finish() -> void:
	super.on_finish()

#==============================================================================
# Internal
#==============================================================================

func _play_cast_animation() -> void:

	if _skill == null:
		return

	if _skill.cast_animation.is_empty():
		return

	if animation != null:
		animation.play(
			_skill.cast_animation,
			true
		)

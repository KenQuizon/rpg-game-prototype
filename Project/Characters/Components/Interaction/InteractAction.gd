extends CharacterAction
class_name InteractAction

#==============================================================================
# Runtime
#==============================================================================

var _target: Node

#==============================================================================
# Validation
#==============================================================================

func can_execute() -> bool:

	if context.interaction == null:
		return false

	# Lets an attack (or any other action/status) explicitly suppress
	# interaction by including INTERACTION in its own locks, independent of
	# — and in addition to — whatever the scheduler's priority-based
	# preemption would otherwise decide between two competing actions.
	if context.is_locked(ActionLock.Id.INTERACTION):
		return false

	_target = _request.target if _request.target != null else context.interaction.current_target

	return _target != null

#==============================================================================
# Lifecycle
#==============================================================================

func on_start() -> void:

	super.on_start()

	if _target == null:
		return

	context.interaction.begin_interaction(_target)

	_play_interact_animation()

	# No authored duration means "perform immediately" rather than waiting
	# for a duration that will never arrive — duration only needs to be
	# set at all for a channeled (hold-to-interact) case.
	if _definition == null or _definition.duration <= 0.0:
		request_finish()

func on_update(_delta: float) -> int:
	return ActionExecutionStatus.Id.RUNNING

# The one place the interactable's effect actually fires — reached either
# immediately (instant case, called from on_start above) or when a
# channeled interaction's duration elapses naturally via
# CharacterAction.tick()'s own duration timeout. on_cancel()/on_interrupt()
# below never route through here, so breaking a channel early — taking a
# hit, a higher-priority action preempting it — never completes it.
func on_finish_requested() -> void:
	if _target != null:
		context.interaction.complete_interaction(_target)

# Safety net — idempotent, since InteractionComponent.complete_interaction()
# already no-ops if _target no longer matches _active_target. Guarantees the
# interaction still fires even if on_finish_requested() was skipped (e.g. a
# future force_finish_current() authority override bypasses it the same way
# AttackAction.on_finish() guards against that path).
func on_finish() -> void:
	if _target != null:
		context.interaction.complete_interaction(_target)
	super.on_finish()

func on_cancel() -> void:
	if _target != null:
		context.interaction.cancel_interaction(_target)

func on_interrupt() -> void:
	on_cancel()

#==============================================================================
# Internal
#==============================================================================

func _play_interact_animation() -> void:

	var interact_definition := _definition as InteractDefinition

	if interact_definition == null:
		return

	if interact_definition.interact_animation.is_empty():
		return

	if animation != null:
		animation.play(
			interact_definition.interact_animation,
			true
		)

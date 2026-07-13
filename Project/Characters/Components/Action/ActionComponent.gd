extends BaseComponent
class_name ActionComponent

#==============================================================================
# Signals
#==============================================================================

signal execution_started(execution: ActionExecution)
signal execution_finished(execution: ActionExecution)

#==============================================================================
# Private
#==============================================================================

var _scheduler := ActionScheduler.new()
var _factory := ActionFactory.new()

#==============================================================================
# Properties
#==============================================================================

var current_execution: ActionExecution:
	get:
		return _scheduler.current_execution

func is_busy() -> bool:
	return not _scheduler.is_idle()

# Locks held by the currently running action (NONE when idle). Other
# components (movement, rotation, camera...) query this to decide whether
# their own behavior should be suppressed right now.
var acquired_locks: int:
	get:
		return _scheduler.current_locks

func has_lock(lock: int) -> bool:
	return (acquired_locks & lock) != 0

#==============================================================================
# Public API
#==============================================================================

func submit(
	request: ActionRequest
) -> ActionResult:

	var execution := _factory.create(request)

	if execution == null:
		return ActionResult.new(
			ActionResultCode.Id.INVALID,
			ActionCompletionReason.Id.INVALID_REQUEST
		)

	var validation := execution.action.validate()

	if validation.failed():
		return validation

	var previous := _scheduler.current_execution

	var result := _scheduler.submit(execution)

	if result.succeeded():

		execution_started.emit(execution)

		# Preemption swaps current_execution synchronously here, not inside
		# process_update()'s before/after check — emit the replaced
		# execution's finish so listeners still see a matched pair.
		if previous != null and _scheduler.current_execution == execution:
			execution_finished.emit(previous)

	return result

func cancel_current() -> void:
	_scheduler.cancel()

func interrupt_current() -> void:
	_scheduler.interrupt()

func stop_current_action() -> void:
	_scheduler.request_finish_current()

# Forwarded to the currently running action — see AnimationEvents.
# OPEN_INTERRUPT_WINDOW / OpenInterruptWindowHandler.
func open_interrupt_window() -> void:
	if _scheduler.current_execution != null:
		_scheduler.current_execution.action.open_interrupt_window()

func release_locks(mask: int) -> void:
	_scheduler.release_locks(mask)

# Whether the currently running action can be preempted right now — see
# CharacterAction.is_interruptible(). Used by AnimationComponent to decide
# whether locomotion animation may take back the animation channel from a
# still-recovering action whose interrupt window has opened, rather than
# waiting for it to fully finish.
func is_current_interruptible() -> bool:
	if _scheduler.current_execution == null:
		return false
	return _scheduler.current_execution.action.is_interruptible()

# Bypasses recovery entirely — an immediate administrative/system override.
# Not currently called anywhere in the framework; exposed for cases like a
# networked "server says this ends now" authority override in the future.
func force_finish_current() -> void:
	_scheduler.force_finish()

#==============================================================================
# Updates
#==============================================================================

func process_update(delta: float) -> void:

	var previous := _scheduler.current_execution

	_scheduler.update(delta)

	if previous != null and _scheduler.current_execution == null:
		execution_finished.emit(previous)

# ActionComponent.gd
func notify_projectile_spawned() -> void:
	if _scheduler.current_execution != null:
		_scheduler.current_execution.action.on_projectile_spawned()

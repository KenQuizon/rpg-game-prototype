extends RefCounted
class_name ActionScheduler

#==============================================================================
# Private
#==============================================================================

var _current_execution: ActionExecution
var _pending_execution: ActionExecution

#==============================================================================
# Properties
#==============================================================================

var current_execution: ActionExecution:
	get:
		return _current_execution

# Locks held by the currently running action, or NONE when idle. Other
# components query this instead of hardcoding "any action running" checks,
# so a specific action declares exactly which categories of behavior it
# suppresses (see MovementComponent / AnimationComponent).
var current_locks: int:
	get:
		if _current_execution == null:
			return ActionLock.Id.NONE
		return _current_execution.runtime.acquired_locks

#==============================================================================
# Queries
#==============================================================================

func has_execution() -> bool:
	return _current_execution != null

func is_idle() -> bool:
	return _current_execution == null

#==============================================================================
# Submission
#==============================================================================

func submit(execution: ActionExecution) -> ActionResult:

	if execution == null:
		return ActionResult.new(
			ActionResultCode.Id.INVALID,
			ActionCompletionReason.Id.INVALID_REQUEST
		)

	if not has_execution():
		_current_execution = execution
		_start_execution()
		return execution.result

	return _resolve_conflicting_submission(execution)

#==============================================================================
# Update
#==============================================================================

func update(delta: float) -> void:

	if not has_execution():
		return

	var status := _current_execution.action.tick(delta)

	match status:

		ActionExecutionStatus.Id.RUNNING:
			pass

		ActionExecutionStatus.Id.WAITING:
			pass

		ActionExecutionStatus.Id.COMPLETED:
			_finish_execution(
				ActionResultCode.Id.SUCCESS,
				ActionCompletionReason.Id.COMPLETED
			)

		ActionExecutionStatus.Id.FAILED:
			_finish_execution(
				ActionResultCode.Id.FAILED,
				ActionCompletionReason.Id.SYSTEM
			)

#==============================================================================
# Lifecycle
#==============================================================================

# cancel()/interrupt() are explicit player/system-driven stops — they drop
# any buffered follow-up action too (e.g. a dodge-cancel shouldn't let a
# buffered combo hit still fire afterward).

func cancel() -> void:

	if not has_execution():
		return

	_current_execution.action.cancel()

	_finish_execution(
		ActionResultCode.Id.CANCELLED,
		ActionCompletionReason.Id.CANCELLED,
		true
	)

func interrupt() -> void:

	if not has_execution():
		return

	_current_execution.action.interrupt()

	_finish_execution(
		ActionResultCode.Id.INTERRUPTED,
		ActionCompletionReason.Id.INTERRUPTED,
		true
	)

# Natural/deliberate successful finish (animation event, duration timeout).
# Unlike cancel()/interrupt(), this allows a buffered action to chain in.
func force_finish() -> void:

	if not has_execution():
		return

	_finish_execution(
		ActionResultCode.Id.SUCCESS,
		ActionCompletionReason.Id.COMPLETED
	)

# The FINISH_ACTION-event path. Tells the current action to begin winding
# down; the scheduler discovers completion naturally once tick() reports
# COMPLETED (after recovery), through the normal update() loop below — this
# is what lets recovery_time actually hold the action's locks.
func request_finish_current() -> void:

	if not has_execution():
		return

	_current_execution.action.request_finish()
func clear() -> void:
	_current_execution = null

# Lets the currently running action voluntarily give back specific locks
# before it finishes — e.g. once its interrupt window opens, it may no
# longer need to hold MOVEMENT. Submission-based conflicts (attack, dash,
# skill) don't need this; only continuous per-frame checks like
# MovementComponent's is_locked(MOVEMENT) do.
func release_locks(mask: int) -> void:
	if not has_execution():
		return
	_current_execution.runtime.acquired_locks &= ~mask

#==============================================================================
# Internal — Conflict Resolution
#==============================================================================

func _resolve_conflicting_submission(execution: ActionExecution) -> ActionResult:

	var current_definition := _current_execution.request.definition as ActionDefinition
	var incoming_definition := execution.request.definition as ActionDefinition

	# Strictly-higher priority always wins, regardless of interruptibility
	# (e.g. a stagger/knockback action should be able to cut in on
	# anything). Equal priority only wins if the current action is
	# currently interruptible — this is what lets an opened interrupt
	# window be preempted by another normal-priority action (basic
	# attack, dash, skill) rather than only by something more important.
	var current_interruptible := (
		current_definition == null
		or _current_execution.action.is_interruptible()
	)

	var can_preempt := (
		execution.effective_priority > _current_execution.effective_priority
		or (
			current_interruptible
			and execution.effective_priority >= _current_execution.effective_priority
		)
	)

	if can_preempt:
		_preempt_current(execution)
		return execution.result

	if _can_queue(incoming_definition, current_definition):
		_queue_next(execution)
		return ActionResult.new(
			ActionResultCode.Id.QUEUED,
			ActionCompletionReason.Id.NONE
		)

	return ActionResult.new(
		ActionResultCode.Id.REJECTED,
		ActionCompletionReason.Id.SYSTEM
	)

# Both sides opt in: the incoming action must declare itself QUEUEABLE, and
# the currently running action must declare CAN_QUEUE_WHILE_RUNNING. Neither
# is on by default (see ActionDefinition.flags), so existing content's
# behavior is unchanged until a designer explicitly enables buffering on a
# given attack/action.
func _can_queue(
	incoming_definition: ActionDefinition,
	current_definition: ActionDefinition
) -> bool:

	if _pending_execution != null:
		return false

	if incoming_definition == null or current_definition == null:
		return false

	return (
		_has_flag(incoming_definition.flags, ActionFlags.Id.QUEUEABLE)
		and _has_flag(current_definition.flags, ActionFlags.Id.CAN_QUEUE_WHILE_RUNNING)
	)

func _queue_next(execution: ActionExecution) -> void:
	execution.queue_index = 0
	_pending_execution = execution

func _preempt_current(execution: ActionExecution) -> void:

	_current_execution.action.interrupt()

	_current_execution.result.code = ActionResultCode.Id.INTERRUPTED
	_current_execution.result.reason = ActionCompletionReason.Id.REPLACED

	_current_execution.runtime.acquired_locks = ActionLock.Id.NONE

	clear()

	_pending_execution = null

	_current_execution = execution

	_start_execution()

static func _has_flag(flags: int, flag: int) -> bool:
	return (flags & flag) != 0

#==============================================================================
# Internal — Execution
#==============================================================================

func _start_execution() -> void:

	var runtime := _current_execution.runtime

	var definition := _current_execution.request.definition as ActionDefinition

	runtime.acquired_locks = definition.locks if definition != null else ActionLock.Id.NONE

	runtime.state = ActionState.Id.STARTING

	_current_execution.action.start()

	runtime.state = ActionState.Id.RUNNING

func _finish_execution(
	code: int,
	reason: int,
	drop_pending: bool = false
) -> void:

	var runtime := _current_execution.runtime

	runtime.state = ActionState.Id.FINISHING

	_current_execution.action.complete()

	_current_execution.result.code = code
	_current_execution.result.reason = reason

	runtime.acquired_locks = ActionLock.Id.NONE

	runtime.state = ActionState.Id.COMPLETED

	clear()

	if drop_pending:
		_pending_execution = null

	_promote_pending()

func _promote_pending() -> void:

	if _pending_execution == null:
		return

	if has_execution():
		return

	var next := _pending_execution

	_pending_execution = null

	_current_execution = next

	_start_execution()

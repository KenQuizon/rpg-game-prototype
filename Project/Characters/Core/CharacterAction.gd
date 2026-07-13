extends RefCounted
class_name CharacterAction

#==============================================================================
# Runtime References
#==============================================================================

var _request: ActionRequest
var _runtime: ActionRuntimeContext

var _context: CharacterContext
var _definition: ActionDefinition

var _animation: AnimationComponent

var _finish_requested := false
var _recovery_remaining := 0.0

# True = this action can currently be preempted (subject to
# ActionFlags.INTERRUPTIBLE and priority — see ActionScheduler). Defaults
# to true so any action that doesn't opt into delayed_interrupt_window
# keeps its exact prior behavior: INTERRUPTIBLE means interruptible from
# frame one.
var _interrupt_window_open := true

#==============================================================================
# Properties
#==============================================================================

var request: ActionRequest:
	get:
		return _request

var runtime: ActionRuntimeContext:
	get:
		return _runtime

var context: CharacterContext:
	get:
		return _context

var definition: ActionDefinition:
	get:
		return _definition

var animation: AnimationComponent:
	get:
		return _animation

#==============================================================================
# Initialization
#==============================================================================

func initialize(
	p_request: ActionRequest,
	p_runtime: ActionRuntimeContext
) -> void:

	_request = p_request
	_runtime = p_runtime

	_context = p_request.context
	_definition = p_request.definition

	_animation = _context.animation

	on_initialize()

func on_initialize() -> void:
	pass

#==============================================================================
# Validation
#==============================================================================

func can_execute() -> bool:
	return true

func validate() -> ActionResult:

	var alive_result := _validate_alive()

	if alive_result.failed():
		return alive_result

	var flag_result := _validate_flags()

	if flag_result.failed():
		return flag_result

	var policy_result := _validate_policies()

	if policy_result.failed():
		return policy_result

	if not can_execute():
		return ActionResult.new(
			ActionResultCode.Id.REJECTED,
			ActionCompletionReason.Id.FAILED_VALIDATION
		)

	return ActionResult.new()

# Unconditional, not opt-in via a flag — a dead character being unable to
# act is a base guarantee of the framework, not something every future
# ActionDefinition has to remember to declare. Runs before flags/policies
# since it's the cheapest possible rejection and applies universally.
func _validate_alive() -> ActionResult:

	if _context == null:
		return ActionResult.new()

	var health := _context.health

	if health != null and health.is_dead:
		return ActionResult.new(
			ActionResultCode.Id.REJECTED,
			ActionCompletionReason.Id.CHARACTER_DEAD
		)

	return ActionResult.new()

# Runs every ActionPolicy attached to this action's ActionDefinition, in
# order, stopping at the first failure. Definitions with no policies (the
# default) skip this entirely and behave exactly as before this existed.
func _validate_policies() -> ActionResult:

	if _definition == null:
		return ActionResult.new()

	for policy in _definition.policies:

		if policy == null:
			continue

		var result := policy.evaluate(_request, _runtime)

		if result.failed():
			return result

	return ActionResult.new()

func _validate_flags() -> ActionResult:

	if _definition == null:
		return ActionResult.new()

	var flags := _definition.flags

	if (flags & ActionFlags.Id.REQUIRES_WEAPON) != 0:
		if _context.weapon == null or not _context.weapon.has_weapon():
			return ActionResult.new(
				ActionResultCode.Id.REJECTED,
				ActionCompletionReason.Id.NO_WEAPON
			)

	if (flags & ActionFlags.Id.REQUIRES_TARGET) != 0:
		if _request.target == null:
			return ActionResult.new(
				ActionResultCode.Id.REJECTED,
				ActionCompletionReason.Id.LOST_TARGET
			)

	if (flags & ActionFlags.Id.REQUIRES_GROUND) != 0:
		# is_on_floor() is a CharacterBody3D capability, not something every
		# CharacterContext host guarantees (context.character is typed Node
		# — see roadmap 7.2). Cast defensively rather than assuming Character;
		# a non-physics-body host (e.g. a stationary turret) simply never
		# authors an action with REQUIRES_GROUND, so failing this check for
		# one is the correct outcome, not an error.
		var character := _context.character as CharacterBody3D
		if character == null or not character.is_on_floor():
			return ActionResult.new(
				ActionResultCode.Id.REJECTED,
				ActionCompletionReason.Id.FAILED_VALIDATION
			)

	return ActionResult.new()

#==============================================================================
# Framework Lifecycle
#==============================================================================

func start() -> void:
	_interrupt_window_open = not (
		_definition != null and _definition.delayed_interrupt_window
	)
	_commit_policies()
	on_start()

func _commit_policies() -> void:

	if _definition == null:
		return

	for policy in _definition.policies:

		if policy == null:
			continue

		policy.commit(_request, _runtime)

func tick(delta: float) -> int:

	_runtime.elapsed_time += delta

	if _finish_requested:

		_recovery_remaining -= delta

		if _recovery_remaining <= 0.0:
			return ActionExecutionStatus.Id.COMPLETED

		return ActionExecutionStatus.Id.RUNNING

	var status := on_update(delta)

	if status == ActionExecutionStatus.Id.RUNNING or status == ActionExecutionStatus.Id.WAITING:
		if _definition != null and _definition.duration > 0.0:
			if _runtime.elapsed_time >= _definition.duration:
				request_finish()
				return ActionExecutionStatus.Id.RUNNING

	return status

func complete() -> void:
	on_finish()

func interrupt() -> void:
	on_interrupt()

func cancel() -> void:
	on_cancel()

#==============================================================================
# Wind-Down / Recovery
#==============================================================================

# Begins the action's wind-down. on_finish_requested() fires immediately so
# the action can stop its gameplay effects right away (deactivate a hitbox,
# stop dealing damage), while the action itself keeps holding its locks for
# get_recovery_time() more seconds before the scheduler actually completes
# it. cancel()/interrupt() intentionally bypass this — those are meant to be
# instant, not subject to authored recovery.
func request_finish() -> void:

	if _finish_requested:
		return

	_finish_requested = true
	_recovery_remaining = get_recovery_time()

	on_finish_requested()

func get_recovery_time() -> float:
	return 0.0

func on_finish_requested() -> void:
	pass

#==============================================================================
# Interrupt Window
#==============================================================================
# Read by ActionScheduler at conflict-resolution time — see
# _resolve_conflicting_submission(). Combines the authored intent
# (ActionFlags.INTERRUPTIBLE) with the runtime gate above, so a Resource
# can declare "I *can* be interrupted" while the actual window only opens
# once open_interrupt_window() is called (or immediately, by default).

func is_interruptible() -> bool:
	if _definition == null:
		return false
	if (_definition.flags & ActionFlags.Id.INTERRUPTIBLE) == 0:
		return false
	return _interrupt_window_open

# Override to also release any locks (movement/rotation) this action no
# longer needs held once its committed effect has happened — see
# AttackAction for an example. Base implementation only flips the gate,
# so calling this on an action that never opted into
# delayed_interrupt_window is a harmless no-op (the window was already
# open).
func open_interrupt_window() -> void:
	_interrupt_window_open = true

func close_interrupt_window() -> void:
	_interrupt_window_open = false

#==============================================================================
# Gameplay Hooks
#==============================================================================

func on_start() -> void:
	pass

func on_update(_delta: float) -> int:
	return ActionExecutionStatus.Id.COMPLETED

func on_finish() -> void:
	pass

func on_cancel() -> void:
	on_finish()

func on_interrupt() -> void:
	on_cancel()

# CharacterAction.gd
# Called by SpawnProjectileHandler the instant a projectile actually
# leaves this action's owner. Distinct from open_interrupt_window(): this
# fires at the exact commit frame, which may be earlier than when the
# action becomes preemptible. No-op by default.
func on_projectile_spawned() -> void:
	pass

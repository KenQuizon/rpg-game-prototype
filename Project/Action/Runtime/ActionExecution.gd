extends RefCounted
class_name ActionExecution

#==============================================================================
# Identity
#==============================================================================

# Monotonic across the whole process — every ActionExecution ever created
# gets a unique id, regardless of which character it belongs to. Consumers
# needing per-character sequencing can pair this with request.context.
static var _next_execution_id: int = 1

#==============================================================================
# Runtime
#==============================================================================

var request: ActionRequest

var action: CharacterAction

var runtime: ActionRuntimeContext

var result: ActionResult

#==============================================================================
# Scheduler Metadata
#==============================================================================

var execution_id: int = 0

var queue_index: int = -1

var effective_priority: int = ActionPriority.Id.NORMAL

#==============================================================================
# Timing
#==============================================================================

var submitted_at: float = 0.0

var started_at: float = 0.0

var finished_at: float = 0.0

#==============================================================================
# Construction
#==============================================================================

func _init(
	p_request: ActionRequest,
	p_action: CharacterAction,
	p_runtime: ActionRuntimeContext
) -> void:

	request = p_request
	action = p_action
	runtime = p_runtime

	execution_id = _next_execution_id
	_next_execution_id += 1

	effective_priority = request.priority

	result = ActionResult.new()

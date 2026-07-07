extends RefCounted
class_name ActionResult

#==============================================================================
# Result
#==============================================================================

var code: int = ActionResultCode.Id.SUCCESS

var reason: int = ActionCompletionReason.Id.NONE

var message: String = ""

var data: Variant

#==============================================================================
# Construction
#==============================================================================

func _init(
	p_code := ActionResultCode.Id.SUCCESS,
	p_reason := ActionCompletionReason.Id.NONE
) -> void:

	code = p_code
	reason = p_reason

#==============================================================================
# Helpers
#==============================================================================

func succeeded() -> bool:
	return code == ActionResultCode.Id.SUCCESS or code == ActionResultCode.Id.QUEUED

func failed() -> bool:
	return not succeeded()

# Convenience factory — equivalent to ActionResult.new(), but reads clearly
# at call sites like ActionPolicy.evaluate() that only ever return success
# or an explicit rejection.
static func success() -> ActionResult:
	return ActionResult.new()

extends RefCounted
class_name ActionRuntimeContext

#==============================================================================
# Runtime
#==============================================================================

var state: int = ActionState.Id.CREATED

var elapsed_time: float = 0.0

var started_at: float = 0.0

var finished_at: float = 0.0

# Reserved for Phase 4 (lock acquisition/release) — not yet read or written.
var acquired_locks: int = ActionLock.Id.NONE

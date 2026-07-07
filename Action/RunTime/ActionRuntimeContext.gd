extends RefCounted
class_name ActionRuntimeContext

#==============================================================================
# Runtime
#==============================================================================

var state: int = ActionState.Id.CREATED

var elapsed_time: float = 0.0

var started_at: float = 0.0

var finished_at: float = 0.0

# Set from ActionDefinition.locks when the scheduler starts this execution
# (ActionScheduler._start_execution), cleared on finish/preemption, and read
# via ActionComponent.acquired_locks by other components (Movement,
# Animation, ...) to decide whether their own behavior should be suppressed.
var acquired_locks: int = ActionLock.Id.NONE

extends Resource
class_name ActionDefinition

#==============================================================================
# Identification
#==============================================================================

@export var id: StringName

@export var display_name: String = ""

@export_multiline var description: String = ""

@export var action_script: Script

#==============================================================================
# Scheduling
#==============================================================================

@export var priority: ActionPriority.Id = ActionPriority.Id.NORMAL

@export_flags(
	"MOVEMENT",
	"ROTATION",
	"ACTIONS",
	"ATTACK",
	"SKILLS",
	"INTERACTION",
	"EQUIPMENT",
	"INPUT",
	"CAMERA"
)
var locks: int = ActionLock.Id.NONE

@export_flags(
	"QUEUEABLE",
	"INTERRUPTIBLE",
	"CAN_QUEUE_WHILE_RUNNING",
	"REQUIRES_TARGET",
	"REQUIRES_WEAPON",
	"REQUIRES_GROUND",
	"IGNORE_GLOBAL_LOCKS",
	"SERVER_ONLY",
	"CLIENT_ONLY"
)
var flags: int = (
	ActionFlags.Id.QUEUEABLE
	| ActionFlags.Id.INTERRUPTIBLE
)

#==============================================================================
# Runtime
#==============================================================================

@export var duration: float = 0.0

@export var cooldown_group: StringName

@export var cooldown: float = 0.0

#==============================================================================
# Validation
#==============================================================================

# Pluggable, composable validation gates evaluated in order during
# CharacterAction.validate(), after flag checks and before can_execute().
# Use this for cooldown checks, resource costs (mana/stamina), network
# authority checks, etc. — new gate types are new ActionPolicy subclasses,
# not edits to CharacterAction or ActionScheduler.
@export var policies: Array[ActionPolicy] = []

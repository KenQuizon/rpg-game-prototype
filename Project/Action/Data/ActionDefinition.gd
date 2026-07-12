extends Resource
class_name ActionDefinition

#==============================================================================
# Identification
#==============================================================================

@export var id: StringName

@export var icon: Texture2D

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

# Opt-in gate for INTERRUPTIBLE (see ActionFlags). When false (default),
# an INTERRUPTIBLE action is preemptible from the moment it starts — the
# original, unchanged behavior. When true, the action starts LOCKED even
# if INTERRUPTIBLE is set, and only becomes preemptible once something
# calls CharacterAction.open_interrupt_window() — typically an animation
# call-method track firing AnimationEvents.OPEN_INTERRUPT_WINDOW at the
# "point of commitment" (an arrow already loosed, a spell already cast).
# Lets a single action be locked for its early frames and interruptible
# for its later ones, without touching any other action's behavior.
@export var delayed_interrupt_window: bool = false

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

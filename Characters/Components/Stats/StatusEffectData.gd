extends Resource
class_name StatusEffectData

#==============================================================================
# Stacking Rules
#==============================================================================

enum StackMode {
	# A re-application while active just resets remaining_duration.
	REFRESH_DURATION,
	# A re-application adds a stack (up to max_stacks) and refreshes duration.
	ADD_STACK,
	# A re-application while active does nothing.
	IGNORE_IF_ACTIVE
}

#==============================================================================
# Identity
#==============================================================================

@export var id: StringName = &""

@export var display_name: String = ""

@export_multiline var description: String = ""

#==============================================================================
# Duration & Stacking
#==============================================================================

# 0.0 = infinite; stays active until remove_status()/clear_all() is called
# explicitly (e.g. a condition cleared by an item, not by time).
@export var duration: float = 5.0

@export var stack_mode: StackMode = StackMode.REFRESH_DURATION

@export_range(1, 99)
var max_stacks: int = 1

#==============================================================================
# Locks
#==============================================================================

# Same flag set as ActionDefinition.locks, reused so a "Stun" effect and an
# attack's own action can both suppress e.g. MOVEMENT through the exact
# same query path (CharacterContext.is_locked). This is what makes a status
# effect able to act as a "Character Condition" (stagger/stun/root/etc.)
# without a separate condition class — a condition IS a StatusEffectData
# with locks set and no stat modifiers or damage.
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

#==============================================================================
# Stat Modifiers
#==============================================================================

@export var stat_modifiers: Array[StatModifierEntry] = []

#==============================================================================
# Damage Over Time
#==============================================================================

@export var damage_per_tick: float = 0.0

@export_range(0.05, 30.0)
var tick_interval: float = 1.0

@export var damage_type: DamageType.Id = DamageType.Id.PHYSICAL

#==============================================================================
# Tags
#==============================================================================

@export var tags: Array[StringName] = []

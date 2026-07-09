extends BaseComponent
class_name PoiseComponent

#==============================================================================
# Signals
#==============================================================================

signal staggered

#==============================================================================
# Export Variables
#==============================================================================

# Regen only starts once this long has passed since the last poise damage
# was taken — mirrors the "combat resets the timer" feel of stamina/combo
# systems elsewhere in the framework, rather than poise regenerating even
# mid-flurry.
@export var regen_delay: float = 2.0

@export var regen_per_second: float = 15.0

#==============================================================================
# Runtime
#==============================================================================

var _accumulated_damage: float = 0.0
var _time_since_hit: float = 0.0

#==============================================================================
# Cached Components
#==============================================================================

var _stats: StatsComponent

#==============================================================================
# Public Properties
#==============================================================================

var current_poise_damage: float:
	get:
		return _accumulated_damage

var max_poise: float:
	get:
		if _stats == null:
			return 0.0
		return _stats.get_stat(StatType.Id.POISE)

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:
	_stats = context.stats

#==============================================================================
# Public API
#==============================================================================

# Adds poise damage from a hit. Returns true if this hit broke poise (i.e.
# accumulated damage reached max_poise), in which case the accumulator is
# reset back to zero — a break "spends" everything that built up toward it,
# same shape as HealthComponent going to 0 on death.
func apply_stagger_damage(amount: float) -> bool:

	if amount <= 0.0:
		return false

	_accumulated_damage += amount
	_time_since_hit = 0.0

	var max_value := max_poise

	# max_poise <= 0 means this character has no poise resource authored at
	# all (e.g. no StatsComponent, or a StatsProfile with poise left at 0)
	# — treat as unstaggerable rather than instantly breaking on any hit.
	if max_value <= 0.0:
		return false

	if _accumulated_damage < max_value:
		return false

	_accumulated_damage = 0.0

	staggered.emit()

	return true


func reset() -> void:
	_accumulated_damage = 0.0
	_time_since_hit = 0.0

#==============================================================================
# Updates
#==============================================================================

func process_update(delta: float) -> void:

	if _accumulated_damage <= 0.0:
		return

	_time_since_hit += delta

	if _time_since_hit < regen_delay:
		return

	_accumulated_damage = max(
		0.0,
		_accumulated_damage - regen_per_second * delta
	)

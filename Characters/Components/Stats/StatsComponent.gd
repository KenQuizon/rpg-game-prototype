extends BaseComponent
class_name StatsComponent

#==============================================================================
# Signals
#==============================================================================

signal stat_changed(
	stat: StatType.Id,
	old_value: float,
	new_value: float
)

#==============================================================================
# Export Variables
#==============================================================================

@export var stats_profile: StatsProfile

#==============================================================================
# Private Variables
#==============================================================================

var _base_stats: Dictionary = {}

var _modifiers: Dictionary = {}

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:

	if stats_profile == null:
		push_error("StatsComponent requires a StatsProfile.")
		return

	_load_profile()

#==============================================================================
# Public API
#==============================================================================

func get_stat(stat: StatType.Id) -> float:

	var value: float = _base_stats.get(stat, 0.0)

	if _modifiers.has(stat):

		for modifier: StatModifier in _modifiers[stat]:
			value += modifier.value

	return value


func get_base_stat(stat: StatType.Id) -> float:
	return _base_stats.get(stat, 0.0)


func set_base_stat(
	stat: StatType.Id,
	value: float
) -> void:

	var old_value := get_stat(stat)

	_base_stats[stat] = value

	stat_changed.emit(
		stat,
		old_value,
		get_stat(stat)
	)


func add_modifier(
	stat: StatType.Id,
	modifier: StatModifier
) -> void:

	if not _modifiers.has(stat):
		_modifiers[stat] = []

	var modifiers: Array = _modifiers[stat]

	modifiers.append(modifier)

	stat_changed.emit(
		stat,
		get_stat(stat) - modifier.value,
		get_stat(stat)
	)


func remove_modifiers_from_source(
	source: Object
) -> void:

	for stat in _modifiers.keys():

		var modifiers: Array = _modifiers[stat]

		var old_value := get_stat(stat)

		modifiers = modifiers.filter(
			func(modifier: StatModifier):
				return modifier.source != source
		)

		_modifiers[stat] = modifiers

		var new_value := get_stat(stat)

		if old_value != new_value:

			stat_changed.emit(
				stat,
				old_value,
				new_value
			)

#==============================================================================
# Internal
#==============================================================================

func _load_profile() -> void:

	_base_stats.clear()

	_base_stats[StatType.Id.STRENGTH] = stats_profile.strength
	_base_stats[StatType.Id.DEXTERITY] = stats_profile.dexterity
	_base_stats[StatType.Id.INTELLIGENCE] = stats_profile.intelligence
	_base_stats[StatType.Id.VITALITY] = stats_profile.vitality

	_base_stats[StatType.Id.MOVE_SPEED] = stats_profile.move_speed
	_base_stats[StatType.Id.ATTACK_SPEED] = stats_profile.attack_speed

	_base_stats[StatType.Id.DEFENSE] = stats_profile.defense

	_base_stats[StatType.Id.CRITICAL_CHANCE] = stats_profile.critical_chance
	_base_stats[StatType.Id.CRITICAL_DAMAGE] = stats_profile.critical_damage

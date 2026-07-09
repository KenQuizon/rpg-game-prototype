extends RefCounted
class_name RandomSource

#==============================================================================
# Purpose
#==============================================================================
# Wraps RandomNumberGenerator so gameplay-affecting randomness (crit rolls,
# loot rolls, AI decision jitter, etc.) goes through one seedable, injectable
# source instead of scattered bare randf()/randi() calls. Bare calls can
# never be made deterministic after the fact — every call site has to be
# found and rewritten. Routing through RandomSource from the start means a
# save/replay/seeded-run feature only ever has to seed one thing.
#
# Mirrors the CombatEventDispatcher.get_default() / set_dispatcher() shape
# already used elsewhere in the framework: a shared default instance for
# normal gameplay, with an explicit override point for tests, replays, or a
# specific character (e.g. a boss whose rolls should use a dedicated,
# separately-seeded stream).

#==============================================================================
# Shared Default Instance
#==============================================================================

static var _default: RandomSource = null

static func get_default() -> RandomSource:
	if _default == null:
		_default = RandomSource.new()
	return _default

# Allows tests/replays to swap in a specifically-seeded source without
# touching any call site that uses RandomSource.get_default().
static func set_default(source: RandomSource) -> void:
	if source == null:
		return
	_default = source

#==============================================================================
# Private
#==============================================================================

var _rng := RandomNumberGenerator.new()

#==============================================================================
# Initialization
#==============================================================================

# seed_value < 0 (default) randomizes from OS entropy, matching the previous
# bare randf() behavior. Pass a specific seed for determinism (tests,
# replays, seeded runs).
func _init(seed_value: int = -1) -> void:
	if seed_value >= 0:
		_rng.seed = seed_value
	else:
		_rng.randomize()

#==============================================================================
# Seeding
#==============================================================================

func set_seed(seed_value: int) -> void:
	_rng.seed = seed_value

func get_seed() -> int:
	return _rng.seed

#==============================================================================
# Rolls
#==============================================================================

func randf() -> float:
	return _rng.randf()

func randf_range(from: float, to: float) -> float:
	return _rng.randf_range(from, to)

func randi() -> int:
	return _rng.randi()

func randi_range(from: int, to: int) -> int:
	return _rng.randi_range(from, to)

# Standard shape for "does this X% chance succeed" rolls (crit chance,
# status-apply chance, loot-drop chance, ...) so call sites read as intent
# rather than reimplementing the < comparison each time.
func roll_chance(chance: float) -> bool:
	return randf() < chance

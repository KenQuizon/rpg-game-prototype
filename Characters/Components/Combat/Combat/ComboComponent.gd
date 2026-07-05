extends BaseComponent
class_name ComboComponent

#==============================================================================
# Signals
#==============================================================================

signal combo_started
signal combo_advanced(index: int)
signal combo_finished

#==============================================================================
# Export
#==============================================================================

# Fallback only — used when nothing supplies a more specific timeout via
# set_active_timeout() (e.g. an attack with no AttackTiming assigned).
@export var default_combo_timeout := 1.0

#==============================================================================
# Runtime
#==============================================================================

var _combo_index := 0
var _combo_timer := 0.0
var _combo_active := false
var _active_timeout := 0.0

#==============================================================================
# Properties
#==============================================================================

var combo_index: int:
	get:
		return _combo_index

func is_combo_active() -> bool:
	return _combo_active

#==============================================================================
# Updates
#==============================================================================

func process_update(delta: float) -> void:

	if not _combo_active:
		return

	_combo_timer += delta

	if _combo_timer >= _active_timeout:
		reset_combo()

#==============================================================================
# Public API
#==============================================================================

func begin_combo() -> void:

	if _combo_active:
		return

	_combo_active = true
	_combo_timer = 0.0
	_combo_index = 0
	_active_timeout = default_combo_timeout

	combo_started.emit()

func reset_timer() -> void:
	_combo_timer = 0.0

# Lets whoever selects the next attack (AttackRuntime) supply that specific
# attack's own AttackTiming.combo_close_time as the window for chaining
# into the next hit, instead of every attack sharing one fixed timeout.
func set_active_timeout(timeout: float) -> void:
	if timeout <= 0.0:
		return
	_active_timeout = timeout

func advance_combo(max_attacks: int) -> void:

	reset_timer()

	if max_attacks <= 0:
		reset_combo()
		return

	_combo_index += 1

	if _combo_index >= max_attacks:
		_combo_index = 0

	combo_advanced.emit(_combo_index)

func reset_combo() -> void:

	if not _combo_active:
		return

	_combo_active = false
	_combo_timer = 0.0
	_combo_index = 0
	_active_timeout = default_combo_timeout

	combo_finished.emit()

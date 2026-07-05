extends Node
class_name CharacterStateMachine

#==============================================================================
# Signals
#==============================================================================

signal state_changed(
	previous_state: CharacterState,
	new_state: CharacterState
)

#==============================================================================
# Private Variables
#==============================================================================

var _context: CharacterContext

var _current_state: CharacterState
var _previous_state: CharacterState

#==============================================================================
# Public Properties
#==============================================================================

var current_state: CharacterState:
	get:
		return _current_state

var previous_state: CharacterState:
	get:
		return _previous_state

#==============================================================================
# Initialization
#==============================================================================

func initialize(character_context: CharacterContext) -> void:
	_context = character_context

#==============================================================================
# State Management
#==============================================================================

func change_state(new_state: CharacterState) -> void:

	if new_state == null:
		return

	if _current_state == new_state:
		return

	if _current_state != null:

		if not _current_state.can_transition_to(new_state):
			return

		_current_state.exit()

	_previous_state = _current_state
	_current_state = new_state

	_current_state.initialize(_context)
	_current_state.enter()

	state_changed.emit(
		_previous_state,
		_current_state
	)

#==============================================================================
# Updates
#==============================================================================

func physics_update(delta: float) -> void:

	if _current_state:
		_current_state.physics_update(delta)

func process_update(delta: float) -> void:

	if _current_state:
		_current_state.process_update(delta)

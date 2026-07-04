extends BaseComponent
class_name ActionComponent

#==============================================================================
# Signals
#==============================================================================

signal action_started(action: CharacterAction)
signal action_finished(action: CharacterAction)

#==============================================================================
# Private
#==============================================================================

var _current_action: CharacterAction

#==============================================================================
# Properties
#==============================================================================

var current_action: CharacterAction:
	get:
		return _current_action

func is_busy() -> bool:
	return _current_action != null

#==============================================================================
# Public API
#==============================================================================

func execute_action(action: CharacterAction) -> bool:
	return execute(action)
	
func execute(action: CharacterAction) -> bool:

	if action == null:
		return false

	if is_busy():
		return false

	action.initialize(context)

	if not action.can_execute():
		return false

	_current_action = action

	action.begin()

	action_started.emit(action)

	return true

func stop_current_action() -> void:

	if _current_action == null:
		return

	var finished := _current_action

	finished.finish()

	_current_action = null

	action_finished.emit(finished)

#==============================================================================
# Updates
#==============================================================================

func process_update(delta: float) -> void:

	if _current_action == null:
		return

	_current_action.update(delta)

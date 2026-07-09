extends RefCounted
class_name CharacterState

#==============================================================================
# Private Variables
#==============================================================================

var _context: CharacterContext

#==============================================================================
# Public Properties
#==============================================================================

var context: CharacterContext:
	get:
		return _context

#==============================================================================
# Initialization
#==============================================================================

func initialize(character_context: CharacterContext) -> void:
	_context = character_context

#==============================================================================
# Virtual API
#==============================================================================

func get_state_name() -> StringName:
	return &"State"

func can_transition_to(_next_state: CharacterState) -> bool:
	return true

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func process_update(_delta: float) -> void:
	pass

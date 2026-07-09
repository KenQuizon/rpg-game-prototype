extends Node
class_name BaseController

#==============================================================================
# Private Variables
#==============================================================================

var _character: Node = null
var _context: CharacterContext = null
var _initialized: bool = false

#==============================================================================
# Public Properties
#==============================================================================

var character: Node:
	get:
		return _character

var context: CharacterContext:
	get:
		return _context

var is_initialized: bool:
	get:
		return _initialized

#==============================================================================
# Framework API
#==============================================================================

func initialize(character_owner: Node, character_context: CharacterContext) -> void:
	if _initialized:
		return

	_character = character_owner
	_context = character_context

	on_initialize()

	_initialized = true


func shutdown_controller() -> void:
	if not _initialized:
		return

	on_shutdown()

	_initialized = false

#==============================================================================
# Update API
#==============================================================================

func physics_update(_delta: float) -> void:
	pass


func process_update(_delta: float) -> void:
	pass

#==============================================================================
# Virtual Methods
#==============================================================================

func on_initialize() -> void:
	pass


func on_shutdown() -> void:
	pass

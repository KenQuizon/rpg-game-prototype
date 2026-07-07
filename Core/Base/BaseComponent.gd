extends Node
class_name BaseComponent

#==============================================================================
# Signals
#==============================================================================

signal initialized(component: BaseComponent)
signal shutting_down(component: BaseComponent)

#==============================================================================
# Private Variables
#==============================================================================

var _owner: Node = null
var _registry: ComponentRegistry = null
var _initialized: bool = false
var _context: CharacterContext = null

#==============================================================================
# Public Properties
#==============================================================================

var owner_character: Node:
	get:
		return _owner

var registry: ComponentRegistry:
	get:
		return _registry

var is_initialized: bool:
	get:
		return _initialized
		
var context: CharacterContext:
	get:
		return _context

#==============================================================================
# Framework API
#==============================================================================

func register_component(
	character_owner: Node,
	character_context: CharacterContext,
	component_registry: ComponentRegistry
) -> void:

	_owner = character_owner
	_context = character_context
	_registry = component_registry

	_registry.register_component(self)

# Resolves to the highest-level framework component type (e.g.
# MovementComponent), not the concrete instantiated script. This lets a
# game-specific subclass — e.g. `FlyingMovementComponent extends
# MovementComponent` on a boss — still be found via `context.movement`,
# which looks up by the base MovementComponent script. Without this, the
# registry would key subclasses under their own script and typed
# CharacterContext accessors would silently return null for them.
func get_component_key() -> Script:

	var script := get_script() as Script

	if script == null:
		return null
	
	var base_script: Script = script.get_base_script()

	while base_script != null and base_script != BaseComponent:
		script = base_script
		base_script = script.get_base_script()

	return script


func initialize() -> void:
			
	if _initialized:
		return
		
	on_initialize()

	_initialized = true

	initialized.emit(self)


func shutdown_component() -> void:
	if not _initialized:
		return

	on_shutdown()

	_registry.unregister_component(self)

	_initialized = false

	shutting_down.emit(self)

#==============================================================================
# Virtual Methods
#==============================================================================

func on_initialize() -> void:
	pass


func on_shutdown() -> void:
	pass

#==============================================================================
# Updates
#==============================================================================

func process_update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass

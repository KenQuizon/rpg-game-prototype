extends RefCounted
class_name CharacterAction

#==============================================================================
# Protected
#==============================================================================

var _context: CharacterContext

var _animation: AnimationComponent

#==============================================================================
# Properties
#==============================================================================

var context: CharacterContext:
	get:
		return _context

var animation: AnimationComponent:
	get:
		return _animation

#==============================================================================
# Initialization
#==============================================================================

func initialize(character_context: CharacterContext) -> void:

	_context = character_context

	_animation = _context.animation

#==============================================================================
# Validation
#==============================================================================

func can_execute() -> bool:
	return true

#==============================================================================
# Lifecycle
#==============================================================================

func begin() -> void:

	_connect_animation()


func update(_delta: float) -> void:
	pass


func finish() -> void:

	_disconnect_animation()
	
func can_cancel() -> bool:
	return true


func cancel() -> void:
	finish()

#==============================================================================
# Animation
#==============================================================================

func _connect_animation() -> void:

	if _animation == null:
		return

	if not _animation.animation_event.is_connected(_on_animation_event):
		_animation.animation_event.connect(_on_animation_event)

	if not _animation.animation_finished.is_connected(_on_animation_finished):
		_animation.animation_finished.connect(_on_animation_finished)


func _disconnect_animation() -> void:

	if _animation == null:
		return

	if _animation.animation_event.is_connected(_on_animation_event):
		_animation.animation_event.disconnect(_on_animation_event)

	if _animation.animation_finished.is_connected(_on_animation_finished):
		_animation.animation_finished.disconnect(_on_animation_finished)

#==============================================================================
# Virtual Animation Events
#==============================================================================

func _on_animation_event(_event: StringName) -> void:
	pass


func _on_animation_finished(_animation: StringName) -> void:

	if context.action.current_action == self:
		context.action.stop_current_action()

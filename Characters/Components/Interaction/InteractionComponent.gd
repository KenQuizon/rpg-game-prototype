extends BaseComponent
class_name InteractionComponent

#==============================================================================
# Signals
#==============================================================================

signal interaction_target_changed(
	previous_target: Node,
	new_target: Node
)

signal interaction_requested(target: Node)

signal interaction_performed(target: Node)

#==============================================================================
# Cached Nodes
#==============================================================================

var _interaction_area: Area3D

#==============================================================================
# Interaction
#==============================================================================

var _nearby: Array[Node] = []

var _current_target: Node = null

#==============================================================================
# Public API
#==============================================================================

var current_target: Node:
	get:
		return _current_target


func has_target() -> bool:
	return _current_target != null


func interact() -> void:
	if _current_target == null:
		return

	interaction_requested.emit(_current_target)

	if _current_target.has_method("interact"):
		_current_target.call("interact",context.character)

	interaction_performed.emit(_current_target)

#==============================================================================
# Initialization
#==============================================================================

# InteractionComponent.on_initialize()
func on_initialize() -> void:

	if context == null:
		push_error("InteractionComponent: context is null.")
		return

	if context.character == null:
		push_error("InteractionComponent: context.character is null.")
		return

	var character := context.character

	_interaction_area = character.character_interaction_area

	if _interaction_area == null:
		push_error("InteractionArea not found.")
		return

	if not _interaction_area.body_entered.is_connected(_on_body_entered):
		_interaction_area.body_entered.connect(_on_body_entered)

	if not _interaction_area.body_exited.is_connected(_on_body_exited):
		_interaction_area.body_exited.connect(_on_body_exited)

#==============================================================================
# Area Events
#==============================================================================

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("interactable"):
		return

	if _nearby.has(body):
		return

	_nearby.append(body)

	_refresh_target()


func _on_body_exited(body: Node) -> void:

	if not _nearby.has(body):
		return

	_nearby.erase(body)

	_refresh_target()

#==============================================================================
# Internal
#==============================================================================

func _refresh_target() -> void:

	var previous := _current_target

	if _nearby.is_empty():
		_current_target = null
	else:
		_current_target = _nearby[0]

	if previous != _current_target:

		interaction_target_changed.emit(
			previous,
			_current_target
		)

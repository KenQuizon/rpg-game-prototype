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

signal interaction_cancelled(target: Node)

#==============================================================================
# Export Variables
#==============================================================================

# Used for any interactable that doesn't supply its own via
# get_interact_definition() below — assign an instant (duration = 0)
# InteractDefinition here so existing interactable scripts (which only
# implement interact(character)) keep working unchanged.
@export var default_interact_definition: InteractDefinition

#==============================================================================
# Cached Nodes
#==============================================================================

var _interaction_area: Area3D

#==============================================================================
# Interaction
#==============================================================================

var _nearby: Array[Node] = []

var _current_target: Node = null

# The target an in-flight InteractAction is actually operating on, captured
# at begin_interaction() and independent of _current_target — so if the
# character walks away (or a different object becomes nearest) mid-channel,
# the interaction still completes/cancels against the object it actually
# started with, not whatever happens to be nearest when it finishes.
var _active_target: Node = null

#==============================================================================
# Public API
#==============================================================================

var current_target: Node:
	get:
		return _current_target


func has_target() -> bool:
	return _current_target != null


# Returns the InteractDefinition to submit for this target: the target's
# own get_interact_definition() if it implements one (duck-typed, same
# pattern as the existing has_method("interact") check below), otherwise
# this component's default_interact_definition.
func get_interact_definition(target: Node) -> InteractDefinition:

	if target != null and target.has_method("get_interact_definition"):

		var custom = target.call("get_interact_definition")

		if custom is InteractDefinition:
			return custom

	return default_interact_definition

#==============================================================================
# Action Pipeline Hooks
#==============================================================================

# Called by InteractAction.on_start() — announces intent only. The
# interactable's actual interact(character) call happens in
# complete_interaction(), not here, so a channeled interaction that gets
# cancelled never triggers its target.
func begin_interaction(target: Node) -> void:

	if target == null:
		return

	_active_target = target

	interaction_requested.emit(target)


# Called by InteractAction.on_finish_requested() — the interaction
# actually happens here, once, whether that's immediately (instant case)
# or after a channeled duration completes uninterrupted.
func complete_interaction(target: Node) -> void:

	if target == null or target != _active_target:
		return

	if target.has_method("interact"):
		target.call("interact", context.character)

	interaction_performed.emit(target)

	_active_target = null


# Called by InteractAction.on_cancel()/on_interrupt() — the interaction
# was broken before completing and must not trigger its target.
func cancel_interaction(target: Node) -> void:

	if target != _active_target:
		return

	interaction_cancelled.emit(target)

	_active_target = null

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
# Updates
#==============================================================================

# Re-selects the best target as the character moves relative to nearby
# interactables — not just on enter/exit — since "closest" can change
# without anything entering or leaving the area. Only bothers when there's
# more than one candidate, since with 0 or 1 nearby the answer can't change.
func physics_update(_delta: float) -> void:

	if _nearby.size() <= 1:
		return

	_prune_invalid()
	_refresh_target()

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

func _prune_invalid() -> void:
	_nearby = _nearby.filter(
		func(body: Node): return is_instance_valid(body)
	)


func _refresh_target() -> void:

	var previous := _current_target

	_current_target = _select_best_target()

	if previous != _current_target:

		interaction_target_changed.emit(
			previous,
			_current_target
		)


# Closest-by-distance rather than "first entered" — a simple, genre-neutral
# default. A raycast-facing or priority-tag based selector can replace this
# later without touching anything outside this one function.
func _select_best_target() -> Node:

	if _nearby.is_empty():
		return null

	var character := context.character

	if character == null:
		return _nearby[0]

	var best: Node = null
	var best_distance := INF

	for candidate in _nearby:

		if not is_instance_valid(candidate):
			continue

		var candidate_3d := candidate as Node3D

		if candidate_3d == null:
			continue

		var distance := character.global_position.distance_squared_to(
			candidate_3d.global_position
		)

		if distance < best_distance:
			best_distance = distance
			best = candidate

	return best if best != null else _nearby[0]

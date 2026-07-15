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

# Emitted whenever the set or order of nearby interactables changes —
# separate from interaction_target_changed, which only means "the
# highlighted/active one changed." UI (Stage 2) listens to this to
# rebuild its list, and to the other to update the highlight.
signal interaction_list_changed(ordered: Array[Node])

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

# Distance-sorted copy of _nearby, closest first. Recomputed whenever
# _nearby changes or the character moves relative to more than one
# candidate — see physics_update(). This is what scroll cycling and the
# Stage 2 prompt list both iterate, so both always agree on order.
var _ordered_nearby: Array[Node] = []

var _current_target: Node = null

# Non-null while the player has manually scrolled to a specific target,
# overriding the default closest-first selection. Falls back to auto
# (closest) the moment this node is no longer in _ordered_nearby — see
# _resolve_current_target().
var _manual_target: Node = null

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


# Distance-sorted copy of every currently-nearby interactable, closest
# first — the same order the prompt list (Stage 2) renders and scrolling
# cycles through. Returns a duplicate so callers can't mutate internal state.
func get_ordered_nearby() -> Array[Node]:
	return _ordered_nearby.duplicate()


# Returns the target's own get_interact_info() if it implements one
# (duck-typed, same pattern as get_interact_definition() below),
# otherwise a generic fallback so any existing interactable that hasn't
# opted in still renders sensibly in the prompt list.
func get_interactable_info(target: Node) -> InteractableInfo:

	if target != null and target.has_method("get_interact_info"):

		var custom = target.call("get_interact_info")

		if custom is InteractableInfo:
			return custom

	return InteractableInfo.new()


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
# Selection
#==============================================================================

# Moves the manual selection one entry toward the front of the ordered
# list (visually "up"). Wraps. No-ops if nothing is nearby.
func select_previous() -> void:
	_cycle_selection(-1)


# Moves the manual selection one entry toward the back of the ordered
# list (visually "down"). Wraps. No-ops if nothing is nearby.
func select_next() -> void:
	_cycle_selection(1)


func _cycle_selection(delta: int) -> void:

	if _ordered_nearby.is_empty():
		return

	var current_index := _ordered_nearby.find(_current_target)

	if current_index == -1:
		current_index = 0

	var count := _ordered_nearby.size()
	var new_index := ((current_index + delta) % count + count) % count

	_manual_target = _ordered_nearby[new_index]

	var previous := _current_target

	_current_target = _manual_target

	if previous != _current_target:
		interaction_target_changed.emit(previous, _current_target)

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

	# Duck-typed against get_character_interaction_area() — context.character
	# is typed Node, not Character (roadmap 7.2), so any host implementing
	# the framework's get_character_*() contract can supply its own
	# interaction area, not just the concrete Character class.
	if not character.has_method("get_character_interaction_area"):
		push_error("InteractionComponent: host does not implement get_character_interaction_area().")
		return

	_interaction_area = character.get_character_interaction_area()

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

	_update_ordered_nearby()
	_current_target = _resolve_current_target()

	if previous != _current_target:

		interaction_target_changed.emit(
			previous,
			_current_target
		)


# Recomputes _ordered_nearby (closest-first) and emits
# interaction_list_changed only when the order or membership actually
# changed — avoids spamming the signal every physics frame once things
# have settled.
func _update_ordered_nearby() -> void:

	var new_ordered := _compute_ordered_by_distance()

	if new_ordered == _ordered_nearby:
		return

	_ordered_nearby = new_ordered

	interaction_list_changed.emit(_ordered_nearby.duplicate())


# Picks the manually-selected target if it's still valid, otherwise falls
# back to closest (index 0 of the distance-sorted list). This is the one
# place selection mode is decided — everything else just reads the result.
func _resolve_current_target() -> Node:

	if _ordered_nearby.is_empty():
		_manual_target = null
		return null

	if _manual_target != null and _ordered_nearby.has(_manual_target):
		return _manual_target

	_manual_target = null

	return _ordered_nearby[0]


# Closest-by-distance rather than "first entered" — a simple, genre-neutral
# default. A raycast-facing or priority-tag based selector can replace this
# later without touching anything outside this one function.
func _compute_ordered_by_distance() -> Array[Node]:

	if _nearby.is_empty():
		return []

	# context.character is typed Node (roadmap 7.2) — only world position is
	# needed here, so cast to Node3D rather than assuming Character, mirroring
	# TargetingComponent._select_best_target()'s identical pattern.
	var character := context.character as Node3D

	if character == null:
		return _nearby.duplicate()

	var valid: Array[Node] = _nearby.filter(
		func(candidate: Node): return is_instance_valid(candidate) and candidate is Node3D
	)

	valid.sort_custom(
		func(a: Node3D, b: Node3D) -> bool:
			var distance_a := character.global_position.distance_squared_to(a.global_position)
			var distance_b := character.global_position.distance_squared_to(b.global_position)
			return distance_a < distance_b
	)

	return valid

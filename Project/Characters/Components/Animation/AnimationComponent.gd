extends BaseComponent
class_name AnimationComponent

#==============================================================================
# Signals
#==============================================================================

signal animation_started(animation_name: StringName)
signal animation_finished(animation_name: StringName)
signal animation_event(event_name: StringName)

func play_idle() -> void:
	_play(animation_profile.idle)


func play_walk() -> void:
	_play(animation_profile.walk)


func play_attack():

	_play(
		animation_profile.attack_primary,
		true
	)
	
#==============================================================================
# Export Variables
#==============================================================================

@export var rotation_speed: float = 10.0
@export var animation_profile: AnimationProfile

#==============================================================================
# Cached References
#==============================================================================

var _movement: MovementComponent
var _visual_root: Node3D
var _animation_player: AnimationPlayer

#==============================================================================
# Animation State
#==============================================================================

var _current_animation: StringName = &""

var current_animation: StringName:
	get:
		return _current_animation

# Once movement input is seen while an action is busy-but-interruptible,
# locomotion takes over the animation channel for the rest of that
# action's run — including switching to play_idle() if movement later
# stops again. Without this latch, is_moving briefly flipping back to
# false mid-recovery would re-trigger the "no input yet" lock and freeze
# on whatever was last playing (walk), instead of falling through to
# idle. Reset whenever the action stops being busy-and-interruptible, so
# the next action starts fresh and requires its own input before
# overriding.
var _locomotion_active := false

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:

	# Duck-typed against the get_character_visual()/get_character_animation_player()
	# contract (see Character.gd) rather than requiring owner_character to be a
	# Character — any host node implementing the same methods works here.
	if not owner_character.has_method("get_character_visual"):
		return
	if not owner_character.has_method("get_character_animation_player"):
		return

	_movement = context.movement
	_visual_root = owner_character.get_character_visual()
	_animation_player = owner_character.get_character_animation_player()

	if not _animation_player.animation_finished.is_connected(_on_animation_finished):
		_animation_player.animation_finished.connect(_on_animation_finished)

#==============================================================================
# Updates
#==============================================================================

func process_update(delta: float) -> void:

	if animation_profile == null:
		return

	if _movement == null:
		return

	if _visual_root == null:
		return
		
	if context.combat != null and context.combat.is_dead():
		return 
		
	_update_locomotion_takeover()

	if _is_action_locked_with_no_input():
		return

	if context.combat != null and context.combat.is_blocking:
		play_block_idle()
		return

	if _movement.is_moving and not _is_rotation_locked():

		var direction := _movement.facing_direction

		var target_rotation := atan2(
			direction.x,
			direction.z
		)

		_visual_root.rotation.y = lerp_angle(
			_visual_root.rotation.y,
			target_rotation,
			rotation_speed * delta
		)

	if _movement.is_moving:
		play_walk()
	else:
		play_idle()

# Updates _locomotion_active — see its declaration above for why this
# needs to be a latch rather than a live is_moving check.
func _update_locomotion_takeover() -> void:

	if context.action == null or not context.action.is_busy():
		_locomotion_active = false
		return

	if not context.action.is_current_interruptible():
		_locomotion_active = false
		return

	if _movement.is_moving:
		_locomotion_active = true

# True while an action is still running and either (a) not interruptible
# yet — the window hasn't opened, so it owns the animation outright — or
# (b) interruptible but locomotion hasn't taken over yet (see
# _locomotion_active above). In case (b) we deliberately do NOT force
# play_idle(): the action's own animation should keep playing to its
# natural end unless something actually happens. "Something happens"
# means movement input, which works identically for a player (WASD) and
# an AI (chase steering via AIController._chase) — no notion of which
# controller is driving, only whether movement occurred. A brand new
# action (attack/dash/skill) interrupting doesn't go through this at
# all: it calls animation.play() directly in its own on_start(), so it
# always cuts in immediately regardless of this gate.
func _is_action_locked_with_no_input() -> bool:

	if context.action == null:
		return false

	if not context.action.is_busy():
		return false

	if not context.action.is_current_interruptible():
		return true

	return not _locomotion_active

func _is_rotation_locked() -> bool:
	return context.is_locked(ActionLock.Id.ROTATION)

#==============================================================================
# Animation
#==============================================================================

func _play(
	animation_name: StringName,
	force_restart: bool = false
) -> void:

	if _animation_player == null:
		return

	if not force_restart:
		if animation_name == _current_animation:
			return

	if not _animation_player.has_animation(animation_name):
		push_warning("Animation '%s' not found." % animation_name)
		return

	_current_animation = animation_name

	_animation_player.play(animation_name)

	animation_started.emit(animation_name)
	
func animation_event_trigger(event_name: StringName) -> void:

	animation_event.emit(event_name)

	if context == null:
		return

	if context.combat == null:
		return

	context.combat.dispatch_event(event_name)


func _on_animation_finished(animation_name: StringName) -> void:
	animation_finished.emit(animation_name)
	
func play(animation_name: StringName, force_restart := false) -> void:
	_play(animation_name, force_restart)

func play_death() -> void:
	_play(animation_profile.death, true)

func play_hurt() -> void:
	_play(animation_profile.hurt, true)

func play_dash() -> void:
	_play(animation_profile.dash, true)

func play_block_idle() -> void:
	_play(animation_profile.block_idle)

func play_block_hit() -> void:
	_play(animation_profile.block_hit, true)

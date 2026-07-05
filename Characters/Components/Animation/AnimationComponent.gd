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

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:

	var character := owner_character as Character

	if character == null:
		return

	_movement = context.movement
	_visual_root = character.character_visual
	_animation_player = character.character_animation_player

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

	# Locomotion animations never override a running action's animation —
	# this stays a blanket "any action running" check regardless of which
	# specific locks that action declares, since it's about not stomping
	# the action's own animation, not about physical movement/rotation.
	if context.action != null and context.action.is_busy():
		return

	if _movement.is_moving:
		play_walk()
	else:
		play_idle()

func _is_rotation_locked() -> bool:
	if context.action == null:
		return false
	return context.action.has_lock(ActionLock.Id.ROTATION)

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

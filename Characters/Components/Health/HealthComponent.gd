extends BaseComponent
class_name HealthComponent
#==============================================================================
# Signals
#==============================================================================
signal health_changed(previous: float, current: float)
signal damaged(amount: float)
signal healed(amount: float)
signal died()
#==============================================================================
# Export Variables
#==============================================================================
@export var profile: HealthProfile
#==============================================================================
# State
#==============================================================================
var _current_health: float = 0.0
var _dead: bool = false
var _invulnerable: bool = false
#==============================================================================
# Public Properties
#==============================================================================
var current_health: float:
	get:
		return _current_health
var max_health: float:
	get:
		if profile:
			return profile.max_health
		return 0.0
var is_dead: bool:
	get:
		return _dead
var is_alive: bool:
	get:
		return not _dead
var is_invulnerable: bool:
	get:
		return _invulnerable
#==============================================================================
# Lifecycle
#==============================================================================
func on_initialize() -> void:
	if profile == null:
		push_error("HealthProfile is not assigned.")
		return
	if profile.start_at_full_health:
		_current_health = profile.max_health
	else:
		_current_health = clamp(
			profile.starting_health,
			0.0,
			profile.max_health
		)
#==============================================================================
# Updates
#==============================================================================
func physics_update(delta: float) -> void:
	if _dead:
		return
	if profile == null:
		return
	if profile.enable_regeneration and profile.regeneration_per_second > 0.0:
		heal(
			profile.regeneration_per_second * delta
		)
#==============================================================================
# Public API
#==============================================================================
func damage(amount: float) -> void:

	if _dead:
		return

	if _invulnerable:
		return

	if amount <= 0.0:
		return

	var previous := _current_health

	print("")
	print("================ DAMAGE =================")
	print("[Health] Target:", owner.name)
	print("[Health] Incoming Damage:", amount)
	print("[Health] Health Before:", previous)

	_current_health = max(
		0.0,
		_current_health - amount
	)

	print("[Health] Health After:", _current_health)

	health_changed.emit(
		previous,
		_current_health
	)

	damaged.emit(amount)

	if _current_health <= 0.0:
		print("[Health] Target Died")
		_die()

	print("=========================================")
func heal(amount: float) -> void:
	if _dead:
		return
	if amount <= 0.0:
		return
	var previous := _current_health
	_current_health = min(
		max_health,
		_current_health + amount
	)
	if previous == _current_health:
		return
	health_changed.emit(
		previous,
		_current_health
	)
	healed.emit(
		_current_health - previous
	)
func restore_full_health() -> void:
	if profile == null:
		return
	var previous := _current_health
	_current_health = profile.max_health
	health_changed.emit(
		previous,
		_current_health
	)
func set_invulnerable(value: bool) -> void:
	_invulnerable = value
func kill() -> void:
	damage(current_health)
	
func get_health_percent() -> float:
	if max_health <= 0.0:
		return 0.0
	return _current_health / max_health
	
#==============================================================================
# Internal
#==============================================================================
func _die() -> void:
	if _dead:
		return
	_dead = true
	died.emit()

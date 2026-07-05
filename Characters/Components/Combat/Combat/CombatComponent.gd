extends BaseComponent
class_name CombatComponent
#==============================================================================
# Signals
#==============================================================================
signal damage_received(request: DamageRequest)
signal damage_dealt(request: DamageRequest)
signal attack_started()
signal attack_finished()
signal death()
#==============================================================================
# Cached Components
#==============================================================================
var _health: HealthComponent
var _stats: StatsComponent
var _hurtbox: HurtboxComponent
var _dispatcher: CombatEventDispatcher
#==============================================================================
# Attack State
#==============================================================================
var _is_attacking: bool = false
var is_attacking: bool:
	get:
		return _is_attacking
#==============================================================================
# Lifecycle
#==============================================================================
func on_initialize() -> void:
	_health = context.health
	_stats = context.stats
	_hurtbox = owner_character.get_component(HurtboxComponent)
	_dispatcher = CombatEventDispatcher.get_default()
	if _health != null:
		if not _health.died.is_connected(_on_died):
			_health.died.connect(_on_died)
#==============================================================================
# Combat Events
#==============================================================================
# Entry point for animation-driven combat events (weapon on/off, action
# finish, etc). Routes through the CombatEventDispatcher rather than
# branching here, so new events are handled by registering a new
# CombatEventHandler instead of editing this method.
func dispatch_event(event_name: StringName) -> void:
	if _dispatcher == null:
		return
	_dispatcher.dispatch(event_name, context)
# Allows a specific character (e.g. a boss with unique event handling) to
# override the shared default dispatcher without changing any call sites.
func set_dispatcher(dispatcher: CombatEventDispatcher) -> void:
	if dispatcher == null:
		return
	_dispatcher = dispatcher
#==============================================================================
# Attack Lifecycle
#==============================================================================
func begin_attack() -> void:
	_is_attacking = true
	attack_started.emit()
func finish_attack() -> void:
	if not _is_attacking:
		return
	_is_attacking = false
	var hitbox := get_hitbox()
	if hitbox != null and hitbox.is_active():
		hitbox.deactivate()
	attack_finished.emit()
#==============================================================================
# Damage
#==============================================================================
func receive_damage(request: DamageRequest) -> void:
	DamageSystem.apply_damage(
		self,
		request
	)
func apply_damage(result: DamageResult) -> void:
	if result == null:
		return
	if _health == null:
		return
	_health.damage(result.final_damage)
#==============================================================================
# Queries
#==============================================================================
func get_defense() -> float:
	if _stats == null:
		return 0.0
	return _stats.get_stat(
		StatType.Id.DEFENSE
	)
func get_hitbox() -> HitboxComponent:
	if context.weapon == null:
		return null
	return context.weapon.get_hitbox()
func get_hurtbox() -> HurtboxComponent:
	return _hurtbox
#==============================================================================
# Internal
#==============================================================================
func _on_died() -> void:
	death.emit()

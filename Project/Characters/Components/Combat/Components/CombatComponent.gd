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
var _active_projectile_scene: PackedScene = null
var _active_projectile_data: AttackData = null
#==============================================================================
# Attack State
#==============================================================================
var _is_attacking: bool = false
var is_attacking: bool:
	get:
		return _is_attacking
		
#==============================================================================
# Defense State
#==============================================================================

var _is_blocking: bool = false
var is_blocking: bool:
	get:
		return _is_blocking

var _is_evading: bool = false
var is_evading: bool:
	get:
		return _is_evading

func set_blocking(value: bool) -> void:
	_is_blocking = value

func set_evading(value: bool) -> void:
	_is_evading = value
#==============================================================================
# Lifecycle
#==============================================================================
func on_initialize() -> void:
	_health = context.health
	_stats = context.stats
	# registry (not owner_character.get_component) — BaseComponent already
	# exposes the registry directly, so this needs no Node-hierarchy access
	# at all and works for any host, Character or otherwise.
	_hurtbox = registry.get_component(HurtboxComponent)
	_dispatcher = CombatEventDispatcher.get_default()
	if _health != null:
		if not _health.died.is_connected(_on_died):
			_health.died.connect(_on_died)
	if not damage_received.is_connected(_on_damage_received):
		damage_received.connect(_on_damage_received)
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
	# DamagePipeline (via DamageApplicationStage) already applies the
	# damage to this target internally as part of resolving the request.
	# The returned DamageResult is for callers who want the outcome (e.g.
	# for events/UI) — it must not be re-applied here, or every hit deals
	# double damage.
	DamageSystem.apply_damage(self, request)

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

	# Death should immediately stop whatever the character was doing, not
	# let an in-flight action run out its recovery — cancel() (not
	# request_finish()) is deliberate here: dying is not a natural
	# completion, it should behave like any other hard interrupt.
	if context.action != null:
		context.action.cancel_current()

	# Duck-typed against get_character_state_machine() rather than
	# context.character.character_state_machine — a state machine is an
	# optional capability, not something every damageable host has (a
	# destructible object dying doesn't need a CharacterDeadState).
	if owner_character.has_method("get_character_state_machine"):
		var state_machine: CharacterStateMachine = owner_character.get_character_state_machine()
		if state_machine != null:
			state_machine.change_state(CharacterDeadState.new())

	if context.status != null:
		context.status.clear_all()

	death.emit()
	
# CombatComponent — new query, alongside get_defense()/get_hitbox()/get_hurtbox()
func is_dead() -> bool:
	return _health != null and _health.is_dead

func set_active_projectile(scene: PackedScene, data: AttackData) -> void:
	_active_projectile_scene = scene
	_active_projectile_data = data

func clear_active_projectile() -> void:
	_active_projectile_scene = null
	_active_projectile_data = null

func get_active_projectile_scene() -> PackedScene:
	return _active_projectile_scene

func get_active_projectile_data() -> AttackData:
	return _active_projectile_data

func _on_damage_received(result: DamageResult) -> void:

	if is_dead():
		return   # the killing blow already triggered play_death() via _on_died()

	if context.animation == null:
		return

	if result.evaded:
		return

	if result.blocked:
		context.animation.play_block_hit()   # see below
		return

	context.animation.play_hurt()

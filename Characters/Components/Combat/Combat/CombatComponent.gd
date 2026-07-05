extends BaseComponent
class_name CombatComponent

#==============================================================================
# Signals
#==============================================================================

signal damage_received(request: DamageRequest)
signal damage_dealt(request: DamageRequest)
signal death()

#==============================================================================
# Cached Components
#==============================================================================

var _health: HealthComponent
var _stats: StatsComponent
var _hurtbox: HurtboxComponent

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:

	_health = context.health
	_stats = context.stats
	_hurtbox = owner_character.get_component(HurtboxComponent)

	if _health != null:
		if not _health.died.is_connected(_on_died):
			_health.died.connect(_on_died)

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

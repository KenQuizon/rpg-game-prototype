extends BaseComponent
class_name StatusComponent

#==============================================================================
# Signals
#==============================================================================

signal status_applied(instance: StatusEffectInstance)
signal status_removed(instance: StatusEffectInstance)

#==============================================================================
# Cached Components
#==============================================================================

var _stats: StatsComponent
var _combat: CombatComponent

#==============================================================================
# Runtime
#==============================================================================

var _active: Dictionary = {} # StringName -> StatusEffectInstance

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:
	_stats = context.stats
	_combat = context.combat

#==============================================================================
# Public API
#==============================================================================

func apply_status(
	data: StatusEffectData,
	source: Object = null
) -> StatusEffectInstance:

	if data == null:
		return null

	if data.id.is_empty():
		push_warning(
			"StatusEffectData '%s' has no id set — multiple such resources will collide in StatusComponent's active-status dictionary." % data.resource_path
		)

	if _active.has(data.id):
		return _reapply_status(data, source)

	var instance := StatusEffectInstance.new(data, source)

	_active[data.id] = instance

	_apply_modifiers(instance)

	status_applied.emit(instance)

	return instance


func remove_status(id: StringName) -> void:

	if not _active.has(id):
		return

	var instance: StatusEffectInstance = _active[id]

	_remove_modifiers(instance)

	_active.erase(id)

	status_removed.emit(instance)


func clear_all() -> void:
	for id in _active.keys().duplicate():
		remove_status(id)


func has_status(id: StringName) -> bool:
	return _active.has(id)


func get_status(id: StringName) -> StatusEffectInstance:
	return _active.get(id)


func get_active_statuses() -> Array[StatusEffectInstance]:
	var result: Array[StatusEffectInstance] = []
	for instance in _active.values():
		result.append(instance)
	return result

#==============================================================================
# Locks
#==============================================================================

# Mirrors ActionComponent.has_lock()'s interface so CharacterContext can
# query both action-driven and status-driven locks through one call
# (see CharacterContext.is_locked).
func has_lock(lock: int) -> bool:
	return (get_active_locks() & lock) != 0


func get_active_locks() -> int:

	var locks := ActionLock.Id.NONE

	for instance: StatusEffectInstance in _active.values():
		locks |= instance.data.locks

	return locks

#==============================================================================
# Updates
#==============================================================================

func process_update(delta: float) -> void:

	if _active.is_empty():
		return

	var expired: Array[StringName] = []

	for id in _active.keys():

		var instance: StatusEffectInstance = _active[id]

		_tick_damage(instance, delta)

		if instance.data.duration > 0.0:

			instance.remaining_duration -= delta

			if instance.remaining_duration <= 0.0:
				expired.append(id)

	for id in expired:
		remove_status(id)

#==============================================================================
# Internal — Stacking
#==============================================================================

func _reapply_status(
	data: StatusEffectData,
	source: Object
) -> StatusEffectInstance:

	var instance: StatusEffectInstance = _active[data.id]

	match data.stack_mode:

		StatusEffectData.StackMode.IGNORE_IF_ACTIVE:
			pass

		StatusEffectData.StackMode.ADD_STACK:
			if instance.stacks < data.max_stacks:
				instance.stacks += 1
				_apply_modifiers(instance, true)
			instance.remaining_duration = data.duration

		StatusEffectData.StackMode.REFRESH_DURATION, _:
			instance.remaining_duration = data.duration

	return instance

#==============================================================================
# Internal — Stat Modifiers
#==============================================================================

func _apply_modifiers(
	instance: StatusEffectInstance,
	additional_stack_only: bool = false
) -> void:

	if _stats == null:
		return

	if instance.data.stat_modifiers.is_empty():
		return

	# additional_stack_only exists so ADD_STACK re-applications add another
	# copy of the modifiers (one "dose" per stack) without needing to track
	# which specific StatModifier belongs to which stack — since every
	# modifier from this instance shares the same source object, they are
	# all removed together in one call when the effect fully expires.
	for entry: StatModifierEntry in instance.data.stat_modifiers:
		_stats.add_modifier(
			entry.stat,
			StatModifier.new(instance, entry.value)
		)


func _remove_modifiers(instance: StatusEffectInstance) -> void:

	if _stats == null:
		return

	_stats.remove_modifiers_from_source(instance)

#==============================================================================
# Internal — Damage Over Time
#==============================================================================

func _tick_damage(instance: StatusEffectInstance, delta: float) -> void:

	if instance.data.damage_per_tick <= 0.0:
		return

	if instance.data.tick_interval <= 0.0:
		return

	instance.time_since_tick += delta

	while instance.time_since_tick >= instance.data.tick_interval:

		instance.time_since_tick -= instance.data.tick_interval

		_apply_tick_damage(instance)


func _apply_tick_damage(instance: StatusEffectInstance) -> void:

	if _combat == null:
		return

	var builder := DamageRequestBuilder.new()

	builder \
		.attacker(instance.source as CombatComponent) \
		.source(instance) \
		.damage(instance.data.damage_per_tick) \
		.damage_type(instance.data.damage_type) \
		.can_be_blocked(false) \
		.can_be_evaded(false) \
		.can_stagger(false)

	for tag in instance.data.tags:
		builder.add_tag(tag)

	_combat.receive_damage(builder.build())

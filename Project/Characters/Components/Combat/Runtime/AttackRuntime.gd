extends RefCounted
class_name AttackRuntime

#==============================================================================
# Private
#==============================================================================

var _weapon: WeaponComponent

# The weapon instance combo_index was last read against. Compared each
# call so a mid-combo weapon switch (Stage 1's range-based selection)
# resets the combo instead of misapplying its index/count against a
# different weapon's attack set.
var _last_instance: WeaponInstance

#==============================================================================
# Initialization
#==============================================================================

func initialize(
	weapon: WeaponComponent
) -> void:

	_weapon = weapon

#==============================================================================
# Public API
#==============================================================================

func select_next_attack() -> AttackDefinition:

	if _weapon == null:
		return null

	var combo := _weapon.context.combo
	var set := _weapon.get_attack_set()

	if combo == null or set == null:
		return null

	var instance := _weapon.current_instance

	if instance != _last_instance:
		combo.reset_combo()
		_last_instance = instance

	# Pure read — no longer advances anything. Safe to call as many times
	# as validation needs to; it always returns the same attack until
	# commit_attack() below is actually called.
	return set.get_light_attack(combo.combo_index)

# Called by AttackAction.on_start() — the one place guaranteed to run only
# once an attack has actually been accepted by the scheduler and begun.
func commit_attack(attack: AttackDefinition) -> void:

	if _weapon == null:
		return

	var combo := _weapon.context.combo
	var set := _weapon.get_attack_set()

	if combo == null or set == null:
		return

	if not combo.is_combo_active():
		combo.begin_combo()
	else:
		combo.reset_timer()

	if attack != null and attack.timing != null:
		combo.set_active_timeout(attack.timing.combo_close_time)

	combo.advance_combo(
		set.get_light_attack_count()
	)


func reset_combo() -> void:

	if _weapon == null:
		return

	if _weapon.context.combo:
		_weapon.context.combo.reset_combo()

	_last_instance = null

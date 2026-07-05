extends RefCounted
class_name AttackRuntime

#==============================================================================
# Private
#==============================================================================

var _weapon: WeaponComponent

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

	if combo == null:
		return null

	if set == null:
		return null

	if not combo.is_combo_active():
		combo.begin_combo()
	else:
		combo.reset_timer()

	var attack = set.get_light_attack(
		combo.combo_index
	)

	combo.advance_combo(
		set.get_light_attack_count()
	)

	return attack


func reset_combo() -> void:

	if _weapon == null:
		return

	if _weapon.context.combo:
		_weapon.context.combo.reset_combo()

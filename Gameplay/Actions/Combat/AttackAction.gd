extends CharacterAction
class_name AttackAction

#==============================================================================
# Runtime
#==============================================================================

var _weapon: WeaponComponent
var _attack: AttackDefinition

#==============================================================================
# Validation
#==============================================================================

func can_execute() -> bool:

	_weapon = context.weapon

	if _weapon == null:
		return false

	if not _weapon.has_weapon():
		return false

	_attack = _weapon.select_next_attack()

	if _attack == null:
		return false

	return true

#==============================================================================
# Lifecycle
#==============================================================================

func begin() -> void:

	super.begin()

	context.combat.begin_attack()

	_play_attack_animation()


func finish() -> void:

	context.combat.finish_attack()

	super.finish()

#==============================================================================
# Internal
#==============================================================================

func _play_attack_animation() -> void:

	if _attack == null:
		return

	if _attack.animation.is_empty():
		animation.play_attack()
		return

	animation.play(
		_attack.animation,
		true
	)

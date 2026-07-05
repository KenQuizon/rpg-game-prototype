extends RefCounted
class_name AttackContext

#==============================================================================
# Runtime
#==============================================================================

var attacker: Character

var weapon: WeaponComponent

var attack: AttackDefinition

#==============================================================================
# State
#==============================================================================

var started := false

var finished := false

var elapsed_time := 0.0

#==============================================================================
# API
#==============================================================================

func begin(
	p_attacker: Character,
	p_weapon: WeaponComponent,
	p_attack: AttackDefinition
) -> void:

	attacker = p_attacker
	weapon = p_weapon
	attack = p_attack

	started = true
	finished = false
	elapsed_time = 0.0


func update(delta: float) -> void:

	if not started:
		return

	if finished:
		return

	elapsed_time += delta


func finish() -> void:

	finished = true


func clear() -> void:

	attacker = null
	weapon = null
	attack = null

	started = false
	finished = false
	elapsed_time = 0.0

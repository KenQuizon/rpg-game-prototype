extends Resource
class_name AttackSet

#==============================================================================
# Light Combo
#==============================================================================

@export var light_attacks: Array[AttackDefinition] = []

#==============================================================================
# Heavy Attacks
#==============================================================================

@export var heavy_attack: AttackDefinition

#==============================================================================
# Movement Attacks
#==============================================================================

@export var dash_attack: AttackDefinition

@export var running_attack: AttackDefinition

@export var air_attack: AttackDefinition

#==============================================================================
# Utility
#==============================================================================

func get_light_attack(index: int) -> AttackDefinition:

	if light_attacks.is_empty():
		return null

	index = clamp(index, 0, light_attacks.size() - 1)

	return light_attacks[index]


func get_light_attack_count() -> int:
	return light_attacks.size()


func has_light_combo() -> bool:
	return not light_attacks.is_empty()


func has_heavy_attack() -> bool:
	return heavy_attack != null


func has_dash_attack() -> bool:
	return dash_attack != null


func has_running_attack() -> bool:
	return running_attack != null


func has_air_attack() -> bool:
	return air_attack != null

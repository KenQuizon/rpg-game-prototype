extends Node3D
class_name AttackRangeIndicator

func set_range(attack_range: float) -> void:
	scale = Vector3(attack_range, 1.0, attack_range)

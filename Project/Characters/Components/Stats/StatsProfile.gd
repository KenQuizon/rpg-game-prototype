extends Resource
class_name StatsProfile

@export_group("Primary Attributes")

@export var strength: float = 10.0

@export var dexterity: float = 10.0

@export var intelligence: float = 10.0

@export var vitality: float = 10.0

@export_group("Combat")

@export var defense: float = 0.0

@export var attack_speed: float = 1.0

@export var critical_chance: float = 0.05

@export var critical_damage: float = 1.5

@export var poise: float = 50.0

@export_group("Movement")

@export var move_speed: float = 4.5

extends Control
class_name CharacterStatsPanel

@onready var stat_items: VBoxContainer = $VBoxContainer/StatsList
@onready var character_name: Label = $VBoxContainer/CharacterName
@onready var level_label: Label = $VBoxContainer/Level
@onready var experience_bar: ProgressBar = $VBoxContainer/ExperienceBar

@export var stat_item_scene: PackedScene

var character: Character
var stats_component: StatsComponent

func setup(bound_character: Character) -> void:
	character = bound_character

	if character == null:
		return

	character_name.text = character.name

	# No leveling/XP system exists yet — static placeholders until that
	# gameplay system is built.
	level_label.text = "Lv. 1"
	experience_bar.visible = false

	if character.context and character.context.stats:
		stats_component = character.context.stats
		update_stats()
		stats_component.stat_changed.connect(_on_stat_changed)

func update_stats() -> void:
	for child in stat_items.get_children():
		child.queue_free()

	var stat_types: Array[StatType.Id] = [
		StatType.Id.STRENGTH,
		StatType.Id.DEXTERITY,
		StatType.Id.INTELLIGENCE,
		StatType.Id.VITALITY,
		StatType.Id.DEFENSE,
		StatType.Id.MOVE_SPEED,
		StatType.Id.ATTACK_SPEED,
		StatType.Id.CRITICAL_CHANCE,
		StatType.Id.CRITICAL_DAMAGE,
		StatType.Id.POISE,
	]

	for stat_type in stat_types:
		var stat_value := stats_component.get_stat(stat_type)
		var stat_item = stat_item_scene.instantiate()
		stat_items.add_child(stat_item)
		stat_item.set_stat(StatType.Id.keys()[stat_type].capitalize(), stat_value)

func _on_stat_changed(_stat: StatType.Id, _old_value: float, _new_value: float) -> void:
	update_stats()

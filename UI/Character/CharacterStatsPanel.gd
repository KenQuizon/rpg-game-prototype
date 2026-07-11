extends BaseUIPanel
class_name CharacterStatsPanel

@onready var stat_items: VBoxContainer = $VBoxContainer/StatsList
@onready var character_name: Label = $VBoxContainer/CharacterName
@onready var level_label: Label = $VBoxContainer/Level
@onready var experience_bar: ProgressBar = $VBoxContainer/ExperienceBar

@export var stat_item_scene: PackedScene

var character: Character
var stats_component: Node

func _ready() -> void:
	super._ready()
	character = get_tree().root.get_node("World/Player")
	
	if character:
		character_name.text = character.name
		if character.has_method("get_character_stats"):
			stats_component = character.get_character_stats()
			update_stats()
			stats_component.stat_changed.connect(_on_stat_changed)

func update_stats() -> void:
	# Clear existing items
	for child in stat_items.get_children():
		child.queue_free()
	
	# Add stat items for each stat
	var stat_types = ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]
	
	for stat_type in stat_types:
		var stat_value = stats_component.get_stat(stat_type)
		var stat_item = stat_item_scene.instantiate()
		stat_item.set_stat(stat_type, stat_value)
		stat_items.add_child(stat_item)

func _on_stat_changed(stat_name: String, new_value: float) -> void:
	update_stats()

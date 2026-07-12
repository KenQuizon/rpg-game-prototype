extends Node
class_name CharacterRef

# Provides a consistent way to access the player character and its
# components. Gameplay components live on character.context (a
# CharacterContext), NOT behind get_character_*() methods — those methods
# are reserved for framework/visual plumbing (visual root, animation
# player, weapon sockets). See Character.gd / CharacterContext.gd.
static var player: Character


static func get_player() -> Character:
	"""Get the player character (auto-finds if needed)"""
	if not player:
		_find_player()
	return player


# Static functions can't call instance methods like get_tree(), so the
# tree is reached via Engine.get_main_loop() instead — that call is
# static-safe.
static func _find_player() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return

	var found := tree.root.find_child("Character", true, false)
	if found is Character:
		player = found
		print("Player character found: %s" % player.name)


static func get_player_health() -> HealthComponent:
	"""Get player health component"""
	var p := get_player()
	if p and p.context:
		return p.context.health
	return null


static func get_player_resources() -> ResourceComponent:
	"""Get player resource component (mana/stamina/etc.)"""
	var p := get_player()
	if p and p.context:
		return p.context.resources
	return null


static func get_player_skills() -> SkillComponent:
	"""Get player skills component"""
	var p := get_player()
	if p and p.context:
		return p.context.skills
	return null


static func get_player_inventory() -> InventoryComponent:
	"""Get player inventory component"""
	var p := get_player()
	if p and p.context:
		return p.context.inventory
	return null


static func get_player_equipment() -> EquipmentComponent:
	"""Get player equipment component"""
	var p := get_player()
	if p and p.context:
		return p.context.equipment
	return null


static func get_player_stats() -> StatsComponent:
	"""Get player stats component"""
	var p := get_player()
	if p and p.context:
		return p.context.stats
	return null

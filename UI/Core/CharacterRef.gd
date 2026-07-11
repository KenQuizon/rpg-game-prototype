extends Node
class_name CharacterRef

# Provides consistent way to access character and its components
static var player: Character

func _enter_tree() -> void:
	# Auto-find player when scene loads
	await get_tree().process_frame
	if not player:
		player = get_tree().root.find_child("Player", true, false)
		if player:
			print("Player character found: %s" % player.name)

static func get_player() -> Character:
	"""Get the player character (auto-finds if needed)"""
	if not player:
		player = get_tree().root.find_child("Player", true, false)
	return player

static func get_player_health() -> Node:
	"""Get player health component"""
	var p = get_player()
	if p and p.has_method("get_character_health"):
		return p.get_character_health()
	return null

static func get_player_skills() -> Node:
	"""Get player skills component"""
	var p = get_player()
	if p and p.has_method("get_character_skills"):
		return p.get_character_skills()
	return null

static func get_player_inventory() -> Node:
	"""Get player inventory component"""
	var p = get_player()
	if p and p.has_method("get_character_inventory"):
		return p.get_character_inventory()
	return null

static func get_player_equipment() -> Node:
	"""Get player equipment component"""
	var p = get_player()
	if p and p.has_method("get_character_equipment"):
		return p.get_character_equipment()
	return null

static func get_player_stats() -> Node:
	"""Get player stats component"""
	var p = get_player()
	if p and p.has_method("get_character_stats"):
		return p.get_character_stats()
	return null

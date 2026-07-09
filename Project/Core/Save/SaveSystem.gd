extends RefCounted
class_name SaveSystem

const SAVE_PATH := "user://savegame.json"

static func save_game(character: Character) -> bool:

	var data := character.save_state()
	var json := JSON.stringify(data)

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		return false

	file.store_string(json)
	file.close()

	return true

static func load_game(character: Character) -> bool:

	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		return false

	var text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)

	if parsed == null or not (parsed is Dictionary):
		return false

	character.load_state(parsed)

	return true

static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

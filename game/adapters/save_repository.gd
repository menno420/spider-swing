extends RefCounted
class_name SaveRepository
## Exclusive persistent writer for player-owned state.
##
## Settings use the same versioned, recoverable write seam that future
## progression will extend. Presentation and application never write files.

const SETTINGS_PATH := "user://player_settings.json"
const TEMP_PATH := "user://player_settings.json.tmp"
const BACKUP_PATH := "user://player_settings.json.bak"


func load_settings() -> PlayerSettings:
	var primary := _read_dictionary(SETTINGS_PATH)
	if not primary.is_empty():
		return PlayerSettings.from_dictionary(primary)
	var backup := _read_dictionary(BACKUP_PATH)
	if not backup.is_empty():
		return PlayerSettings.from_dictionary(backup)
	return PlayerSettings.defaults()


func save_settings(settings: PlayerSettings) -> bool:
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(settings.to_dictionary(), "\t"))
	file.flush()
	file.close()

	var primary_absolute := ProjectSettings.globalize_path(SETTINGS_PATH)
	var temporary_absolute := ProjectSettings.globalize_path(TEMP_PATH)
	var backup_absolute := ProjectSettings.globalize_path(BACKUP_PATH)
	if FileAccess.file_exists(BACKUP_PATH):
		DirAccess.remove_absolute(backup_absolute)
	if FileAccess.file_exists(SETTINGS_PATH):
		if DirAccess.rename_absolute(primary_absolute, backup_absolute) != OK:
			DirAccess.remove_absolute(temporary_absolute)
			return false
	var result := DirAccess.rename_absolute(temporary_absolute, primary_absolute)
	if result != OK:
		if FileAccess.file_exists(BACKUP_PATH):
			DirAccess.rename_absolute(backup_absolute, primary_absolute)
		return false
	if FileAccess.file_exists(BACKUP_PATH):
		DirAccess.remove_absolute(backup_absolute)
	return true


static func decode_settings(text: String) -> PlayerSettings:
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		return PlayerSettings.from_dictionary(parsed as Dictionary)
	return PlayerSettings.defaults()


func _read_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed as Dictionary if parsed is Dictionary else {}

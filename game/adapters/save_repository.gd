extends RefCounted
class_name SaveRepository
## Exclusive persistent writer for player-owned state.
##
## Settings use the same versioned, recoverable write seam that future
## progression will extend. Presentation and application never write files.

const SETTINGS_PATH := "user://player_settings.json"

var _settings_path: String
var _temp_path: String
var _backup_path: String


func _init(settings_path: String = SETTINGS_PATH) -> void:
	_settings_path = settings_path
	_temp_path = "%s.tmp" % settings_path
	_backup_path = "%s.bak" % settings_path


func load_settings() -> PlayerSettings:
	var primary := _read_dictionary(_settings_path)
	if not primary.is_empty():
		return PlayerSettings.from_dictionary(primary)
	var backup := _read_dictionary(_backup_path)
	if not backup.is_empty():
		return PlayerSettings.from_dictionary(backup)
	return PlayerSettings.defaults()


func save_settings(settings: PlayerSettings) -> bool:
	var file := FileAccess.open(_temp_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(settings.to_dictionary(), "\t"))
	file.flush()
	file.close()

	var primary_absolute := ProjectSettings.globalize_path(_settings_path)
	var temporary_absolute := ProjectSettings.globalize_path(_temp_path)
	var backup_absolute := ProjectSettings.globalize_path(_backup_path)
	if FileAccess.file_exists(_backup_path):
		DirAccess.remove_absolute(backup_absolute)
	if FileAccess.file_exists(_settings_path):
		if DirAccess.rename_absolute(primary_absolute, backup_absolute) != OK:
			DirAccess.remove_absolute(temporary_absolute)
			return false
	var result := DirAccess.rename_absolute(temporary_absolute, primary_absolute)
	if result != OK:
		if FileAccess.file_exists(_backup_path):
			DirAccess.rename_absolute(backup_absolute, primary_absolute)
		return false
	if FileAccess.file_exists(_backup_path):
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

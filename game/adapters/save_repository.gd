extends RefCounted
class_name SaveRepository
## Exclusive persistent writer for player-owned state.
##
## Settings and progression share one versioned, recoverable write seam.
## Presentation and application never write files directly.

const SETTINGS_PATH := "user://player_settings.json"
const PROGRESS_PATH := "user://player_progress.json"

var _settings_path: String
var _progress_path: String


func _init(
	settings_path: String = SETTINGS_PATH,
	progress_path: String = PROGRESS_PATH,
) -> void:
	_settings_path = settings_path
	_progress_path = progress_path


func load_settings() -> PlayerSettings:
	var primary := _read_dictionary(_settings_path)
	if not primary.is_empty():
		return PlayerSettings.from_dictionary(primary)
	var backup := _read_dictionary("%s.bak" % _settings_path)
	if not backup.is_empty():
		return PlayerSettings.from_dictionary(backup)
	return PlayerSettings.defaults()


func save_settings(settings: PlayerSettings) -> bool:
	return _write_dictionary(_settings_path, settings.to_dictionary())


func load_progress() -> PlayerProgress:
	var primary := _read_dictionary(_progress_path)
	if not primary.is_empty():
		return PlayerProgress.from_dictionary(primary)
	var backup := _read_dictionary("%s.bak" % _progress_path)
	if not backup.is_empty():
		return PlayerProgress.from_dictionary(backup)
	return PlayerProgress.defaults()


func save_progress(progress: PlayerProgress) -> bool:
	return _write_dictionary(_progress_path, progress.to_dictionary())


func _write_dictionary(path: String, data: Dictionary) -> bool:
	var temporary_path := "%s.tmp" % path
	var backup_path := "%s.bak" % path
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	file.close()

	var primary_absolute := ProjectSettings.globalize_path(path)
	var temporary_absolute := ProjectSettings.globalize_path(temporary_path)
	var backup_absolute := ProjectSettings.globalize_path(backup_path)
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_absolute)
	if FileAccess.file_exists(path):
		if DirAccess.rename_absolute(primary_absolute, backup_absolute) != OK:
			DirAccess.remove_absolute(temporary_absolute)
			return false
	var result := DirAccess.rename_absolute(temporary_absolute, primary_absolute)
	if result != OK:
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(backup_absolute, primary_absolute)
		return false
	if FileAccess.file_exists(backup_path):
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

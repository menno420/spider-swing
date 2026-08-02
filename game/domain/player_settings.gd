extends RefCounted
class_name PlayerSettings
## Versioned player-facing configuration.
##
## This is a value object. It performs validation and serialization but never
## touches the filesystem; SaveRepository is the only persistent writer.

const SCHEMA_VERSION := 3

var swing_preset: StringName = SwingConfig.PRESET_BALANCED
var show_control_hints: bool = true
var reduced_motion: bool = false
var music_enabled: bool = true
var effects_enabled: bool = true
var haptics_enabled: bool = true
var show_debug_tools: bool = true


static func defaults() -> PlayerSettings:
	return PlayerSettings.new()


static func from_dictionary(data: Dictionary) -> PlayerSettings:
	var settings := PlayerSettings.new()
	var requested_preset := SwingConfig.resolve_preset(StringName(str(
		data.get("swing_preset", SwingConfig.PRESET_BALANCED))))
	if requested_preset != &"":
		settings.swing_preset = requested_preset
	settings.show_control_hints = bool(data.get("show_control_hints", true))
	settings.reduced_motion = bool(data.get("reduced_motion", false))
	settings.music_enabled = bool(data.get("music_enabled", true))
	settings.effects_enabled = bool(data.get("effects_enabled", true))
	settings.haptics_enabled = bool(data.get("haptics_enabled", true))
	settings.show_debug_tools = bool(data.get("show_debug_tools", true))
	return settings


func copy() -> PlayerSettings:
	return PlayerSettings.from_dictionary(to_dictionary())


func to_dictionary() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"swing_preset": str(swing_preset),
		"show_control_hints": show_control_hints,
		"reduced_motion": reduced_motion,
		"music_enabled": music_enabled,
		"effects_enabled": effects_enabled,
		"haptics_enabled": haptics_enabled,
		"show_debug_tools": show_debug_tools,
	}

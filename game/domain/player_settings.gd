extends RefCounted
class_name PlayerSettings
## Versioned player-facing configuration.
##
## This is a value object. It performs validation and serialization but never
## touches the filesystem; SaveRepository is the only persistent writer.

const SCHEMA_VERSION := 4
const DEFAULT_MUSIC_VOLUME := 0.5
const MIN_MUSIC_VOLUME := 0.0
const MAX_MUSIC_VOLUME := 1.0

var swing_preset: StringName = SwingConfig.PRESET_BALANCED
var show_control_hints: bool = true
var reduced_motion: bool = false
var music_volume: float = DEFAULT_MUSIC_VOLUME
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
	if data.has("music_volume"):
		settings.music_volume = _validated_music_volume(
			data.get("music_volume", DEFAULT_MUSIC_VOLUME),
		)
	else:
		# Schema 1–3 stored only a binary toggle. Preserve its exact audible
		# meaning: enabled maps to the shipped mix midpoint; disabled stays
		# silent. The new slider can then move in either direction.
		settings.music_volume = (
			DEFAULT_MUSIC_VOLUME
			if bool(data.get("music_enabled", true))
			else MIN_MUSIC_VOLUME
		)
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
		"music_volume": music_volume,
		# Derived compatibility shadow for an intentional downgrade to a build
		# that predates schema 4. It is never authoritative in current code.
		"music_enabled": music_volume > MIN_MUSIC_VOLUME,
		"effects_enabled": effects_enabled,
		"haptics_enabled": haptics_enabled,
		"show_debug_tools": show_debug_tools,
	}


static func _validated_music_volume(value: Variant) -> float:
	var parsed := float(value)
	if not is_finite(parsed):
		return DEFAULT_MUSIC_VOLUME
	return clampf(parsed, MIN_MUSIC_VOLUME, MAX_MUSIC_VOLUME)

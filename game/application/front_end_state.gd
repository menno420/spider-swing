extends RefCounted
class_name FrontEndState
## Application-owned navigation and settings state for the pre-run experience.
##
## Presentation calls these APIs and consumes `changed`; it does not decide
## which settings are valid or when a run may start.

signal changed
signal play_requested(settings: PlayerSettings)
signal settings_changed(settings: PlayerSettings)

enum Screen {
	HOME,
	TUTORIAL,
	SETTINGS,
}

const TUTORIAL_STEPS := [
	{
		"title": "KEEP MOVING",
		"kicker": "01 · THE RUN",
		"body": "The spider moves forward automatically. Your job is to shape "
			+ "that speed into a safe path and travel as far as possible.",
		"tip": "Watch the space ahead, not only the spider.",
	},
	{
		"title": "TAP THE CEILING",
		"kicker": "02 · ATTACH",
		"body": "Tap any solid ceiling or obstacle edge to fire a web. The small "
			+ "glowing markers are aim guides, not the only valid attachment "
			+ "points. Nearby taps are forgiven; out-of-range targets are not.",
		"tip": "Aim ahead along the ceiling to build a longer forward arc.",
	},
	{
		"title": "RELEASE WITH MOMENTUM",
		"kicker": "03 · SWING",
		"body": "While attached, tap anywhere away from the controls to release. "
			+ "Your velocity is preserved, so timing controls height and speed.",
		"tip": "Release while rising to carry momentum forward.",
	},
	{
		"title": "HOLD THE LARGE REEL",
		"kicker": "04 · REEL-IN",
		"body": "Use your left thumb to hold REEL while aiming with your right. "
			+ "It shortens the line at a fixed rate while the rope constraint "
			+ "guides you inward. It no longer stacks a separate speed boost. "
			+ "The energy ring recharges afterward.",
		"tip": "Reel changes your swing radius; release timing still controls speed.",
	},
	{
		"title": "PULL TO THE TARGET",
		"kicker": "05 · ANCHOR BURST",
		"body": "Tap BURST while attached, or double-tap any solid target, to "
			+ "cross half the web distance in a quick controlled pull. Tapping "
			+ "a solid below performs a shorter 25% Dive Pull and never stays "
			+ "attached. During either pull, tap an upper solid to recover with "
			+ "a normal web immediately.",
		"tip": "Burst gains height; lower anchor windows redirect you under high obstacles.",
	},
	{
		"title": "SURVIVE & RECOVER",
		"kicker": "06 · STAY ALIVE",
		"body": "Hitting a warning-colored obstacle, falling below the course, or being "
			+ "left behind ends the run. Tap after death to restart, or use "
			+ "MENU to return here. DEBUG remains optional in Settings.",
		"tip": "Ceilings and floors have gaps: read each silhouette and choose a route.",
	},
]

var screen: int = Screen.HOME
var tutorial_index: int = 0
var settings: PlayerSettings = PlayerSettings.defaults()


func configure(initial_settings: PlayerSettings) -> void:
	settings = initial_settings.copy()
	screen = Screen.HOME
	tutorial_index = 0
	changed.emit()


func show_home() -> void:
	screen = Screen.HOME
	changed.emit()


func show_tutorial() -> void:
	screen = Screen.TUTORIAL
	tutorial_index = 0
	changed.emit()


func show_settings() -> void:
	screen = Screen.SETTINGS
	changed.emit()


func next_tutorial_step() -> void:
	if tutorial_index >= TUTORIAL_STEPS.size() - 1:
		request_play()
		return
	tutorial_index += 1
	changed.emit()


func previous_tutorial_step() -> void:
	tutorial_index = maxi(0, tutorial_index - 1)
	changed.emit()


func request_play() -> void:
	play_requested.emit(settings.copy())


func set_swing_preset(preset: StringName) -> void:
	if preset not in SwingConfig.preset_names() or settings.swing_preset == preset:
		return
	settings.swing_preset = preset
	_publish_settings()


func set_control_hints(enabled: bool) -> void:
	if settings.show_control_hints == enabled:
		return
	settings.show_control_hints = enabled
	_publish_settings()


func set_reduced_motion(enabled: bool) -> void:
	if settings.reduced_motion == enabled:
		return
	settings.reduced_motion = enabled
	_publish_settings()


func set_debug_tools(enabled: bool) -> void:
	if settings.show_debug_tools == enabled:
		return
	settings.show_debug_tools = enabled
	_publish_settings()


func reset_settings() -> void:
	settings = PlayerSettings.defaults()
	_publish_settings()


func current_tutorial_step() -> Dictionary:
	return TUTORIAL_STEPS[tutorial_index]


func _publish_settings() -> void:
	settings_changed.emit(settings.copy())
	changed.emit()

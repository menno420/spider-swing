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
		"title": "TAP AN ANCHOR",
		"kicker": "02 · ATTACH",
		"body": "Tap a glowing cyan anchor to fire a web. Targets outside your "
			+ "range are rejected, so choose the next reachable point.",
		"tip": "Higher anchors create longer, safer arcs.",
	},
	{
		"title": "RELEASE WITH MOMENTUM",
		"kicker": "03 · SWING",
		"body": "While attached, tap anywhere away from the controls to release. "
			+ "Your velocity is preserved, so timing controls height and speed.",
		"tip": "Release while rising to carry momentum forward.",
	},
	{
		"title": "HOLD REEL",
		"kicker": "04 · REEL-IN",
		"body": "While attached, hold REEL to shorten the web and pull upward. "
			+ "The energy ring drains while pulling and recharges afterward.",
		"tip": "Reel is a correction tool, not a permanent boost.",
	},
	{
		"title": "SURVIVE & RECOVER",
		"kicker": "05 · STAY ALIVE",
		"body": "Falling below the course or being left behind ends the run. "
			+ "Tap after death to restart, or use MENU to return here. DEBUG is "
			+ "an optional laboratory tool controlled in Settings.",
		"tip": "The upper boundary is safe; the bottom and left edge are not.",
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

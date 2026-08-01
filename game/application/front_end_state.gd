extends RefCounted
class_name FrontEndState
## Application-owned navigation and settings state for the pre-run experience.
##
## Presentation calls these APIs and consumes `changed`; it does not decide
## which settings are valid or when a run may start.

signal changed
signal play_requested(settings: PlayerSettings)
signal difficulty_requested(mode_id: StringName)
signal campaign_play_requested(
	settings: PlayerSettings,
	level_id: StringName,
)
signal practice_play_requested(
	settings: PlayerSettings,
	region_id: StringName,
	start_distance_pixels: float,
)
signal debug_play_requested(
	settings: PlayerSettings,
	start_distance_pixels: float,
	upgrade_level: int,
)
## A bundled lab trace the owner chose to watch. Carries the path rather than
## the document so the state layer never holds a whole run in memory.
signal trace_watch_requested(settings: PlayerSettings, trace_path: String)
signal creator_play_requested(settings: PlayerSettings, pattern: Array[StringName])
signal settings_changed(settings: PlayerSettings)
signal spider_profile_requested(spider_id: StringName)
signal spider_style_requested(style: StringName)
signal web_variant_requested(web_variant: StringName)
signal upgrade_purchase_requested(upgrade_id: StringName)
signal creator_piece_requested(slot: int)
signal creator_clear_requested

enum Screen {
	HOME,
	TUTORIAL,
	SETTINGS,
	GARAGE,
	SHOP,
	CREATOR,
	PRACTICE,
	CAMPAIGN,
	FIELD_GUIDE,
	DEBUG_RUN_SETUP,
}

const TUTORIAL_STEPS := [
	{
		"title": "KEEP MOVING",
		"kicker": "01 · THE RUN",
		"body": "The spider starts on a training web and moves forward "
			+ "automatically. You have about a second to read the first arc, "
			+ "but may take control immediately. Shape that speed into a safe path.",
		"tip": "Let the opening swing carry you, then watch the space ahead.",
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
			+ "Natural inward movement also keeps most of the shorter length, "
			+ "while leaving a little stretch. The energy ring recharges afterward.",
		"tip": "Reel changes swing radius; the automatic take-up prevents deep surprise drops.",
	},
	{
		"title": "PULL TO THE TARGET",
		"kicker": "05 · ANCHOR BURST",
		"body": "Double-tap any solid target to cross 40% of the web distance "
			+ "in a quick controlled pull toward that exact point. The BURST "
			+ "button does the same without aiming, for when you cannot reach "
			+ "across. Every "
			+ "spider also has a useful minimum Burst travel that upgrades can "
			+ "improve. Tapping "
			+ "a solid below performs a shorter 40% Dive Pull and never stays "
			+ "attached. During either pull, tap an upper solid to recover with "
			+ "a normal web immediately.",
		"tip": "Double-tap aims the Burst; at speed that beats reaching for the button.",
	},
	{
		"title": "SURVIVE & RECOVER",
		"kicker": "06 · STAY ALIVE",
		"body": "Collect flies along suggested routes and watch for Burst Frenzy. "
			+ "The solid ceiling and floor are lethal by default, but reshape "
			+ "around most obstacles to create high, low, and occasional tight "
			+ "routes. A lethal mistake can spend your one visible RESCUE. "
			+ "Buckler also has one moderate rail bounce that an upper web "
			+ "recharges. A hard impact or obstacle still ends the run. Tap after "
			+ "death to restart, or use MENU.",
		"tip": "Follow the changing corridor and save recovery mechanics for real mistakes.",
	},
]

var screen: int = Screen.HOME
var field_guide_return_screen: int = Screen.HOME
var tutorial_index: int = 0
var settings: PlayerSettings = PlayerSettings.defaults()
var progress: PlayerProgress = PlayerProgress.defaults()
var debug_run_distance_pixels: float = 0.0
var debug_run_upgrade_level: int = \
	ProgressionService.DEBUG_UPGRADE_OVERLAY_DISABLED
var _progression_service := ProgressionService.new()


func configure(
	initial_settings: PlayerSettings,
	initial_progress: PlayerProgress = null,
	progression_service: ProgressionService = null,
) -> void:
	if progression_service != null:
		_progression_service = progression_service
	settings = initial_settings.copy()
	progress = (
		initial_progress.copy()
		if initial_progress != null
		else PlayerProgress.defaults()
	)
	if not settings.show_debug_tools:
		_progression_service.clear_debug_upgrade_overlay()
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


func show_garage() -> void:
	screen = Screen.GARAGE
	changed.emit()


func show_shop() -> void:
	screen = Screen.SHOP
	changed.emit()


## The Field Guide is reachable from Home (discoverability) and from the Garage
## (next to the spider it describes), so it remembers which one to go back to
## rather than guessing.
func show_field_guide(return_to: int = Screen.HOME) -> void:
	field_guide_return_screen = (
		return_to if return_to in [Screen.HOME, Screen.GARAGE] else Screen.HOME
	)
	screen = Screen.FIELD_GUIDE
	changed.emit()


func leave_field_guide() -> void:
	screen = field_guide_return_screen
	changed.emit()


func show_creator() -> void:
	screen = Screen.CREATOR
	changed.emit()


func show_practice() -> void:
	screen = Screen.PRACTICE
	changed.emit()


func show_campaign() -> void:
	screen = Screen.CAMPAIGN
	changed.emit()


## Which bundled trace the Test Run screen currently offers to watch.
var debug_trace_index: int = 0


func available_traces() -> Array[Dictionary]:
	return TraceCatalog.entries()


## Step through the bundled traces, wrapping. Wrapping rather than clamping
## because the list is short and a wrap is one tap from either end.
func select_debug_trace(step: int) -> void:
	if not settings.show_debug_tools:
		return
	var traces := available_traces()
	if traces.is_empty():
		debug_trace_index = 0
		return
	debug_trace_index = posmod(debug_trace_index + step, traces.size())
	changed.emit()


func selected_trace() -> Dictionary:
	var traces := available_traces()
	if traces.is_empty():
		return {}
	return traces[posmod(debug_trace_index, traces.size())]


## Watch the selected trace. The upgrade overlay is deliberately NOT set here:
## the trace names its own upgrade level and `SwingLabSession.load_input_trace`
## applies it, so setting it twice from two places would let them disagree.
func request_watch_trace() -> void:
	if not settings.show_debug_tools:
		return
	var trace := selected_trace()
	if trace.is_empty():
		return
	trace_watch_requested.emit(settings.copy(), str(trace["path"]))


func show_debug_run_setup() -> void:
	if not settings.show_debug_tools:
		return
	screen = Screen.DEBUG_RUN_SETUP
	changed.emit()


func configure_progress(updated_progress: PlayerProgress) -> void:
	progress = updated_progress.copy()
	changed.emit()


func resolved_progress() -> PlayerProgress:
	return _progression_service.resolved_progress(progress)


func displayed_upgrade_level(upgrade_id: StringName) -> int:
	return _progression_service.resolved_upgrade_level(progress, upgrade_id)


func debug_upgrade_overlay_enabled() -> bool:
	return _progression_service.debug_upgrade_overlay_enabled()


func debug_upgrade_overlay_level() -> int:
	return _progression_service.debug_upgrade_overlay_level()


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
	_clear_debug_overlay_for_normal_run()
	play_requested.emit(settings.copy())


func request_creator_play() -> void:
	_clear_debug_overlay_for_normal_run()
	creator_play_requested.emit(
		settings.copy(),
		progress.creator_pattern.duplicate(),
	)


## Campaign levels are always available — the teaching tier exists to be
## reached before the player is good enough to unlock anything.
func request_difficulty(mode_id: StringName) -> void:
	if not DifficultyCatalog.has_mode(mode_id):
		return
	difficulty_requested.emit(mode_id)


func difficulty_modes() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for mode: Dictionary in DifficultyCatalog.all_modes():
		var entry := mode.duplicate(true)
		entry["selected"] = StringName(mode["id"]) == \
			DifficultyCatalog.resolve(progress.selected_difficulty)
		entry["best_distance_pixels"] = progress.best_distance_for_mode(
			StringName(mode["id"]))
		result.append(entry)
	return result


func selected_difficulty() -> StringName:
	return DifficultyCatalog.resolve(progress.selected_difficulty)


func request_campaign(level_id: StringName) -> void:
	if not CampaignCatalog.has_level(level_id):
		return
	_clear_debug_overlay_for_normal_run()
	campaign_play_requested.emit(settings.copy(), level_id)


func campaign_levels() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for level: Dictionary in CampaignCatalog.all_levels():
		var entry := level.duplicate(true)
		entry["stars"] = progress.campaign_stars_for(
			StringName(level["id"]))
		result.append(entry)
	return result


func request_practice(region_id: StringName) -> void:
	if not progress.has_region_checkpoint(region_id):
		return
	var start_distance := CourseRegionCatalog.checkpoint_start(region_id)
	if start_distance <= 0.0:
		return
	_clear_debug_overlay_for_normal_run()
	practice_play_requested.emit(
		settings.copy(),
		region_id,
		start_distance,
	)


func set_debug_run_distance_pixels(value: float) -> void:
	if not settings.show_debug_tools:
		return
	var safe_value := TuningCatalog.clamp_value(
		TuningCatalog.DEBUG_START_DISTANCE,
		value,
	)
	if is_equal_approx(debug_run_distance_pixels, safe_value):
		return
	debug_run_distance_pixels = safe_value
	changed.emit()


func adjust_debug_run_distance(direction: int) -> void:
	set_debug_run_distance_pixels(
		debug_run_distance_pixels +
		TuningCatalog.step_for(TuningCatalog.DEBUG_START_DISTANCE) * direction,
	)


func set_debug_run_upgrade_level(level: int) -> void:
	if not settings.show_debug_tools:
		return
	var safe_level := roundi(TuningCatalog.clamp_value(
		TuningCatalog.DEBUG_UPGRADE_LEVEL,
		float(level),
	))
	if debug_run_upgrade_level == safe_level:
		return
	debug_run_upgrade_level = safe_level
	changed.emit()


func adjust_debug_run_upgrade_level(direction: int) -> void:
	set_debug_run_upgrade_level(debug_run_upgrade_level + direction)


func request_debug_play() -> void:
	if not settings.show_debug_tools:
		return
	if debug_run_upgrade_level >= 0:
		_progression_service.set_debug_upgrade_overlay_level(
			debug_run_upgrade_level,
		)
	else:
		_progression_service.clear_debug_upgrade_overlay()
	debug_play_requested.emit(
		settings.copy(),
		debug_run_distance_pixels,
		debug_run_upgrade_level,
	)


func sync_debug_run_setup(
	distance_pixels: float,
	upgrade_level: int,
) -> void:
	if not settings.show_debug_tools:
		return
	debug_run_distance_pixels = TuningCatalog.clamp_value(
		TuningCatalog.DEBUG_START_DISTANCE,
		distance_pixels,
	)
	debug_run_upgrade_level = roundi(TuningCatalog.clamp_value(
		TuningCatalog.DEBUG_UPGRADE_LEVEL,
		float(upgrade_level),
	))


func request_spider_profile(spider_id: StringName) -> void:
	if spider_id in SpiderCatalog.ALL_IDS:
		spider_profile_requested.emit(spider_id)


func request_spider_style(style: StringName) -> void:
	if style in PlayerProgress.ALL_STYLES:
		spider_style_requested.emit(style)


func request_web_variant(web_variant: StringName) -> void:
	if web_variant in PlayerProgress.ALL_WEB_VARIANTS:
		web_variant_requested.emit(web_variant)


func request_upgrade_purchase(upgrade_id: StringName) -> void:
	if not debug_upgrade_overlay_enabled() and \
			not SpiderCatalog.upgrade(upgrade_id).is_empty():
		upgrade_purchase_requested.emit(upgrade_id)


func request_creator_piece(slot: int) -> void:
	if slot >= 0 and slot < progress.creator_pattern.size():
		creator_piece_requested.emit(slot)


func request_creator_clear() -> void:
	creator_clear_requested.emit()


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


func set_effects_enabled(enabled: bool) -> void:
	if settings.effects_enabled == enabled:
		return
	settings.effects_enabled = enabled
	_publish_settings()


func set_haptics_enabled(enabled: bool) -> void:
	if settings.haptics_enabled == enabled:
		return
	settings.haptics_enabled = enabled
	_publish_settings()


func set_debug_tools(enabled: bool) -> void:
	if settings.show_debug_tools == enabled:
		return
	settings.show_debug_tools = enabled
	if not enabled:
		_progression_service.clear_debug_upgrade_overlay()
		if screen == Screen.DEBUG_RUN_SETUP:
			screen = Screen.HOME
	_publish_settings()


func reset_settings() -> void:
	settings = PlayerSettings.defaults()
	if not settings.show_debug_tools:
		_progression_service.clear_debug_upgrade_overlay()
		if screen == Screen.DEBUG_RUN_SETUP:
			screen = Screen.HOME
	_publish_settings()


func current_tutorial_step() -> Dictionary:
	return TUTORIAL_STEPS[tutorial_index]


func _publish_settings() -> void:
	settings_changed.emit(settings.copy())
	changed.emit()


func _clear_debug_overlay_for_normal_run() -> void:
	_progression_service.clear_debug_upgrade_overlay()

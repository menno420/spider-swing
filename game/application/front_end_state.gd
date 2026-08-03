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
signal tutorial_practice_requested(
	settings: PlayerSettings,
	lesson_id: StringName,
)
signal debug_play_requested(
	settings: PlayerSettings,
	start_distance_pixels: float,
	upgrade_level: int,
	bird_overrides: Dictionary,
	tuning_overrides: Dictionary,
)
## A bundled lab trace the owner chose to watch. Carries the path rather than
## the document so the state layer never holds a whole run in memory.
signal trace_watch_requested(settings: PlayerSettings, trace_path: String)
signal creator_play_requested(settings: PlayerSettings, pattern: Array[StringName])
signal settings_changed(settings: PlayerSettings)
signal debug_test_profile_changed(profile: DebugTestProfile)
signal spider_profile_requested(spider_id: StringName)
signal spider_style_requested(style: StringName)
signal web_variant_requested(web_variant: StringName)
signal upgrade_purchase_requested(upgrade_id: StringName)
signal creator_piece_requested(slot: int)
signal creator_clear_requested

enum Screen {
	HOME,
	SPIDER_HUB,
	PLAY_MODES_HUB,
	GUIDE_HUB,
	TUTORIAL,
	SETTINGS,
	GARAGE,
	SHOP,
	CREATOR,
	PRACTICE,
	CAMPAIGN,
	FIELD_GUIDE,
	DEBUG_RUN_SETUP,
	DEBUG_TEST_LAB,
}

## Stable, application-owned lessons. `mechanics` makes coverage checkable
## without trusting paragraph searches or a brittle page count. `preview` asks
## presentation for a staged snapshot; it never starts a second simulation.
const TUTORIAL_STEPS := [
	{
		"id": &"opening_pressure",
		"goal": &"understand_opening_pressure",
		"preview": &"opening_pressure",
		"title": "EARN THE OPENING",
		"kicker": "OPENING · PRESSURE",
		"body": "Bramble Canopy starts you on a guided web. There is no free "
			+ "forward drive after it: speed comes from your swings, while the bird "
			+ "makes standing still unsafe.",
		"tip": "Read the first arc, then keep making useful space ahead.",
		"mechanics": [&"opening_web", &"no_drive", &"earned_speed", &"bird_pressure"],
	},
	{
		"id": &"attach",
		"goal": &"attach_to_legal_solid_targets",
		"preview": &"attach",
		"title": "TAP A SOLID TARGET",
		"kicker": "ATTACH · AIM",
		"body": "Tap an in-range solid ceiling or anchorable obstacle to fire a "
			+ "web. Glowing route cues guide your aim; they do not make a surface legal.",
		"tip": "Aim ahead along the ceiling to build a longer forward arc.",
		"mechanics": [&"attach_legality", &"attach_range", &"aim_guides"],
	},
	{
		"id": &"swing_release",
		"goal": &"release_while_rising_with_momentum",
		"preview": &"swing_release",
		"title": "RELEASE WHILE RISING",
		"kicker": "SWING · RELEASE",
		"body": "While attached, tap the course away from controls to release. "
			+ "A wide rising arc earns forward momentum. Poor timing adds nothing, "
			+ "so preserve the speed you already carried.",
		"tip": "Long, rising arcs create the useful hand-off to your next web.",
		"mechanics": [&"swing_arc", &"release_momentum", &"poor_release"],
	},
	{
		"id": &"reel",
		"goal": &"control_swing_radius_with_reel",
		"preview": &"reel",
		"title": "HOLD REEL TO SHORTEN",
		"kicker": "REEL · RADIUS",
		"body": "Hold REEL to shorten the rope at a fixed rate and tighten your "
			+ "swing radius. It spends the ring, which recharges after release; "
			+ "automatic slack take-up keeps most natural inward gains.",
		"tip": "Reel changes radius; it does not add a separate speed boost.",
		"mechanics": [
			&"reel_rate", &"reel_radius", &"reel_energy", &"reel_recharge",
			&"slack_take_up",
		],
	},
	{
		"id": &"anchor_burst",
		"goal": &"use_aimed_and_fallback_anchor_burst",
		"preview": &"anchor_burst",
		"title": "BURST TO AN ANCHOR",
		"kicker": "ANCHOR BURST · AIM",
		"body": "Double-tap an upper solid to pull 40% toward that exact point. "
			+ "The BURST button is an unaimed fallback. Bursts have a useful minimum "
			+ "travel and spend visible charges that return on cooldown.",
		"tip": "Aim the double-tap when route choice matters; use the button when it does not.",
		"mechanics": [
			&"burst_aimed", &"burst_button", &"burst_fraction",
			&"burst_minimum", &"burst_charges",
		],
	},
	{
		"id": &"dive_recovery",
		"goal": &"dive_once_then_rearm_or_interrupt",
		"preview": &"dive_recovery",
		"title": "DIVE, THEN RECOVER",
		"kicker": "DIVE PULL · RECOVERY",
		"body": "Tap a solid below for a one-shot 40% Dive Pull; it does not stay "
			+ "attached. An upper web rearms the Dive and can interrupt either pull "
			+ "immediately when you need to recover.",
		"tip": "Spend Dive to change height, then secure the next upper web.",
		"mechanics": [
			&"dive_fraction", &"dive_one_shot", &"dive_upper_rearm",
			&"pull_recovery",
		],
	},
	{
		"id": &"read_course",
		"goal": &"read_routes_pickups_and_region_changes",
		"preview": &"read_course",
		"title": "READ THE COURSE",
		"kicker": "ROUTES · REGIONS",
		"body": "The corridor reshapes around real obstacle silhouettes. Read "
			+ "high and low routes, collect flies, avoid lethal rails, and use Burst "
			+ "Frenzy before the scenery and route vocabulary change again.",
		"tip": "Route cues suggest a line; the visible solid course decides what is legal.",
		"mechanics": [
			&"route_change", &"flies", &"obstacles", &"lethal_rails",
			&"burst_frenzy", &"regions",
		],
	},
	{
		"id": &"survive_restart",
		"goal": &"recognize_recovery_death_and_restart_paths",
		"preview": &"survive_restart",
		"title": "SURVIVE, RESTART, LEAVE",
		"kicker": "RESCUE · RESTART",
		"body": "One visible RESCUE can absorb a lethal mistake. Buckler instead "
			+ "adds one moderate rail bounce, rearmed by an upper web. The HUD names "
			+ "bird, obstacle, or rail deaths; tap to restart, or choose MENU.",
		"tip": "Recovery is limited. Spend it on the mistake that would end the run.",
		"mechanics": [
			&"rescue", &"buckler_bounce", &"death_attribution", &"restart", &"menu",
		],
	},
]

## Session-only comparison points for the combined no-drive/bird playtest.
## Every value is `assumed`: the bot cannot pump and therefore cannot tune a
## pursuer intended for human-earned speed. The owner can change each axis.
const BIRD_DEBUG_PRESETS := {
	&"off": {
		"bird_speed": 0.0,
		"bird_acceleration": 12.0,
		"bird_start_offset": 760.0,
	},
	&"slow": {
		"bird_speed": 240.0,
		"bird_acceleration": 8.0,
		"bird_start_offset": 900.0,
	},
	&"base": {
		"bird_speed": SwingConfig.DEFAULT_BIRD_SPEED,
		"bird_acceleration": SwingConfig.DEFAULT_BIRD_ACCELERATION,
		"bird_start_offset": SwingConfig.DEFAULT_BIRD_START_OFFSET,
	},
	&"fast": {
		"bird_speed": 380.0,
		"bird_acceleration": 20.0,
		"bird_start_offset": 600.0,
	},
}

var screen: int = Screen.HOME
var field_guide_return_screen: int = Screen.HOME
var field_guide_spider_id: StringName = SpiderCatalog.CLASSIC
var tutorial_index: int = 0
## Deliberately session-only. Tutorial practice is repeatable coaching, not a
## new progression or save schema.
var tutorial_practice_completed: Array[StringName] = []
var settings: PlayerSettings = PlayerSettings.defaults()
var progress: PlayerProgress = PlayerProgress.defaults()
var debug_test_profile: DebugTestProfile = DebugTestProfile.defaults()
var debug_category_index: int = 0
var debug_run_distance_pixels: float = 0.0
var debug_run_upgrade_level: int = \
	ProgressionService.DEBUG_UPGRADE_OVERLAY_DISABLED
var debug_bird_speed: float = SwingConfig.DEFAULT_BIRD_SPEED
var debug_bird_acceleration: float = SwingConfig.DEFAULT_BIRD_ACCELERATION
var debug_bird_start_offset: float = SwingConfig.DEFAULT_BIRD_START_OFFSET
var _progression_service := ProgressionService.new()


func configure(
	initial_settings: PlayerSettings,
	initial_progress: PlayerProgress = null,
	progression_service: ProgressionService = null,
	initial_debug_test_profile: DebugTestProfile = null,
) -> void:
	if progression_service != null:
		_progression_service = progression_service
	settings = initial_settings.copy()
	progress = (
		initial_progress.copy()
		if initial_progress != null
		else PlayerProgress.defaults()
	)
	debug_test_profile = (
		initial_debug_test_profile.copy()
		if initial_debug_test_profile != null
		else DebugTestProfile.defaults(settings.swing_preset)
	)
	_sync_debug_fields_from_profile()
	_refresh_debug_test_baseline(false)
	_sync_debug_fields_from_profile()
	field_guide_spider_id = progress.selected_spider_id
	if not settings.show_debug_tools:
		_progression_service.clear_debug_upgrade_overlay()
	screen = Screen.HOME
	tutorial_index = 0
	tutorial_practice_completed.clear()
	changed.emit()


func show_home() -> void:
	screen = Screen.HOME
	changed.emit()


func show_spider_hub() -> void:
	screen = Screen.SPIDER_HUB
	changed.emit()


func show_play_modes_hub() -> void:
	screen = Screen.PLAY_MODES_HUB
	changed.emit()


func show_guide_hub() -> void:
	screen = Screen.GUIDE_HUB
	changed.emit()


func show_tutorial() -> void:
	screen = Screen.TUTORIAL
	tutorial_index = 0
	changed.emit()


func show_tutorial_lesson(lesson_id: StringName) -> void:
	for index in range(TUTORIAL_STEPS.size()):
		if StringName(TUTORIAL_STEPS[index].get("id", &"")) == lesson_id:
			tutorial_index = index
			screen = Screen.TUTORIAL
			changed.emit()
			return


func show_settings() -> void:
	screen = Screen.SETTINGS
	changed.emit()


func show_garage() -> void:
	screen = Screen.GARAGE
	changed.emit()


func show_shop() -> void:
	screen = Screen.SHOP
	changed.emit()


## The Field Guide is reachable from the Guide hub and from the Garage beside
## the spider it describes, so it remembers which route to return to rather
## than guessing.
func show_field_guide(return_to: int = Screen.HOME) -> void:
	field_guide_return_screen = (
		return_to
		if return_to in [Screen.HOME, Screen.GUIDE_HUB, Screen.GARAGE]
		else Screen.HOME
	)
	field_guide_spider_id = progress.selected_spider_id
	screen = Screen.FIELD_GUIDE
	changed.emit()


func select_field_guide_spider(spider_id: StringName) -> void:
	if spider_id not in SpiderCatalog.ALL_IDS or \
			field_guide_spider_id == spider_id:
		return
	field_guide_spider_id = spider_id
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


func show_debug_test_lab() -> void:
	if not settings.show_debug_tools:
		return
	screen = Screen.DEBUG_TEST_LAB
	changed.emit()


func configure_progress(updated_progress: PlayerProgress) -> void:
	progress = updated_progress.copy()
	if _refresh_debug_test_baseline(false):
		_publish_debug_test_profile()
	else:
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
		show_guide_hub()
		return
	tutorial_index += 1
	changed.emit()


func previous_tutorial_step() -> void:
	tutorial_index = maxi(0, tutorial_index - 1)
	changed.emit()


func request_play() -> void:
	_clear_debug_overlay_for_normal_run()
	play_requested.emit(settings.copy())


func request_current_tutorial_action() -> void:
	var lesson_id := StringName(current_tutorial_step().get("id", &""))
	if TutorialPracticeCatalog.practice_available(lesson_id):
		_clear_debug_overlay_for_normal_run()
		tutorial_practice_requested.emit(settings.copy(), lesson_id)
		return
	request_play()


func mark_tutorial_practice_completed(lesson_id: StringName) -> void:
	if not TutorialPracticeCatalog.practice_available(lesson_id) or \
			lesson_id in tutorial_practice_completed:
		return
	tutorial_practice_completed.append(lesson_id)
	changed.emit()


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
	set_debug_tuning_value(TuningCatalog.DEBUG_START_DISTANCE, value)


func adjust_debug_run_distance(direction: int) -> void:
	set_debug_run_distance_pixels(
		debug_run_distance_pixels +
		TuningCatalog.step_for(TuningCatalog.DEBUG_START_DISTANCE) * direction,
	)


func set_debug_run_upgrade_level(level: int) -> void:
	set_debug_tuning_value(TuningCatalog.DEBUG_UPGRADE_LEVEL, float(level))


func adjust_debug_run_upgrade_level(direction: int) -> void:
	set_debug_run_upgrade_level(debug_run_upgrade_level + direction)


func set_debug_bird_value(parameter_id: StringName, value: float) -> void:
	if not settings.show_debug_tools or parameter_id not in [
		&"bird_speed", &"bird_acceleration", &"bird_start_offset",
	]:
		return
	set_debug_tuning_value(parameter_id, value)


func adjust_debug_bird_value(parameter_id: StringName, direction: int) -> void:
	if parameter_id not in [
		&"bird_speed", &"bird_acceleration", &"bird_start_offset",
	]:
		return
	var current := float(debug_bird_overrides()[str(parameter_id)])
	set_debug_bird_value(
		parameter_id,
		current + TuningCatalog.step_for(parameter_id) * direction,
	)


func apply_debug_bird_preset(preset_id: StringName) -> void:
	if not settings.show_debug_tools or not BIRD_DEBUG_PRESETS.has(preset_id):
		return
	var preset: Dictionary = BIRD_DEBUG_PRESETS[preset_id]
	var did_change := false
	for parameter_id: StringName in [
		&"bird_speed", &"bird_acceleration", &"bird_start_offset",
	]:
		did_change = debug_test_profile.set_value(
			parameter_id,
			float(preset[str(parameter_id)]),
		) or did_change
	if did_change:
		_publish_debug_test_profile()


func debug_bird_overrides() -> Dictionary:
	return {
		"bird_speed": debug_bird_speed,
		"bird_acceleration": debug_bird_acceleration,
		"bird_start_offset": debug_bird_start_offset,
	}


func debug_tuning_value(parameter_id: StringName) -> float:
	return debug_test_profile.value(parameter_id)


func debug_tuning_overrides() -> Dictionary:
	return debug_test_profile.tuning_overrides()


func set_debug_tuning_value(
	parameter_id: StringName,
	value: float,
) -> void:
	if not settings.show_debug_tools:
		return
	if not debug_test_profile.set_value(parameter_id, value):
		return
	if parameter_id == TuningCatalog.DEBUG_UPGRADE_LEVEL:
		_refresh_debug_test_baseline(false)
	_publish_debug_test_profile()


func adjust_debug_tuning_value(
	parameter_id: StringName,
	direction: int,
) -> void:
	if parameter_id not in TuningCatalog.parameter_ids():
		return
	set_debug_tuning_value(
		parameter_id,
		debug_tuning_value(parameter_id) +
			TuningCatalog.step_for(parameter_id) * direction,
	)


func select_debug_category(index: int) -> void:
	var maximum_index := TuningCatalog.category_index(
		TuningCatalog.CATEGORY_ABILITIES)
	var safe_index := clampi(index, 0, maximum_index)
	if debug_category_index == safe_index:
		return
	debug_category_index = safe_index
	changed.emit()


func save_debug_test_slot(slot_id: StringName) -> void:
	if settings.show_debug_tools and debug_test_profile.save_slot(slot_id):
		_publish_debug_test_profile()


func load_debug_test_slot(slot_id: StringName) -> void:
	if settings.show_debug_tools and debug_test_profile.load_slot(slot_id):
		_refresh_debug_test_baseline(false)
		_publish_debug_test_profile()


func reset_debug_test_profile() -> void:
	if settings.show_debug_tools and debug_test_profile.reset_working(
		settings.swing_preset,
	):
		_refresh_debug_test_baseline(false)
		_publish_debug_test_profile()


## The compact launcher intentionally applies only controls the tester can see.
## Saved Test Lab overrides stay intact for later comparisons, but do not leak
## into a quick run whose screen cannot disclose them.
func request_quick_debug_play() -> void:
	if not settings.show_debug_tools:
		return
	_apply_debug_upgrade_overlay()
	debug_play_requested.emit(
		settings.copy(),
		debug_run_distance_pixels,
		debug_run_upgrade_level,
		debug_bird_overrides(),
		{},
	)


func request_debug_play() -> void:
	if not settings.show_debug_tools:
		return
	_apply_debug_upgrade_overlay()
	debug_play_requested.emit(
		settings.copy(),
		debug_run_distance_pixels,
		debug_run_upgrade_level,
		debug_bird_overrides(),
		debug_tuning_overrides(),
	)


func _apply_debug_upgrade_overlay() -> void:
	if debug_run_upgrade_level >= 0:
		_progression_service.set_debug_upgrade_overlay_level(
			debug_run_upgrade_level,
		)
	else:
		_progression_service.clear_debug_upgrade_overlay()


## Synchronous composition-root guard for the two intentional launch paths.
## The current screen is still authoritative while the request signal runs.
func debug_tuning_request_is_valid(tuning_overrides: Dictionary) -> bool:
	match screen:
		Screen.DEBUG_RUN_SETUP:
			return tuning_overrides.is_empty()
		Screen.DEBUG_TEST_LAB:
			return tuning_overrides == debug_tuning_overrides()
	return false


func sync_debug_run_setup(
	distance_pixels: float,
	upgrade_level: int,
	bird_overrides: Dictionary = {},
	tuning_overrides: Dictionary = {},
) -> void:
	if not settings.show_debug_tools:
		return
	# A live session reports the complete resolved catalogue. Compare it with
	# the same owned/profile/difficulty baseline used to start the run so only
	# values actually changed in the pause lab become persistent overrides.
	# Otherwise merely opening a test run at L40 would save every L40 result as
	# a hard override and erase later progression comparisons.
	var next := debug_test_profile.resolved_values()
	for parameter_id: StringName in TuningCatalog.parameter_ids():
		if tuning_overrides.has(parameter_id) or \
				tuning_overrides.has(str(parameter_id)):
			next[parameter_id] = float(tuning_overrides.get(
				parameter_id,
				tuning_overrides.get(
					str(parameter_id),
					next.get(parameter_id, 0.0),
				),
			))
	next[TuningCatalog.DEBUG_START_DISTANCE] = distance_pixels
	next[TuningCatalog.DEBUG_UPGRADE_LEVEL] = float(upgrade_level)
	for parameter_id: StringName in [
		&"bird_speed", &"bird_acceleration", &"bird_start_offset",
	]:
		if bird_overrides.has(parameter_id) or bird_overrides.has(str(parameter_id)):
			next[parameter_id] = float(bird_overrides.get(
				parameter_id,
				bird_overrides.get(
					str(parameter_id),
					next.get(parameter_id, 0.0),
				),
			))
	var baseline := _debug_test_baseline_values(
		upgrade_level,
		distance_pixels,
	)
	if debug_test_profile.replace_resolved_values(next, baseline):
		_publish_debug_test_profile()
	else:
		_sync_debug_fields_from_profile()


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
	var profile_changed := _refresh_debug_test_baseline(false)
	settings_changed.emit(settings.copy())
	if profile_changed:
		_sync_debug_fields_from_profile()
		debug_test_profile_changed.emit(debug_test_profile.copy())
	changed.emit()


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


func set_music_volume(volume: float) -> void:
	var validated := clampf(
		volume,
		PlayerSettings.MIN_MUSIC_VOLUME,
		PlayerSettings.MAX_MUSIC_VOLUME,
	)
	if not is_finite(validated):
		validated = PlayerSettings.DEFAULT_MUSIC_VOLUME
	if is_equal_approx(settings.music_volume, validated):
		return
	settings.music_volume = validated
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
		if screen in [Screen.DEBUG_RUN_SETUP, Screen.DEBUG_TEST_LAB]:
			screen = Screen.HOME
	_publish_settings()


func reset_settings() -> void:
	settings = PlayerSettings.defaults()
	var profile_changed := _refresh_debug_test_baseline(false)
	if not settings.show_debug_tools:
		_progression_service.clear_debug_upgrade_overlay()
		if screen in [Screen.DEBUG_RUN_SETUP, Screen.DEBUG_TEST_LAB]:
			screen = Screen.HOME
	settings_changed.emit(settings.copy())
	if profile_changed:
		_sync_debug_fields_from_profile()
		debug_test_profile_changed.emit(debug_test_profile.copy())
	changed.emit()


func current_tutorial_step() -> Dictionary:
	var step: Dictionary = TUTORIAL_STEPS[tutorial_index].duplicate(true)
	var lesson_id := StringName(step.get("id", &""))
	var practice := TutorialPracticeCatalog.lesson(lesson_id)
	step["practice"] = practice
	step["practice_completed"] = lesson_id in tutorial_practice_completed
	return step


static func tutorial_lesson(lesson_id: StringName) -> Dictionary:
	for lesson: Dictionary in TUTORIAL_STEPS:
		if StringName(lesson.get("id", &"")) == lesson_id:
			return lesson.duplicate(true)
	return {}


func _publish_debug_test_profile() -> void:
	_sync_debug_fields_from_profile()
	debug_test_profile_changed.emit(debug_test_profile.copy())
	changed.emit()


func _sync_debug_fields_from_profile() -> void:
	debug_run_distance_pixels = debug_test_profile.value(
		TuningCatalog.DEBUG_START_DISTANCE)
	debug_run_upgrade_level = roundi(debug_test_profile.value(
		TuningCatalog.DEBUG_UPGRADE_LEVEL))
	debug_bird_speed = debug_test_profile.value(&"bird_speed")
	debug_bird_acceleration = debug_test_profile.value(&"bird_acceleration")
	debug_bird_start_offset = debug_test_profile.value(&"bird_start_offset")


## Re-resolve values the tester has not explicitly changed. Displaying a
## complete working set makes the lab readable; keeping only manual changes in
## `override_ids` preserves the selected spider, difficulty, and upgrade math.
func _refresh_debug_test_baseline(publish: bool = false) -> bool:
	var changed_profile := debug_test_profile.rebase(
		_debug_test_baseline_values(
			roundi(debug_test_profile.value(
				TuningCatalog.DEBUG_UPGRADE_LEVEL)),
			debug_test_profile.value(TuningCatalog.DEBUG_START_DISTANCE),
		),
	)
	if changed_profile and publish:
		_publish_debug_test_profile()
	return changed_profile


func _debug_test_baseline_values(
	upgrade_level: int,
	distance_pixels: float,
) -> Dictionary:
	var comparison_service := ProgressionService.new()
	if upgrade_level >= 0:
		comparison_service.set_debug_upgrade_overlay_level(upgrade_level)
	var config := SpiderCatalog.resolved_config(
		settings.swing_preset,
		comparison_service.resolved_progress(progress),
	)
	DifficultyCatalog.apply_to_config(config, selected_difficulty())
	var values := DebugTestProfile.defaults_from_config(config).resolved_values()
	values[TuningCatalog.DEBUG_START_DISTANCE] = TuningCatalog.clamp_value(
		TuningCatalog.DEBUG_START_DISTANCE,
		distance_pixels,
	)
	values[TuningCatalog.DEBUG_UPGRADE_LEVEL] = TuningCatalog.clamp_value(
		TuningCatalog.DEBUG_UPGRADE_LEVEL,
		float(upgrade_level),
	)
	return values


func _publish_settings() -> void:
	settings_changed.emit(settings.copy())
	changed.emit()


func _clear_debug_overlay_for_normal_run() -> void:
	_progression_service.clear_debug_upgrade_overlay()


## A debug overlay belongs to the run it was launched for, and returning to the
## menu ends that run. Without this the overlay outlived its run: the Garage and
## Shop kept reporting borrowed levels and `request_upgrade_purchase` stayed a
## no-op, so owned upgrades could not be spent until the player happened to
## launch a normal run or found the DEBUG toggle in Settings. Saved levels were
## never touched — only the menu's view of them.
func end_debug_run_overlay() -> void:
	if _progression_service.clear_debug_upgrade_overlay():
		changed.emit()

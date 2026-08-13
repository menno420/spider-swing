extends Node
## Spider Swing composition root and headless smoke-test entry point.

const FRONT_END_SCENE_PATH := "res://game/presentation/scenes/front_end.tscn"
const SWING_LAB_SCENE_PATH := "res://game/presentation/scenes/swing_lab.tscn"
const FRONT_END_STATE_SCRIPT := preload(
	"res://game/application/front_end_state.gd")
const SAVE_REPOSITORY_SCRIPT := preload(
	"res://game/adapters/save_repository.gd")
const SWING_LAB_SESSION := preload(
	"res://game/application/swing_lab_session.gd")
const PROGRESSION_SERVICE_SCRIPT := preload(
	"res://game/application/progression_service.gd")
const RUN_ATTEMPT_COUNTER_SCRIPT := preload(
	"res://game/application/run_attempt_counter.gd")
const RUN_FEEDBACK_PROMPT_POLICY := preload(
	"res://game/application/run_feedback_prompt_policy.gd")
const INPUT_ROUTER := preload("res://game/adapters/input_router.gd")
const CLIPBOARD_ADAPTER_SCRIPT := preload(
	"res://game/adapters/clipboard_adapter.gd")
const AUDIO_DIRECTOR := preload(
	"res://game/presentation/scripts/audio_director.gd")
const SMOKE_TEST_FLAG := "--smoke-test"
const EXIT_OK := 0
const EXIT_BOOT_FAILED := 1

var _front_end_state: FrontEndState
var _front_end_view: FrontEndView
var _save_repository: SaveRepository
var _progression_service: ProgressionService
var _progress: PlayerProgress
var _run_record_ledger: RunRecordLedger
var _run_attempt_counter: RunAttemptCounter
var _clipboard_adapter: ClipboardAdapter
var _session: SwingLabSession
var _input_router: InputRouter
var _view: SwingLabView
var _audio_director: AudioDirector
var _active_run_is_debug_test: bool = false
var _active_tutorial_lesson_id: StringName = &""
var _pending_run_feedback_prompt: Dictionary = {}


func _ready() -> void:
	_save_repository = SAVE_REPOSITORY_SCRIPT.new() as SaveRepository
	_progression_service = PROGRESSION_SERVICE_SCRIPT.new() as ProgressionService
	_run_attempt_counter = RUN_ATTEMPT_COUNTER_SCRIPT.new() as RunAttemptCounter
	_clipboard_adapter = CLIPBOARD_ADAPTER_SCRIPT.new() as ClipboardAdapter
	_progress = _save_repository.load_progress()
	_run_record_ledger = _save_repository.load_run_record_ledger()
	var settings := _save_repository.load_settings()
	var debug_test_profile := _save_repository.load_debug_test_profile(
		settings.swing_preset)
	_audio_director = AUDIO_DIRECTOR.new() as AudioDirector
	_audio_director.configure_effects(settings.effects_enabled)
	_audio_director.configure_music_volume(settings.music_volume)
	add_child(_audio_director)
	_front_end_state = FRONT_END_STATE_SCRIPT.new() as FrontEndState
	_front_end_state.play_requested.connect(_start_game)
	_front_end_state.practice_play_requested.connect(_start_practice_game)
	_front_end_state.tutorial_practice_requested.connect(
		_start_tutorial_practice_game)
	_front_end_state.campaign_play_requested.connect(_start_campaign_game)
	_front_end_state.difficulty_requested.connect(_select_difficulty)
	_front_end_state.debug_play_requested.connect(_start_debug_game)
	_front_end_state.trace_watch_requested.connect(_start_trace_watch)
	_front_end_state.creator_play_requested.connect(_start_creator_game)
	_front_end_state.settings_changed.connect(_save_settings)
	_front_end_state.debug_test_profile_changed.connect(
		_save_debug_test_profile)
	_front_end_state.spider_profile_requested.connect(_select_spider_profile)
	_front_end_state.spider_style_requested.connect(_select_spider_style)
	_front_end_state.web_variant_requested.connect(_select_web_variant)
	_front_end_state.upgrade_purchase_requested.connect(_purchase_upgrade)
	_front_end_state.creator_piece_requested.connect(_cycle_creator_piece)
	_front_end_state.creator_clear_requested.connect(_clear_creator_pattern)
	_front_end_state.run_history_export_requested.connect(
		_copy_run_history_export)
	_front_end_state.configure(
		settings,
		_progress,
		_progression_service,
		debug_test_profile,
		_run_record_ledger,
	)
	var failures := _mount_front_end()
	if is_smoke_test():
		_report_boot(failures)
		var code: int = EXIT_OK if failures.is_empty() else EXIT_BOOT_FAILED
		call_deferred("_quit_with", code)


func is_smoke_test() -> bool:
	if DisplayServer.get_name() == "headless":
		return true
	return SMOKE_TEST_FLAG in OS.get_cmdline_user_args()


func _mount_front_end() -> PackedStringArray:
	var failures := _instantiate_front_end()
	if not failures.is_empty():
		return failures
	_front_end_view.bind_state(_front_end_state)
	if _front_end_state.settings.music_volume > 0.0 and (
			_audio_director == null or \
			not _audio_director.music_playback_requested()
	):
		failures.append("enabled background music did not request playback")
	return failures


func _instantiate_front_end() -> PackedStringArray:
	var failures := PackedStringArray()
	if not ResourceLoader.exists(FRONT_END_SCENE_PATH):
		failures.append("scene not found: %s" % FRONT_END_SCENE_PATH)
		return failures
	var scene := load(FRONT_END_SCENE_PATH) as PackedScene
	if scene == null:
		failures.append("scene did not load as a PackedScene: %s" %
			FRONT_END_SCENE_PATH)
		return failures
	_front_end_view = scene.instantiate() as FrontEndView
	if _front_end_view == null:
		failures.append("scene failed to instantiate as FrontEndView")
		return failures
	add_child(_front_end_view)
	return failures


func _start_game(settings: PlayerSettings) -> void:
	_active_run_is_debug_test = false
	_active_tutorial_lesson_id = &""
	_unmount_front_end()
	var failures := _mount_swing_lab(settings)
	if failures.is_empty():
		return
	for failure: String in failures:
		printerr("[spider-swing] start failed — %s" % failure)
	_unmount_swing_lab()
	_mount_front_end()


func _start_creator_game(
	settings: PlayerSettings,
	pattern: Array[StringName],
) -> void:
	_active_run_is_debug_test = false
	_active_tutorial_lesson_id = &""
	_unmount_front_end()
	var failures := _mount_swing_lab(settings, pattern)
	if failures.is_empty():
		return
	for failure: String in failures:
		printerr("[spider-swing] creator start failed — %s" % failure)
	_unmount_swing_lab()
	_mount_front_end()


func _start_practice_game(
	settings: PlayerSettings,
	region_id: StringName,
	start_distance_pixels: float,
) -> void:
	if not _progress.has_region_checkpoint(region_id) or \
			not is_equal_approx(
				start_distance_pixels,
				CourseRegionCatalog.checkpoint_start(region_id),
			):
		return
	_active_run_is_debug_test = false
	_active_tutorial_lesson_id = &""
	_unmount_front_end()
	var failures := _mount_swing_lab(
		settings,
		[],
		SwingLabSession.RUN_PRACTICE,
		start_distance_pixels,
	)
	if failures.is_empty():
		return
	for failure: String in failures:
		printerr("[spider-swing] practice start failed — %s" % failure)
	_unmount_swing_lab()
	_mount_front_end()


func _select_difficulty(mode_id: StringName) -> void:
	if not _progression_service.select_difficulty(_progress, mode_id):
		return
	_save_repository.save_progress(_progress)
	_front_end_state.configure_progress(_progress)


func _start_campaign_game(
	settings: PlayerSettings,
	level_id: StringName,
) -> void:
	if not CampaignCatalog.has_level(level_id):
		return
	_active_run_is_debug_test = false
	_active_tutorial_lesson_id = &""
	_unmount_front_end()
	var failures := _mount_swing_lab(
		settings,
		[],
		SwingLabSession.RUN_CAMPAIGN,
		0.0,
		false,
		level_id,
	)
	if failures.is_empty():
		return
	for failure: String in failures:
		printerr("[spider-swing] campaign start failed — %s" % failure)
	_unmount_swing_lab()
	_mount_front_end()


func _start_tutorial_practice_game(
	settings: PlayerSettings,
	lesson_id: StringName,
) -> void:
	if not TutorialPracticeCatalog.practice_available(lesson_id):
		return
	_active_run_is_debug_test = false
	_active_tutorial_lesson_id = lesson_id
	_unmount_front_end()
	var failures := _mount_swing_lab(
		settings,
		[],
		SwingLabSession.RUN_TUTORIAL_PRACTICE,
		0.0,
		false,
		&"",
		{},
		{},
		lesson_id,
	)
	if failures.is_empty():
		return
	for failure: String in failures:
		printerr("[spider-swing] tutorial practice failed — %s" % failure)
	_unmount_swing_lab()
	_show_front_end()


## Mount a run and immediately hand it a recorded trace to replay.
##
## The run is an ordinary debug practice run in every other respect, so it
## inherits the whole no-awards/no-records policy. The session reconstructs the
## world from the trace's own header — seed, start distance, upgrades,
## difficulty, preset — because a replay fed into a different world is not a
## replay, and the point of watching is to judge the run that was reported.
func _start_trace_watch(
	settings: PlayerSettings,
	trace_path: String,
) -> void:
	if not settings.show_debug_tools:
		return
	var trace := SwingLabSession.read_input_trace(trace_path)
	if trace.is_empty():
		printerr("[spider-swing] trace %s is missing or unreadable" % trace_path)
		return
	_active_run_is_debug_test = true
	_active_tutorial_lesson_id = &""
	_unmount_front_end()
	var failures := _mount_swing_lab(
		settings,
		[],
		SwingLabSession.RUN_PRACTICE,
		0.0,
		true,
	)
	if not failures.is_empty():
		for failure: String in failures:
			printerr("[spider-swing] trace watch failed — %s" % failure)
		_active_run_is_debug_test = false
		_unmount_swing_lab()
		_mount_front_end()
		return
	var loaded := _session.load_input_trace(trace)
	if not bool(loaded["ok"]):
		printerr("[spider-swing] trace watch refused — %s" % loaded["reason"])
		_active_run_is_debug_test = false
		_unmount_swing_lab()
		_mount_front_end()


func _start_debug_game(
	settings: PlayerSettings,
	start_distance_pixels: float,
	upgrade_level: int,
	bird_overrides: Dictionary,
	tuning_overrides: Dictionary,
) -> void:
	if not settings.show_debug_tools or not is_equal_approx(
		start_distance_pixels,
		TuningCatalog.clamp_value(
			TuningCatalog.DEBUG_START_DISTANCE,
			start_distance_pixels,
		),
	) or upgrade_level != _progression_service.debug_upgrade_overlay_level() or \
			bird_overrides != _front_end_state.debug_bird_overrides() or \
			not _front_end_state.debug_tuning_request_is_valid(
				tuning_overrides,
			):
		return
	_active_run_is_debug_test = true
	_active_tutorial_lesson_id = &""
	_unmount_front_end()
	var failures := _mount_swing_lab(
		settings,
		[],
		SwingLabSession.RUN_PRACTICE,
		start_distance_pixels,
		true,
		&"",
		bird_overrides,
		tuning_overrides,
	)
	if failures.is_empty():
		return
	for failure: String in failures:
		printerr("[spider-swing] debug test start failed — %s" % failure)
	_active_run_is_debug_test = false
	_unmount_swing_lab()
	_mount_front_end()


func _mount_swing_lab(
	settings: PlayerSettings,
	creator_pattern: Array[StringName] = [],
	run_mode: StringName = SwingLabSession.RUN_STANDARD,
	start_distance_pixels: float = 0.0,
	debug_start: bool = false,
	campaign_level_id: StringName = &"",
	bird_debug_overrides: Dictionary = {},
	debug_tuning_overrides: Dictionary = {},
	tutorial_lesson_id: StringName = &"",
) -> PackedStringArray:
	var failures := PackedStringArray()
	if not ResourceLoader.exists(SWING_LAB_SCENE_PATH):
		failures.append("scene not found: %s" % SWING_LAB_SCENE_PATH)
		return failures

	var scene: PackedScene = load(SWING_LAB_SCENE_PATH) as PackedScene
	if scene == null:
		failures.append("scene did not load as a PackedScene: %s" %
			SWING_LAB_SCENE_PATH)
		return failures

	_view = scene.instantiate() as SwingLabView
	if _view == null:
		failures.append("scene failed to instantiate as SwingLabView")
		return failures

	_session = SWING_LAB_SESSION.new() as SwingLabSession
	_input_router = INPUT_ROUTER.new() as InputRouter
	if _session == null or _input_router == null or _audio_director == null:
		failures.append("run session, input, or audio presentation failed to instantiate")
		return failures

	_session.snapshot_published.connect(_view.present)
	_session.snapshot_published.connect(_input_router.present_snapshot)
	_session.snapshot_published.connect(_audio_director.present_snapshot)
	_session.event_published.connect(_view.present_event)
	_session.event_published.connect(_input_router.present_simulation_event)
	_session.event_published.connect(_audio_director.present_event)
	_session.run_finalized.connect(_apply_run_finalization)
	_session.diagnostic_export_requested.connect(_save_diagnostic_export)
	_session.checkpoint_reached.connect(_unlock_region_checkpoint)
	_session.tutorial_practice_ended.connect(_finish_tutorial_practice)
	_session.configure_progress(_progress, _progression_service)
	_session.configure_attempt_counter(_run_attempt_counter)
	_session.configure_creator_pattern(creator_pattern)
	_session.configure_bird_debug_overrides(bird_debug_overrides)
	_session.configure_run(
		run_mode,
		start_distance_pixels,
		-1,
		debug_start,
		campaign_level_id,
		tutorial_lesson_id,
	)
	_input_router.web_tapped.connect(_on_web_tapped)
	_input_router.reel_changed.connect(_session.set_reel_active)
	_input_router.burst_requested.connect(_session.request_burst)
	_input_router.burst_gesture.connect(_on_burst_gesture)
	_input_router.restart_requested.connect(_request_restart)
	_input_router.menu_requested.connect(_return_to_menu)
	_input_router.run_feedback_answered.connect(_record_run_feedback)
	_input_router.run_feedback_skipped.connect(_skip_run_feedback)
	_input_router.debug_toggle_requested.connect(_session.toggle_debug)
	_input_router.collision_outlines_toggle_requested.connect(
		_session.toggle_collision_outlines)
	_input_router.web_guides_toggle_requested.connect(
		_session.toggle_web_guides)
	_input_router.debug_pause_requested.connect(_session.toggle_debug_pause)
	_input_router.debug_frame_step_requested.connect(_session.step_debug_frame)
	_input_router.slow_motion_requested.connect(_session.toggle_slow_motion)
	_input_router.preset_requested.connect(_session.apply_preset)
	_input_router.tuning_parameter_requested.connect(
		_session.select_tuning_parameter)
	_input_router.tuning_adjustment_requested.connect(
		_session.adjust_selected_parameter)
	_input_router.tuning_category_requested.connect(
		_session.select_tuning_category)
	_input_router.tuning_parameter_adjustment_requested.connect(
		_session.adjust_tuning_parameter)
	_input_router.tuning_value_requested.connect(
		_session.set_tuning_parameter)
	_input_router.environment_theme_requested.connect(
		_view.select_environment_theme)
	_input_router.recording_requested.connect(_session.toggle_recording)
	_input_router.replay_requested.connect(_session.replay_recording)
	_input_router.diagnostic_export_requested.connect(_session.export_diagnostic)

	_audio_director.configure_effects(settings.effects_enabled)
	_audio_director.configure_music_volume(settings.music_volume)
	_input_router.configure_haptics(settings.haptics_enabled)
	_input_router.clear_run_feedback_prompt()
	_view.clear_run_feedback_prompt()
	add_child(_view)
	add_child(_session)
	add_child(_input_router)
	_view.configure_player_options(
		settings.show_control_hints,
		settings.reduced_motion,
		settings.show_debug_tools,
	)
	_input_router.configure_debug_controls(settings.show_debug_tools)
	_session.apply_preset(settings.swing_preset)
	if debug_start:
		_session.apply_debug_tuning_profile(debug_tuning_overrides)
	return failures


func _return_to_menu() -> void:
	call_deferred("_show_front_end")


func _finish_tutorial_practice(
	lesson_id: StringName,
	completed: bool,
) -> void:
	if lesson_id != _active_tutorial_lesson_id:
		return
	if completed:
		_front_end_state.mark_tutorial_practice_completed(lesson_id)
	call_deferred("_show_front_end")


func _show_front_end() -> void:
	var tutorial_return_id := _active_tutorial_lesson_id
	if _session != null and _front_end_state.settings.show_debug_tools:
		var snapshot := _session.current_snapshot()
		if _active_run_is_debug_test or snapshot.debug_start_active or \
				snapshot.debug_upgrade_overlay_level >= 0:
			_front_end_state.sync_debug_run_setup(
				snapshot.start_distance_pixels,
				snapshot.debug_upgrade_overlay_level,
				{
					"bird_speed": snapshot.tuning_values.get(
						&"bird_speed", SwingConfig.DEFAULT_BIRD_SPEED),
					"bird_acceleration": snapshot.tuning_values.get(
						&"bird_acceleration", SwingConfig.DEFAULT_BIRD_ACCELERATION),
					"bird_start_offset": snapshot.tuning_values.get(
						&"bird_start_offset", SwingConfig.DEFAULT_BIRD_START_OFFSET),
				},
				snapshot.tuning_values,
			)
	_unmount_swing_lab()
	_active_run_is_debug_test = false
	_active_tutorial_lesson_id = &""
	# The run is over, so its borrowed upgrade levels are too. Read the snapshot
	# above first — the launcher still needs the level the finished run used.
	_front_end_state.end_debug_run_overlay()
	if tutorial_return_id.is_empty():
		_front_end_state.show_home()
	else:
		_front_end_state.show_tutorial_lesson(tutorial_return_id)
	_mount_front_end()


func _unmount_front_end() -> void:
	if _front_end_view == null:
		return
	remove_child(_front_end_view)
	_front_end_view.queue_free()
	_front_end_view = null


func _unmount_swing_lab() -> void:
	_pending_run_feedback_prompt.clear()
	if _input_router != null:
		_input_router.cancel_held_input()
		remove_child(_input_router)
		_input_router.queue_free()
		_input_router = null
	if _session != null:
		remove_child(_session)
		_session.queue_free()
		_session = null
	if _audio_director != null:
		_audio_director.leave_run()
	if _view != null:
		remove_child(_view)
		_view.queue_free()
		_view = null


func _save_settings(settings: PlayerSettings) -> void:
	if _audio_director != null:
		_audio_director.configure_effects(settings.effects_enabled)
		_audio_director.configure_music_volume(settings.music_volume)
	if not _save_repository.save_settings(settings):
		printerr("[spider-swing] settings write failed; current session continues")


func _save_debug_test_profile(profile: DebugTestProfile) -> void:
	if not _save_repository.save_debug_test_profile(profile):
		printerr(
			"[spider-swing] Test Lab profile write failed; current session continues")


func _apply_run_finalization(
	settlement: RunSettlement,
	record: RunRecord,
) -> void:
	var result := _progression_service.apply_settlement(_progress, settlement)
	if bool(result.get("applied", false)):
		if not _save_repository.save_progress(_progress):
			printerr(
				"[spider-swing] progress write failed; current session continues")
		if _session != null:
			_session.configure_progress(_progress)
		_front_end_state.configure_progress(_progress)
		var unlocked: PackedStringArray = result.get(
			"unlocked", PackedStringArray())
		if not unlocked.is_empty() and _session != null:
			_session.event_published.emit(SimulationEvent.make(
				SimulationEvent.Kind.FLY_COLLECTED,
				Vector2.ZERO,
				"Unlocked spider: %s" % unlocked[0],
				{"unlocked": unlocked},
			))

	# Evidence is optional and deliberately follows the authoritative progression
	# path. A failed evidence write can neither roll back nor re-apply settlement.
	if record == null or record.settlement_id != settlement.settlement_id:
		printerr("[spider-swing] run evidence rejected: settlement identity mismatch")
		return
	if not _run_record_ledger.append_record(record):
		return
	if not _save_repository.save_run_record_ledger(_run_record_ledger):
		printerr(
			"[spider-swing] run evidence write failed; progression remains applied")
	_front_end_state.configure_run_record_ledger(_run_record_ledger)
	var stored := _run_record_ledger.record_by_id(record.record_id)
	_stage_run_feedback_prompt(RUN_FEEDBACK_PROMPT_POLICY.prompt_for(
		stored,
		_run_record_ledger,
	))


func _stage_run_feedback_prompt(prompt: Dictionary) -> void:
	_pending_run_feedback_prompt = prompt.duplicate(true)
	if _input_router != null:
		_input_router.configure_run_feedback_prompt(
			_pending_run_feedback_prompt)
	if _view != null:
		_view.configure_run_feedback_prompt(_pending_run_feedback_prompt)


func _clear_run_feedback_prompt() -> void:
	_pending_run_feedback_prompt.clear()
	if _input_router != null:
		_input_router.clear_run_feedback_prompt()
	if _view != null:
		_view.clear_run_feedback_prompt()


func _record_run_feedback(
	record_id: String,
	question_id: StringName,
	answer_id: StringName,
) -> void:
	if _pending_run_feedback_prompt.is_empty() or \
			record_id != str(_pending_run_feedback_prompt.get("record_id", "")) or \
			question_id != StringName(str(
				_pending_run_feedback_prompt.get("question_id", ""))):
		return
	var response := RunFeedbackResponse.create(
		record_id,
		question_id,
		answer_id,
	)
	if response == null or \
			not _run_record_ledger.append_feedback_response(response):
		return
	_clear_run_feedback_prompt()
	if not _save_repository.save_run_record_ledger(_run_record_ledger):
		printerr(
			"[spider-swing] run feedback write failed; progression remains applied")
	_front_end_state.configure_run_record_ledger(_run_record_ledger)
	if _session != null:
		_session.request_restart()


func _skip_run_feedback(
	record_id: String,
	question_id: StringName,
) -> void:
	if _pending_run_feedback_prompt.is_empty() or \
			record_id != str(_pending_run_feedback_prompt.get("record_id", "")) or \
			question_id != StringName(str(
				_pending_run_feedback_prompt.get("question_id", ""))):
		return
	_clear_run_feedback_prompt()
	if _session != null:
		_session.request_restart()


func _request_restart() -> void:
	if _session != null and _pending_run_feedback_prompt.is_empty():
		_session.request_restart()


func _save_diagnostic_export(payload: Dictionary) -> void:
	if not _save_repository.save_diagnostic(payload):
		printerr("[spider-swing] diagnostic write failed; current run continues")
		return
	if _session != null:
		_session.event_published.emit(SimulationEvent.make(
			SimulationEvent.Kind.DIAGNOSTIC_EXPORTED,
			Vector2.ZERO,
			"Diagnostic saved",
			{"path": _save_repository.diagnostic_absolute_path()},
		))


func _copy_run_history_export(payload: String) -> void:
	var call_made := _clipboard_adapter != null and \
		_clipboard_adapter.copy_text(payload)
	_front_end_state.report_run_history_export_result(call_made)


func _unlock_region_checkpoint(
	region_id: StringName,
	distance_pixels: float,
) -> void:
	if not _progression_service.unlock_region_checkpoint(
		_progress,
		region_id,
		distance_pixels,
	):
		return
	_save_progress_and_refresh()


func _select_spider_profile(spider_id: StringName) -> void:
	if _progression_service.select_spider_profile(_progress, spider_id):
		_save_progress_and_refresh()


func _select_spider_style(style: StringName) -> void:
	if _progression_service.select_spider_style(_progress, style):
		_save_progress_and_refresh()


func _select_web_variant(web_variant: StringName) -> void:
	if _progression_service.select_web_variant(_progress, web_variant):
		_save_progress_and_refresh()


func _purchase_upgrade(upgrade_id: StringName) -> void:
	var result := _progression_service.purchase_upgrade(_progress, upgrade_id)
	if bool(result.get("purchased", false)):
		_save_progress_and_refresh()


func _cycle_creator_piece(slot: int) -> void:
	if _progression_service.cycle_creator_piece(_progress, slot):
		_save_progress_and_refresh()


func _clear_creator_pattern() -> void:
	_progression_service.clear_creator_pattern(_progress)
	_save_progress_and_refresh()


func _save_progress_and_refresh() -> void:
	if not _save_repository.save_progress(_progress):
		printerr("[spider-swing] progress write failed; current session continues")
	_front_end_state.configure_progress(_progress)


func _on_web_tapped(screen_position: Vector2) -> void:
	if _session != null and _view != null:
		_session.request_web_tap(_view.screen_to_world(screen_position))


func _on_burst_gesture(screen_position: Vector2) -> void:
	if _session != null and _view != null:
		_session.request_burst_from_gesture(
			_view.screen_to_world(screen_position))


func _report_boot(failures: PackedStringArray) -> void:
	print("[spider-swing] boot: engine %s" % Engine.get_version_info().get(
		"string", "unknown"))
	print("[spider-swing] boot: main scene %s" % ProjectSettings.get_setting(
		"application/run/main_scene", ""))
	print("[spider-swing] boot: physics_ticks_per_second %d" %
		Engine.physics_ticks_per_second)
	print("[spider-swing] boot: display server %s" % DisplayServer.get_name())
	if failures.is_empty():
		print("[spider-swing] boot: OK — front end mounted before gameplay")
	else:
		for failure: String in failures:
			printerr("[spider-swing] boot: FAILED — %s" % failure)


func _quit_with(code: int) -> void:
	get_tree().quit(code)

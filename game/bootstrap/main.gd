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
const INPUT_ROUTER := preload("res://game/adapters/input_router.gd")
const SMOKE_TEST_FLAG := "--smoke-test"
const EXIT_OK := 0
const EXIT_BOOT_FAILED := 1

var _front_end_state: FrontEndState
var _front_end_view: FrontEndView
var _save_repository: SaveRepository
var _progression_service: ProgressionService
var _progress: PlayerProgress
var _session: SwingLabSession
var _input_router: InputRouter
var _view: SwingLabView


func _ready() -> void:
	_save_repository = SAVE_REPOSITORY_SCRIPT.new() as SaveRepository
	_progression_service = PROGRESSION_SERVICE_SCRIPT.new() as ProgressionService
	_progress = _save_repository.load_progress()
	_front_end_state = FRONT_END_STATE_SCRIPT.new() as FrontEndState
	_front_end_state.play_requested.connect(_start_game)
	_front_end_state.settings_changed.connect(_save_settings)
	_front_end_state.configure(_save_repository.load_settings())
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
	_unmount_front_end()
	var failures := _mount_swing_lab(settings)
	if failures.is_empty():
		return
	for failure: String in failures:
		printerr("[spider-swing] start failed — %s" % failure)
	_unmount_swing_lab()
	_mount_front_end()


func _mount_swing_lab(settings: PlayerSettings) -> PackedStringArray:
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
	if _session == null or _input_router == null:
		failures.append("application or input adapter failed to instantiate")
		return failures

	_session.snapshot_published.connect(_view.present)
	_session.event_published.connect(_view.present_event)
	_session.event_published.connect(_input_router.present_simulation_event)
	_session.settlement_created.connect(_apply_settlement)
	_session.configure_progress(_progress)
	_input_router.web_tapped.connect(_on_web_tapped)
	_input_router.reel_changed.connect(_session.set_reel_active)
	_input_router.burst_requested.connect(_session.request_burst)
	_input_router.burst_gesture.connect(_on_burst_gesture)
	_input_router.restart_requested.connect(_session.request_restart)
	_input_router.menu_requested.connect(_return_to_menu)
	_input_router.debug_toggle_requested.connect(_session.toggle_debug)
	_input_router.debug_pause_requested.connect(_session.toggle_debug_pause)
	_input_router.debug_frame_step_requested.connect(_session.step_debug_frame)
	_input_router.slow_motion_requested.connect(_session.toggle_slow_motion)
	_input_router.preset_requested.connect(_session.apply_preset)
	_input_router.tuning_parameter_requested.connect(
		_session.select_tuning_parameter)
	_input_router.tuning_adjustment_requested.connect(
		_session.adjust_selected_parameter)
	_input_router.recording_requested.connect(_session.toggle_recording)
	_input_router.replay_requested.connect(_session.replay_recording)
	_input_router.diagnostic_export_requested.connect(_session.export_diagnostic)

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
	return failures


func _return_to_menu() -> void:
	call_deferred("_show_front_end")


func _show_front_end() -> void:
	_unmount_swing_lab()
	_front_end_state.show_home()
	_mount_front_end()


func _unmount_front_end() -> void:
	if _front_end_view == null:
		return
	remove_child(_front_end_view)
	_front_end_view.queue_free()
	_front_end_view = null


func _unmount_swing_lab() -> void:
	if _input_router != null:
		_input_router.cancel_held_input()
		remove_child(_input_router)
		_input_router.queue_free()
		_input_router = null
	if _session != null:
		remove_child(_session)
		_session.queue_free()
		_session = null
	if _view != null:
		remove_child(_view)
		_view.queue_free()
		_view = null


func _save_settings(settings: PlayerSettings) -> void:
	if not _save_repository.save_settings(settings):
		printerr("[spider-swing] settings write failed; current session continues")


func _apply_settlement(settlement: RunSettlement) -> void:
	var result := _progression_service.apply_settlement(_progress, settlement)
	if not bool(result.get("applied", false)):
		return
	if not _save_repository.save_progress(_progress):
		printerr("[spider-swing] progress write failed; current session continues")
	if _session != null:
		_session.configure_progress(_progress)
	var unlocked: PackedStringArray = result.get(
		"unlocked", PackedStringArray())
	if not unlocked.is_empty() and _session != null:
		_session.event_published.emit(SimulationEvent.make(
			SimulationEvent.Kind.FLY_COLLECTED,
			Vector2.ZERO,
			"Unlocked spider: %s" % unlocked[0],
			{"unlocked": unlocked},
		))


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

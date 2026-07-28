extends Node
## Spider Swing composition root and headless smoke-test entry point.

const SWING_LAB_SCENE_PATH := "res://game/presentation/scenes/swing_lab.tscn"
const SWING_LAB_SESSION := preload(
	"res://game/application/swing_lab_session.gd")
const INPUT_ROUTER := preload("res://game/adapters/input_router.gd")
const SMOKE_TEST_FLAG := "--smoke-test"
const EXIT_OK := 0
const EXIT_BOOT_FAILED := 1

var _session: SwingLabSession
var _input_router: InputRouter
var _view: SwingLabView


func _ready() -> void:
	var failures: PackedStringArray = _mount_swing_lab()
	if is_smoke_test():
		_report_boot(failures)
		var code: int = EXIT_OK if failures.is_empty() else EXIT_BOOT_FAILED
		call_deferred("_quit_with", code)


func is_smoke_test() -> bool:
	if DisplayServer.get_name() == "headless":
		return true
	return SMOKE_TEST_FLAG in OS.get_cmdline_user_args()


func _mount_swing_lab() -> PackedStringArray:
	var failures := PackedStringArray()
	if not ResourceLoader.exists(SWING_LAB_SCENE_PATH):
		failures.append("scene not found: %s" % SWING_LAB_SCENE_PATH)
		return failures

	var scene: PackedScene = load(SWING_LAB_SCENE_PATH) as PackedScene
	if scene == null:
		failures.append("scene did not load as a PackedScene: %s" % SWING_LAB_SCENE_PATH)
		return failures

	_view = scene.instantiate() as SwingLabView
	if _view == null:
		failures.append("scene failed to instantiate as SwingLabView")
		return failures
	add_child(_view)

	_session = SWING_LAB_SESSION.new() as SwingLabSession
	_input_router = INPUT_ROUTER.new() as InputRouter
	if _session == null or _input_router == null:
		failures.append("application or input adapter failed to instantiate")
		return failures

	_session.snapshot_published.connect(_view.present)
	_session.event_published.connect(_view.present_event)
	_input_router.web_tapped.connect(_on_web_tapped)
	_input_router.reel_changed.connect(_session.set_reel_active)
	_input_router.restart_requested.connect(_session.request_restart)
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

	add_child(_session)
	add_child(_input_router)
	return failures


func _on_web_tapped(screen_position: Vector2) -> void:
	_session.request_web_tap(_view.screen_to_world(screen_position))


func _report_boot(failures: PackedStringArray) -> void:
	print("[spider-swing] boot: engine %s" % Engine.get_version_info().get(
		"string", "unknown"))
	print("[spider-swing] boot: main scene %s" % ProjectSettings.get_setting(
		"application/run/main_scene", ""))
	print("[spider-swing] boot: physics_ticks_per_second %d" %
		Engine.physics_ticks_per_second)
	print("[spider-swing] boot: display server %s" % DisplayServer.get_name())
	if failures.is_empty():
		print("[spider-swing] boot: OK — Swing Laboratory mounted")
	else:
		for failure: String in failures:
			printerr("[spider-swing] boot: FAILED — %s" % failure)


func _quit_with(code: int) -> void:
	get_tree().quit(code)

extends SceneTree
## Headless bootstrap + Phase 0 contract runner.

const ZoneProgressionSuite = preload(
	"res://tests/unit/zone_progression_tests.gd")
const AudioPresentationSuite = preload(
	"res://tests/unit/audio_presentation_tests.gd")
const TutorialPracticeSuite = preload(
	"res://tests/unit/tutorial_practice_tests.gd")

const MAIN_SCENE_PATH := "res://game/bootstrap/main.tscn"
const EXPORT_PRESETS_PATH := "res://export_presets.cfg"
const ANDROID_WORKFLOW_PATH := "res://.github/workflows/android-debug.yml"
const BUILD_VERSION := "0.42.0-difficulty-profiles"
const ANDROID_VERSION_CODE := 62
const ANDROID_APP_NAME := "Spider Swing Difficulty Profiles (dev)"
const DEBUG_KEYSTORE_PATH := "res://.github/android/debug.keystore"
const DEBUG_KEYSTORE_SHA256 := \
	"e9104672477e0238b6cc2f7d6b994c459e37f130cae06a37aff05001f101bbda"
const EXPECTED_CHECK_COUNT := 251
const REQUIRED_INPUT_ACTIONS := [
	"web_action", "reel_in", "burst_action", "pause", "restart_run",
	"toggle_debug"]

var _failures := PackedStringArray()
var _passed := 0


func _initialize() -> void:
	print("[test_runner] Spider Swing contracts — Godot %s" %
		Engine.get_version_info().get("string", "unknown"))
	_check_engine()
	_check_main_scene()
	_check_input_actions()
	_check_project_configuration()
	_check_android_preset()
	_check_no_autoloads()
	_check_inward_dependencies()
	_check_phase0_physics()
	_check_zone_progression()
	_check_spider_biology()
	_check_campaign()
	_check_tutorial_practice()
	_check_difficulty()
	_check_upgrade_audit()
	_check_simulation_lab()
	_check_course_audit()
	_check_course_pressure()
	_check_economy()
	_check_audio_presentation()
	_check_mobile_hud_layout()
	_check_front_end_flow()
	print("")
	if _failures.is_empty() and _passed != EXPECTED_CHECK_COUNT:
		# The common cause is a merge, not a broken test. Two branches that each
		# add a contract each bump this constant by one, writing identical text
		# — so git merges the line with no conflict while the merged tree runs
		# the sum. Say that here, because the diff gives no hint and the wrong
		# repair is to go hunting for a stray test.
		_fail(
			("runner executed %d checks but the declared suite requires %d. "
				+ "If you just merged main, both sides likely added contracts: "
				+ "set EXPECTED_CHECK_COUNT to the executed total %d, not to "
				+ "either branch's value. Only lower it if you deliberately "
				+ "removed a contract.") % [
				_passed,
				EXPECTED_CHECK_COUNT,
				_passed,
			],
		)
	if _failures.is_empty():
		print("[test_runner] PASS — %d check(s) passed" % _passed)
		quit(0)
		return
	printerr("[test_runner] FAIL — %d passed, %d failed" % [
		_passed, _failures.size()])
	for failure: String in _failures:
		printerr("  ✗ %s" % failure)
	quit(1)


func _ok(message: String) -> void:
	_passed += 1
	print("  ✓ %s" % message)


func _fail(message: String) -> void:
	_failures.append(message)


func _check_engine() -> void:
	var info := Engine.get_version_info()
	var actual := "%d.%d.%d" % [
		int(info.get("major", 0)), int(info.get("minor", 0)),
		int(info.get("patch", 0))]
	if actual == _pinned_version():
		_ok("engine is pinned %s" % actual)
	else:
		_fail("engine is %s but pin is %s" % [actual, _pinned_version()])


func _pinned_version() -> String:
	var file := FileAccess.open("res://.godot-version", FileAccess.READ)
	return "missing" if file == null else file.get_as_text().strip_edges()


func _check_main_scene() -> void:
	var configured := str(ProjectSettings.get_setting(
		"application/run/main_scene", ""))
	if configured != MAIN_SCENE_PATH or not ResourceLoader.exists(configured):
		_fail("main scene does not resolve: %s" % configured)
		return
	var scene := load(configured) as PackedScene
	if scene == null:
		_fail("main scene is not a PackedScene")
		return
	var instance := scene.instantiate()
	if instance == null:
		_fail("main scene failed to instantiate")
		return
	instance.free()
	_ok("main scene resolves and instantiates")


func _check_input_actions() -> void:
	var missing := PackedStringArray()
	for action: String in REQUIRED_INPUT_ACTIONS:
		if not InputMap.has_action(action):
			missing.append(action)
	if missing.is_empty():
		_ok("all required input actions exist")
	else:
		_fail("missing input actions: %s" % ", ".join(missing))


func _check_project_configuration() -> void:
	var ticks := int(ProjectSettings.get_setting(
		"physics/common/physics_ticks_per_second", 0))
	var catchup := int(ProjectSettings.get_setting(
		"physics/common/max_physics_steps_per_frame", 0))
	var renderer := str(ProjectSettings.get_setting(
		"rendering/renderer/rendering_method", ""))
	var width := int(ProjectSettings.get_setting(
		"display/window/size/viewport_width", 0))
	var height := int(ProjectSettings.get_setting(
		"display/window/size/viewport_height", 0))
	var orientation := int(ProjectSettings.get_setting(
		"display/window/handheld/orientation", -1))
	var build_version := str(ProjectSettings.get_setting(
		"application/config/version", ""))
	var mouse_from_touch := bool(ProjectSettings.get_setting(
		"input_devices/pointing/emulate_mouse_from_touch", false))
	var touch_from_mouse := bool(ProjectSettings.get_setting(
		"input_devices/pointing/emulate_touch_from_mouse", true))
	if ticks == 60 and Engine.physics_ticks_per_second == 60 and catchup == 4:
		_ok("fixed simulation is 60 Hz with four catch-up steps")
	else:
		_fail("fixed-step configuration drifted")
	if renderer == "gl_compatibility" and width == 1280 and height == 720 and \
			orientation == DisplayServer.SCREEN_LANDSCAPE:
		_ok("renderer, viewport, and landscape orientation are locked")
	else:
		_fail("renderer or display configuration drifted")
	if mouse_from_touch and not touch_from_mouse:
		_ok("touch emulation direction is explicit and adapter-arbitrated")
	else:
		_fail("touch emulation can duplicate or disable the mobile GUI path")
	if build_version == BUILD_VERSION:
		_ok("visible build identity is %s" % BUILD_VERSION)
	else:
		_fail("project build identity is %s but expected %s" % [
			build_version, BUILD_VERSION])


func _check_android_preset() -> void:
	var config := ConfigFile.new()
	if config.load(EXPORT_PRESETS_PATH) != OK:
		_fail("Android export preset cannot be read")
		return
	for section: String in config.get_sections():
		if str(config.get_value(section, "name", "")) != "Android Debug":
			continue
		var options := "%s.options" % section
		if str(config.get_value(section, "platform", "")) != "Android":
			_fail("Android Debug preset targets the wrong platform")
			return
		if str(config.get_value(options, "package/unique_name", "")) != \
				"com.menno420.spiderswing.dev":
			_fail("development package identifier drifted")
			return
		if int(config.get_value(options, "version/code", 0)) != \
				ANDROID_VERSION_CODE or \
				str(config.get_value(options, "version/name", "")) != \
				BUILD_VERSION:
			_fail("Android Debug build identity drifted")
			return
		var workflow := FileAccess.open(ANDROID_WORKFLOW_PATH, FileAccess.READ)
		if workflow == null:
			_fail("Android debug workflow cannot be read")
			return
		var workflow_text := workflow.get_as_text()
		if not workflow_text.contains("BUILD_VERSION: %s" % BUILD_VERSION) or \
				not workflow_text.contains(
					"version/code=%d" % ANDROID_VERSION_CODE) or \
				not workflow_text.contains(
					"APP_NAME: %s" % ANDROID_APP_NAME) or \
				not workflow_text.contains(
					"package/name=\\\"${APP_NAME}\\\"") or \
				not workflow_text.contains("display_name=${APP_NAME}"):
			_fail("Android debug workflow build assertions drifted")
			return
		if not FileAccess.file_exists(DEBUG_KEYSTORE_PATH) or \
				FileAccess.get_sha256(DEBUG_KEYSTORE_PATH) != \
				DEBUG_KEYSTORE_SHA256:
			_fail("stable Android debug keystore is missing or changed")
			return
		if workflow_text.contains("keytool -genkey") or \
				workflow_text.contains("RUNNER_TEMP}/keystore") or \
				workflow_text.contains("runner.temp }}/keystore") or \
				not workflow_text.contains(
					"DEBUG_KEYSTORE_PATH: .github/android/debug.keystore") or \
				not workflow_text.contains("must NEVER be reused"):
			_fail("Android workflow can regenerate or misuse its debug signing key")
			return
		_ok("Android debug signing is stable, public, and release-forbidden")
		_ok("Android Debug preset is development-only and uniquely versioned")
		return
	_fail("Android Debug preset is missing")


func _check_no_autoloads() -> void:
	for property: Dictionary in ProjectSettings.get_property_list():
		if str(property.get("name", "")).begins_with("autoload/"):
			_fail("autoload introduced without an ADR")
			return
	_ok("no gameplay autoload singletons")


func _check_inward_dependencies() -> void:
	var forbidden := {
		"res://game/domain": ["simulation", "application", "adapters", "presentation"],
		"res://game/simulation": ["application", "adapters", "presentation"],
		"res://game/application": ["adapters", "presentation"],
	}
	for root: String in forbidden:
		for path: String in _gd_files_under(root):
			var file := FileAccess.open(path, FileAccess.READ)
			if file == null:
				continue
			var text := file.get_as_text()
			for token: String in forbidden[root]:
				if text.contains("res://game/%s" % token):
					_fail("%s references outward layer %s" % [path, token])
					return
	_ok("inward dependency direction holds")


func _gd_files_under(root: String) -> PackedStringArray:
	var found := PackedStringArray()
	var dir := DirAccess.open(root)
	if dir == null:
		return found
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if not entry.begins_with("."):
			var path := "%s/%s" % [root, entry]
			if dir.current_is_dir():
				found.append_array(_gd_files_under(path))
			elif entry.ends_with(".gd"):
				found.append(path)
		entry = dir.get_next()
	dir.list_dir_end()
	return found


func _check_phase0_physics() -> void:
	var result := Phase0PhysicsTests.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Phase 0 physics: %d deterministic checks" %
			int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Phase 0 physics — %s" % failure)


func _check_zone_progression() -> void:
	var result := ZoneProgressionSuite.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Zones 3–8: %d geometry, mechanic, and art contracts" %
			int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Zones 3–8 — %s" % failure)


func _check_economy() -> void:
	var result := EconomyTests.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Economy: %d currency and reward contracts" %
			int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Economy — %s" % failure)


func _check_upgrade_audit() -> void:
	var result := UpgradeAuditTests.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Upgrade wiring: %d contracts" % int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Upgrade wiring — %s" % failure)


func _check_simulation_lab() -> void:
	var result := SimulationLabTests.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Simulation lab inputs: %d contracts" % int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Simulation lab inputs — %s" % failure)


func _check_course_audit() -> void:
	var result := CourseAuditTests.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Course audit instrument: %d contracts" % int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Course audit instrument — %s" % failure)


func _check_course_pressure() -> void:
	var result := CoursePressureTests.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Course pressure curve: %d contracts" % int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Course pressure curve — %s" % failure)


func _check_difficulty() -> void:
	var result := DifficultyTests.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Difficulty modes: %d contracts" % int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Difficulty modes — %s" % failure)


func _check_campaign() -> void:
	var result := CampaignTests.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Campaign teaching tier: %d contracts" %
			int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Campaign teaching tier — %s" % failure)


func _check_tutorial_practice() -> void:
	var result := TutorialPracticeSuite.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Tutorial lesson practice: %d contracts" % int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Tutorial lesson practice — %s" % failure)


func _check_spider_biology() -> void:
	var result := SpiderBiologyTests.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Spider biology: %d inspiration and disclosure contracts" %
			int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Spider biology — %s" % failure)


func _check_audio_presentation() -> void:
	var result := AudioPresentationSuite.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Generated audio: %d source, asset, and wiring contracts" %
			int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Generated audio — %s" % failure)


func _check_mobile_hud_layout() -> void:
	var result := MobileHudLayoutTests.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Mobile HUD layout: %d GUI contracts" %
			int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Mobile HUD layout — %s" % failure)


func _check_front_end_flow() -> void:
	var result := FrontEndFlowTests.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Front-end flow: %d navigation and settings contracts" %
			int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Front-end flow — %s" % failure)

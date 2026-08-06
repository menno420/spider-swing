extends SceneTree
## Headless bootstrap + Phase 0 contract runner.

const ZoneProgressionSuite = preload(
	"res://tests/unit/zone_progression_tests.gd")
const AudioPresentationSuite = preload(
	"res://tests/unit/audio_presentation_tests.gd")
const TutorialPracticeSuite = preload(
	"res://tests/unit/tutorial_practice_tests.gd")
const RunEvidenceSuite = preload(
	"res://tests/unit/run_evidence_tests.gd")

const MAIN_SCENE_PATH := "res://game/bootstrap/main.tscn"
const EXPORT_PRESETS_PATH := "res://export_presets.cfg"
const ANDROID_WORKFLOW_PATH := "res://.github/workflows/android-debug.yml"
const ANDROID_RELEASE_WORKFLOW_PATH := \
	"res://.github/workflows/android-release.yml"
const BUILD_VERSION := "0.44.0-run-evidence"
const ANDROID_VERSION_CODE := 65
const ANDROID_APP_NAME := "Spider Swing Run Evidence (dev)"
const DEBUG_KEYSTORE_PATH := "res://.github/android/debug.keystore"
const DEBUG_KEYSTORE_SHA256 := \
	"e9104672477e0238b6cc2f7d6b994c459e37f130cae06a37aff05001f101bbda"
# Release packaging (ADR 0005). Play requires an App Bundle for new apps, and a
# published applicationId is permanent — so the committed identity is a
# deliberate placeholder and the workflow substitutes the owner's real value.
const RELEASE_PRESET_NAME := "Android Release"
const RELEASE_PLACEHOLDER_PACKAGE := "com.example.PLACEHOLDER.setbyworkflow"
const RELEASE_PLACEHOLDER_APP_NAME := "PLACEHOLDER SET BY WORKFLOW"
const RELEASE_EXPORT_FORMAT_AAB := 1
const RELEASE_MIN_SDK := "24"
const RELEASE_TARGET_SDK := "36"
const EXPECTED_CHECK_COUNT := 266
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
	_check_android_release_preset()
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
	_check_run_evidence()
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
	var android_version_code := int(ProjectSettings.get_setting(
		"application/config/android_version_code", 0))
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
	if build_version == BUILD_VERSION and \
			android_version_code == ANDROID_VERSION_CODE:
		_ok("visible build identity is %s / Android %d" % [
			BUILD_VERSION, ANDROID_VERSION_CODE])
	else:
		_fail("project build identity is %s / Android %d but expected %s / %d" % [
			build_version, android_version_code,
			BUILD_VERSION, ANDROID_VERSION_CODE,
		])


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


func _check_android_release_preset() -> void:
	## ADR 0005. Google Play has not accepted an APK for a new app since August
	## 2021, so a release path must produce an App Bundle. These contracts guard
	## the two ways that path can go wrong quietly: shipping the wrong artifact
	## format, and freezing a permanent identifier or a real key into the tree.
	var config := ConfigFile.new()
	if config.load(EXPORT_PRESETS_PATH) != OK:
		_fail("export presets cannot be read")
		return
	for section: String in config.get_sections():
		if str(config.get_value(section, "name", "")) != RELEASE_PRESET_NAME:
			continue
		var options := "%s.options" % section
		if str(config.get_value(section, "platform", "")) != "Android":
			_fail("Android Release preset targets the wrong platform")
			return

		# An APK cannot be submitted as a new app, and Godot refuses the AAB
		# format unless the Gradle build is enabled — so these two travel together.
		if int(config.get_value(options, "gradle_build/export_format", -1)) != \
				RELEASE_EXPORT_FORMAT_AAB:
			_fail("Android Release preset does not export an App Bundle")
			return
		if not bool(config.get_value(
				options, "gradle_build/use_gradle_build", false)):
			_fail("Android Release preset needs the Gradle build for an AAB")
			return
		if not str(config.get_value(section, "export_path", "")).ends_with(
				".aab"):
			_fail("Android Release export path is not an .aab")
			return
		_ok("Android Release preset exports an App Bundle via the Gradle build")

		# Pinned rather than left blank: Play requires API 36 of new submissions
		# from 2026-08-31, and an engine upgrade must not move it silently.
		if str(config.get_value(options, "gradle_build/min_sdk", "")) != \
				RELEASE_MIN_SDK or \
				str(config.get_value(options, "gradle_build/target_sdk", "")) != \
				RELEASE_TARGET_SDK:
			_fail("Android Release SDK levels are not pinned to %s/%s" % [
				RELEASE_MIN_SDK, RELEASE_TARGET_SDK])
			return
		_ok("Android Release pins min/target SDK for Play's requirement")

		# A published applicationId can never be changed or reused. The committed
		# value must stay a placeholder; the workflow substitutes the real one.
		var release_package := str(
			config.get_value(options, "package/unique_name", ""))
		if release_package != RELEASE_PLACEHOLDER_PACKAGE:
			_fail("Android Release package identifier is no longer the "
				+ "placeholder — a permanent applicationId must not be committed")
			return
		if str(config.get_value(options, "package/name", "")) != \
				RELEASE_PLACEHOLDER_APP_NAME:
			_fail("Android Release app label is no longer the placeholder")
			return
		_ok("Android Release identity stays a placeholder in the tree")

		# No key exists here, so the committed preset must not claim to sign.
		if bool(config.get_value(options, "package/signed", true)):
			_fail("Android Release preset claims signing with no key in the tree")
			return
		_ok("Android Release preset is unsigned in the committed tree")

		var workflow := FileAccess.open(
			ANDROID_RELEASE_WORKFLOW_PATH, FileAccess.READ)
		if workflow == null:
			_fail("Android release workflow cannot be read")
			return
		var workflow_text := workflow.get_as_text()
		# Never on a push, never publishing, never signing with the public key.
		#
		# Matched against the release signing ASSIGNMENTS rather than a bare
		# mention of the key: the file names the debug keystore in prose to say
		# it must never be used here, and a substring test cannot tell a
		# prohibition from a use. An earlier version of this contract could not,
		# and failed on the sentence forbidding the thing it was checking for.
		var debug_key_wired := RegEx.new()
		debug_key_wired.compile(
			"GODOT_ANDROID_KEYSTORE_RELEASE_(PATH|USER|PASSWORD):"
			+ "[^\\n]*(debug\\.keystore|androiddebugkey)")
		if debug_key_wired.search(workflow_text) != null:
			_fail("Android release workflow signs with the public debug key")
			return
		if not workflow_text.contains("workflow_dispatch:") or \
				workflow_text.contains("branches: [main]"):
			_fail("Android release workflow must be manual dispatch only")
			return
		if not workflow_text.contains("vars.RELEASE_PACKAGE_ID") or \
				not workflow_text.contains("com.example.*|*PLACEHOLDER*"):
			_fail("Android release workflow does not refuse a placeholder identity")
			return
		_ok("Android release workflow is dispatch-only and refuses placeholders")
		return
	_fail("Android Release preset is missing")


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


func _check_run_evidence() -> void:
	var result := RunEvidenceSuite.run()
	var failures: PackedStringArray = result["failures"]
	if failures.is_empty():
		_passed += int(result["passed"])
		print("  ✓ Local run evidence: %d metric, lifecycle, and UI contracts" %
			int(result["passed"]))
		return
	for failure: String in failures:
		_fail("Local run evidence — %s" % failure)


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

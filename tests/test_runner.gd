extends SceneTree
## Headless test runner for Spider Swing.
##
## Run via `tools/verify.py`, or directly:
##     godot --headless --path . --script res://tests/test_runner.gd
##
## Exits 0 when every check passes, 1 otherwise. Each check is independent and
## all of them run, so one failure never hides the rest.
##
## Scope: this runner asserts the *bootstrap contracts* — the configuration and
## architectural invariants this repository promises. It deliberately contains
## no swing-physics assertions, because no swing physics exists yet. Phase 0
## adds fixed-rate and trajectory tests under tests/unit/ and
## tests/integration/ and registers them here.

const MAIN_SCENE_PATH := "res://game/bootstrap/main.tscn"
const EXPORT_PRESETS_PATH := "res://export_presets.cfg"
const ANDROID_DEBUG_PRESET_NAME := "Android Debug"
const EXPECTED_PHYSICS_TICKS := 60
const EXPECTED_MAX_CATCHUP_STEPS := 4
const EXPECTED_RENDERING_METHOD := "gl_compatibility"

const REQUIRED_INPUT_ACTIONS: PackedStringArray = [
	"web_action",
	"reel_in",
	"pause",
	"restart_run",
	"toggle_debug",
]

## Layers that must not reach outward. Each entry maps an inward layer to the
## outward layer tokens it may never reference. The authoritative, richer
## version of this rule lives in tools/check_architecture.py; this runner keeps
## an in-engine copy so a Godot-side regression is caught even if someone runs
## the suite without the Python checker.
const INWARD_LAYERS: Dictionary = {
	"res://game/domain": ["presentation", "adapters", "application", "simulation"],
	"res://game/simulation": ["presentation", "adapters", "application"],
	"res://game/application": ["presentation", "adapters"],
}

var _failures: PackedStringArray = []
var _passed: int = 0


func _initialize() -> void:
	print("[test_runner] Spider Swing bootstrap contracts — Godot %s" % \
		Engine.get_version_info().get("string", "unknown"))

	_check_engine_version()
	_check_main_scene_resolves()
	_check_main_scene_instantiates()
	_check_input_actions()
	_check_physics_configuration()
	_check_renderer_and_viewport()
	_check_android_debug_preset()
	_check_inward_dependencies()
	_check_no_gameplay_autoloads()

	print("")
	if _failures.is_empty():
		print("[test_runner] PASS — %d check(s) passed" % _passed)
		quit(0)
		return

	printerr("[test_runner] FAIL — %d passed, %d failed" % [_passed, _failures.size()])
	for failure: String in _failures:
		printerr("  ✗ %s" % failure)
	quit(1)


func _ok(what: String) -> void:
	_passed += 1
	print("  ✓ %s" % what)


func _fail(what: String) -> void:
	_failures.append(what)


## The project must be running on the pinned engine series. verify.py checks the
## binary too; this catches someone pointing a stale binary at the project.
func _check_engine_version() -> void:
	var info: Dictionary = Engine.get_version_info()
	var major: int = int(info.get("major", 0))
	var minor: int = int(info.get("minor", 0))
	var patch: int = int(info.get("patch", 0))
	var actual := "%d.%d.%d" % [major, minor, patch]
	var expected := _pinned_version()
	if actual == expected:
		_ok("engine is the pinned %s" % expected)
	else:
		_fail("engine is %s but .godot-version pins %s" % [actual, expected])


func _pinned_version() -> String:
	var file := FileAccess.open("res://.godot-version", FileAccess.READ)
	if file == null:
		return "4.7.1"
	return file.get_as_text().strip_edges()


func _check_main_scene_resolves() -> void:
	var configured: String = str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if configured != MAIN_SCENE_PATH:
		_fail("main scene is '%s', expected '%s'" % [configured, MAIN_SCENE_PATH])
		return
	if not ResourceLoader.exists(configured):
		_fail("configured main scene does not exist: %s" % configured)
		return
	_ok("main scene resolves: %s" % configured)


## Boot proof: the main scene must actually instantiate, not merely exist. This
## is the check that would have caught a broken script reference or a renamed
## unique node.
func _check_main_scene_instantiates() -> void:
	var scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	if scene == null:
		_fail("main scene did not load as a PackedScene")
		return
	var instance: Node = scene.instantiate()
	if instance == null:
		_fail("main scene failed to instantiate")
		return
	instance.free()
	_ok("main scene instantiates cleanly")


func _check_input_actions() -> void:
	var missing := PackedStringArray()
	for action: String in REQUIRED_INPUT_ACTIONS:
		if not InputMap.has_action(action):
			missing.append(action)
	if missing.is_empty():
		_ok("all %d required input actions exist" % REQUIRED_INPUT_ACTIONS.size())
	else:
		_fail("missing input action(s): %s" % ", ".join(missing))


func _check_physics_configuration() -> void:
	var ticks: int = int(ProjectSettings.get_setting(
		"physics/common/physics_ticks_per_second", 0))
	if ticks == EXPECTED_PHYSICS_TICKS:
		_ok("fixed physics tick rate is %d Hz" % ticks)
	else:
		_fail("physics_ticks_per_second is %d, expected %d" % [ticks, EXPECTED_PHYSICS_TICKS])

	# The engine must agree with the project file at runtime, not just on disk.
	if Engine.physics_ticks_per_second == EXPECTED_PHYSICS_TICKS:
		_ok("engine reports %d Hz at runtime" % Engine.physics_ticks_per_second)
	else:
		_fail("Engine.physics_ticks_per_second is %d, expected %d" % [
			Engine.physics_ticks_per_second, EXPECTED_PHYSICS_TICKS])

	var catchup: int = int(ProjectSettings.get_setting(
		"physics/common/max_physics_steps_per_frame", 0))
	if catchup == EXPECTED_MAX_CATCHUP_STEPS:
		_ok("max physics catch-up steps per frame is %d" % catchup)
	else:
		_fail("max_physics_steps_per_frame is %d, expected %d" % [
			catchup, EXPECTED_MAX_CATCHUP_STEPS])


func _check_renderer_and_viewport() -> void:
	var method: String = str(ProjectSettings.get_setting(
		"rendering/renderer/rendering_method", ""))
	if method == EXPECTED_RENDERING_METHOD:
		_ok("renderer is %s (Compatibility)" % method)
	else:
		_fail("rendering_method is '%s', expected '%s'" % [method, EXPECTED_RENDERING_METHOD])

	var width: int = int(ProjectSettings.get_setting("display/window/size/viewport_width", 0))
	var height: int = int(ProjectSettings.get_setting("display/window/size/viewport_height", 0))
	if width == 1280 and height == 720:
		_ok("reference viewport is %dx%d" % [width, height])
	else:
		_fail("reference viewport is %dx%d, expected 1280x720" % [width, height])

	# 0 == DisplayServer.SCREEN_LANDSCAPE.
	var orientation: int = int(ProjectSettings.get_setting(
		"display/window/handheld/orientation", -1))
	if orientation == DisplayServer.SCREEN_LANDSCAPE:
		_ok("handheld orientation is landscape")
	else:
		_fail("handheld orientation is %d, expected %d (landscape)" % [
			orientation, DisplayServer.SCREEN_LANDSCAPE])


func _check_android_debug_preset() -> void:
	var config := ConfigFile.new()
	var err: int = config.load(EXPORT_PRESETS_PATH)
	if err != OK:
		_fail("could not read %s (error %d)" % [EXPORT_PRESETS_PATH, err])
		return

	var found_name := ""
	var found_platform := ""
	var found_package := ""
	for section: String in config.get_sections():
		if not config.has_section_key(section, "name"):
			continue
		if str(config.get_value(section, "name", "")) != ANDROID_DEBUG_PRESET_NAME:
			continue
		found_name = ANDROID_DEBUG_PRESET_NAME
		found_platform = str(config.get_value(section, "platform", ""))
		var options_section := "%s.options" % section
		found_package = str(config.get_value(options_section, "package/unique_name", ""))
		break

	if found_name.is_empty():
		_fail("export preset named exactly '%s' not found in %s" % [
			ANDROID_DEBUG_PRESET_NAME, EXPORT_PRESETS_PATH])
		return
	_ok("export preset '%s' exists" % ANDROID_DEBUG_PRESET_NAME)

	if found_platform == "Android":
		_ok("preset platform is Android")
	else:
		_fail("preset '%s' targets platform '%s', expected 'Android'" % [
			ANDROID_DEBUG_PRESET_NAME, found_platform])

	# Guards the deliberate development-only identifier: a production package
	# name must never appear here without an owner-controlled signing decision.
	if found_package == "com.menno420.spiderswing.dev":
		_ok("package identifier is the development-only com.menno420.spiderswing.dev")
	else:
		_fail("package/unique_name is '%s', expected the development-only 'com.menno420.spiderswing.dev'" % found_package)


## Inward-dependency guard, engine-side. tools/check_architecture.py is the
## authoritative and more thorough implementation.
func _check_inward_dependencies() -> void:
	var violations := PackedStringArray()
	for layer_root: String in INWARD_LAYERS:
		var forbidden: Array = INWARD_LAYERS[layer_root]
		for script_path: String in _gd_files_under(layer_root):
			var file := FileAccess.open(script_path, FileAccess.READ)
			if file == null:
				continue
			var text: String = file.get_as_text()
			for token: String in forbidden:
				if text.contains("res://game/%s" % token):
					violations.append("%s references outward layer '%s'" % [script_path, token])
	if violations.is_empty():
		_ok("inward dependency direction holds across domain/simulation/application")
	else:
		for violation: String in violations:
			_fail(violation)


func _gd_files_under(root: String) -> PackedStringArray:
	var found := PackedStringArray()
	var dir := DirAccess.open(root)
	if dir == null:
		return found
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = dir.get_next()
			continue
		var full := "%s/%s" % [root, entry]
		if dir.current_is_dir():
			found.append_array(_gd_files_under(full))
		elif entry.ends_with(".gd"):
			found.append(full)
		entry = dir.get_next()
	dir.list_dir_end()
	return found


## The GDD forbids a collection of global `Manager` singletons (GDD 19). No
## autoload exists yet, and Phase 0 must not add one casually: an autoload is an
## architecture decision that belongs in an ADR, so this check fails on any
## autoload appearing without one.
func _check_no_gameplay_autoloads() -> void:
	var autoloads := PackedStringArray()
	for property: Dictionary in ProjectSettings.get_property_list():
		var name: String = str(property.get("name", ""))
		if name.begins_with("autoload/"):
			autoloads.append(name.trim_prefix("autoload/"))
	if autoloads.is_empty():
		_ok("no autoload singletons registered")
	else:
		_fail("autoload singleton(s) introduced without an ADR: %s — the GDD forbids global Manager singletons (GDD 19)" % ", ".join(autoloads))

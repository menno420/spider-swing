extends Node
## Spider Swing boot entry point.
##
## Phase-0-bootstrap scope: bring the tree up, mount the Swing Laboratory
## placeholder, and terminate cleanly when running as a headless smoke test.
##
## This script deliberately contains NO gameplay. It is an adapter-layer boot
## shim: it may reference presentation, but nothing in `game/domain/` or
## `game/simulation/` may ever reference it. Phase 0 replaces the placeholder
## mount with the real simulation bring-up; the smoke-test contract below is
## meant to survive that change unmodified.

## Scene mounted at boot. Kept as a constant (not a preload) so a missing scene
## surfaces as an explicit, readable boot failure instead of a parse error.
const SWING_LAB_SCENE_PATH := "res://game/presentation/scenes/swing_lab.tscn"

## Passed as a user argument (`godot ... -- --smoke-test`) to force the
## boot-and-exit path even on a machine with a real display server.
const SMOKE_TEST_FLAG := "--smoke-test"

## Exit codes the smoke test contract promises to CI.
const EXIT_OK := 0
const EXIT_BOOT_FAILED := 1


func _ready() -> void:
	var failures: PackedStringArray = _mount_swing_lab()

	if is_smoke_test():
		_report_boot(failures)
		# Quit from an idle callback rather than inline: quitting inside _ready
		# tears the tree down mid-notification, which reports success even when
		# a child failed to enter the tree.
		var code: int = EXIT_OK if failures.is_empty() else EXIT_BOOT_FAILED
		call_deferred("_quit_with", code)


## True when this process should boot once, report, and exit rather than run
## interactively: either the headless display driver is active (CI) or the
## caller passed --smoke-test explicitly.
func is_smoke_test() -> bool:
	if DisplayServer.get_name() == "headless":
		return true
	return SMOKE_TEST_FLAG in OS.get_cmdline_user_args()


## Instantiates the Swing Laboratory placeholder. Returns a list of failure
## descriptions — empty means the mount succeeded.
func _mount_swing_lab() -> PackedStringArray:
	var failures := PackedStringArray()

	if not ResourceLoader.exists(SWING_LAB_SCENE_PATH):
		failures.append("scene not found: %s" % SWING_LAB_SCENE_PATH)
		return failures

	var scene: PackedScene = load(SWING_LAB_SCENE_PATH) as PackedScene
	if scene == null:
		failures.append("scene did not load as a PackedScene: %s" % SWING_LAB_SCENE_PATH)
		return failures

	var instance: Node = scene.instantiate()
	if instance == null:
		failures.append("scene failed to instantiate: %s" % SWING_LAB_SCENE_PATH)
		return failures

	add_child(instance)
	return failures


func _report_boot(failures: PackedStringArray) -> void:
	print("[spider-swing] boot: engine %s" % Engine.get_version_info().get("string", "unknown"))
	print("[spider-swing] boot: main scene %s" % ProjectSettings.get_setting("application/run/main_scene", ""))
	print("[spider-swing] boot: physics_ticks_per_second %d" % Engine.physics_ticks_per_second)
	print("[spider-swing] boot: display server %s" % DisplayServer.get_name())
	if failures.is_empty():
		print("[spider-swing] boot: OK — smoke test passed")
	else:
		for failure: String in failures:
			printerr("[spider-swing] boot: FAILED — %s" % failure)


func _quit_with(code: int) -> void:
	get_tree().quit(code)

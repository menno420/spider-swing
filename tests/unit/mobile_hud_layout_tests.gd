extends RefCounted
class_name MobileHudLayoutTests
## Regression coverage for the Android screen/canvas coordinate seam.


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_recorded_phone_canvas_size(failures)
	passed += _test_recorded_reel_touch(failures)
	passed += _test_recorded_debug_touch(failures)
	passed += _test_reference_viewport_identity(failures)
	return {"passed": passed, "failures": failures}


static func _recorded_stretch() -> Transform2D:
	# Menno's recording is 1040x480. canvas_items + expand keeps the logical
	# height at 720, producing a 1560x720 canvas and a 2/3 screen scale.
	return Transform2D(
		Vector2(2.0 / 3.0, 0.0),
		Vector2(0.0, 2.0 / 3.0),
		Vector2.ZERO,
	)


static func _recorded_canvas_size() -> Vector2:
	return InputRouter.logical_canvas_size(
		Vector2(1040.0, 480.0),
		_recorded_stretch(),
	)


static func _test_recorded_phone_canvas_size(
	failures: PackedStringArray,
) -> int:
	var actual := _recorded_canvas_size()
	var expected := Vector2(1560.0, 720.0)
	if not actual.is_equal_approx(expected):
		failures.append("1040x480 maps to %s, expected %s" % [actual, expected])
		return 0
	return 1


static func _test_recorded_reel_touch(failures: PackedStringArray) -> int:
	var logical_size := _recorded_canvas_size()
	var recorded_touch := Vector2(1455.0, 612.0)
	if not LabLayout.reel_rect(logical_size).has_point(recorded_touch):
		failures.append("recorded Reel touch misses the logical Reel rectangle")
		return 0
	if LabLayout.reel_rect(Vector2(1040.0, 480.0)).has_point(recorded_touch):
		failures.append("regression proof invalid: physical-size rectangle also hit")
		return 0
	return 1


static func _test_recorded_debug_touch(failures: PackedStringArray) -> int:
	var logical_size := _recorded_canvas_size()
	var recorded_touch := Vector2(1504.0, 50.0)
	if not LabLayout.debug_toggle_rect(logical_size).has_point(recorded_touch):
		failures.append("recorded DEBUG touch misses the logical DEBUG rectangle")
		return 0
	if LabLayout.debug_toggle_rect(Vector2(1040.0, 480.0)).has_point(
			recorded_touch):
		failures.append("regression proof invalid: physical-size DEBUG also hit")
		return 0
	return 1


static func _test_reference_viewport_identity(
	failures: PackedStringArray,
) -> int:
	var actual := InputRouter.logical_canvas_size(
		LabLayout.REFERENCE_SIZE,
		Transform2D.IDENTITY,
	)
	if not actual.is_equal_approx(LabLayout.REFERENCE_SIZE):
		failures.append("identity stretch changed the reference viewport")
		return 0
	return 1

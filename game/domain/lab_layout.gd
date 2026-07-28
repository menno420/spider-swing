extends RefCounted
class_name LabLayout
## Shared viewport-space geometry for the code-drawn HUD and touch adapter.
##
## Both outer peer layers depend inward on this contract; neither imports the
## other or duplicates hit regions.

const REFERENCE_SIZE := Vector2(1280.0, 720.0)
const TUNING_PARAMETERS := [
	&"gravity",
	&"drive",
	&"web_range",
	&"tap_retarget",
	&"aim_forgiveness",
	&"attach_catch_pct",
	&"reel_rate",
	&"burst_pull_pct",
	&"burst_duration",
	&"pull_cooldown",
	&"dive_pull_pct",
	&"dive_duration",
	&"rope_damping",
]
const ACTION_TARGET_SIZE := Vector2(228.0, 228.0)
const ACTION_SIDE_MARGIN := 36.0
const ACTION_BOTTOM_MARGIN := 32.0


static func reel_rect(viewport_size: Vector2) -> Rect2:
	return Rect2(
		ACTION_SIDE_MARGIN,
		viewport_size.y - ACTION_BOTTOM_MARGIN - ACTION_TARGET_SIZE.y,
		ACTION_TARGET_SIZE.x,
		ACTION_TARGET_SIZE.y,
	)


static func burst_rect(viewport_size: Vector2) -> Rect2:
	return Rect2(
		viewport_size.x - ACTION_SIDE_MARGIN - ACTION_TARGET_SIZE.x,
		viewport_size.y - ACTION_BOTTOM_MARGIN - ACTION_TARGET_SIZE.y,
		ACTION_TARGET_SIZE.x,
		ACTION_TARGET_SIZE.y,
	)


static func menu_rect(_viewport_size: Vector2) -> Rect2:
	return Rect2(24.0, 24.0, 92.0, 52.0)


static func debug_toggle_rect(viewport_size: Vector2) -> Rect2:
	return Rect2(viewport_size.x - 88.0, 24.0, 64.0, 52.0)


static func preset_rect(index: int) -> Rect2:
	return Rect2(410.0 + float(index) * 154.0, 24.0, 142.0, 42.0)


static func tuning_previous_rect() -> Rect2:
	return Rect2(26.0, 520.0, 46.0, 42.0)


static func tuning_minus_rect() -> Rect2:
	return Rect2(78.0, 520.0, 52.0, 42.0)


static func tuning_plus_rect() -> Rect2:
	return Rect2(268.0, 520.0, 52.0, 42.0)


static func tuning_next_rect() -> Rect2:
	return Rect2(326.0, 520.0, 46.0, 42.0)


static func utility_rect(index: int) -> Rect2:
	return Rect2(26.0 + float(index) * 112.0, 580.0, 102.0, 42.0)

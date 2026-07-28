extends RefCounted
class_name LabLayout
## Shared viewport-space geometry for the code-drawn HUD and touch adapter.
##
## Both outer peer layers depend inward on this contract; neither imports the
## other or duplicates hit regions.

const REFERENCE_SIZE := Vector2(1280.0, 720.0)
const TUNING_PARAMETERS := [&"gravity", &"drive", &"reel_rate", &"rope_damping"]


static func reel_rect(viewport_size: Vector2) -> Rect2:
	return Rect2(28.0, viewport_size.y - 218.0, 190.0, 190.0)


static func burst_rect(viewport_size: Vector2) -> Rect2:
	return Rect2(viewport_size.x - 206.0, viewport_size.y - 206.0, 178.0, 178.0)


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

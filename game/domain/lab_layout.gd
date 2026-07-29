extends RefCounted
class_name LabLayout
## Shared viewport-space geometry for the code-drawn HUD and touch adapter.
##
## Both outer peer layers depend inward on this contract; neither imports the
## other or duplicates hit regions.

const REFERENCE_SIZE := Vector2(1280.0, 720.0)
const ACTION_TARGET_SIZE := Vector2(228.0, 228.0)
const ACTION_SIDE_MARGIN := 36.0
const ACTION_BOTTOM_MARGIN := 32.0
const DEBUG_PANEL := Rect2(72.0, 12.0, 1136.0, 696.0)
const DEBUG_CONTENT_TOP := 202.0
const DEBUG_CARD_SIZE := Vector2(542.0, 146.0)
const DEBUG_CARD_GAP := Vector2(16.0, 12.0)


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
	return Rect2(viewport_size.x - 126.0, 24.0, 102.0, 56.0)


static func preset_rect(index: int) -> Rect2:
	return Rect2(274.0 + float(index) * 192.0, 76.0, 180.0, 52.0)


static func category_rect(index: int) -> Rect2:
	return Rect2(92.0 + float(index) * 218.0, 140.0, 204.0, 52.0)


static func parameter_card_rect(index: int) -> Rect2:
	var column := index % 2
	var row := index / 2
	return Rect2(
		Vector2(92.0, DEBUG_CONTENT_TOP) +
			Vector2(
				float(column) * (DEBUG_CARD_SIZE.x + DEBUG_CARD_GAP.x),
				float(row) * (DEBUG_CARD_SIZE.y + DEBUG_CARD_GAP.y),
			),
		DEBUG_CARD_SIZE,
	)


static func parameter_minus_rect(index: int) -> Rect2:
	var card := parameter_card_rect(index)
	return Rect2(card.position + Vector2(18.0, 82.0), Vector2(58.0, 52.0))


static func parameter_plus_rect(index: int) -> Rect2:
	var card := parameter_card_rect(index)
	return Rect2(
		card.end - Vector2(76.0, 64.0),
		Vector2(58.0, 52.0),
	)


static func parameter_quick_rect(
	card_index: int,
	quick_index: int,
	quick_count: int,
) -> Rect2:
	var card := parameter_card_rect(card_index)
	var left := card.position.x + 88.0
	var width := card.size.x - 176.0
	var gap := 6.0
	var button_width := (width - gap * float(quick_count - 1)) / \
		float(quick_count)
	return Rect2(
		left + float(quick_index) * (button_width + gap),
		card.position.y + 86.0,
		button_width,
		48.0,
	)


static func utility_rect(index: int) -> Rect2:
	return parameter_card_rect(index)

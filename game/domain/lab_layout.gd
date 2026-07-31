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
const DEBUG_SIDE_MARGIN := 72.0
const DEBUG_TOP_MARGIN := 12.0
const DEBUG_CONTENT_TOP := 202.0
const DEBUG_CARD_HEIGHT := 146.0
const DEBUG_CARD_GAP := Vector2(16.0, 12.0)
const ENVIRONMENT_THEME_COUNT := 5
const ENVIRONMENT_THEME_CARD_HEIGHT := 196.0


static func debug_panel_rect(
	viewport_size: Vector2 = REFERENCE_SIZE,
) -> Rect2:
	return Rect2(
		DEBUG_SIDE_MARGIN,
		DEBUG_TOP_MARGIN,
		maxf(960.0, viewport_size.x - DEBUG_SIDE_MARGIN * 2.0),
		maxf(640.0, viewport_size.y - DEBUG_TOP_MARGIN * 2.0),
	)


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


static func preset_rect(
	index: int,
	viewport_size: Vector2 = REFERENCE_SIZE,
) -> Rect2:
	var panel := debug_panel_rect(viewport_size)
	var group_width := 564.0
	return Rect2(
		panel.get_center().x - group_width * 0.5 + float(index) * 192.0,
		76.0,
		180.0,
		52.0,
	)


static func category_rect(
	index: int,
	viewport_size: Vector2 = REFERENCE_SIZE,
) -> Rect2:
	var panel := debug_panel_rect(viewport_size)
	var gap := 14.0
	var count := float(TuningCatalog.category_count())
	var width := (panel.size.x - 40.0 - gap * (count - 1.0)) / count
	return Rect2(
		panel.position.x + 20.0 + float(index) * (width + gap),
		140.0,
		width,
		52.0,
	)


static func parameter_card_rect(
	index: int,
	viewport_size: Vector2 = REFERENCE_SIZE,
) -> Rect2:
	var panel := debug_panel_rect(viewport_size)
	var column := index % 2
	var row := index / 2
	var card_width := (panel.size.x - 40.0 - DEBUG_CARD_GAP.x) * 0.5
	return Rect2(
		Vector2(panel.position.x + 20.0, DEBUG_CONTENT_TOP) +
			Vector2(
				float(column) * (card_width + DEBUG_CARD_GAP.x),
				float(row) * (DEBUG_CARD_HEIGHT + DEBUG_CARD_GAP.y),
			),
		Vector2(card_width, DEBUG_CARD_HEIGHT),
	)


static func parameter_minus_rect(
	index: int,
	viewport_size: Vector2 = REFERENCE_SIZE,
) -> Rect2:
	var card := parameter_card_rect(index, viewport_size)
	return Rect2(card.position + Vector2(18.0, 82.0), Vector2(58.0, 52.0))


static func parameter_plus_rect(
	index: int,
	viewport_size: Vector2 = REFERENCE_SIZE,
) -> Rect2:
	var card := parameter_card_rect(index, viewport_size)
	return Rect2(
		card.end - Vector2(76.0, 64.0),
		Vector2(58.0, 52.0),
	)


static func parameter_value_entry_rect(
	index: int,
	viewport_size: Vector2 = REFERENCE_SIZE,
) -> Rect2:
	var card := parameter_card_rect(index, viewport_size)
	return Rect2(
		Vector2(card.end.x - 174.0, card.position.y + 8.0),
		Vector2(102.0, 48.0),
	)


static func parameter_value_apply_rect(
	index: int,
	viewport_size: Vector2 = REFERENCE_SIZE,
) -> Rect2:
	var entry := parameter_value_entry_rect(index, viewport_size)
	return Rect2(
		entry.end + Vector2(6.0, 0.0),
		Vector2(48.0, 48.0),
	)


static func parameter_quick_rect(
	card_index: int,
	quick_index: int,
	quick_count: int,
	viewport_size: Vector2 = REFERENCE_SIZE,
) -> Rect2:
	var card := parameter_card_rect(card_index, viewport_size)
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


static func utility_rect(
	index: int,
	viewport_size: Vector2 = REFERENCE_SIZE,
) -> Rect2:
	return parameter_card_rect(index, viewport_size)


static func environment_theme_card_rect(
	index: int,
	viewport_size: Vector2 = REFERENCE_SIZE,
) -> Rect2:
	var panel := debug_panel_rect(viewport_size)
	var columns := 3
	var column := index % columns
	var row := index / columns
	var gap := 14.0
	var width := (panel.size.x - 40.0 - gap * 2.0) / 3.0
	return Rect2(
		panel.position + Vector2(
			20.0 + float(column) * (width + gap),
			DEBUG_CONTENT_TOP + float(row) *
				(ENVIRONMENT_THEME_CARD_HEIGHT + gap),
		),
		Vector2(width, ENVIRONMENT_THEME_CARD_HEIGHT),
	)

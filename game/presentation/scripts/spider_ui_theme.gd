extends RefCounted
class_name SpiderUiTheme
## One presentation-owned skin for every front-end surface.
##
## The neutral slate is the information surface; moss, sap, dew and silk are
## reserved for meaning and selection. This gives dense scientific/debug copy
## the contrast of a real field notebook while keeping the miniature-forest
## identity in its fibres, webs, and material edges.

const BACKGROUND := Color("0d1112")
const PANEL := Color("1a1f20")
const PANEL_SOFT := Color("242a2b")
const PANEL_RAISED := Color("313839")
const INK := Color("f0f2e9")
const MUTED := Color("b0bab6")
const SILK := Color("d9fbff")
const DEW := Color("70d2c2")
const MOSS := Color("82ad73")
const SAP := Color("cf9157")
const AMBER := Color("ffd166")
const BARK := Color("39312d")


static func create_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = 18
	theme.set_color(&"font_color", &"Label", INK)
	theme.set_color(&"font_color", &"Button", INK)
	theme.set_color(&"font_hover_color", &"Button", INK)
	theme.set_color(&"font_focus_color", &"Button", INK)
	theme.set_color(&"font_pressed_color", &"Button", BACKGROUND)
	theme.set_color(&"font_disabled_color", &"Button", Color(MUTED, 0.48))
	theme.set_stylebox(
		&"normal",
		&"Button",
		button_style(PANEL_SOFT, MOSS),
	)
	theme.set_stylebox(
		&"hover",
		&"Button",
		button_style(PANEL_RAISED, DEW),
	)
	theme.set_stylebox(
		&"pressed",
		&"Button",
		button_style(MOSS, MOSS),
	)
	theme.set_stylebox(
		&"focus",
		&"Button",
		button_style(PANEL_SOFT, SILK, 3),
	)
	theme.set_stylebox(
		&"disabled",
		&"Button",
		button_style(Color("101812"), Color(MUTED, 0.28)),
	)
	theme.set_stylebox(&"panel", &"PanelContainer", panel_style(PANEL))
	theme.set_color(&"font_color", &"CheckButton", INK)
	theme.set_color(&"font_hover_color", &"CheckButton", SILK)
	theme.set_color(&"font_pressed_color", &"CheckButton", DEW)
	theme.set_color(&"font_focus_color", &"CheckButton", SILK)
	theme.set_font_size(&"font_size", &"CheckButton", 22)
	theme.set_stylebox(
		&"scroll",
		&"VScrollBar",
		scroll_track_style(),
	)
	theme.set_stylebox(
		&"scroll_focus",
		&"VScrollBar",
		scroll_track_style(),
	)
	theme.set_stylebox(
		&"grabber",
		&"VScrollBar",
		scroll_grabber_style(Color(SILK, 0.64)),
	)
	theme.set_stylebox(
		&"grabber_highlight",
		&"VScrollBar",
		scroll_grabber_style(DEW),
	)
	theme.set_stylebox(
		&"grabber_pressed",
		&"VScrollBar",
		scroll_grabber_style(MOSS),
	)
	theme.set_constant(&"minimum_grab_thickness", &"VScrollBar", 42)
	return theme


static func panel_style(
	fill: Color = PANEL,
	radius: int = 22,
	border: Color = Color(MOSS, 0.42),
	width: int = 2,
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(BACKGROUND, 0.68)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0.0, 4.0)
	style.border_blend = true
	return style


static func button_style(
	fill: Color,
	border: Color,
	width: int = 2,
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 6
	style.border_blend = true
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


static func badge_style(accent: Color) -> StyleBoxFlat:
	var style := button_style(Color(accent, 0.12), Color(accent, 0.72), 2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	return style


static func selected_style(accent: Color) -> StyleBoxFlat:
	return button_style(Color(accent, 0.26), accent, 3)


static func profile_accent(profile_id: StringName) -> Color:
	match profile_id:
		&"skitter":
			return DEW
		&"anchorite":
			return SAP
		&"ballooner":
			return SILK
		&"springtail":
			return AMBER
		_:
			return MOSS


static func scroll_track_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(SILK, 0.08)
	style.set_corner_radius_all(5)
	style.content_margin_left = 4.0
	style.content_margin_right = 4.0
	return style


static func scroll_grabber_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(5)
	style.content_margin_left = 4.0
	style.content_margin_right = 4.0
	return style


static func configure_touch_scroll(scroll: ScrollContainer) -> void:
	# Built-in touch dragging already supplies inertial scrolling on Android.
	# Focus following is intentionally off: a tapped upgrade must not snap the
	# viewport while the same gesture is becoming a drag.
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.follow_focus = false
	scroll.scroll_deadzone = 12
	scroll.scroll_vertical_custom_step = 64.0


static func enable_descendant_drag_bubbling(scroll: ScrollContainer) -> void:
	# ScrollContainer can only claim a touchscreen drag after the GUI event
	# reaches it. Buttons, labels, panels, and containers default to STOP, which
	# leaves dead zones whenever a swipe begins on a card instead of bare space.
	# PASS preserves each child's tap behavior while allowing the existing
	# ScrollContainer deadzone/inertia policy to become the one gesture owner.
	for child: Node in scroll.get_children():
		_set_drag_bubbling_recursive(child)


static func _set_drag_bubbling_recursive(node: Node) -> void:
	var control := node as Control
	if control != null:
		control.mouse_filter = Control.MOUSE_FILTER_PASS
	for child: Node in node.get_children():
		_set_drag_bubbling_recursive(child)

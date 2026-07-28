extends Control
class_name TutorialPreview
## Lightweight, in-engine tutorial animation.
##
## It illustrates the same mechanics described by FrontEndState. No prerecorded
## asset can drift away from the live control contract.

const INK := Color("d9fbff")
const CYAN := Color("4de8ee")
const ORANGE := Color("f28c45")
const GREEN := Color("73e0a4")
const YELLOW := Color("ffd166")
const RED := Color("ff6577")
const MUTED := Color("668b98")
const PANEL := Color("0b1e29")

var step_index: int = 0
var reduced_motion: bool = false
var _elapsed: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()


func configure(next_step: int, motion_reduced: bool) -> void:
	step_index = clampi(next_step, 0, FrontEndState.TUTORIAL_STEPS.size() - 1)
	reduced_motion = motion_reduced
	_elapsed = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	if not reduced_motion:
		_elapsed += delta
		queue_redraw()


func _draw() -> void:
	var area := Rect2(Vector2.ZERO, size)
	draw_style_box(_panel_style(), area)
	if size.x < 10.0 or size.y < 10.0:
		return
	_draw_grid(area)
	match step_index:
		0:
			_draw_forward_motion(area)
		1:
			_draw_attachment(area)
		2:
			_draw_release(area)
		3:
			_draw_reel(area)
		4:
			_draw_burst(area)
		5:
			_draw_boundaries(area)


func _draw_grid(area: Rect2) -> void:
	for x in range(24, int(area.size.x), 48):
		draw_line(Vector2(float(x), 0.0), Vector2(float(x), area.size.y),
			Color(0.3, 0.75, 0.75, 0.06), 1.0)
	for y in range(24, int(area.size.y), 48):
		draw_line(Vector2(0.0, float(y)), Vector2(area.size.x, float(y)),
			Color(0.3, 0.75, 0.75, 0.06), 1.0)


func _draw_forward_motion(area: Rect2) -> void:
	var travel := 0.5 if reduced_motion else fposmod(_elapsed * 0.28, 1.0)
	var spider := Vector2(
		lerpf(area.size.x * 0.22, area.size.x * 0.7, travel),
		area.size.y * 0.55 + sin(_elapsed * 2.0) * 18.0,
	)
	_draw_spider(spider)
	var arrow_y := area.size.y * 0.77
	draw_line(Vector2(area.size.x * 0.2, arrow_y),
		Vector2(area.size.x * 0.78, arrow_y), GREEN, 5.0, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(area.size.x * 0.78, arrow_y - 12.0),
		Vector2(area.size.x * 0.83, arrow_y),
		Vector2(area.size.x * 0.78, arrow_y + 12.0),
	]), GREEN)


func _draw_attachment(area: Rect2) -> void:
	var spider := Vector2(area.size.x * 0.28, area.size.y * 0.7)
	var anchor := Vector2(area.size.x * 0.7, area.size.y * 0.26)
	var progress := 1.0 if reduced_motion else clampf(
		fposmod(_elapsed, 1.6) / 1.1, 0.0, 1.0)
	var ceiling := Rect2(24.0, area.size.y * 0.12, area.size.x - 48.0, 46.0)
	draw_rect(ceiling, Color(0.07, 0.26, 0.29, 0.96))
	draw_line(
		Vector2(ceiling.position.x, ceiling.end.y),
		Vector2(ceiling.end.x, ceiling.end.y),
		CYAN,
		5.0,
	)
	for x in range(90, int(area.size.x) - 40, 120):
		_draw_anchor(Vector2(float(x), ceiling.end.y), true)
	_draw_anchor(anchor, true)
	_draw_spider(spider)
	var web_end := spider.lerp(anchor, progress)
	draw_line(spider, web_end, INK, 4.0, true)
	_draw_tap_pulse(anchor)


func _draw_release(area: Rect2) -> void:
	var anchor := Vector2(area.size.x * 0.48, area.size.y * 0.22)
	var phase := 0.62 if reduced_motion else fposmod(_elapsed * 0.32, 1.0)
	var angle := lerpf(2.55, 0.3, minf(phase * 1.35, 1.0))
	var rope := minf(area.size.x, area.size.y) * 0.32
	var spider := anchor + Vector2(cos(angle), sin(angle)) * rope
	_draw_anchor(anchor, true)
	if phase < 0.72:
		draw_line(anchor, spider, INK, 4.0, true)
	_draw_spider(spider)
	for index in range(7):
		var t := float(index) / 6.0
		var point := spider + Vector2(150.0 * t, -88.0 * t + 86.0 * t * t)
		draw_circle(point, 4.0, GREEN)


func _draw_reel(area: Rect2) -> void:
	var anchor := Vector2(area.size.x * 0.5, area.size.y * 0.18)
	var pulse := 0.5 if reduced_motion else (sin(_elapsed * 2.5) + 1.0) * 0.5
	var rope := lerpf(area.size.y * 0.56, area.size.y * 0.34, pulse)
	var spider := anchor + Vector2(-rope * 0.25, rope)
	_draw_anchor(anchor, true)
	draw_line(anchor, spider, YELLOW, 5.0, true)
	_draw_spider(spider)
	var center := Vector2(area.size.x * 0.82, area.size.y * 0.73)
	draw_circle(center, 46.0, Color(0.05, 0.18, 0.22, 0.95))
	draw_arc(center, 40.0, -PI * 0.5, PI * (1.5 - pulse * 1.5),
		32, YELLOW, 7.0, true)
	_draw_centered("HOLD", center + Vector2(0.0, 6.0), 16, INK)


func _draw_burst(area: Rect2) -> void:
	var cycle := 0.2 if reduced_motion else fposmod(_elapsed * 0.32, 1.0)
	var diving := cycle >= 0.5
	var travel := 0.5 if reduced_motion else fposmod(_elapsed * 0.8, 1.0)
	var start := Vector2(area.size.x * 0.24, area.size.y * 0.7)
	var upper_anchor := Vector2(area.size.x * 0.72, area.size.y * 0.2)
	var lower_anchor := Vector2(area.size.x * 0.70, area.size.y * 0.86)
	var anchor := lower_anchor if diving else upper_anchor
	var distance_share := 0.25 if diving else 0.5
	var pull_direction := (anchor - start).normalized()
	var spider := start + (anchor - start) * distance_share * travel
	var ceiling := PackedVector2Array([
		Vector2(area.size.x * 0.52, area.size.y * 0.11),
		Vector2(area.size.x * 0.90, area.size.y * 0.11),
		Vector2(area.size.x * 0.90, area.size.y * 0.20),
		Vector2(area.size.x * 0.52, area.size.y * 0.20),
	])
	draw_colored_polygon(ceiling, Color(0.07, 0.26, 0.29, 0.96))
	var branch := PackedVector2Array([
		Vector2(area.size.x * 0.53, area.size.y * 0.94),
		Vector2(area.size.x * 0.63, area.size.y * 0.78),
		Vector2(area.size.x * 0.74, area.size.y * 0.86),
		Vector2(area.size.x * 0.86, area.size.y * 0.94),
	])
	draw_colored_polygon(branch, Color(0.25, 0.11, 0.07))
	draw_polyline(PackedVector2Array([
		branch[0], branch[1], branch[2], branch[3],
	]), ORANGE, 4.0, true)
	_draw_anchor(anchor, true)
	draw_line(start, anchor, Color(INK, 0.34), 3.0, true)
	for index in range(5):
		var trail := spider - pull_direction * (26.0 + float(index) * 24.0)
		draw_line(
			trail,
			trail + pull_direction * 18.0,
			Color(YELLOW, 1.0 - float(index) * 0.16),
			5.0,
			true,
		)
	_draw_spider(spider)
	_draw_centered(
		"40% DIVE" if diving else "50% BURST",
		Vector2(area.size.x * 0.48, area.size.y * 0.30),
		16,
		YELLOW,
	)
	var button := Rect2(
		area.size.x - 134.0,
		area.size.y - 112.0,
		94.0,
		72.0,
	)
	draw_rect(button, Color(0.24, 0.16, 0.05, 0.96), true)
	draw_rect(button, YELLOW, false, 3.0)
	_draw_centered("BURST", button.get_center() + Vector2(0.0, 6.0),
		15, INK)

func _draw_boundaries(area: Rect2) -> void:
	var floor_y := area.size.y * 0.78
	draw_line(Vector2(24.0, floor_y), Vector2(area.size.x - 24.0, floor_y),
		RED, 5.0, true)
	_draw_centered("DANGER", Vector2(area.size.x * 0.5, floor_y + 30.0),
		15, RED)
	var spider := Vector2(area.size.x * 0.42, area.size.y * 0.48)
	if not reduced_motion:
		spider.y += sin(_elapsed * 2.0) * 22.0
	_draw_spider(spider)
	var obstacle := PackedVector2Array([
		Vector2(area.size.x * 0.61, floor_y),
		Vector2(area.size.x * 0.66, floor_y - 72.0),
		Vector2(area.size.x * 0.72, floor_y - 132.0),
		Vector2(area.size.x * 0.79, floor_y - 84.0),
		Vector2(area.size.x * 0.85, floor_y),
	])
	draw_colored_polygon(obstacle, Color(0.25, 0.11, 0.07))
	var closed_obstacle := obstacle.duplicate()
	closed_obstacle.append(obstacle[0])
	draw_polyline(closed_obstacle, ORANGE, 4.0, true)
	var menu := Rect2(28.0, 24.0, 92.0, 42.0)
	draw_rect(menu, Color(0.08, 0.24, 0.28), true)
	draw_rect(menu, CYAN, false, 2.0)
	_draw_centered("MENU", menu.get_center() + Vector2(0.0, 5.0), 15, INK)
	var restart := Rect2(area.size.x - 150.0, 24.0, 122.0, 42.0)
	draw_rect(restart, Color(0.08, 0.24, 0.28), true)
	draw_rect(restart, GREEN, false, 2.0)
	_draw_centered("RESTART", restart.get_center() + Vector2(0.0, 5.0),
		14, INK)


func _draw_anchor(position: Vector2, active: bool) -> void:
	var pulse := 0.0 if reduced_motion else sin(_elapsed * 4.0) * 4.0
	draw_circle(position, 18.0 + pulse, Color(CYAN, 0.16))
	draw_circle(position, 9.0, CYAN if active else MUTED)
	draw_circle(position, 4.0, INK)


func _draw_spider(position: Vector2) -> void:
	draw_circle(position, 17.0, Color("17202b"))
	draw_circle(position + Vector2(13.0, -5.0), 11.0, ORANGE)
	for side in [-1.0, 1.0]:
		for index in range(4):
			var y := -12.0 + float(index) * 8.0
			var joint := position + Vector2(side * 20.0, y)
			var foot := joint + Vector2(side * (16.0 + float(index % 2) * 5.0),
				-8.0 + float(index) * 5.0)
			draw_line(position + Vector2(side * 8.0, y * 0.45),
				joint, INK, 3.0, true)
			draw_line(joint, foot, INK, 3.0, true)


func _draw_tap_pulse(position: Vector2) -> void:
	var phase := 0.45 if reduced_motion else fposmod(_elapsed * 1.3, 1.0)
	draw_arc(position, 24.0 + phase * 26.0, 0.0, TAU, 40,
		Color(CYAN, 1.0 - phase), 3.0, true)


func _draw_centered(
	text: String,
	position: Vector2,
	font_size: int,
	color: Color,
) -> void:
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1,
		font_size).x
	draw_string(font, position - Vector2(width * 0.5, 0.0), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = Color(CYAN, 0.35)
	style.set_border_width_all(2)
	style.set_corner_radius_all(22)
	return style

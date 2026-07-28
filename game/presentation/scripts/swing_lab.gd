extends Node2D
class_name SwingLabView
## Code-drawn Phase 0 presentation.
##
## It consumes snapshots/events and emits no authoritative writes. The visual
## web follows physics endpoints; it never drives the constraint.

const BACKGROUND := Color("102531")
const BACKGROUND_DEEP := Color("08141d")
const GRID := Color(0.25, 0.55, 0.58, 0.14)
const SPIDER_DARK := Color("17202b")
const SPIDER_ACCENT := Color("f28c45")
const WEB := Color("d9fbff")
const CYAN := Color("4de8ee")
const GREEN := Color("73e0a4")
const YELLOW := Color("ffd166")
const RED := Color("ff6577")
const MUTED := Color("8ba9b5")

var _snapshot: SimulationSnapshot
var _camera_x: float = 0.0
var _feedback_message: String = "Tap a glowing anchor to attach"
var _feedback_position: Vector2 = Vector2.ZERO
var _feedback_color: Color = GREEN
var _feedback_remaining: float = 3.0
var _font: Font
var _show_control_hints: bool = true
var _reduced_motion: bool = false
var _show_debug_tools: bool = true


func _ready() -> void:
	_font = ThemeDB.fallback_font
	set_process(true)
	queue_redraw()


func configure_player_options(
	show_control_hints: bool,
	reduced_motion: bool,
	show_debug_tools: bool,
) -> void:
	_show_control_hints = show_control_hints
	_reduced_motion = reduced_motion
	_show_debug_tools = show_debug_tools
	queue_redraw()


func present(snapshot: SimulationSnapshot) -> void:
	_snapshot = snapshot
	queue_redraw()


func present_event(event: SimulationEvent) -> void:
	_feedback_message = event.message
	_feedback_position = event.position
	_feedback_remaining = 1.2
	match event.kind:
		SimulationEvent.Kind.INVALID_TARGET:
			_feedback_color = RED
		SimulationEvent.Kind.OUT_OF_RANGE, SimulationEvent.Kind.REEL_UNAVAILABLE, \
				SimulationEvent.Kind.REEL_EMPTY:
			_feedback_color = YELLOW
		_:
			_feedback_color = GREEN
	queue_redraw()


func screen_to_world(screen_position: Vector2) -> Vector2:
	return screen_position + Vector2(_camera_x, 0.0)


func _process(delta: float) -> void:
	if _snapshot == null:
		return
	var viewport_size := get_viewport_rect().size
	var look_ahead := maxf(0.0, _snapshot.velocity.x - _snapshot.target_speed) * \
		_snapshot.camera_look_ahead
	var target := maxf(
		0.0,
		_snapshot.furthest_x - viewport_size.x / 3.0 + look_ahead,
	)
	if _reduced_motion:
		_camera_x = target
	else:
		var follow := 1.0 - exp(-_snapshot.camera_follow_strength * delta)
		_camera_x = lerpf(_camera_x, target, follow)
	_feedback_remaining = maxf(0.0, _feedback_remaining - delta)
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		size = LabLayout.REFERENCE_SIZE
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND)
	_draw_parallax(size)
	_draw_course(size)
	if _snapshot == null:
		_draw_text(Vector2(32.0, 58.0), "Loading Swing Laboratory…", 24, WEB)
		return
	_draw_web()
	_draw_spider()
	_draw_feedback()
	_draw_hud(size)
	if _show_debug_tools and _snapshot.debug_visible:
		_draw_debug(size)


func _draw_parallax(size: Vector2) -> void:
	draw_rect(Rect2(0.0, size.y * 0.72, size.x, size.y * 0.28), BACKGROUND_DEEP)
	var parallax_x := 0.0 if _reduced_motion else _camera_x
	var far_offset := fposmod(-parallax_x * 0.08, 240.0)
	for index in range(-1, 8):
		var x := far_offset + float(index) * 240.0
		draw_circle(Vector2(x, 135.0 + float(index % 3) * 54.0), 105.0,
			Color(0.13, 0.34, 0.32, 0.55))
	var near_offset := fposmod(-parallax_x * 0.22, 310.0)
	for index in range(-1, 6):
		var x := near_offset + float(index) * 310.0
		draw_circle(Vector2(x, size.y + 25.0), 155.0,
			Color(0.08, 0.28, 0.25, 0.9))
	for y in range(90, int(size.y), 90):
		draw_line(Vector2(0.0, float(y)), Vector2(size.x, float(y)), GRID, 1.0)
	var grid_offset := fposmod(-parallax_x, 120.0)
	for x in range(-120, int(size.x) + 120, 120):
		draw_line(Vector2(float(x) + grid_offset, 0.0),
			Vector2(float(x) + grid_offset, size.y), GRID, 1.0)


func _draw_course(size: Vector2) -> void:
	draw_line(Vector2(0.0, 680.0), Vector2(size.x, 680.0),
		Color(0.22, 0.5, 0.47, 0.5), 3.0)
	if _snapshot == null:
		return
	for anchor: Vector2 in _snapshot.anchors:
		var screen := _world_to_screen(anchor)
		if screen.x < -80.0 or screen.x > size.x + 80.0:
			continue
		var distance := anchor.distance_to(_snapshot.position)
		var in_range := distance >= 90.0 and distance <= 620.0
		var color := GREEN if in_range else YELLOW
		draw_line(screen + Vector2(0.0, -34.0), screen + Vector2(0.0, 34.0),
			Color(0.48, 0.74, 0.64, 0.8), 6.0)
		draw_circle(screen, 15.0, Color(color, 0.18))
		draw_arc(screen, 17.0, 0.0, TAU, 32, color, 3.0)
		draw_circle(screen, 4.0, WEB)
	var kill_x := _world_to_screen(Vector2(_snapshot.left_kill_boundary, 0.0)).x
	if kill_x > 0.0 and kill_x < size.x:
		draw_line(Vector2(kill_x, 0.0), Vector2(kill_x, size.y), RED, 3.0)


func _draw_web() -> void:
	if not _snapshot.web_attached:
		return
	var spider := _world_to_screen(_snapshot.position)
	var anchor := _world_to_screen(_snapshot.anchor)
	draw_line(spider, anchor, Color(0.25, 0.72, 0.77, 0.35), 7.0)
	draw_line(spider, anchor, WEB, 2.5)
	if _snapshot.reel_active:
		var pulse := fposmod(float(_snapshot.tick) * 0.08, 1.0)
		draw_circle(spider.lerp(anchor, pulse), 7.0, CYAN)


func _draw_spider() -> void:
	var center := _world_to_screen(_snapshot.position)
	var rotation := clampf(_snapshot.velocity.angle() * 0.16, -0.35, 0.35)
	for side in [-1.0, 1.0]:
		for index in range(4):
			var y := -15.0 + float(index) * 10.0
			var hip := center + Vector2(side * 10.0, y).rotated(rotation)
			var knee := center + Vector2(side * (24.0 + index * 2.0),
				y - 9.0 + index * 5.0).rotated(rotation)
			var foot := center + Vector2(side * (38.0 + index * 3.0),
				y + 2.0 + index * 6.0).rotated(rotation)
			draw_polyline(PackedVector2Array([hip, knee, foot]), SPIDER_DARK, 5.0, true)
			draw_polyline(PackedVector2Array([hip, knee, foot]), SPIDER_ACCENT, 1.5, true)
	draw_circle(center + Vector2(-8.0, 0.0).rotated(rotation), 17.0, SPIDER_DARK)
	draw_circle(center + Vector2(12.0, -1.0).rotated(rotation), 14.0, SPIDER_DARK)
	draw_circle(center + Vector2(-9.0, -4.0).rotated(rotation), 6.0, SPIDER_ACCENT)
	draw_circle(center + Vector2(17.0, -5.0).rotated(rotation), 3.2, WEB)
	draw_circle(center + Vector2(17.0, -5.0).rotated(rotation), 1.4, Color("15202b"))
	if _show_debug_tools and _snapshot.debug_visible:
		draw_arc(center, 18.0, 0.0, TAU, 40, CYAN, 1.5)
		draw_line(center, center + _snapshot.velocity * 0.12, YELLOW, 2.0)


func _draw_feedback() -> void:
	if _feedback_remaining <= 0.0:
		return
	if _feedback_position != Vector2.ZERO:
		var screen := _world_to_screen(_feedback_position)
		var radius := 18.0 + (1.2 - _feedback_remaining) * 28.0
		draw_arc(screen, radius, 0.0, TAU, 32,
			Color(_feedback_color, clampf(_feedback_remaining, 0.0, 1.0)), 3.0)


func _draw_hud(size: Vector2) -> void:
	var distance_metres := _snapshot.distance_pixels / 10.0
	_draw_text(Vector2(142.0, 48.0), "%05.1f m" % distance_metres, 28, WEB)
	_draw_button(LabLayout.menu_rect(size), "MENU", false)
	if _show_control_hints:
		_draw_text(Vector2(142.0, 76.0),
			"Tap anchor · tap again to release", 16, MUTED)
		_draw_text(Vector2(142.0, 99.0),
			_feedback_message, 17, _feedback_color)
	_draw_text(
		Vector2(30.0, size.y - 18.0),
		"BUILD %s" % ProjectSettings.get_setting(
			"application/config/version",
			"unknown",
		),
		13,
		MUTED,
	)

	if _show_debug_tools:
		var debug_rect := LabLayout.debug_toggle_rect(size)
		_draw_button(debug_rect, "DEBUG", _snapshot.debug_visible)

	var reel_rect := LabLayout.reel_rect(size)
	var center := reel_rect.get_center()
	var radius := reel_rect.size.x * 0.44
	var reel_fill := Color(0.04, 0.3, 0.34, 0.94) if _snapshot.reel_active \
		else Color(0.04, 0.12, 0.16, 0.82)
	draw_circle(center, radius, reel_fill)
	draw_arc(center, radius, 0.0, TAU, 64,
		CYAN if _snapshot.reel_active else Color(0.55, 0.72, 0.76, 0.55),
		6.0 if _snapshot.reel_active else 4.0)
	var energy_ratio := _snapshot.reel_energy / maxf(_snapshot.reel_capacity, 0.001)
	draw_arc(center, radius, -PI * 0.5, -PI * 0.5 + TAU * energy_ratio,
		64, CYAN if _snapshot.reel_lockout <= 0.0 else RED, 8.0)
	var reel_label := "PULL" if _snapshot.reel_active else "REEL"
	_draw_text(center + Vector2(-31.0, 7.0), reel_label, 19, WEB)

	if _snapshot.run_state != &"active":
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.04, 0.06, 0.62))
		var title := "FALLING…" if _snapshot.run_state == &"dying" else "RUN ENDED"
		_draw_text(Vector2(size.x * 0.5 - 90.0, size.y * 0.43), title, 30, WEB)
		if _snapshot.run_state == &"dead":
			_draw_text(Vector2(size.x * 0.5 - 154.0, size.y * 0.5),
				"Tap anywhere to restart", 22, CYAN)


func _draw_debug(_size: Vector2) -> void:
	var panel := Rect2(18.0, 120.0, 370.0, 510.0)
	draw_rect(panel, Color(0.02, 0.07, 0.1, 0.9))
	draw_rect(panel, CYAN, false, 2.0)
	var lines := [
		"build: %s" % ProjectSettings.get_setting(
			"application/config/version", "unknown"),
		"tick: %d  seed: %d" % [_snapshot.tick, _snapshot.seed],
		"state: %s  web: %s" % [
			_snapshot.run_state,
			"attached" if _snapshot.web_attached else "detached"],
		"pos: (%.1f, %.1f)" % [_snapshot.position.x, _snapshot.position.y],
		"velocity: (%.1f, %.1f)" % [_snapshot.velocity.x, _snapshot.velocity.y],
		"speed target: %.1f" % _snapshot.target_speed,
		"rope: %.1f  tension: %.1f" % [
			_snapshot.rope_length, _snapshot.tension],
		"Reel: %.1f / %.1f  lockout %.2f" % [
			_snapshot.reel_energy, _snapshot.reel_capacity, _snapshot.reel_lockout],
		"preset: %s" % _snapshot.preset_name,
		"recording: %s  replay: %s" % [
			_snapshot.recording, _snapshot.replaying],
	]
	for index in range(lines.size()):
		_draw_text(Vector2(32.0, 150.0 + float(index) * 30.0),
			lines[index], 16, WEB)

	for index in range(SwingConfig.preset_names().size()):
		var name := SwingConfig.preset_names()[index]
		_draw_button(LabLayout.preset_rect(index), str(index + 1), name == _snapshot.preset_name)

	_draw_button(LabLayout.tuning_previous_rect(), "<", false)
	_draw_button(LabLayout.tuning_minus_rect(), "-", false)
	draw_rect(Rect2(136.0, 520.0, 126.0, 42.0), Color(0.06, 0.16, 0.2, 0.9))
	_draw_text(Vector2(146.0, 547.0), "%s %.2f" % [
		_snapshot.selected_parameter, _snapshot.selected_parameter_value], 14, WEB)
	_draw_button(LabLayout.tuning_plus_rect(), "+", false)
	_draw_button(LabLayout.tuning_next_rect(), ">", false)

	var labels := ["PAUSE", "STEP", "SLOW", "REC", "REPLAY", "EXPORT"]
	for index in range(labels.size()):
		var active := (
			(index == 0 and _snapshot.debug_paused)
			or (index == 2 and _snapshot.slow_motion)
			or (index == 3 and _snapshot.recording)
			or (index == 4 and _snapshot.replaying)
		)
		_draw_button(LabLayout.utility_rect(index), labels[index], active)
	_draw_text(Vector2(32.0, 652.0), "Touch EXPORT or press F8 for diagnostic JSON",
		14, MUTED)


func _draw_button(rect: Rect2, label: String, active: bool) -> void:
	draw_rect(rect, Color(0.08, 0.35, 0.38, 0.94) if active
		else Color(0.04, 0.14, 0.18, 0.88))
	draw_rect(rect, CYAN if active else MUTED, false, 2.0)
	var width := _font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
	_draw_text(Vector2(rect.get_center().x - width * 0.5, rect.get_center().y + 5.0),
		label, 15, WEB)


func _draw_text(position: Vector2, text: String, size: int, color: Color) -> void:
	draw_string(_font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)


func _world_to_screen(world_position: Vector2) -> Vector2:
	return world_position - Vector2(_camera_x, 0.0)

extends PanelContainer
class_name SpiderWebPanel
## Reusable spider-built card surface for the front end.
##
## The StyleBox remains the authoritative layout background. This layer adds
## deterministic low-contrast fibres, corner webs, silk knots, and cocoon
## forms behind child controls. It never processes input or owns navigation.

const MINIMUM_SIZE := Vector2(96.0, 64.0)
const FIBRE_SPACING := 22.0

var accent_color := SpiderUiTheme.MOSS
var panel_fill := SpiderUiTheme.PANEL
var panel_radius := 22


func configure(
	fill: Color,
	radius: int,
	accent: Color,
) -> void:
	panel_fill = fill
	panel_radius = radius
	accent_color = accent
	mouse_filter = Control.MOUSE_FILTER_PASS
	_refresh_style()
	queue_redraw()


func set_accent(accent: Color) -> void:
	if accent_color.is_equal_approx(accent):
		return
	accent_color = accent
	_refresh_style()
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var geometry := ornament_geometry(size)
	for fibre: PackedVector2Array in geometry["fibres"]:
		draw_line(
			fibre[0], fibre[1], Color(accent_color, 0.055), 1.0, true)
	for spoke: PackedVector2Array in geometry["spokes"]:
		draw_line(
			spoke[0], spoke[1], Color(SpiderUiTheme.SILK, 0.16), 1.15, true)
	for ring: PackedVector2Array in geometry["rings"]:
		draw_polyline(
			ring, Color(SpiderUiTheme.SILK, 0.13), 1.0, true)
	for knot: Vector2 in geometry["knots"]:
		draw_circle(knot, 2.4, Color(accent_color, 0.46), true, -1.0, true)
	for cocoon: PackedVector2Array in geometry["cocoons"]:
		draw_colored_polygon(cocoon, Color(SpiderUiTheme.SILK, 0.075))
		draw_polyline(cocoon, Color(accent_color, 0.22), 1.0, true)


static func ornament_geometry(requested_size: Vector2) -> Dictionary:
	var panel_size := Vector2(
		maxf(MINIMUM_SIZE.x, requested_size.x),
		maxf(MINIMUM_SIZE.y, requested_size.y),
	)
	var fibres: Array[PackedVector2Array] = []
	var fibre_index := 0
	var y := 12.0
	while y < panel_size.y - 10.0:
		var sway := sin(float(fibre_index) * 1.73) * 5.0
		fibres.append(PackedVector2Array([
			Vector2(10.0, clampf(y + sway, 6.0, panel_size.y - 6.0)),
			Vector2(
				panel_size.x - 10.0,
				clampf(y - sway * 0.55, 6.0, panel_size.y - 6.0),
			),
		]))
		fibre_index += 1
		y += FIBRE_SPACING

	var spokes: Array[PackedVector2Array] = []
	var rings: Array[PackedVector2Array] = []
	_append_corner_web(
		Vector2(panel_size.x - 8.0, 8.0),
		Vector2(-1.0, 1.0),
		minf(74.0, minf(panel_size.x, panel_size.y) * 0.34),
		spokes,
		rings,
	)
	_append_corner_web(
		Vector2(8.0, panel_size.y - 8.0),
		Vector2(1.0, -1.0),
		minf(58.0, minf(panel_size.x, panel_size.y) * 0.27),
		spokes,
		rings,
	)

	var knots: Array[Vector2] = []
	for progress in [0.18, 0.36, 0.58, 0.79]:
		knots.append(Vector2(panel_size.x * progress, 5.0))
	knots.append(Vector2(5.0, panel_size.y * 0.31))
	knots.append(Vector2(panel_size.x - 5.0, panel_size.y * 0.68))

	var cocoons: Array[PackedVector2Array] = [
		_ellipse_points(Vector2(18.0, 17.0), Vector2(5.0, 9.0)),
		_ellipse_points(
			Vector2(panel_size.x - 18.0, panel_size.y - 17.0),
			Vector2(5.0, 9.0),
		),
	]
	return {
		"fibres": fibres,
		"spokes": spokes,
		"rings": rings,
		"knots": knots,
		"cocoons": cocoons,
	}


static func _append_corner_web(
	anchor: Vector2,
	direction: Vector2,
	radius: float,
	spokes: Array[PackedVector2Array],
	rings: Array[PackedVector2Array],
) -> void:
	var directions: Array[Vector2] = []
	for spoke_index in range(6):
		var progress := float(spoke_index) / 5.0
		var ray := Vector2(
			direction.x * cos(progress * PI * 0.5),
			direction.y * sin(progress * PI * 0.5),
		)
		directions.append(ray)
		spokes.append(PackedVector2Array([anchor, anchor + ray * radius]))
	for ring_index in range(1, 4):
		var points := PackedVector2Array()
		var ring_radius := radius * float(ring_index) / 4.0
		for ray: Vector2 in directions:
			points.append(anchor + ray * ring_radius)
		rings.append(points)


static func _ellipse_points(center: Vector2, radius: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(13):
		var angle := TAU * float(index) / 12.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points


func _refresh_style() -> void:
	add_theme_stylebox_override(
		"panel",
		SpiderUiTheme.panel_style(
			panel_fill,
			panel_radius,
			Color(accent_color, 0.58),
		),
	)

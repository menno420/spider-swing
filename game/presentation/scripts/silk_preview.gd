extends Control
class_name SilkPreview
## Compact cosmetic preview for Garage silk choices.
##
## This control is visual only. It never owns attachment rules or web state.

var _variant: StringName = PlayerProgress.WEB_CLASSIC


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.y = 38.0
	queue_redraw()


func show_variant(variant: StringName) -> void:
	_variant = variant
	queue_redraw()


func _draw() -> void:
	if size.x <= 1.0 or size.y <= 1.0:
		return
	var color := _silk_color()
	var left := Vector2(10.0, size.y * 0.68)
	var right := Vector2(size.x - 10.0, size.y * 0.34)
	for strand_index in range(3):
		var points := PackedVector2Array()
		for sample in range(25):
			var progress := float(sample) / 24.0
			var point := left.lerp(right, progress)
			point.y += sin(progress * PI * 2.0 + strand_index * 0.72) * 2.6
			point += Vector2(0.0, float(strand_index - 1) * 6.0)
			points.append(point)
		draw_polyline(points, Color(color, 0.42 + strand_index * 0.22), 1.5, true)
	for knot_progress in [0.18, 0.50, 0.82]:
		var knot := left.lerp(right, knot_progress)
		match _variant:
			PlayerProgress.WEB_DEW:
				draw_circle(knot, 4.5, Color(color, 0.32))
				draw_circle(knot + Vector2(-1.0, -1.0), 2.2, color)
			PlayerProgress.WEB_EMBER:
				draw_circle(knot, 6.5, Color(color, 0.16))
				draw_circle(knot, 2.8, color)
			_:
				draw_circle(knot, 2.0, color)


func _silk_color() -> Color:
	match _variant:
		PlayerProgress.WEB_DEW:
			return SpiderUiTheme.MOSS
		PlayerProgress.WEB_EMBER:
			return SpiderUiTheme.AMBER
		_:
			return SpiderUiTheme.SILK

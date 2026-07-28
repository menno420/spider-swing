extends RefCounted
class_name CourseStream
## Deterministic bounded Phase 0.5 world stream.
##
## A tiny pattern vocabulary is repeated with height variation. Geometry is
## generated from chunk indices, so replay and tests never depend on frame rate
## or mutable random state. This is the seam later content can extend.

const CHUNK_WIDTH := 960.0
const KEEP_BEHIND := 2
const GENERATE_AHEAD := 4
const GUIDE_SPACING := 160.0
const CEILING_THICKNESS := 38.0

var _geometry := CourseGeometry.new()


func reset() -> void:
	_geometry = CourseGeometry.new()
	update_for_position(SimulationWorld.START_POSITION.x)


func update_for_position(world_x: float) -> CourseGeometry:
	var current_index := maxi(0, floori(world_x / CHUNK_WIDTH))
	var first := maxi(0, current_index - KEEP_BEHIND)
	var last := current_index + GENERATE_AHEAD
	_geometry = _build_range(first, last)
	return _geometry.duplicate_geometry()


func geometry() -> CourseGeometry:
	return _geometry.duplicate_geometry()


func retained_chunk_count() -> int:
	return _geometry.last_chunk_index - _geometry.first_chunk_index + 1


func _build_range(first: int, last: int) -> CourseGeometry:
	var result := CourseGeometry.new()
	result.first_chunk_index = first
	result.last_chunk_index = last
	for chunk_index in range(first, last + 1):
		_append_chunk(result, chunk_index)
	return result


func _append_chunk(result: CourseGeometry, chunk_index: int) -> void:
	var start_x := float(chunk_index) * CHUNK_WIDTH
	var pattern := posmod(chunk_index, 6)
	var ceiling_y := 72.0 + float(posmod(chunk_index * 37, 4)) * 24.0
	var surface := Rect2(
		start_x,
		ceiling_y,
		CHUNK_WIDTH + 2.0,
		CEILING_THICKNESS,
	)
	result.surface_segments.append(surface)
	var guide_y := surface.end.y
	var guide_x := start_x + 96.0
	while guide_x < start_x + CHUNK_WIDTH:
		result.aim_guides.append(Vector2(guide_x, guide_y))
		guide_x += GUIDE_SPACING

	if chunk_index < 2:
		return
	match pattern:
		1:
			result.obstacles.append(Rect2(start_x + 590.0, 548.0, 96.0, 132.0))
		2:
			result.obstacles.append(Rect2(start_x + 420.0, 470.0, 112.0, 210.0))
		3:
			result.obstacles.append(Rect2(start_x + 610.0, guide_y, 88.0, 205.0))
		4:
			result.obstacles.append(Rect2(start_x + 360.0, 585.0, 210.0, 95.0))
			result.obstacles.append(Rect2(start_x + 720.0, guide_y, 72.0, 160.0))
		5:
			result.obstacles.append(Rect2(start_x + 510.0, 520.0, 82.0, 160.0))

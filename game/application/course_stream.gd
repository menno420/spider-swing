extends RefCounted
class_name CourseStream
## Deterministic bounded Phase 0.8 world stream.
##
## Polygon silhouettes create changing ceilings, gaps, branches, and gates.
## Every retained solid is targetable; obstacle polygons additionally carry
## the authoritative lethal-contact policy in SimulationWorld.

const CHUNK_WIDTH := 960.0
const KEEP_BEHIND := 2
const GENERATE_AHEAD := 4
const GUIDE_SPACING := 160.0
const CEILING_THICKNESS := 42.0

var _geometry := CourseGeometry.new()


func reset() -> void:
	_geometry = CourseGeometry.new()
	update_for_position(SimulationWorld.START_POSITION.x)


func update_for_position(world_x: float) -> CourseGeometry:
	var current_index := maxi(0, floori(world_x / CHUNK_WIDTH))
	var first := maxi(0, current_index - KEEP_BEHIND)
	var last := current_index + GENERATE_AHEAD
	if not _geometry.surfaces.is_empty() and \
			_geometry.first_chunk_index == first and \
			_geometry.last_chunk_index == last:
		return _geometry.duplicate_geometry()
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
	var ceiling_y := 118.0 + float(posmod(chunk_index * 37, 4)) * 24.0

	if chunk_index < 2:
		_append_ceiling(result, start_x, CHUNK_WIDTH + 2.0, ceiling_y)
		if chunk_index == 1:
			_append_lower_anchor_window(result, start_x + 430.0, 610.0, 170.0)
		return

	match pattern:
		0:
			_append_ceiling(result, start_x, CHUNK_WIDTH + 2.0, ceiling_y)
			_append_lower_anchor_window(result, start_x + 210.0, 610.0, 170.0)
			_append_floor_branch(result, start_x + 530.0, 680.0, 210.0, 138.0)
		1:
			_append_ceiling(result, start_x, 430.0, ceiling_y)
			_append_ceiling(result, start_x + 630.0, 332.0, ceiling_y + 28.0)
			_append_lower_anchor_window(result, start_x + 260.0, 600.0, 160.0)
			_append_floor_branch(result, start_x + 500.0, 680.0, 190.0, 172.0)
		2:
			_append_ceiling(result, start_x + 190.0, 772.0, ceiling_y)
			_append_lower_anchor_window(result, start_x + 360.0, 605.0, 180.0)
			_append_hanging_branch(
				result,
				start_x + 610.0,
				ceiling_y,
				138.0,
				225.0,
			)
		3:
			_append_ceiling(result, start_x, 310.0, ceiling_y + 22.0)
			_append_ceiling(result, start_x + 520.0, 442.0, ceiling_y)
			_append_lower_anchor_window(result, start_x + 205.0, 600.0, 150.0)
			_append_broken_pot_gate(result, start_x + 410.0, 365.0)
		4:
			_append_ceiling(result, start_x, 650.0, ceiling_y)
			_append_lower_anchor_window(result, start_x + 120.0, 610.0, 170.0)
			_append_floor_branch(result, start_x + 360.0, 680.0, 260.0, 195.0)
			_append_hanging_branch(
				result,
				start_x + 730.0,
				ceiling_y,
				92.0,
				158.0,
			)
		5:
			_append_ceiling(result, start_x + 120.0, 350.0, ceiling_y + 28.0)
			_append_ceiling(result, start_x + 650.0, 312.0, ceiling_y)
			_append_lower_anchor_window(result, start_x + 315.0, 605.0, 160.0)
			_append_broken_pot_gate(result, start_x + 515.0, 330.0)


func _append_ceiling(
	result: CourseGeometry,
	start_x: float,
	width: float,
	underside_y: float,
) -> void:
	result.surfaces.append(PackedVector2Array([
		Vector2(start_x, underside_y - CEILING_THICKNESS),
		Vector2(start_x + width, underside_y - CEILING_THICKNESS),
		Vector2(start_x + width, underside_y),
		Vector2(start_x, underside_y),
	]))
	var guide_x := start_x + 80.0
	while guide_x < start_x + width - 36.0:
		result.aim_guides.append(Vector2(guide_x, underside_y))
		guide_x += GUIDE_SPACING


func _append_floor_branch(
	result: CourseGeometry,
	start_x: float,
	floor_y: float,
	width: float,
	height: float,
) -> void:
	result.obstacles.append(PackedVector2Array([
		Vector2(start_x, floor_y),
		Vector2(start_x + width * 0.18, floor_y - height * 0.58),
		Vector2(start_x + width * 0.43, floor_y - height),
		Vector2(start_x + width * 0.64, floor_y - height * 0.72),
		Vector2(start_x + width, floor_y - height * 0.40),
		Vector2(start_x + width, floor_y),
	]))


func _append_lower_anchor_window(
	result: CourseGeometry,
	start_x: float,
	top_y: float,
	width: float,
) -> void:
	# A short, nonlethal root silhouette creates an intentional Dive Pull window
	# without turning the entire floor into a permanent safety net.
	var base_y := 720.0
	result.surfaces.append(PackedVector2Array([
		Vector2(start_x, base_y),
		Vector2(start_x + width * 0.12, top_y + 48.0),
		Vector2(start_x + width * 0.32, top_y + 12.0),
		Vector2(start_x + width * 0.56, top_y),
		Vector2(start_x + width * 0.78, top_y + 22.0),
		Vector2(start_x + width, base_y),
	]))
	result.aim_guides.append(Vector2(start_x + width * 0.56, top_y))


func _append_hanging_branch(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	width: float,
	height: float,
) -> void:
	result.obstacles.append(PackedVector2Array([
		Vector2(start_x, ceiling_y),
		Vector2(start_x + width, ceiling_y),
		Vector2(start_x + width * 0.82, ceiling_y + height * 0.54),
		Vector2(start_x + width * 0.56, ceiling_y + height),
		Vector2(start_x + width * 0.34, ceiling_y + height * 0.68),
		Vector2(start_x + width * 0.12, ceiling_y + height * 0.42),
	]))


func _append_broken_pot_gate(
	result: CourseGeometry,
	center_x: float,
	center_y: float,
) -> void:
	var outer_width := 190.0
	var outer_height := 230.0
	var opening_width := 82.0
	var opening_height := 104.0
	var left := center_x - outer_width * 0.5
	var right := center_x + outer_width * 0.5
	var top := center_y - outer_height * 0.5
	var bottom := center_y + outer_height * 0.5
	var opening_left := center_x - opening_width * 0.5
	var opening_right := center_x + opening_width * 0.5
	var opening_top := center_y - opening_height * 0.5
	var opening_bottom := center_y + opening_height * 0.5
	result.obstacles.append(PackedVector2Array([
		Vector2(left + 28.0, top),
		Vector2(right - 24.0, top + 10.0),
		Vector2(opening_right, opening_top),
		Vector2(opening_left, opening_top),
	]))
	result.obstacles.append(PackedVector2Array([
		Vector2(left, top + 34.0),
		Vector2(opening_left, opening_top),
		Vector2(opening_left, opening_bottom),
		Vector2(left + 18.0, bottom - 22.0),
	]))
	result.obstacles.append(PackedVector2Array([
		Vector2(opening_right, opening_top),
		Vector2(right, top + 42.0),
		Vector2(right - 12.0, bottom - 30.0),
		Vector2(opening_right, opening_bottom),
	]))
	result.obstacles.append(PackedVector2Array([
		Vector2(opening_left, opening_bottom),
		Vector2(opening_right, opening_bottom),
		Vector2(right - 30.0, bottom),
		Vector2(left + 34.0, bottom - 8.0),
	]))

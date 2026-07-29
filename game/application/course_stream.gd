extends RefCounted
class_name CourseStream
## Deterministic, bounded course stream with an authored difficulty runway.
##
## Ceiling/floor rails are their own geometry class so the laboratory can test
## them as visible targetable solids, lethal boundaries, or disabled geometry
## without changing obstacle collision policy. Detached middle-lane hazards do
## not appear until the configured distance runway has elapsed.

const CHUNK_WIDTH := 960.0
const KEEP_BEHIND := 2
const GENERATE_AHEAD := 4
const GUIDE_SPACING := 160.0
const CEILING_THICKNESS := 46.0
const FLOOR_THICKNESS := 54.0
const FLOOR_Y := 684.0
const START_X := 220.0

var _geometry := CourseGeometry.new()
var _middle_hazard_start_distance: float = 10000.0
var _edge_obstacle_scale: float = 0.94
var _floating_obstacle_scale: float = 0.90
var _gate_opening_scale: float = 1.12
var _creator_pattern: Array[StringName] = []


func reset(
	middle_hazard_start_distance: float = 10000.0,
	edge_obstacle_scale: float = 0.94,
	floating_obstacle_scale: float = 0.90,
	gate_opening_scale: float = 1.12,
	creator_pattern: Array[StringName] = [],
) -> void:
	_middle_hazard_start_distance = middle_hazard_start_distance
	_edge_obstacle_scale = edge_obstacle_scale
	_floating_obstacle_scale = floating_obstacle_scale
	_gate_opening_scale = gate_opening_scale
	_creator_pattern = creator_pattern.duplicate()
	_geometry = CourseGeometry.new()
	update_for_position(SimulationWorld.START_POSITION.x)


func update_for_position(
	world_x: float,
	middle_hazard_start_distance: float = -1.0,
) -> CourseGeometry:
	if middle_hazard_start_distance >= 0.0 and not is_equal_approx(
		middle_hazard_start_distance,
		_middle_hazard_start_distance,
	):
		_middle_hazard_start_distance = middle_hazard_start_distance
		_geometry = CourseGeometry.new()
	var current_index := maxi(0, floori(world_x / CHUNK_WIDTH))
	var first := maxi(0, current_index - KEEP_BEHIND)
	var last := current_index + GENERATE_AHEAD
	if not _geometry.boundary_surfaces.is_empty() and \
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
	var pattern := posmod(chunk_index, 8)
	var ceiling_y := 112.0 + float(posmod(chunk_index * 37, 4)) * 22.0
	var floor_y := FLOOR_Y - float(posmod(chunk_index * 29, 3)) * 18.0
	_append_boundary_pattern(result, start_x, ceiling_y, floor_y, pattern)
	_append_route_flies(result, start_x, ceiling_y, floor_y, pattern)

	var distance_at_chunk := maxf(0.0, start_x - START_X)
	if not _creator_pattern.is_empty() and chunk_index >= 1:
		_append_creator_challenge(
			result,
			start_x,
			ceiling_y,
			floor_y,
			_creator_pattern[posmod(
				chunk_index - 1,
				_creator_pattern.size(),
			)],
		)
	elif distance_at_chunk < _middle_hazard_start_distance:
		_append_opening_edge_detail(
			result,
			start_x,
			ceiling_y,
			floor_y,
			pattern,
			chunk_index,
		)
	else:
		_append_middle_challenge(
			result,
			start_x,
			ceiling_y,
			floor_y,
			pattern,
		)

	if chunk_index >= 3 and posmod(chunk_index, 5) == 3:
		result.boost_positions.append(Vector2(
			start_x + 720.0,
			lerpf(ceiling_y + 150.0, floor_y - 120.0, 0.5),
		))


func _append_boundary_pattern(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	pattern: int,
) -> void:
	# Each chunk has readable rails, but a deliberate gap on one side creates
	# occasional freedom to rise or fall outside the usual corridor.
	match pattern:
		1, 5:
			_append_ceiling(result, start_x, 350.0, ceiling_y)
			_append_ceiling(result, start_x + 550.0, 412.0, ceiling_y + 18.0)
			_append_floor(result, start_x, CHUNK_WIDTH + 2.0, floor_y)
		2, 6:
			_append_ceiling(result, start_x, CHUNK_WIDTH + 2.0, ceiling_y)
			_append_floor(result, start_x, 410.0, floor_y)
			_append_floor(result, start_x + 610.0, 352.0, floor_y - 12.0)
		3:
			_append_ceiling(result, start_x + 130.0, 832.0, ceiling_y)
			_append_floor(result, start_x, 520.0, floor_y)
			_append_floor(result, start_x + 700.0, 262.0, floor_y)
		7:
			_append_ceiling(result, start_x, 610.0, ceiling_y)
			_append_ceiling(result, start_x + 800.0, 162.0, ceiling_y + 26.0)
			_append_floor(result, start_x + 100.0, 862.0, floor_y)
		_:
			_append_ceiling(result, start_x, CHUNK_WIDTH + 2.0, ceiling_y)
			_append_floor(result, start_x, CHUNK_WIDTH + 2.0, floor_y)


func _append_opening_edge_detail(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	pattern: int,
	chunk_index: int,
) -> void:
	if chunk_index == 0:
		return
	# The opening runway teaches the corridor and web rhythm. It never adds a
	# detached middle obstacle; sparse shapes grow only from an existing edge.
	if posmod(chunk_index, 3) != 1:
		return
	if pattern in [1, 3, 5, 7]:
		_append_leaf_cluster(
			result, start_x + 650.0, floor_y, false, _edge_obstacle_scale)
	else:
		_append_leaf_cluster(
			result, start_x + 650.0, ceiling_y, true, _edge_obstacle_scale)


func _append_middle_challenge(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	pattern: int,
) -> void:
	# Every challenge keeps a usable lower or upper rail before the hazard. Its
	# fly trail communicates the intended route without making it mandatory.
	match pattern:
		0:
			_append_vine_fork(
				result, start_x + 610.0, floor_y,
				220.0 * _floating_obstacle_scale,
				180.0 * _floating_obstacle_scale)
		1:
			_append_hanging_seed_pod(
				result, start_x + 650.0, ceiling_y,
				150.0 * _floating_obstacle_scale,
				235.0 * _floating_obstacle_scale)
		2:
			_append_leaf_cluster(
				result, start_x + 620.0, floor_y, false,
				_floating_obstacle_scale)
			_append_hanging_seed_pod(
				result, start_x + 790.0, ceiling_y,
				105.0 * _floating_obstacle_scale,
				165.0 * _floating_obstacle_scale)
		3:
			_append_broken_pot_gate(result, start_x + 690.0, 370.0)
		4:
			_append_vine_fork(
				result, start_x + 650.0, floor_y,
				250.0 * _floating_obstacle_scale,
				215.0 * _floating_obstacle_scale)
		5:
			_append_hanging_seed_pod(
				result, start_x + 620.0, ceiling_y,
				175.0 * _floating_obstacle_scale,
				260.0 * _floating_obstacle_scale)
		6:
			_append_leaf_cluster(
				result, start_x + 610.0, floor_y, false,
				_floating_obstacle_scale)
			_append_leaf_cluster(
				result, start_x + 815.0, ceiling_y, true,
				_floating_obstacle_scale)
		_:
			_append_broken_pot_gate(result, start_x + 700.0, 350.0)


func _append_creator_challenge(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	piece: StringName,
) -> void:
	match piece:
		&"leaf":
			_append_leaf_cluster(
				result, start_x + 650.0, floor_y, false,
				_floating_obstacle_scale)
		&"pod":
			_append_hanging_seed_pod(
				result, start_x + 650.0, ceiling_y,
				160.0 * _floating_obstacle_scale,
				235.0 * _floating_obstacle_scale)
		&"vine":
			_append_vine_fork(
				result, start_x + 650.0, floor_y,
				235.0 * _floating_obstacle_scale,
				195.0 * _floating_obstacle_scale)
		&"gate":
			_append_broken_pot_gate(result, start_x + 690.0, 370.0)
		_:
			pass


func _append_ceiling(
	result: CourseGeometry,
	start_x: float,
	width: float,
	underside_y: float,
) -> void:
	result.boundary_surfaces.append(PackedVector2Array([
		Vector2(start_x, underside_y - CEILING_THICKNESS),
		Vector2(start_x + width, underside_y - CEILING_THICKNESS),
		Vector2(start_x + width, underside_y),
		Vector2(start_x, underside_y),
	]))
	_append_guides(result, start_x, width, underside_y)


func _append_floor(
	result: CourseGeometry,
	start_x: float,
	width: float,
	top_y: float,
) -> void:
	result.boundary_surfaces.append(PackedVector2Array([
		Vector2(start_x, top_y),
		Vector2(start_x + width, top_y),
		Vector2(start_x + width, top_y + FLOOR_THICKNESS),
		Vector2(start_x, top_y + FLOOR_THICKNESS),
	]))
	_append_guides(result, start_x, width, top_y)


func _append_guides(
	result: CourseGeometry,
	start_x: float,
	width: float,
	y: float,
) -> void:
	var guide_x := start_x + 76.0
	while guide_x < start_x + width - 32.0:
		result.aim_guides.append(Vector2(guide_x, y))
		guide_x += GUIDE_SPACING


func _append_route_flies(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	pattern: int,
) -> void:
	var high_route := pattern in [1, 3, 4, 7]
	var base_y := floor_y - 135.0 if high_route else ceiling_y + 155.0
	var arc_sign := -1.0 if high_route else 1.0
	for index in range(5):
		var progress := float(index) / 4.0
		result.fly_positions.append(Vector2(
			start_x + 230.0 + float(index) * 120.0,
			base_y + sin(progress * PI) * 82.0 * arc_sign,
		))


func _append_leaf_cluster(
	result: CourseGeometry,
	center_x: float,
	edge_y: float,
	hanging: bool,
	scale: float = 1.0,
) -> void:
	var direction := 1.0 if hanging else -1.0
	var polygon := PackedVector2Array([
		Vector2(center_x - 105.0, edge_y),
		Vector2(center_x - 78.0, edge_y + direction * 46.0),
		Vector2(center_x - 120.0, edge_y + direction * 94.0),
		Vector2(center_x - 36.0, edge_y + direction * 82.0),
		Vector2(center_x, edge_y + direction * 142.0),
		Vector2(center_x + 34.0, edge_y + direction * 78.0),
		Vector2(center_x + 118.0, edge_y + direction * 102.0),
		Vector2(center_x + 76.0, edge_y + direction * 42.0),
		Vector2(center_x + 105.0, edge_y),
	])
	result.obstacles.append(_scaled_polygon(
		polygon,
		Vector2(center_x, edge_y),
		scale,
	))


func _append_vine_fork(
	result: CourseGeometry,
	center_x: float,
	floor_y: float,
	width: float,
	height: float,
) -> void:
	result.obstacles.append(PackedVector2Array([
		Vector2(center_x - width * 0.48, floor_y),
		Vector2(center_x - width * 0.36, floor_y - height * 0.34),
		Vector2(center_x - width * 0.50, floor_y - height * 0.58),
		Vector2(center_x - width * 0.20, floor_y - height * 0.49),
		Vector2(center_x - width * 0.04, floor_y - height),
		Vector2(center_x + width * 0.11, floor_y - height * 0.55),
		Vector2(center_x + width * 0.46, floor_y - height * 0.73),
		Vector2(center_x + width * 0.28, floor_y - height * 0.37),
		Vector2(center_x + width * 0.48, floor_y),
	]))


func _append_hanging_seed_pod(
	result: CourseGeometry,
	center_x: float,
	ceiling_y: float,
	width: float,
	height: float,
) -> void:
	result.obstacles.append(PackedVector2Array([
		Vector2(center_x - width * 0.48, ceiling_y),
		Vector2(center_x + width * 0.42, ceiling_y),
		Vector2(center_x + width * 0.34, ceiling_y + height * 0.46),
		Vector2(center_x + width * 0.15, ceiling_y + height * 0.88),
		Vector2(center_x, ceiling_y + height),
		Vector2(center_x - width * 0.20, ceiling_y + height * 0.82),
		Vector2(center_x - width * 0.40, ceiling_y + height * 0.43),
	]))


func _append_broken_pot_gate(
	result: CourseGeometry,
	center_x: float,
	center_y: float,
) -> void:
	var outer_x := 105.0 * _floating_obstacle_scale
	var outer_y := 126.0 * _floating_obstacle_scale
	var opening_x := 48.0 * _floating_obstacle_scale * _gate_opening_scale
	var opening_y := 57.0 * _floating_obstacle_scale * _gate_opening_scale
	var left := center_x - outer_x
	var right := center_x + outer_x
	var top := center_y - outer_y
	var bottom := center_y + outer_y
	var opening_left := center_x - opening_x
	var opening_right := center_x + opening_x
	var opening_top := center_y - opening_y
	var opening_bottom := center_y + opening_y
	result.obstacles.append(PackedVector2Array([
		Vector2(left + 30.0, top),
		Vector2(right - 24.0, top + 12.0),
		Vector2(opening_right, opening_top),
		Vector2(opening_left, opening_top),
	]))
	result.obstacles.append(PackedVector2Array([
		Vector2(left, top + 38.0),
		Vector2(opening_left, opening_top),
		Vector2(opening_left, opening_bottom),
		Vector2(left + 22.0, bottom - 20.0),
	]))
	result.obstacles.append(PackedVector2Array([
		Vector2(opening_right, opening_top),
		Vector2(right, top + 46.0),
		Vector2(right - 16.0, bottom - 34.0),
		Vector2(opening_right, opening_bottom),
	]))
	result.obstacles.append(PackedVector2Array([
		Vector2(opening_left, opening_bottom),
		Vector2(opening_right, opening_bottom),
		Vector2(right - 32.0, bottom),
		Vector2(left + 38.0, bottom - 10.0),
	]))


func _scaled_polygon(
	polygon: PackedVector2Array,
	origin: Vector2,
	scale: float,
) -> PackedVector2Array:
	var scaled := PackedVector2Array()
	for point: Vector2 in polygon:
		scaled.append(origin + (point - origin) * scale)
	return scaled

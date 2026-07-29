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
const CEILING_Y := 112.0
const FLOOR_Y := 684.0
const START_X := 220.0
const ROUTE_HIGH := &"high"
const ROUTE_LOW := &"low"
const ROUTE_CENTRE := &"centre"
const ROUTE_TIGHT := &"tight"

var _geometry := CourseGeometry.new()
var _middle_hazard_start_distance: float = 10000.0
var _edge_obstacle_scale: float = 0.94
var _floating_obstacle_scale: float = 0.90
var _gate_opening_scale: float = 1.12
var _creator_pattern: Array[StringName] = []
var _corridor_contours_enabled: bool = true
var _corridor_clearance_scale: float = 1.0
var _corridor_tight_gap_scale: float = 1.0
var _tight_corridor_start_distance: float = 20000.0


func reset(
	middle_hazard_start_distance: float = 10000.0,
	edge_obstacle_scale: float = 0.94,
	floating_obstacle_scale: float = 0.90,
	gate_opening_scale: float = 1.12,
	creator_pattern: Array[StringName] = [],
	corridor_contours_enabled: bool = true,
	corridor_clearance_scale: float = 1.0,
	corridor_tight_gap_scale: float = 1.0,
	tight_corridor_start_distance: float = 20000.0,
) -> void:
	_middle_hazard_start_distance = middle_hazard_start_distance
	_edge_obstacle_scale = edge_obstacle_scale
	_floating_obstacle_scale = floating_obstacle_scale
	_gate_opening_scale = gate_opening_scale
	_creator_pattern = creator_pattern.duplicate()
	_corridor_contours_enabled = corridor_contours_enabled
	_corridor_clearance_scale = corridor_clearance_scale
	_corridor_tight_gap_scale = corridor_tight_gap_scale
	_tight_corridor_start_distance = tight_corridor_start_distance
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
	var opening_pattern := posmod(chunk_index, 8)
	var ceiling_y := CEILING_Y
	var floor_y := FLOOR_Y
	var distance_at_chunk := maxf(0.0, start_x - START_X)
	var has_middle_hazard := \
		distance_at_chunk >= _middle_hazard_start_distance
	var pattern_id := pattern_id_for_chunk(chunk_index)
	var creator_piece := &""
	if not _creator_pattern.is_empty() and chunk_index >= 1:
		creator_piece = _creator_pattern[posmod(
			chunk_index - 1,
			_creator_pattern.size(),
		)]
	var route := _route_plan(
		pattern_id,
		chunk_index,
		has_middle_hazard,
		distance_at_chunk >= _tight_corridor_start_distance,
		creator_piece,
	)
	_append_boundary_pattern(
		result,
		start_x,
		ceiling_y,
		floor_y,
		StringName(route["lane"]),
	)
	_append_route_flies(
		result,
		start_x,
		float(route["guide_y"]),
		StringName(route["lane"]),
		float(route.get("guide_end_x", 710.0)),
	)

	if not creator_piece.is_empty():
		_append_creator_challenge(
			result,
			start_x,
			ceiling_y,
			floor_y,
			creator_piece,
			StringName(route["lane"]),
		)
	elif not has_middle_hazard:
		_append_opening_edge_detail(
			result,
			start_x,
			ceiling_y,
			floor_y,
			opening_pattern,
			chunk_index,
			StringName(route["lane"]),
		)
	elif StringName(route["lane"]) != ROUTE_TIGHT:
		_append_middle_challenge(
			result,
			start_x,
			ceiling_y,
			floor_y,
			pattern_id,
			StringName(route["lane"]),
			distance_at_chunk,
		)

	if chunk_index >= 3 and posmod(chunk_index, 5) == 3:
		result.boost_positions.append(Vector2(
			start_x + 720.0,
			lerpf(ceiling_y + 150.0, floor_y - 120.0, 0.5),
		))


func pattern_id_for_chunk(chunk_index: int) -> StringName:
	var distance_at_chunk := maxf(
		0.0,
		float(chunk_index) * CHUNK_WIDTH - START_X,
	)
	return CoursePatternCatalog.pattern_id_for_chunk(
		chunk_index,
		distance_at_chunk,
	)


func _append_boundary_pattern(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	route_lane: StringName,
) -> void:
	# The rails never disappear. Their matching endpoints keep chunk seams
	# continuous, while local profiles open a readable bypass around most
	# hazards. Only occasional late patterns narrow both sides into a gap.
	var ceiling_profile := _boundary_profile(
		start_x,
		ceiling_y,
		route_lane,
		true,
	)
	var floor_profile := _boundary_profile(
		start_x,
		floor_y,
		route_lane,
		false,
	)
	_append_ceiling_profile(result, ceiling_profile)
	_append_floor_profile(result, floor_profile)


func _boundary_profile(
	start_x: float,
	base_y: float,
	route_lane: StringName,
	is_ceiling: bool,
) -> PackedVector2Array:
	var profile := PackedVector2Array([
		Vector2(start_x, base_y),
		Vector2(start_x + 240.0, base_y),
		Vector2(start_x + 430.0, base_y),
		Vector2(start_x + 720.0, base_y),
		Vector2(start_x + CHUNK_WIDTH, base_y),
	])
	if not _corridor_contours_enabled or start_x < CHUNK_WIDTH:
		return profile
	var clearance := 60.0 * _corridor_clearance_scale
	if route_lane == ROUTE_HIGH and is_ceiling:
		profile.set(2, profile[2] + Vector2.UP * clearance * 0.72)
		profile.set(3, profile[3] + Vector2.UP * clearance)
	elif route_lane == ROUTE_LOW and not is_ceiling:
		profile.set(2, profile[2] + Vector2.DOWN * clearance * 0.72)
		profile.set(3, profile[3] + Vector2.DOWN * clearance)
	elif route_lane == ROUTE_CENTRE:
		var direction := Vector2.UP if is_ceiling else Vector2.DOWN
		profile.set(2, profile[2] + direction * clearance * 0.55)
		profile.set(3, profile[3] + direction * clearance * 0.72)
	elif route_lane == ROUTE_TIGHT:
		var gap := 324.0 * _corridor_tight_gap_scale
		var centre := 398.0
		var edge_y := centre - gap * 0.5 if is_ceiling \
			else centre + gap * 0.5
		profile.set(2, Vector2(profile[2].x, edge_y))
		profile.set(3, Vector2(profile[3].x, edge_y))
	return profile


func _boundary_edge_y_at(
	start_x: float,
	world_x: float,
	base_y: float,
	route_lane: StringName,
	is_ceiling: bool,
) -> float:
	var profile := _boundary_profile(
		start_x,
		base_y,
		route_lane,
		is_ceiling,
	)
	for index in range(profile.size() - 1):
		var first := profile[index]
		var second := profile[index + 1]
		if world_x < first.x or world_x > second.x:
			continue
		var span := maxf(1.0, second.x - first.x)
		return lerpf(first.y, second.y, (world_x - first.x) / span)
	return base_y


func _route_plan(
	pattern_id: StringName,
	chunk_index: int,
	has_middle_hazard: bool,
	allow_tight_corridor: bool,
	creator_piece: StringName,
) -> Dictionary:
	if not creator_piece.is_empty():
		match creator_piece:
			&"leaf", &"vine":
				return {"lane": ROUTE_HIGH, "guide_y": CEILING_Y + 160.0}
			&"pod":
				return {"lane": ROUTE_LOW, "guide_y": FLOOR_Y - 160.0}
			&"gate":
				return {
					"lane": ROUTE_CENTRE,
					"guide_y": 370.0,
					"guide_end_x": 690.0,
				}
			_:
				return {"lane": ROUTE_CENTRE, "guide_y": 398.0}

	if not has_middle_hazard:
		if chunk_index == 0 or posmod(chunk_index, 3) != 1:
			return {"lane": ROUTE_CENTRE, "guide_y": 398.0}
		if posmod(chunk_index, 2) == 1:
			return {"lane": ROUTE_HIGH, "guide_y": CEILING_Y + 160.0}
		return {"lane": ROUTE_LOW, "guide_y": FLOOR_Y - 160.0}

	var pattern := CoursePatternCatalog.pattern_for_chunk(
		chunk_index,
		maxf(0.0, float(chunk_index) * CHUNK_WIDTH - START_X),
	)
	var lane := StringName(pattern.get("lane", ROUTE_CENTRE))
	if pattern_id == &"tight_rail" and allow_tight_corridor:
		lane = ROUTE_TIGHT
	elif lane == ROUTE_TIGHT:
		lane = ROUTE_CENTRE
	if pattern_id == &"rooted_gate":
		return {
			"lane": ROUTE_CENTRE,
			"guide_y": 370.0,
			"guide_end_x": 690.0,
		}
	if lane == ROUTE_HIGH:
		return {"lane": lane, "guide_y": CEILING_Y + 160.0}
	if lane == ROUTE_LOW:
		return {"lane": lane, "guide_y": FLOOR_Y - 160.0}
	return {"lane": lane, "guide_y": 398.0}


func _append_opening_edge_detail(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	pattern: int,
	chunk_index: int,
	route_lane: StringName,
) -> void:
	if chunk_index == 0:
		return
	# The opening runway teaches the corridor and web rhythm. It never adds a
	# detached middle obstacle; sparse shapes grow only from an existing edge.
	if posmod(chunk_index, 3) != 1:
		return
	var obstacle_x := start_x + 650.0
	if route_lane == ROUTE_HIGH:
		_append_leaf_cluster(
			result,
			obstacle_x,
			_boundary_edge_y_at(
				start_x, obstacle_x, floor_y, route_lane, false),
			false,
			_edge_obstacle_scale,
		)
	else:
		_append_leaf_cluster(
			result,
			obstacle_x,
			_boundary_edge_y_at(
				start_x, obstacle_x, ceiling_y, route_lane, true),
			true,
			_edge_obstacle_scale,
		)


func _append_middle_challenge(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	pattern_id: StringName,
	route_lane: StringName,
	distance_at_chunk: float,
) -> void:
	# Every challenge keeps a usable lower or upper rail before the hazard. Its
	# fly trail communicates the intended route without making it mandatory.
	# Small hazards grow by at most 12%; the broad passage opening never shrinks.
	var growth := _obstacle_growth_scale(distance_at_chunk)
	match pattern_id:
		&"floor_vine":
			var x := start_x + 610.0
			_append_vine_fork(
				result,
				x,
				_boundary_edge_y_at(
					start_x, x, floor_y, route_lane, false),
				220.0 * _floating_obstacle_scale * growth,
				180.0 * _floating_obstacle_scale * growth,
			)
		&"canopy_pod", &"hanging_vine":
			var x := start_x + 650.0
			_append_hanging_seed_pod(
				result,
				x,
				_boundary_edge_y_at(
					start_x, x, ceiling_y, route_lane, true),
				150.0 * _floating_obstacle_scale * growth,
				235.0 * _floating_obstacle_scale * growth,
			)
		&"thorn_ridge":
			var x := start_x + 640.0
			_append_leaf_cluster(
				result,
				x,
				_boundary_edge_y_at(
					start_x, x, floor_y, route_lane, false),
				false,
				_floating_obstacle_scale * growth,
			)
		&"bramble_curve":
			var x := start_x + 655.0
			_append_vine_fork(
				result,
				x,
				_boundary_edge_y_at(
					start_x, x, floor_y, route_lane, false),
				245.0 * _floating_obstacle_scale * growth,
				205.0 * _floating_obstacle_scale * growth,
			)
		&"staggered_s":
			var floor_x := start_x + 570.0
			var ceiling_x := start_x + 805.0
			_append_leaf_cluster(
				result,
				floor_x,
				_boundary_edge_y_at(
					start_x, floor_x, floor_y, route_lane, false),
				false,
				_floating_obstacle_scale * growth,
			)
			_append_hanging_seed_pod(
				result,
				ceiling_x,
				_boundary_edge_y_at(
					start_x, ceiling_x, ceiling_y, route_lane, true),
				105.0 * _floating_obstacle_scale * growth,
				165.0 * _floating_obstacle_scale * growth,
			)
		&"rooted_gate":
			var x := start_x + 690.0
			_append_split_root_gate(
				result,
				x,
				370.0,
				_boundary_edge_y_at(
					start_x, x, ceiling_y, route_lane, true),
				_boundary_edge_y_at(
					start_x, x, floor_y, route_lane, false),
			)
		&"tall_vine":
			var x := start_x + 650.0
			_append_vine_fork(
				result,
				x,
				_boundary_edge_y_at(
					start_x, x, floor_y, route_lane, false),
				250.0 * _floating_obstacle_scale * growth,
				215.0 * _floating_obstacle_scale * growth,
			)
		&"long_pod":
			var x := start_x + 620.0
			_append_hanging_seed_pod(
				result,
				x,
				_boundary_edge_y_at(
					start_x, x, ceiling_y, route_lane, true),
				175.0 * _floating_obstacle_scale * growth,
				260.0 * _floating_obstacle_scale * growth,
			)
		&"alternating_thorns":
			var floor_x := start_x + 590.0
			var ceiling_x := start_x + 815.0
			_append_leaf_cluster(
				result,
				floor_x,
				_boundary_edge_y_at(
					start_x, floor_x, floor_y, route_lane, false),
				false,
				_floating_obstacle_scale * growth,
			)
			_append_leaf_cluster(
				result,
				ceiling_x,
				_boundary_edge_y_at(
					start_x, ceiling_x, ceiling_y, route_lane, true),
				true,
				_floating_obstacle_scale * growth,
			)
		&"fallen_stump", &"ceiling_stump":
			var hanging := pattern_id == &"ceiling_stump"
			var x := start_x + 650.0
			var edge_y := _boundary_edge_y_at(
				start_x,
				x,
				ceiling_y if hanging else floor_y,
				route_lane,
				hanging,
			)
			_append_root_stump(
				result,
				x,
				edge_y,
				hanging,
				245.0 * _floating_obstacle_scale * growth,
				190.0 * _floating_obstacle_scale * growth,
			)
		&"vine_curtain":
			for local_x: float in [560.0, 805.0]:
				var x := start_x + local_x
				_append_hanging_seed_pod(
					result,
					x,
					_boundary_edge_y_at(
						start_x, x, ceiling_y, route_lane, true),
					112.0 * _floating_obstacle_scale * growth,
					(160.0 if local_x < 700.0 else 205.0) * \
						_floating_obstacle_scale * growth,
				)
		&"bramble_steps", &"recovery_pair":
			for local_x: float in [565.0, 805.0]:
				var x := start_x + local_x
				_append_root_stump(
					result,
					x,
					_boundary_edge_y_at(
						start_x, x, floor_y, route_lane, false),
					false,
					180.0 * _floating_obstacle_scale * growth,
					(135.0 if local_x < 700.0 else 180.0) * \
						_floating_obstacle_scale * growth,
				)
		&"stump_and_vine":
			var floor_x := start_x + 560.0
			var ceiling_x := start_x + 815.0
			_append_root_stump(
				result,
				floor_x,
				_boundary_edge_y_at(
					start_x, floor_x, floor_y, route_lane, false),
				false,
				210.0 * _floating_obstacle_scale * growth,
				165.0 * _floating_obstacle_scale * growth,
			)
			_append_hanging_seed_pod(
				result,
				ceiling_x,
				_boundary_edge_y_at(
					start_x, ceiling_x, ceiling_y, route_lane, true),
				105.0 * _floating_obstacle_scale * growth,
				160.0 * _floating_obstacle_scale * growth,
			)
		_:
			pass


func _obstacle_growth_scale(distance_at_chunk: float) -> float:
	if distance_at_chunk < CoursePatternCatalog.CONTROL_START_DISTANCE:
		return 1.0
	if distance_at_chunk < CoursePatternCatalog.MASTERY_START_DISTANCE:
		return 1.06
	if distance_at_chunk < CoursePatternCatalog.DEEP_FOREST_START_DISTANCE:
		return 1.10
	return 1.12


func _append_creator_challenge(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	piece: StringName,
	route_lane: StringName,
) -> void:
	match piece:
		&"leaf":
			var x := start_x + 650.0
			_append_leaf_cluster(
				result,
				x,
				_boundary_edge_y_at(
					start_x, x, floor_y, route_lane, false),
				false,
				_floating_obstacle_scale,
			)
		&"pod":
			var x := start_x + 650.0
			_append_hanging_seed_pod(
				result,
				x,
				_boundary_edge_y_at(
					start_x, x, ceiling_y, route_lane, true),
				160.0 * _floating_obstacle_scale,
				235.0 * _floating_obstacle_scale,
			)
		&"vine":
			var x := start_x + 650.0
			_append_vine_fork(
				result,
				x,
				_boundary_edge_y_at(
					start_x, x, floor_y, route_lane, false),
				235.0 * _floating_obstacle_scale,
				195.0 * _floating_obstacle_scale,
			)
		&"gate":
			var x := start_x + 690.0
			_append_split_root_gate(
				result,
				x,
				370.0,
				_boundary_edge_y_at(
					start_x, x, ceiling_y, route_lane, true),
				_boundary_edge_y_at(
					start_x, x, floor_y, route_lane, false),
			)
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


func _append_ceiling_profile(
	result: CourseGeometry,
	underside: PackedVector2Array,
) -> void:
	var polygon := underside.duplicate()
	for index in range(underside.size() - 1, -1, -1):
		polygon.append(underside[index] + Vector2.UP * CEILING_THICKNESS)
	result.boundary_surfaces.append(polygon)
	_append_profile_guides(result, underside)


func _append_floor_profile(
	result: CourseGeometry,
	top: PackedVector2Array,
) -> void:
	var polygon := top.duplicate()
	for index in range(top.size() - 1, -1, -1):
		polygon.append(top[index] + Vector2.DOWN * FLOOR_THICKNESS)
	result.boundary_surfaces.append(polygon)
	_append_profile_guides(result, top)


func _append_profile_guides(
	result: CourseGeometry,
	profile: PackedVector2Array,
) -> void:
	for index in range(profile.size() - 1):
		var start := profile[index]
		var finish := profile[index + 1]
		var segment := finish - start
		var count := maxi(1, floori(segment.length() / GUIDE_SPACING))
		for sample in range(count):
			var progress := (float(sample) + 0.5) / float(count)
			result.aim_guides.append(start.lerp(finish, progress))


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
	guide_y: float,
	route_lane: StringName,
	guide_end_x: float,
) -> void:
	var arc := 0.0
	if route_lane == ROUTE_HIGH:
		arc = 46.0
	elif route_lane == ROUTE_LOW:
		arc = -46.0
	for index in range(5):
		var progress := float(index) / 4.0
		result.fly_positions.append(Vector2(
			lerpf(start_x + 230.0, start_x + guide_end_x, progress),
			guide_y + sin(progress * PI) * arc,
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


func _append_root_stump(
	result: CourseGeometry,
	center_x: float,
	edge_y: float,
	hanging: bool,
	width: float,
	height: float,
) -> void:
	var direction := 1.0 if hanging else -1.0
	result.obstacles.append(PackedVector2Array([
		Vector2(center_x - width * 0.50, edge_y),
		Vector2(center_x - width * 0.42, edge_y + direction * height * 0.28),
		Vector2(center_x - width * 0.10, edge_y + direction * height),
		Vector2(center_x + width * 0.12, edge_y + direction * height * 0.74),
		Vector2(center_x + width * 0.43, edge_y + direction * height * 0.34),
		Vector2(center_x + width * 0.50, edge_y),
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


func _append_split_root_gate(
	result: CourseGeometry,
	center_x: float,
	center_y: float,
	ceiling_y: float,
	floor_y: float,
) -> void:
	var root_half_width := 105.0 * _floating_obstacle_scale
	var throat_half_width := 56.0 * _floating_obstacle_scale
	var opening_half_height := \
		132.0 * _floating_obstacle_scale * _gate_opening_scale
	var root_left := center_x - root_half_width
	var root_right := center_x + root_half_width
	var throat_left := center_x - throat_half_width
	var throat_right := center_x + throat_half_width
	var opening_top := center_y - opening_half_height
	var opening_bottom := center_y + opening_half_height
	# These are not detached precision obstacles. Each root overlaps its lethal
	# rail and tapers toward one broad opening. The single opening value controls
	# the visible throat, collision edge, and verified steering envelope.
	result.obstacles.append(PackedVector2Array([
		Vector2(root_left, ceiling_y - 4.0),
		Vector2(root_right, ceiling_y - 4.0),
		Vector2(throat_right, opening_top),
		Vector2(throat_left, opening_top),
	]))
	result.obstacles.append(PackedVector2Array([
		Vector2(throat_left, opening_bottom),
		Vector2(throat_right, opening_bottom),
		Vector2(root_right, floor_y + 4.0),
		Vector2(root_left, floor_y + 4.0),
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

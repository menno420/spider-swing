extends RefCounted
class_name ZoneCourseBuilder
## Authored geometry for Silk Hollow and the five post-15 km zones.
##
## Ancient Forest and Bramble Canopy deliberately stay in CourseStream. Every
## lethal polygon added here states its anchor eligibility at the call site.
## Motion dictionaries are immutable phase descriptions; CourseMotion samples
## them from `(chunk_index, course_seed, tick)`.

const CHUNK_WIDTH := 960.0
const COURSE_START_X := 220.0
const MID_Y := 398.0

## `hollow_lattice_high` and `hollow_lattice_low` were the **only** two patterns
## in the first 15 km that broke the corridor-width envelope: measured at 6.69
## player diameters against the 7.39 floor their class may never cross, held for
## 1.94 spider widths (99 ms). They are `swing` class — the route requires a
## direction change around them — so unlike a threading gate they get no credit
## for a short constriction.
##
## Lowered from 292 px. The bars are boxes tilted 0.48 rad, so a bar's vertical
## reach is `height·cos(0.48) + 32·sin(0.48)`; 292 → 258 removes ~30 px of reach
## and lifts the corridor clear of the floor. `hollow_suspended_bridge` keeps its
## own 178 px lattice, which was never near the floor.
##
## D-0056's own words on why the fix is here rather than in Silk Hollow's
## spacing: *"Silk Hollow's difficulty is to come from its 0.20 s spacing, not
## from corridor width."*
const SWING_LATTICE_HEIGHT := 258.0

const V_HOLLOW_COCOON := &"hollow_cocoon"
const V_HOLLOW_LATTICE := &"hollow_lattice"
const V_HOLLOW_SPINDLE := &"hollow_spindle"
const V_HOLLOW_FLOOR_NEEDLE := &"hollow_floor_needle"
const V_ARBORETUM_BEAM := &"arboretum_beam"
const V_ARBORETUM_DRIP := &"arboretum_drip"
const V_ARBORETUM_PANE := &"arboretum_pane"
const V_ARBORETUM_ROTOR := &"arboretum_rotor"
const V_RIDGE_SPIRE := &"ridge_spire"
const V_RIDGE_SCREE := &"ridge_scree"
const V_RIDGE_LIGHTNING := &"ridge_lightning"
const V_CITY_HIGHWAY := &"city_highway"
const V_CITY_STICKY := &"city_sticky"
const V_CITY_RESIDENT := &"city_resident"
const V_CITY_EGG := &"city_egg"
const V_ASH_SOUND := &"ashen_sound"
const V_ASH_ROTTEN := &"ashen_rotten"
const V_ASH_EMBER := &"ashen_ember"
const V_MIST_LIT := &"mist_lit_anchor"
const V_MIST_HAZARD := &"mist_hazard"


static func handles(pattern_id: StringName) -> bool:
	var id := String(pattern_id)
	return id.begins_with("hollow_") or id.begins_with("arboretum_") or \
		id.begins_with("ridge_") or id.begins_with("city_") or \
		id.begins_with("ashen_") or id.begins_with("mist_")


static func append_challenge(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	pattern_id: StringName,
	route_lane: StringName,
	distance_at_chunk: float,
	chunk_index: int,
	course_seed: int,
) -> void:
	if String(pattern_id).begins_with("hollow_"):
		_append_hollow(result, start_x, ceiling_y, floor_y, pattern_id)
	elif String(pattern_id).begins_with("arboretum_"):
		_append_arboretum(
			result, start_x, ceiling_y, floor_y, pattern_id,
			route_lane, distance_at_chunk, chunk_index, course_seed)
	elif String(pattern_id).begins_with("ridge_"):
		_append_ridge(
			result, start_x, ceiling_y, floor_y, pattern_id,
			route_lane, distance_at_chunk, chunk_index, course_seed)
	elif String(pattern_id).begins_with("city_"):
		_append_city(
			result, start_x, ceiling_y, pattern_id, route_lane, distance_at_chunk,
			chunk_index, course_seed)
	elif String(pattern_id).begins_with("ashen_"):
		_append_ashen(
			result, start_x, ceiling_y, floor_y, pattern_id,
			distance_at_chunk, chunk_index, course_seed)
	else:
		_append_mist(result, start_x, ceiling_y, floor_y, pattern_id)


static func boundary_profile(
	start_x: float,
	base_y: float,
	route_lane: StringName,
	is_ceiling: bool,
) -> PackedVector2Array:
	var distance := maxf(0.0, start_x - COURSE_START_X + CHUNK_WIDTH * 0.5)
	var region_id := StringName(
		CourseRegionCatalog.region_for_distance(distance)["id"])
	match region_id:
		CourseRegionCatalog.SILK_HOLLOW:
			return _hollow_profile(start_x, base_y, route_lane, is_ceiling)
		CourseRegionCatalog.RUINED_ARBORETUM:
			return _arboretum_profile(start_x, base_y, is_ceiling)
		CourseRegionCatalog.STORM_RIDGE:
			return _ridge_profile(start_x, base_y, is_ceiling)
		CourseRegionCatalog.WEB_CITY:
			return _city_profile(start_x, base_y, is_ceiling)
		CourseRegionCatalog.ASHEN_HOLLOW:
			return _ashen_profile(start_x, base_y, is_ceiling)
		CourseRegionCatalog.DEEP_MIST:
			return _mist_profile(start_x, base_y, is_ceiling)
		_:
			return PackedVector2Array()


static func _hollow_profile(
	start_x: float,
	base_y: float,
	route_lane: StringName,
	is_ceiling: bool,
) -> PackedVector2Array:
	var direction := 1.0 if is_ceiling else -1.0
	var lane_relief := 34.0 if (
		(route_lane == &"high" and is_ceiling) or
		(route_lane == &"low" and not is_ceiling)
	) else 0.0
	return _profile(start_x, base_y, [
		0.0, direction * 18.0, direction * (72.0 - lane_relief),
		direction * 28.0, direction * (92.0 - lane_relief), 0.0,
	])


static func _arboretum_profile(
	start_x: float,
	base_y: float,
	is_ceiling: bool,
) -> PackedVector2Array:
	if is_ceiling:
		# Repeating greenhouse gables: straight iron, not organic canopy.
		return _profile(start_x, base_y, [0.0, -70.0, -8.0, -82.0, -8.0, 0.0])
	return _profile(start_x, base_y, [0.0, 0.0, -26.0, -26.0, -70.0, 0.0])


static func _ridge_profile(
	start_x: float,
	base_y: float,
	is_ceiling: bool,
) -> PackedVector2Array:
	if is_ceiling:
		# The roof withdraws to expose sky; only the seam sockets remain.
		return _profile(start_x, base_y, [0.0, -58.0, -76.0, -76.0, -58.0, 0.0])
	return _profile(start_x, base_y, [0.0, -42.0, -158.0, -76.0, -206.0, 0.0])


static func _city_profile(
	start_x: float,
	base_y: float,
	is_ceiling: bool,
) -> PackedVector2Array:
	var direction := -1.0 if is_ceiling else 1.0
	return _profile(start_x, base_y, [
		0.0, direction * 44.0, direction * 92.0,
		direction * 92.0, direction * 44.0, 0.0,
	])


static func _ashen_profile(
	start_x: float,
	base_y: float,
	is_ceiling: bool,
) -> PackedVector2Array:
	var direction := 1.0 if is_ceiling else -1.0
	return _profile(start_x, base_y, [
		0.0, direction * 12.0, direction * 88.0,
		direction * 24.0, direction * 126.0, 0.0,
	])


static func _mist_profile(
	start_x: float,
	base_y: float,
	is_ceiling: bool,
) -> PackedVector2Array:
	var direction := -1.0 if is_ceiling else 1.0
	return _profile(start_x, base_y, [
		0.0, direction * 50.0, direction * 50.0,
		direction * 50.0, direction * 50.0, 0.0,
	])


static func _profile(
	start_x: float,
	base_y: float,
	offsets: Array,
) -> PackedVector2Array:
	var xs := [0.0, 190.0, 380.0, 580.0, 770.0, CHUNK_WIDTH]
	var result := PackedVector2Array()
	for index in range(xs.size()):
		result.append(Vector2(start_x + float(xs[index]), base_y + float(offsets[index])))
	return result


static func _boundary_edge_y_at(
	start_x: float,
	world_x: float,
	base_y: float,
	route_lane: StringName,
	is_ceiling: bool,
) -> float:
	var profile := boundary_profile(start_x, base_y, route_lane, is_ceiling)
	if profile.is_empty():
		return base_y
	for index in range(profile.size() - 1):
		var first := profile[index]
		var second := profile[index + 1]
		if world_x < first.x or world_x > second.x:
			continue
		var span := second.x - first.x
		if is_zero_approx(span):
			return first.y
		return lerpf(first.y, second.y, (world_x - first.x) / span)
	return profile[0].y if world_x < profile[0].x else profile[-1].y


static func _append_hollow(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	pattern_id: StringName,
) -> void:
	match pattern_id:
		&"hollow_cocoon_chute":
			for item: Array in [[500.0, 118.0], [655.0, 178.0], [810.0, 126.0]]:
				_append_cocoon(result, Vector2(start_x + item[0], ceiling_y), item[1], true)
		&"hollow_spindle_gate":
			_append_spindle(
				result, Vector2(start_x + 650.0, ceiling_y), 238.0, true)
			_append_spindle(
				result, Vector2(start_x + 830.0, floor_y), 148.0, false)
		&"hollow_thread_eye":
			_append_thread_eye(
				result, Vector2(start_x + 665.0, MID_Y), ceiling_y, floor_y)
		&"hollow_lattice_high":
			_append_lattice(
				result, start_x + 620.0, floor_y, false, SWING_LATTICE_HEIGHT)
		&"hollow_lattice_low":
			_append_lattice(
				result, start_x + 620.0, ceiling_y, true, SWING_LATTICE_HEIGHT)
		&"hollow_droplet_needles":
			for item: Array in [[500.0, 128.0], [650.0, 205.0], [800.0, 150.0]]:
				_append_spindle(
					result, Vector2(start_x + item[0], ceiling_y), item[1], true)
		&"hollow_orb_cluster":
			for offset: Vector2 in [Vector2(0, 0), Vector2(78, 34), Vector2(35, 104)]:
				_append_cocoon(result, Vector2(start_x + 610.0, ceiling_y) + offset, 116.0, true)
		&"hollow_twin_sacs":
			_append_cocoon(result, Vector2(start_x + 580.0, ceiling_y), 205.0, true)
			_append_cocoon(result, Vector2(start_x + 790.0, ceiling_y), 205.0, true)
		&"hollow_suspended_bridge":
			_append_lattice(result, start_x + 650.0, floor_y, false, 178.0)
			_append_cocoon(result, Vector2(start_x + 785.0, ceiling_y), 136.0, true)


static func _append_cocoon(
	result: CourseGeometry,
	origin: Vector2,
	height: float,
	anchorable: bool,
) -> void:
	var width := height * 0.48
	var polygon := PackedVector2Array([
		origin + Vector2(-10.0, 0.0), origin + Vector2(12.0, 0.0),
		origin + Vector2(width * 0.52, height * 0.34),
		origin + Vector2(width * 0.42, height * 0.72),
		origin + Vector2(0.0, height),
		origin + Vector2(-width * 0.42, height * 0.72),
		origin + Vector2(-width * 0.52, height * 0.34),
	])
	result.append_obstacle(
		polygon, anchorable, CourseObstacleCatalog.UNSPECIFIED,
		&"silk_cocoon", V_HOLLOW_COCOON, {},
		CourseGeometry.ANCHOR_FIXED)


static func _append_spindle(
	result: CourseGeometry,
	origin: Vector2,
	height: float,
	from_ceiling: bool,
) -> void:
	var direction := 1.0 if from_ceiling else -1.0
	var polygon := PackedVector2Array([
		origin + Vector2(-13.0, 0.0), origin + Vector2(13.0, 0.0),
		origin + Vector2(38.0, direction * height * 0.28),
		origin + Vector2(8.0, direction * height * 0.62),
		origin + Vector2(0.0, direction * height),
		origin + Vector2(-8.0, direction * height * 0.62),
		origin + Vector2(-38.0, direction * height * 0.28),
	])
	result.append_obstacle(
		polygon, from_ceiling, CourseObstacleCatalog.UNSPECIFIED, &"silk_spindle",
		V_HOLLOW_SPINDLE if from_ceiling else V_HOLLOW_FLOOR_NEEDLE, {},
		CourseGeometry.ANCHOR_FIXED)


static func _append_thread_eye(
	result: CourseGeometry,
	centre: Vector2,
	ceiling_y: float,
	floor_y: float,
) -> void:
	# Four silk bars leave a real collision-free diamond aperture.
	for index in range(4):
		var angle := PI * 0.25 + float(index) * PI * 0.5
		var bar_centre := centre + Vector2.from_angle(angle) * 92.0
		var bar := _oriented_box(
			bar_centre,
			Vector2(168.0, 26.0), angle + PI * 0.5)
		var ceiling_grown := index >= 2
		result.append_obstacle(
			bar, ceiling_grown, CourseObstacleCatalog.UNSPECIFIED,
			&"silk_thread_eye", V_HOLLOW_LATTICE, {},
			CourseGeometry.ANCHOR_FIXED)
		var edge_y := ceiling_y if ceiling_grown else floor_y
		var support_height := absf(bar_centre.y - edge_y)
		result.append_obstacle(
			_oriented_box(
				Vector2(bar_centre.x, (bar_centre.y + edge_y) * 0.5),
				Vector2(14.0, support_height), 0.0),
			ceiling_grown, CourseObstacleCatalog.UNSPECIFIED,
			&"silk_thread_eye_support", V_HOLLOW_LATTICE, {},
			CourseGeometry.ANCHOR_FIXED)


static func _append_lattice(
	result: CourseGeometry,
	centre_x: float,
	edge_y: float,
	from_ceiling: bool,
	height: float,
) -> void:
	var direction := 1.0 if from_ceiling else -1.0
	for index in range(3):
		var x := centre_x + (float(index) - 1.0) * 92.0
		var centre := Vector2(x, edge_y + direction * height * 0.52)
		var angle := direction * (0.48 if index % 2 == 0 else -0.48)
		result.append_obstacle(
			_oriented_box(centre, Vector2(32.0, height), angle),
			from_ceiling, CourseObstacleCatalog.UNSPECIFIED,
			&"silk_lattice", V_HOLLOW_LATTICE, {},
			CourseGeometry.ANCHOR_FIXED)


static func _append_arboretum(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	pattern_id: StringName,
	route_lane: StringName,
	distance_at_chunk: float,
	chunk_index: int,
	course_seed: int,
) -> void:
	var metres := distance_at_chunk / CourseRegionCatalog.PIXELS_PER_METRE
	match pattern_id:
		&"arboretum_beam_high", &"arboretum_frame_rest_high":
			_append_broken_beam(
				result, start_x + 650.0, ceiling_y + 150.0, -0.18, true,
				start_x, ceiling_y, route_lane)
		&"arboretum_beam_low", &"arboretum_frame_rest_low":
			_append_broken_beam(
				result, start_x + 650.0, ceiling_y + 112.0, 0.18, true,
				start_x, ceiling_y, route_lane)
		&"arboretum_drip_arch_high":
			_append_broken_beam(
				result, start_x + 620.0, ceiling_y + 168.0, -0.42, true,
				start_x, ceiling_y, route_lane)
			_append_drip_guides(
				result, start_x + 720.0, ceiling_y, chunk_index, course_seed, 13)
		&"arboretum_drip_arch_low":
			_append_broken_beam(
				result, start_x + 620.0, ceiling_y + 138.0, 0.42, true,
				start_x, ceiling_y, route_lane)
			_append_drip_guides(
				result, start_x + 760.0, ceiling_y, chunk_index, course_seed, 17)
		&"arboretum_beam_corridor":
			_append_broken_beam(
				result, start_x + 590.0, ceiling_y + 115.0, 0.14, true,
				start_x, ceiling_y, route_lane)
			_append_broken_beam(
				result, start_x + 800.0, ceiling_y + 265.0, -0.14, true,
				start_x, ceiling_y, route_lane)
		&"arboretum_collapsed_high", &"arboretum_broken_span":
			if pattern_id == &"arboretum_broken_span":
				_append_broken_beam(
					result, start_x + 650.0, ceiling_y + 175.0, -0.34, true,
					start_x, ceiling_y, route_lane)
			else:
				_append_collapsed_frame(result, start_x + 650.0, floor_y, false)
		&"arboretum_collapsed_low":
			_append_collapsed_frame(result, start_x + 650.0, ceiling_y, true)
		&"arboretum_pane_high", &"arboretum_pane_low":
			_append_pane(result, Vector2(start_x + 650.0, ceiling_y + 12.0), chunk_index, course_seed, 1)
		&"arboretum_rotor_high", &"arboretum_rotor_low":
			_append_rotor(result, Vector2(start_x + 690.0, MID_Y), chunk_index, course_seed, 2)
		&"arboretum_pane_pair":
			_append_pane(result, Vector2(start_x + 570.0, ceiling_y + 10.0), chunk_index, course_seed, 3)
			if metres >= 17000.0:
				_append_pane(result, Vector2(start_x + 810.0, ceiling_y + 10.0), chunk_index, course_seed, 7)
		&"arboretum_rotor_pane", &"arboretum_drip_rotor":
			_append_rotor(result, Vector2(start_x + 620.0, MID_Y), chunk_index, course_seed, 5)
			var local_chunk := floori((
				distance_at_chunk + CHUNK_WIDTH * 0.5 - 150000.0
			) / CHUNK_WIDTH)
			if metres >= 18500.0 and posmod(local_chunk, 10) == 3:
				_append_pane(result, Vector2(start_x + 830.0, ceiling_y + 10.0), chunk_index, course_seed, 9)
			else:
				_append_drip_guides(
					result, start_x + 830.0, ceiling_y,
					chunk_index, course_seed, 23)
		&"arboretum_timed_gate":
			_append_rotor(result, Vector2(start_x + 690.0, MID_Y), chunk_index, course_seed, 11)


static func _append_broken_beam(
	result: CourseGeometry,
	centre_x: float,
	centre_y: float,
	angle: float,
	ceiling_grown: bool,
	start_x: float,
	ceiling_y: float,
	route_lane: StringName,
) -> void:
	var beam := _oriented_box(Vector2(centre_x, centre_y), Vector2(310.0, 38.0), angle)
	result.append_obstacle(
		beam, ceiling_grown, CourseObstacleCatalog.UNSPECIFIED,
		&"arboretum_broken_beam", V_ARBORETUM_BEAM, {},
		CourseGeometry.ANCHOR_FIXED)
	if ceiling_grown:
		var support_x := centre_x - 92.0
		var support_top_y := _boundary_edge_y_at(
			start_x, support_x, ceiling_y, route_lane, true)
		var support_height := centre_y - support_top_y
		if support_height <= 4.0:
			return
		result.append_obstacle(
			_oriented_box(
				Vector2(support_x, support_top_y + support_height * 0.5),
				Vector2(24.0, support_height), 0.0),
			true, CourseObstacleCatalog.UNSPECIFIED,
			&"arboretum_beam_support", V_ARBORETUM_BEAM, {},
			CourseGeometry.ANCHOR_FIXED)


static func _append_collapsed_frame(
	result: CourseGeometry,
	x: float,
	edge_y: float,
	from_ceiling: bool,
) -> void:
	var direction := 1.0 if from_ceiling else -1.0
	var polygon := PackedVector2Array([
		Vector2(x - 150.0, edge_y),
		Vector2(x - 92.0, edge_y + direction * 44.0),
		Vector2(x - 18.0, edge_y + direction * 232.0),
		Vector2(x + 22.0, edge_y + direction * 182.0),
		Vector2(x + 112.0, edge_y + direction * 76.0),
		Vector2(x + 150.0, edge_y),
	])
	result.append_obstacle(
		polygon, from_ceiling, CourseObstacleCatalog.UNSPECIFIED,
		&"arboretum_collapsed_frame",
		V_ARBORETUM_BEAM, {}, CourseGeometry.ANCHOR_FIXED)


static func _append_drip_guides(
	result: CourseGeometry,
	x: float,
	ceiling_y: float,
	chunk_index: int,
	course_seed: int,
	phase_salt: int,
) -> void:
	# Harmless phase-teaching droplets share the authoritative phase evaluator
	# but never enter either collision or anchor targeting.
	for index in range(5):
		result.aim_guides.append(Vector2(x, ceiling_y + 76.0 + index * 82.0))
		result.append_decoration(
			_diamond(Vector2(x, ceiling_y + 46.0), Vector2(14.0, 24.0)),
			&"arboretum_drip_chain", V_ARBORETUM_DRIP,
			{
				"kind": &"fall_loop",
				"chunk_index": chunk_index,
				"course_seed": course_seed,
				"distance": 410.0,
				"period_ticks": 150,
				"visible_ticks": 138,
				"phase_salt": phase_salt + index * 29,
			})


static func _append_pane(
	result: CourseGeometry,
	origin: Vector2,
	chunk_index: int,
	course_seed: int,
	phase_salt: int,
) -> void:
	var rest_pivot := origin + Vector2(0.0, 38.0)
	var spec := {
		"kind": &"pendulum",
		"chunk_index": chunk_index,
		"course_seed": course_seed,
		"origin": origin,
		"radius": 38.0,
		"amplitude_radians": deg_to_rad(42.0),
		"period_ticks": 300,
		"phase_salt": phase_salt,
		"rest_pivot": rest_pivot,
	}
	var pane := PackedVector2Array([
		rest_pivot + Vector2(-17.0, 8.0), rest_pivot + Vector2(19.0, 14.0),
		rest_pivot + Vector2(44.0, 196.0), rest_pivot + Vector2(5.0, 238.0),
		rest_pivot + Vector2(-31.0, 188.0),
	])
	# The glass edge kills and never answers taps; the round pivot is safe.
	result.append_obstacle(
		pane, false, CourseObstacleCatalog.UNSPECIFIED,
		&"arboretum_hanging_pane", V_ARBORETUM_PANE, spec,
		CourseGeometry.ANCHOR_FIXED)
	result.append_anchor_surface(
		_circle(rest_pivot, 23.0, 10), CourseGeometry.ANCHOR_MOVING_PIVOT,
		&"arboretum_pane_pivot", V_ARBORETUM_PANE, spec)


static func _append_rotor(
	result: CourseGeometry,
	centre: Vector2,
	chunk_index: int,
	course_seed: int,
	phase_salt: int,
) -> void:
	var spec := {
		"kind": &"rotate",
		"chunk_index": chunk_index,
		"course_seed": course_seed,
		"pivot": centre,
		"period_ticks": 360,
		"phase_salt": phase_salt,
	}
	for index in range(2):
		result.append_obstacle(
			_oriented_box(centre, Vector2(312.0, 30.0), float(index) * PI * 0.5),
			false, CourseObstacleCatalog.UNSPECIFIED,
			&"arboretum_slow_rotor", V_ARBORETUM_ROTOR, spec,
			CourseGeometry.ANCHOR_FIXED)
	result.append_obstacle(
		_circle(centre, 34.0, 12), false, CourseObstacleCatalog.UNSPECIFIED,
		&"arboretum_rotor_hub",
		V_ARBORETUM_ROTOR, {}, CourseGeometry.ANCHOR_FIXED)


static func _append_ridge(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	pattern_id: StringName,
	route_lane: StringName,
	distance_at_chunk: float,
	chunk_index: int,
	course_seed: int,
) -> void:
	var metres := distance_at_chunk / CourseRegionCatalog.PIXELS_PER_METRE
	if metres >= 21000.0 and metres < 22500.0:
		# The first gust lesson is intentionally an empty corridor. Boundaries,
		# route flies, and constant forward motion remain; nothing can be hit.
		return
	match pattern_id:
		&"ridge_spire_high", &"ridge_wind_tree_high":
			_append_spire(
				result, start_x + 660.0, ceiling_y, true, 238.0,
				start_x, route_lane)
		&"ridge_spire_low", &"ridge_wind_tree_low":
			_append_spire(
				result, start_x + 660.0, ceiling_y, true, 310.0,
				start_x, route_lane)
		&"ridge_scree_high", &"ridge_scree_chute":
			_append_scree(result, start_x + 660.0, floor_y, 290.0)
		&"ridge_gust_arch", &"ridge_open_gust":
			_append_spire(
				result, start_x + 820.0, ceiling_y, true, 172.0,
				start_x, route_lane)
		&"ridge_split_spires":
			_append_spire(
				result, start_x + 560.0, ceiling_y, true, 216.0,
				start_x, route_lane)
			_append_scree(result, start_x + 810.0, floor_y, 170.0)
		&"ridge_lightning_high", &"ridge_lightning_low":
			_append_spire(
				result, start_x + 650.0, ceiling_y, true, 226.0,
				start_x, route_lane)
			if metres >= 23500.0:
				_append_lightning(
					result, start_x + 650.0, ceiling_y + 226.0,
					chunk_index, course_seed, 19)


static func _append_spire(
	result: CourseGeometry,
	x: float,
	ceiling_y: float,
	from_ceiling: bool,
	height: float,
	start_x: float,
	route_lane: StringName,
) -> void:
	if from_ceiling:
		var support_top_y := _boundary_edge_y_at(
			start_x, x, ceiling_y, route_lane, true)
		var support_height := ceiling_y - support_top_y
		if support_height > 4.0:
			result.append_obstacle(
				_oriented_box(
					Vector2(x, support_top_y + support_height * 0.5),
					Vector2(38.0, support_height), 0.0),
				true, CourseObstacleCatalog.UNSPECIFIED,
				&"ridge_spire_support", V_RIDGE_SPIRE, {},
				CourseGeometry.ANCHOR_FIXED)
	var direction := 1.0 if from_ceiling else -1.0
	var polygon := PackedVector2Array([
		Vector2(x - 46.0, ceiling_y), Vector2(x + 42.0, ceiling_y),
		Vector2(x + 26.0, ceiling_y + direction * height * 0.52),
		Vector2(x, ceiling_y + direction * height),
		Vector2(x - 21.0, ceiling_y + direction * height * 0.48),
	])
	result.append_obstacle(
		polygon, from_ceiling, CourseObstacleCatalog.UNSPECIFIED,
		&"ridge_exposed_spire", V_RIDGE_SPIRE, {},
		CourseGeometry.ANCHOR_FIXED)


static func _append_scree(
	result: CourseGeometry,
	x: float,
	floor_y: float,
	height: float,
) -> void:
	var polygon := PackedVector2Array([
		Vector2(x - 150.0, floor_y), Vector2(x - 112.0, floor_y - height * 0.28),
		Vector2(x - 54.0, floor_y - height * 0.48),
		Vector2(x - 8.0, floor_y - height),
		Vector2(x + 42.0, floor_y - height * 0.52),
		Vector2(x + 96.0, floor_y - height * 0.66),
		Vector2(x + 150.0, floor_y),
	])
	result.append_obstacle(
		polygon, false, CourseObstacleCatalog.UNSPECIFIED,
		&"ridge_loose_scree", V_RIDGE_SCREE, {},
		CourseGeometry.ANCHOR_FIXED)


static func _append_lightning(
	result: CourseGeometry,
	x: float,
	y: float,
	chunk_index: int,
	course_seed: int,
	phase_salt: int,
) -> void:
	var polygon := PackedVector2Array([
		Vector2(x - 18.0, y), Vector2(x + 22.0, y), Vector2(x - 6.0, y + 96.0),
		Vector2(x + 26.0, y + 96.0), Vector2(x - 28.0, y + 238.0),
		Vector2(x - 8.0, y + 126.0), Vector2(x - 42.0, y + 126.0),
	])
	var spec := {
		"kind": &"phase_active",
		"chunk_index": chunk_index,
		"course_seed": course_seed,
		"period_ticks": 240,
		"active_ticks": 24,
		"phase_salt": phase_salt,
	}
	result.append_obstacle(
		polygon, false, CourseObstacleCatalog.UNSPECIFIED,
		&"ridge_lightning", V_RIDGE_LIGHTNING, spec,
		CourseGeometry.ANCHOR_FIXED)


static func _append_city(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	pattern_id: StringName,
	route_lane: StringName,
	distance_at_chunk: float,
	chunk_index: int,
	course_seed: int,
) -> void:
	var metres := distance_at_chunk / CourseRegionCatalog.PIXELS_PER_METRE
	match pattern_id:
		&"city_highway_high":
			_append_highway(result, start_x, 272.0, -0.08, false)
		&"city_highway_low":
			_append_highway(result, start_x, 516.0, 0.06, false)
		&"city_highway_diagonal":
			_append_highway(result, start_x, 310.0, 0.28, false)
		&"city_sticky_high":
			_append_highway(result, start_x, 278.0, -0.05, metres >= 27000.0)
		&"city_sticky_low":
			_append_highway(result, start_x, 510.0, 0.05, metres >= 27000.0)
		&"city_egg_arch":
			_append_egg_arch(result, start_x, ceiling_y, route_lane)
		&"city_resident_high", &"city_resident_low":
			_append_highway(result, start_x, 300.0 if pattern_id.ends_with("high") else 500.0, 0.0, false)
			if metres >= 28000.0:
				_append_resident(
					result, Vector2(start_x + 670.0, 340.0 if pattern_id.ends_with("high") else 470.0),
					chunk_index, course_seed, 23)
		&"city_torn_high":
			_append_highway(result, start_x, 278.0, -0.10, false, 510.0)
		&"city_torn_low":
			_append_highway(result, start_x, 512.0, 0.10, false, 510.0)
		&"city_crossroads":
			_append_highway(result, start_x, 285.0, 0.27, false)
			_append_highway(result, start_x, 520.0, -0.24, metres >= 27000.0)


static func _append_highway(
	result: CourseGeometry,
	start_x: float,
	y: float,
	angle: float,
	sticky: bool,
	length: float = 720.0,
) -> void:
	var centre := Vector2(start_x + 210.0 + length * 0.5, y)
	var thickness := 38.0 if sticky else 18.0
	var anchor_class := CourseGeometry.ANCHOR_STICKY \
		if sticky else CourseGeometry.ANCHOR_HIGHWAY
	var visual := V_CITY_STICKY if sticky else V_CITY_HIGHWAY
	var content := &"city_sticky_strand" if sticky else &"city_silk_highway"
	result.append_anchor_surface(
		_oriented_box(centre, Vector2(length, thickness), angle),
		anchor_class, content, visual)
	if sticky:
		# Beads are safe geometry, creating a silhouette distinct from highways.
		for index in range(6):
			var local := Vector2(-length * 0.42 + index * length * 0.17, 0.0).rotated(angle)
			result.append_anchor_surface(
				_circle(centre + local, 25.0, 10), anchor_class,
				content, visual)


static func _append_egg_arch(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	route_lane: StringName,
) -> void:
	var support_x := start_x + 652.0
	var support_top_y := _boundary_edge_y_at(
		start_x, support_x, ceiling_y, route_lane, true)
	var support_bottom_y := 188.0
	result.append_obstacle(
		_oriented_box(
			Vector2(support_x, (support_top_y + support_bottom_y) * 0.5),
			Vector2(20.0, support_bottom_y - support_top_y), 0.0),
		true, CourseObstacleCatalog.UNSPECIFIED,
		&"city_egg_support", V_CITY_EGG, {}, CourseGeometry.ANCHOR_FIXED)
	for offset: Vector2 in [Vector2(0, 0), Vector2(78, 36), Vector2(32, 104)]:
		var centre := Vector2(start_x + 620.0, 188.0) + offset
		result.append_obstacle(
			_circle(centre, 48.0, 12), true, CourseObstacleCatalog.UNSPECIFIED,
			&"city_egg_sac", V_CITY_EGG, {},
			CourseGeometry.ANCHOR_FIXED)


static func _append_resident(
	result: CourseGeometry,
	centre: Vector2,
	chunk_index: int,
	course_seed: int,
	phase_salt: int,
) -> void:
	var spec := {
		"kind": &"translate_sine",
		"chunk_index": chunk_index,
		"course_seed": course_seed,
		"axis": Vector2(1.0, 0.0),
		"amplitude": 88.0,
		"period_ticks": 270,
		"phase_salt": phase_salt,
	}
	var body := _circle(centre, 42.0, 12)
	result.append_obstacle(
		body, false, CourseObstacleCatalog.UNSPECIFIED,
		&"city_resident_spider", V_CITY_RESIDENT, spec,
		CourseGeometry.ANCHOR_FIXED)
	for direction in [-1.0, 1.0]:
		for index in range(3):
			var leg_centre := centre + Vector2(direction * 52.0, (index - 1) * 24.0)
			result.append_obstacle(
				_oriented_box(leg_centre, Vector2(72.0, 10.0), direction * (index - 1) * 0.35),
				false, CourseObstacleCatalog.UNSPECIFIED,
				&"city_resident_spider", V_CITY_RESIDENT, spec,
				CourseGeometry.ANCHOR_FIXED)


static func _append_ashen(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	pattern_id: StringName,
	distance_at_chunk: float,
	chunk_index: int,
	course_seed: int,
) -> void:
	var metres := distance_at_chunk / CourseRegionCatalog.PIXELS_PER_METRE
	match pattern_id:
		&"ashen_sound_char_high":
			_append_char(result, start_x + 650.0, ceiling_y, 255.0)
		&"ashen_sound_char_low":
			_append_char(result, start_x + 650.0, ceiling_y, 190.0)
		&"ashen_rotten_high", &"ashen_rotten_low":
			_append_rotten(result, start_x + 650.0, ceiling_y, 238.0, false)
		&"ashen_ember_high", &"ashen_ember_low":
			_append_char(result, start_x + 790.0, ceiling_y, 148.0)
			_append_ember(result, Vector2(start_x + 610.0, 182.0), chunk_index, course_seed, 29)
		&"ashen_collapsing_high", &"ashen_collapsing_low":
			if metres >= 33000.0:
				_append_rotten(result, start_x + 650.0, ceiling_y, 330.0, true)
			else:
				_append_char(result, start_x + 650.0, ceiling_y, 238.0)
		&"ashen_bone_gate":
			_append_char(result, start_x + 570.0, ceiling_y, 210.0)
			_append_floor_bone(result, start_x + 790.0, floor_y, 180.0)
		&"ashen_char_pair":
			_append_char(result, start_x + 550.0, ceiling_y, 190.0)
			_append_char(result, start_x + 800.0, ceiling_y, 250.0)
		&"ashen_ember_corridor":
			_append_ember(result, Vector2(start_x + 540.0, 164.0), chunk_index, course_seed, 31)
			_append_ember(result, Vector2(start_x + 790.0, 164.0), chunk_index, course_seed, 37)


static func _append_char(
	result: CourseGeometry,
	x: float,
	ceiling_y: float,
	height: float,
) -> void:
	var polygon := PackedVector2Array([
		Vector2(x - 56.0, ceiling_y), Vector2(x + 52.0, ceiling_y),
		Vector2(x + 36.0, ceiling_y + height * 0.55),
		Vector2(x + 84.0, ceiling_y + height * 0.76),
		Vector2(x + 18.0, ceiling_y + height * 0.70),
		Vector2(x, ceiling_y + height),
		Vector2(x - 20.0, ceiling_y + height * 0.66),
		Vector2(x - 48.0, ceiling_y + height * 0.46),
	])
	result.append_obstacle(
		polygon, true, CourseObstacleCatalog.UNSPECIFIED,
		&"ashen_standing_char", V_ASH_SOUND, {},
		CourseGeometry.ANCHOR_FIXED)


static func _append_rotten(
	result: CourseGeometry,
	x: float,
	ceiling_y: float,
	width: float,
	collapsing: bool,
) -> void:
	var centre := Vector2(x, ceiling_y + 82.0)
	var spec := {
		"kind": &"anchor_lifetime",
		"lifetime_ticks": 54 if collapsing else 78,
	}
	var anchor_class := CourseGeometry.ANCHOR_COLLAPSING \
		if collapsing else CourseGeometry.ANCHOR_ROTTEN
	var branch := PackedVector2Array([
		centre + Vector2(-width * 0.50, -28.0),
		centre + Vector2(-width * 0.20, -12.0),
		centre + Vector2(-width * 0.08, -38.0),
		centre + Vector2(width * 0.04, -8.0),
		centre + Vector2(width * 0.26, -30.0),
		centre + Vector2(width * 0.50, -10.0),
		centre + Vector2(width * 0.42, 22.0),
		centre + Vector2(width * 0.08, 12.0),
		centre + Vector2(-width * 0.02, 38.0),
		centre + Vector2(-width * 0.25, 14.0),
		centre + Vector2(-width * 0.46, 24.0),
	])
	result.append_obstacle(
		branch, true, CourseObstacleCatalog.UNSPECIFIED,
		&"ashen_collapsing_span" if collapsing else &"ashen_rotten_branch",
		V_ASH_ROTTEN, spec, anchor_class)


static func _append_floor_bone(
	result: CourseGeometry,
	x: float,
	floor_y: float,
	height: float,
) -> void:
	var polygon := PackedVector2Array([
		Vector2(x - 72.0, floor_y), Vector2(x - 32.0, floor_y - height * 0.55),
		Vector2(x, floor_y - height), Vector2(x + 24.0, floor_y - height * 0.52),
		Vector2(x + 70.0, floor_y),
	])
	result.append_obstacle(
		polygon, false, CourseObstacleCatalog.UNSPECIFIED,
		&"ashen_floor_bone", V_ASH_SOUND, {},
		CourseGeometry.ANCHOR_FIXED)


static func _append_ember(
	result: CourseGeometry,
	centre: Vector2,
	chunk_index: int,
	course_seed: int,
	phase_salt: int,
) -> void:
	var spec := {
		"kind": &"fall_loop",
		"chunk_index": chunk_index,
		"course_seed": course_seed,
		"distance": 410.0,
		"period_ticks": 210,
		"visible_ticks": 170,
		"phase_salt": phase_salt,
	}
	result.append_obstacle(
		_diamond(centre, Vector2(30.0, 58.0)), false,
		CourseObstacleCatalog.UNSPECIFIED,
		&"ashen_falling_ember", V_ASH_EMBER, spec,
		CourseGeometry.ANCHOR_FIXED)


static func _append_mist(
	result: CourseGeometry,
	start_x: float,
	ceiling_y: float,
	floor_y: float,
	pattern_id: StringName,
) -> void:
	match pattern_id:
		&"mist_echo_spire_high":
			_append_mist_spire(result, start_x + 710.0, floor_y, false, 205.0)
		&"mist_echo_spire_low":
			_append_mist_spire(result, start_x + 710.0, ceiling_y, true, 205.0)
		&"mist_lone_beam":
			_append_lit_beam(
				result, start_x + 660.0, 238.0, -0.12, ceiling_y)
		&"mist_scree_shelf":
			_append_scree(result, start_x + 720.0, floor_y, 155.0)
		&"mist_cocoon":
			_append_cocoon(result, Vector2(start_x + 720.0, ceiling_y), 182.0, true)
		&"mist_standing_char":
			_append_char(result, start_x + 720.0, ceiling_y, 180.0)
		&"mist_root_gap":
			_append_floor_bone(result, start_x + 720.0, floor_y, 150.0)
		&"mist_high_gap":
			_append_lit_beam(
				result, start_x + 760.0, 258.0, 0.15, ceiling_y)
		&"mist_low_gap":
			_append_mist_spire(result, start_x + 760.0, ceiling_y, true, 165.0)


static func _append_mist_spire(
	result: CourseGeometry,
	x: float,
	edge_y: float,
	from_ceiling: bool,
	height: float,
) -> void:
	var direction := 1.0 if from_ceiling else -1.0
	var polygon := PackedVector2Array([
		Vector2(x - 42.0, edge_y), Vector2(x + 42.0, edge_y),
		Vector2(x + 12.0, edge_y + direction * height * 0.56),
		Vector2(x, edge_y + direction * height),
		Vector2(x - 12.0, edge_y + direction * height * 0.56),
	])
	result.append_obstacle(
		polygon, from_ceiling, CourseObstacleCatalog.UNSPECIFIED,
		&"mist_echo_spire", V_MIST_HAZARD, {},
		CourseGeometry.ANCHOR_FIXED)


static func _append_lit_beam(
	result: CourseGeometry,
	x: float,
	y: float,
	angle: float,
	ceiling_y: float,
) -> void:
	result.append_obstacle(
		_oriented_box(
			Vector2(x - 104.0, (ceiling_y + y) * 0.5),
			Vector2(14.0, y - ceiling_y), 0.0),
		true, CourseObstacleCatalog.UNSPECIFIED,
		&"mist_lit_beam_support", V_MIST_LIT, {},
		CourseGeometry.ANCHOR_FIXED)
	result.append_obstacle(
		_oriented_box(Vector2(x, y), Vector2(300.0, 34.0), angle),
		true, CourseObstacleCatalog.UNSPECIFIED,
		&"mist_lit_beam", V_MIST_LIT, {}, CourseGeometry.ANCHOR_FIXED)


static func _oriented_box(
	centre: Vector2,
	size: Vector2,
	angle: float,
) -> PackedVector2Array:
	var half := size * 0.5
	var polygon := PackedVector2Array()
	for local: Vector2 in [
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y),
	]:
		polygon.append(centre + local.rotated(angle))
	return polygon


static func _circle(
	centre: Vector2,
	radius: float,
	point_count: int,
) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for index in range(point_count):
		polygon.append(centre + Vector2.from_angle(
			TAU * float(index) / float(point_count)) * radius)
	return polygon


static func _diamond(
	centre: Vector2,
	size: Vector2,
) -> PackedVector2Array:
	return PackedVector2Array([
		centre + Vector2(0.0, -size.y * 0.5),
		centre + Vector2(size.x * 0.5, 0.0),
		centre + Vector2(0.0, size.y * 0.5),
		centre + Vector2(-size.x * 0.5, 0.0),
	])

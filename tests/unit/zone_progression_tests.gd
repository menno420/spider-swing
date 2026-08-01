extends RefCounted
class_name ZoneProgressionTests
## Contracts for the 10 km+ authored zones and ADR 0004 moving-part model.

const FIXED_DELTA := 1.0 / 60.0


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_region_entries_append_without_new_checkpoints(failures)
	passed += _test_authored_hazards_declare_identity_and_anchorability(failures)
	passed += _test_motion_phase_is_pure_seeded_and_periodic(failures)
	passed += _test_moving_polygon_collision_is_swept(failures)
	passed += _test_arboretum_density_and_moving_pivot(failures)
	passed += _test_storm_density_force_and_lightning(failures)
	passed += _test_web_city_route_classes_and_density(failures)
	passed += _test_ashen_timed_anchors_fail_once(failures)
	passed += _test_deep_mist_is_sparse_and_audio_first(failures)
	passed += _test_recorded_zone_obstacles_resolve_finished_art(failures)
	passed += _test_zone_art_audit_is_current_and_clean(failures)
	return {"passed": passed, "failures": failures}


static func _test_region_entries_append_without_new_checkpoints(
	failures: PackedStringArray,
) -> int:
	var expected := [
		[CourseRegionCatalog.ANCIENT_FOREST, 0.0],
		[CourseRegionCatalog.BRAMBLE_CANOPY, 50000.0],
		[CourseRegionCatalog.SILK_HOLLOW, 100000.0],
		[CourseRegionCatalog.RUINED_ARBORETUM, 150000.0],
		[CourseRegionCatalog.STORM_RIDGE, 200000.0],
		[CourseRegionCatalog.WEB_CITY, 250000.0],
		[CourseRegionCatalog.ASHEN_HOLLOW, 300000.0],
		[CourseRegionCatalog.DEEP_MIST, 350000.0],
	]
	if CourseRegionCatalog.REGIONS.size() != expected.size():
		failures.append("zone catalog is not the eight-region append-only sequence")
		return 0
	for index in range(expected.size()):
		var region: Dictionary = CourseRegionCatalog.REGIONS[index]
		if StringName(region["id"]) != expected[index][0] or \
				not is_equal_approx(float(region["start_distance"]), expected[index][1]):
			failures.append("zone %d changed id or 5 km boundary" % (index + 1))
			return 0
		if index >= 3 and (
			not bool(region.get("safe_entry", false)) or
			bool(region.get("checkpoint", true))
		):
			failures.append("post-15 km regions must enter safely without owning checkpoints")
			return 0
	var practice_ids: Array[StringName] = []
	for region: Dictionary in CourseRegionCatalog.practice_regions():
		practice_ids.append(StringName(region["id"]))
	if practice_ids != [
		CourseRegionCatalog.BRAMBLE_CANOPY,
		CourseRegionCatalog.SILK_HOLLOW,
	]:
		failures.append("zone append changed the campaign/checkpoint surface")
		return 0

	var session := SwingLabSession.new()
	session.configure_run(SwingLabSession.RUN_STANDARD, 0.0, 77)
	session._reset_run()
	var entered: Array[StringName] = []
	session.event_published.connect(func(event: SimulationEvent) -> void:
		if event.kind == SimulationEvent.Kind.REGION_ENTERED:
			entered.append(StringName(event.data.get("region_id", &""))))
	for index in range(3, expected.size()):
		session._world.distance_pixels = float(expected[index][1])
		session._update_region_progress()
	session.free()
	if entered != [
		CourseRegionCatalog.RUINED_ARBORETUM,
		CourseRegionCatalog.STORM_RIDGE,
		CourseRegionCatalog.WEB_CITY,
		CourseRegionCatalog.ASHEN_HOLLOW,
		CourseRegionCatalog.DEEP_MIST,
	]:
		failures.append("zones 4–8 do not emit their own region-entry sequence")
		return 0
	return 1


static func _test_authored_hazards_declare_identity_and_anchorability(
	failures: PackedStringArray,
) -> int:
	var authored_sets := [
		[CoursePatternCatalog.SILK_HOLLOW_PATTERNS, 125000.0],
		[CoursePatternCatalog.ARBORETUM_OPENING_PATTERNS, 158000.0],
		[CoursePatternCatalog.RUINED_ARBORETUM_PATTERNS, 190000.0],
		[CoursePatternCatalog.STORM_RIDGE_PATTERNS, 240000.0],
		[CoursePatternCatalog.WEB_CITY_PATTERNS, 290000.0],
		[CoursePatternCatalog.ASHEN_HOLLOW_PATTERNS, 340000.0],
		[CoursePatternCatalog.DEEP_MIST_PATTERNS, 360000.0],
	]
	var saw_anchorable := false
	var saw_untappable := false
	for set_index in range(authored_sets.size()):
		var patterns: Array = authored_sets[set_index][0]
		var distance := float(authored_sets[set_index][1])
		for pattern: Dictionary in patterns:
			var geometry := CourseGeometry.new()
			ZoneCourseBuilder.append_challenge(
				geometry, 0.0, CourseStream.CEILING_Y, CourseStream.FLOOR_Y,
				StringName(pattern["id"]), StringName(pattern["lane"]),
				distance, 197 + set_index, 707)
			if geometry.obstacles.is_empty() and geometry.surfaces.is_empty() and \
					geometry.decorations.is_empty():
				failures.append("authored pattern %s has no zone geometry" % pattern["id"])
				return 0
			if geometry.obstacle_anchorable.size() != geometry.obstacles.size() or \
					geometry.obstacle_ids.size() != geometry.obstacles.size() or \
					geometry.obstacle_visual_ids.size() != geometry.obstacles.size() or \
					geometry.obstacle_anchor_classes.size() != geometry.obstacles.size() or \
					geometry.obstacle_motion_specs.size() != geometry.obstacles.size():
				failures.append("pattern %s has incomplete obstacle metadata" % pattern["id"])
				return 0
			for obstacle_index in range(geometry.obstacles.size()):
				if geometry.obstacle_id(obstacle_index).is_empty() or \
						geometry.obstacle_visual_id(obstacle_index).is_empty() or \
						geometry.obstacle_anchor_class(obstacle_index).is_empty():
					failures.append("pattern %s contains an anonymous hazard" % pattern["id"])
					return 0
				var anchorable := geometry.is_obstacle_anchorable(obstacle_index)
				saw_anchorable = saw_anchorable or anchorable
				saw_untappable = saw_untappable or not anchorable
				var bounds := SolidGeometry.bounds(geometry.obstacles[obstacle_index])
				var floor_grown := bounds.end.y >= CourseStream.FLOOR_Y - 0.01 and \
						bounds.position.y > CourseStream.CEILING_Y + 0.01
				if floor_grown and anchorable:
					failures.append("floor-grown %s still answers web taps" %
						geometry.obstacle_id(obstacle_index))
					return 0
				if geometry.obstacle_visual_id(obstacle_index) in [
					ZoneCourseBuilder.V_HOLLOW_FLOOR_NEEDLE,
					ZoneCourseBuilder.V_ARBORETUM_ROTOR,
					ZoneCourseBuilder.V_RIDGE_SCREE,
					ZoneCourseBuilder.V_RIDGE_LIGHTNING,
					ZoneCourseBuilder.V_CITY_RESIDENT,
					ZoneCourseBuilder.V_ASH_EMBER,
				] and anchorable:
					failures.append("lethal moving/floor visual %s is tappable" %
						geometry.obstacle_visual_id(obstacle_index))
					return 0
			if geometry.surface_ids.size() != geometry.surfaces.size() or \
					geometry.surface_visual_ids.size() != geometry.surfaces.size() or \
					geometry.surface_anchor_classes.size() != geometry.surfaces.size() or \
					geometry.surface_motion_specs.size() != geometry.surfaces.size():
				failures.append("pattern %s has incomplete safe-anchor metadata" % pattern["id"])
				return 0
			for surface_index in range(geometry.surfaces.size()):
				if geometry.surface_id(surface_index).is_empty() or \
						geometry.surface_visual_id(surface_index).is_empty():
					failures.append("pattern %s contains an anonymous safe anchor" % pattern["id"])
					return 0
			if geometry.decoration_ids.size() != geometry.decorations.size() or \
					geometry.decoration_visual_ids.size() != geometry.decorations.size() or \
					geometry.decoration_motion_specs.size() != geometry.decorations.size():
				failures.append("pattern %s has incomplete harmless-phase metadata" % pattern["id"])
				return 0
	if not saw_anchorable or not saw_untappable:
		failures.append("authored zone vocabulary lost explicit anchorable/NOT contrast")
		return 0
	return 1


static func _test_motion_phase_is_pure_seeded_and_periodic(
	failures: PackedStringArray,
) -> int:
	var base := _rectangle_polygon(Rect2(480.0, 250.0, 70.0, 110.0))
	var cases := [
		{
			"kind": &"pendulum", "chunk_index": 197, "course_seed": 77,
			"origin": Vector2(520.0, 112.0), "rest_pivot": Vector2(520.0, 150.0),
			"radius": 38.0, "amplitude_radians": deg_to_rad(42.0),
			"period_ticks": 300, "phase_salt": 3,
		},
		{
			"kind": &"rotate", "chunk_index": 245, "course_seed": 77,
			"pivot": Vector2(520.0, 305.0), "period_ticks": 360,
			"phase_salt": 5,
		},
		{
			"kind": &"translate_sine", "chunk_index": 292, "course_seed": 77,
			"axis": Vector2.RIGHT, "amplitude": 88.0, "period_ticks": 270,
			"phase_salt": 7,
		},
		{
			"kind": &"fall_loop", "chunk_index": 344, "course_seed": 77,
			"distance": 410.0, "period_ticks": 210, "visible_ticks": 170,
			"phase_salt": 11,
		},
		{
			"kind": &"phase_active", "chunk_index": 244, "course_seed": 77,
			"period_ticks": 240, "active_ticks": 24, "phase_salt": 13,
		},
	]
	var original := base.duplicate()
	var seed_changed_sample := false
	for spec: Dictionary in cases:
		var first := CourseMotion.sample_polygon(base, spec, 137, FIXED_DELTA)
		var repeated := CourseMotion.sample_polygon(base, spec, 137, FIXED_DELTA)
		var period := int(spec["period_ticks"])
		var cycled := CourseMotion.sample_polygon(
			base, spec, 137 + period, FIXED_DELTA)
		if first != repeated or first != cycled:
			failures.append("motion %s is not pure and exactly periodic" % spec["kind"])
			return 0
		var alternate := spec.duplicate(true)
		alternate["course_seed"] = 91
		var seeded := CourseMotion.sample_polygon(base, alternate, 137, FIXED_DELTA)
		seed_changed_sample = seed_changed_sample or seeded != first
	if base != original or not seed_changed_sample:
		failures.append("phase evaluation mutated base geometry or ignores course seed")
		return 0
	return 1


static func _test_moving_polygon_collision_is_swept(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.course_boundaries_enabled = false
	var world := SimulationWorld.new()
	world.reset(config, CourseGeometry.new())
	world.obstacles = [_rectangle_polygon(Rect2(360.0, 360.0, 40.0, 76.0))]
	world._next_obstacles = [
		_rectangle_polygon(Rect2(800.0, 360.0, 40.0, 76.0)),
	]
	world._obstacle_active = PackedByteArray([1])
	world._next_obstacle_active = PackedByteArray([1])
	var stationary_spider := Vector2(610.0, 398.0)
	var contact := world._first_obstacle_contact(
		stationary_spider, stationary_spider + Vector2(0.1, 0.0))
	if not bool(contact["found"]):
		failures.append("a fast moving polygon can tunnel through a near-static spider")
		return 0
	return 1


static func _test_arboretum_density_and_moving_pivot(
	failures: PackedStringArray,
) -> int:
	var opening := _stream_at(15500.0, 707)
	for spec: Dictionary in opening.obstacle_motion_specs:
		if not spec.is_empty():
			failures.append("Arboretum moves a lethal part before 16.5 km")
			return 0
	for spec: Dictionary in opening.surface_motion_specs:
		if not spec.is_empty():
			failures.append("Arboretum moves an anchor before 16.5 km")
			return 0
	if opening.decorations.is_empty():
		failures.append("Arboretum opening has no harmless phase-teaching drips")
		return 0

	var combo_chunk := -1
	for chunk_index in range(190, 220):
		var distance := maxf(
			0.0, float(chunk_index) * CourseStream.CHUNK_WIDTH - CourseStream.START_X)
		if distance < 185000.0 or distance >= 200000.0:
			continue
		if CoursePatternCatalog.pattern_id_for_chunk(chunk_index, distance, 707) == \
				&"arboretum_rotor_pane":
			combo_chunk = chunk_index
			var next_distance := distance + CourseStream.CHUNK_WIDTH
			if CoursePatternCatalog.pattern_id_for_chunk(
				chunk_index + 1, next_distance, 707) != &"open_recovery":
				failures.append("rotor-plus-pane is not followed by static recovery")
				return 0
			break
	if combo_chunk < 0:
		failures.append("Arboretum never authors its post-18.5 km phase combination")
		return 0

	var geometry := CourseGeometry.new()
	ZoneCourseBuilder.append_challenge(
		geometry, 0.0, CourseStream.CEILING_Y, CourseStream.FLOOR_Y,
		&"arboretum_pane_high", &"high", 175000.0, combo_chunk, 707)
	var pivot_index := geometry.surface_anchor_classes.find(
		CourseGeometry.ANCHOR_MOVING_PIVOT)
	if pivot_index < 0:
		failures.append("hanging pane has no independently safe moving pivot")
		return 0
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.course_boundaries_enabled = false
	var world := SimulationWorld.new()
	world.reset(config, geometry, 0.0)
	var target := _polygon_centre(world.surfaces[pivot_index])
	var expected_next := _polygon_centre(world._next_surfaces[pivot_index])
	world.queue_command(InputCommand.attach(target, 1, 0))
	var events := world.step(FIXED_DELTA)
	var selected_anchor := Vector2.ZERO
	for event: SimulationEvent in events:
		if event.kind == SimulationEvent.Kind.ATTACHED:
			selected_anchor = event.position
	var expected_bound_point := expected_next + selected_anchor - target
	if not _contains_event(events, SimulationEvent.Kind.ATTACHED) or \
			world._web_anchor_class != CourseGeometry.ANCHOR_MOVING_PIVOT or \
			world.web.anchor.distance_to(expected_bound_point) > 0.001:
		failures.append("web binding does not follow the exact sampled pane pivot")
		return 0
	return 1


static func _test_storm_density_force_and_lightning(
	failures: PackedStringArray,
) -> int:
	var mild := ZoneMechanics.wind_acceleration(205000.0, 77, 137, false)
	if mild != ZoneMechanics.BASE_WIND_ACCELERATION or \
			ZoneMechanics.gust_strength(210000.0, 77, 137) != 0.0 or \
			ZoneMechanics.wind_acceleration(199999.0, 77, 137, false) != Vector2.ZERO:
		failures.append("Storm wind does not enter as mild constant force then zero-ramp gust")
		return 0
	var peak_tick := 0
	var peak_strength := 0.0
	for tick in range(ZoneMechanics.GUST_PERIOD_TICKS):
		var strength := ZoneMechanics.gust_strength(220000.0, 77, tick)
		if strength > peak_strength:
			peak_strength = strength
			peak_tick = tick
	var detached := ZoneMechanics.wind_acceleration(220000.0, 77, peak_tick, false)
	var attached := ZoneMechanics.wind_acceleration(220000.0, 77, peak_tick, true)
	if peak_strength < 0.99 or \
			absf(attached.length() / detached.length() - \
				ZoneMechanics.ATTACHED_WIND_FACTOR) > 0.0001 or \
			detached != ZoneMechanics.wind_acceleration(220000.0, 77, peak_tick, false):
		failures.append("Storm gust is not deterministic or attached silk lacks protection")
		return 0
	var first_gust := CourseGeometry.new()
	ZoneCourseBuilder.append_challenge(
		first_gust, 0.0, CourseStream.CEILING_Y, CourseStream.FLOOR_Y,
		&"ridge_split_spires", &"centre", 215000.0, 224, 77)
	if not first_gust.obstacles.is_empty():
		failures.append("first gust lesson is not an empty corridor")
		return 0
	var before_lightning := CourseGeometry.new()
	var after_lightning := CourseGeometry.new()
	ZoneCourseBuilder.append_challenge(
		before_lightning, 0.0, CourseStream.CEILING_Y, CourseStream.FLOOR_Y,
		&"ridge_lightning_high", &"high", 234900.0, 244, 77)
	ZoneCourseBuilder.append_challenge(
		after_lightning, 0.0, CourseStream.CEILING_Y, CourseStream.FLOOR_Y,
		&"ridge_lightning_high", &"high", 235100.0, 245, 77)
	if before_lightning.obstacle_ids.has(&"ridge_lightning") or \
			not after_lightning.obstacle_ids.has(&"ridge_lightning"):
		failures.append("Storm lightning does not begin at 23.5 km")
		return 0
	return 1


static func _test_web_city_route_classes_and_density(
	failures: PackedStringArray,
) -> int:
	var gift := CourseGeometry.new()
	var sticky := CourseGeometry.new()
	ZoneCourseBuilder.append_challenge(
		gift, 0.0, CourseStream.CEILING_Y, CourseStream.FLOOR_Y,
		&"city_sticky_high", &"high", 269000.0, 280, 77)
	ZoneCourseBuilder.append_challenge(
		sticky, 0.0, CourseStream.CEILING_Y, CourseStream.FLOOR_Y,
		&"city_sticky_high", &"high", 271000.0, 282, 77)
	if gift.surface_anchor_classes.has(CourseGeometry.ANCHOR_STICKY) or \
			not gift.surface_anchor_classes.has(CourseGeometry.ANCHOR_HIGHWAY) or \
			not sticky.surface_anchor_classes.has(CourseGeometry.ANCHOR_STICKY):
		failures.append("Web City introduces sticky discrimination before 27 km or not at all")
		return 0
	var before_residents := CourseGeometry.new()
	var after_residents := CourseGeometry.new()
	ZoneCourseBuilder.append_challenge(
		before_residents, 0.0, CourseStream.CEILING_Y, CourseStream.FLOOR_Y,
		&"city_resident_high", &"high", 279000.0, 290, 77)
	ZoneCourseBuilder.append_challenge(
		after_residents, 0.0, CourseStream.CEILING_Y, CourseStream.FLOOR_Y,
		&"city_resident_high", &"high", 281000.0, 292, 77)
	if before_residents.obstacle_ids.has(&"city_resident_spider") or \
			not after_residents.obstacle_ids.has(&"city_resident_spider"):
		failures.append("Web City residents do not begin at 28 km")
		return 0
	var input_velocity := Vector2(760.0, -80.0)
	if ZoneMechanics.apply_sticky_bleed(input_velocity, FIXED_DELTA).length() >= \
			input_velocity.length():
		failures.append("sticky silk does not bleed attached speed")
		return 0

	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.course_boundaries_enabled = false
	var world := SimulationWorld.new()
	world.reset(config, gift)
	var highway_index := world.surface_anchor_classes.find(
		CourseGeometry.ANCHOR_HIGHWAY)
	var target := SolidGeometry.bounds(world.surfaces[highway_index]).position + \
		Vector2(120.0, 9.0)
	world.queue_command(InputCommand.attach(target, 1, 0))
	var events := world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.ATTACHED) or \
			world._web_anchor_class != CourseGeometry.ANCHOR_HIGHWAY or \
			world.web.anchor.x < target.x + \
				SimulationWorld.HIGHWAY_ANCHOR_SPEED * FIXED_DELTA - 0.01:
		failures.append("silk highway is not a forward-riding safe anchor class")
		return 0
	return 1


static func _test_ashen_timed_anchors_fail_once(
	failures: PackedStringArray,
) -> int:
	var before_collapse := CourseGeometry.new()
	var after_collapse := CourseGeometry.new()
	ZoneCourseBuilder.append_challenge(
		before_collapse, 0.0, CourseStream.CEILING_Y, CourseStream.FLOOR_Y,
		&"ashen_collapsing_high", &"high", 329000.0, 342, 77)
	ZoneCourseBuilder.append_challenge(
		after_collapse, 0.0, CourseStream.CEILING_Y, CourseStream.FLOOR_Y,
		&"ashen_collapsing_high", &"high", 331000.0, 344, 77)
	if before_collapse.obstacle_anchor_classes.has(
		CourseGeometry.ANCHOR_COLLAPSING) or \
			not after_collapse.obstacle_anchor_classes.has(
				CourseGeometry.ANCHOR_COLLAPSING):
		failures.append("collapsing spans do not begin at 33 km")
		return 0

	var geometry := CourseGeometry.new()
	var rotten := _rectangle_polygon(Rect2(470.0, 132.0, 120.0, 32.0))
	geometry.append_obstacle(
		rotten, true, CourseObstacleCatalog.UNSPECIFIED,
		&"ashen_rotten_branch", ZoneCourseBuilder.V_ASH_ROTTEN,
		{"kind": &"anchor_lifetime", "lifetime_ticks": 5},
		CourseGeometry.ANCHOR_ROTTEN)
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.course_boundaries_enabled = false
	var world := SimulationWorld.new()
	world.reset(config, geometry)
	var target := Vector2(500.0, 148.0)
	world.queue_command(InputCommand.attach(target, 1, 0))
	var events := world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.ATTACHED) or \
			not _contains_event(events, SimulationEvent.Kind.HAZARD_CUE):
		failures.append("rotten anchor gives no attach-time crack warning")
		return 0
	var failure_events := 0
	for _step in range(7):
		events = world.step(FIXED_DELTA)
		for event: SimulationEvent in events:
			if event.kind == SimulationEvent.Kind.ANCHOR_FAILED:
				failure_events += 1
	if failure_events != 1 or world.web.attached or \
			bool(world.nearest_solid_point(target)["found"]):
		failures.append("rotten anchor did not fail once and become permanently spent")
		return 0
	return 1


static func _test_deep_mist_is_sparse_and_audio_first(
	failures: PackedStringArray,
) -> int:
	var geometry := _stream_at(37500.0, 77)
	if geometry.obstacles.size() > 12:
		failures.append("Deep Mist stacks dense geometry behind reduced visibility")
		return 0
	for spec: Dictionary in geometry.obstacle_motion_specs:
		if not spec.is_empty():
			failures.append("Deep Mist escalates with a new moving hazard")
			return 0

	var cue_geometry := CourseGeometry.new()
	var start_distance := 350000.0
	var player_x := SimulationWorld.START_POSITION.x + start_distance
	cue_geometry.course_seed = 77
	cue_geometry.append_obstacle(
		_rectangle_polygon(Rect2(player_x + 760.0, 330.0, 60.0, 130.0)),
		false, CourseObstacleCatalog.UNSPECIFIED,
		&"mist_echo_spire", ZoneCourseBuilder.V_MIST_HAZARD, {},
		CourseGeometry.ANCHOR_FIXED)
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.course_boundaries_enabled = false
	var world := SimulationWorld.new()
	world.reset(config, cue_geometry, start_distance)
	var events := world.step(FIXED_DELTA)
	var cue_found := false
	for event: SimulationEvent in events:
		if event.kind == SimulationEvent.Kind.HAZARD_CUE and \
				StringName(event.data.get("cue", &"")) == &"mist_echo" and \
				float(event.data.get("lead_pixels", 0.0)) >= 700.0:
			cue_found = true
	if not cue_found:
		failures.append("Deep Mist hazard does not announce itself before vision")
		return 0
	return 1


static func _test_zone_art_audit_is_current_and_clean(
	failures: PackedStringArray,
) -> int:
	var path := "res://docs/visual/zones/zone-art-audit.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		failures.append("zone art has no committed source/runtime/silhouette audit")
		return 0
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		failures.append("zone art audit is not valid JSON")
		return 0
	var audit := parsed as Dictionary
	var assets: Array = audit.get("assets", [])
	if assets.size() != 20 or not (audit.get("failures", []) as Array).is_empty():
		failures.append("zone art audit is incomplete or records a failure")
		return 0
	for asset_value in assets:
		var asset := asset_value as Dictionary
		var states := asset.get("alpha", {}) as Dictionary
		for state_name in ["source", "runtime", "gameplay_25_percent"]:
			var state := states.get(state_name, {}) as Dictionary
			if int(state.get("transparent", 0)) <= 0 or \
					int(state.get("chroma_fringe_pixels", 1)) != 0:
				failures.append("%s fails alpha/fringe audit at %s" % [
					asset.get("asset", "unknown"), state_name])
				return 0
		var runtime_path := "res://assets/runtime/zone-art/%s.png" % \
			str(asset.get("asset", ""))
		if FileAccess.get_sha256(runtime_path) != str(asset.get("runtime_sha256", "")):
			failures.append("zone art audit is stale for %s" % asset.get("asset", ""))
			return 0
	if float((audit.get("highest_pair_iou", {}) as Dictionary).get(
		"intersection_over_union", 1.0)) > 0.55:
		failures.append("25% zone silhouette separation regressed above IoU 0.55")
		return 0
	return 1


static func _test_recorded_zone_obstacles_resolve_finished_art(
	failures: PackedStringArray,
) -> int:
	# These are the exact visual/content-id families visible as prototype bars
	# in the owner's 10 km and 15 km Android recordings. Each route must remain
	# explicit so a new renderer fallback cannot silently recreate that defect.
	var cases := [
		[ZoneCourseBuilder.V_HOLLOW_COCOON, &"silk_cocoon", true,
			ArtAssetCatalog.HOLLOW_COCOON, &"contain", Vector2(384.0, 768.0)],
		[ZoneCourseBuilder.V_HOLLOW_SPINDLE, &"silk_spindle", true,
			ArtAssetCatalog.HOLLOW_SPINDLE, &"contain", Vector2(256.0, 768.0)],
		[ZoneCourseBuilder.V_HOLLOW_FLOOR_NEEDLE, &"silk_spindle", false,
			ArtAssetCatalog.HOLLOW_SPINDLE, &"contain", Vector2(256.0, 768.0)],
		[ZoneCourseBuilder.V_HOLLOW_LATTICE, &"silk_lattice", true,
			ArtAssetCatalog.HOLLOW_LATTICE_STRUT, &"oriented", Vector2(768.0, 128.0)],
		[ZoneCourseBuilder.V_ARBORETUM_BEAM, &"arboretum_broken_beam", true,
			ArtAssetCatalog.ARBORETUM_BEAM, &"oriented", Vector2(768.0, 96.0)],
		[ZoneCourseBuilder.V_ARBORETUM_BEAM, &"arboretum_collapsed_frame", false,
			ArtAssetCatalog.ARBORETUM_COLLAPSED_FRAME, &"contain", Vector2(640.0, 512.0)],
		[ZoneCourseBuilder.V_ARBORETUM_PANE, &"arboretum_hanging_pane", false,
			ArtAssetCatalog.ARBORETUM_PANE, &"contain", Vector2(512.0, 512.0)],
		[ZoneCourseBuilder.V_ARBORETUM_ROTOR, &"arboretum_slow_rotor", false,
			ArtAssetCatalog.ARBORETUM_ROTOR_ARM, &"oriented", Vector2(768.0, 96.0)],
		[ZoneCourseBuilder.V_ARBORETUM_ROTOR, &"arboretum_rotor_hub", false,
			ArtAssetCatalog.ARBORETUM_ROTOR_HUB, &"contain", Vector2(256.0, 256.0)],
	]
	for case: Array in cases:
		var spec := ArtAssetCatalog.zone_obstacle_art_spec(
			case[0], case[1], case[2])
		if StringName(spec.get("asset_id", &"")) != case[3] or \
				StringName(spec.get("placement", &"")) != case[4]:
			failures.append("recorded obstacle %s/%s has no explicit finished-art route" % [
				case[0], case[1]])
			return 0
		var path := ArtAssetCatalog.texture_path(case[3])
		if path.is_empty() or not ResourceLoader.exists(path):
			failures.append("recorded obstacle art is missing: %s" % path)
			return 0
		var texture := load(path) as Texture2D
		if texture == null or texture.get_size() != case[5]:
			failures.append("recorded obstacle art has wrong runtime dimensions: %s" % path)
			return 0
	var floor_spec := ArtAssetCatalog.zone_obstacle_art_spec(
		ZoneCourseBuilder.V_HOLLOW_FLOOR_NEEDLE, &"silk_spindle", false)
	if not bool(floor_spec.get("flip_y", false)):
		failures.append("floor-grown Silk spindle art does not point up from the floor")
		return 0
	var ceiling_frame := ArtAssetCatalog.zone_obstacle_art_spec(
		ZoneCourseBuilder.V_ARBORETUM_BEAM,
		&"arboretum_collapsed_frame", true)
	if not bool(ceiling_frame.get("flip_y", false)):
		failures.append("ceiling-grown collapsed frame art does not mirror its geometry")
		return 0
	return 1


static func _stream_at(metres: float, seed: int) -> CourseGeometry:
	var world_x := SimulationWorld.START_POSITION.x + \
		metres * CourseRegionCatalog.PIXELS_PER_METRE
	var stream := CourseStream.new()
	stream.reset(
		10000.0, 0.94, 0.90, 1.12, [], true, 1.0, 1.0,
		20000.0, seed, world_x)
	return stream.geometry()


static func _polygon_centre(polygon: PackedVector2Array) -> Vector2:
	return SolidGeometry.bounds(polygon).get_center()


static func _contains_event(events: Array[SimulationEvent], kind: int) -> bool:
	for event: SimulationEvent in events:
		if event.kind == kind:
			return true
	return false


static func _rectangle_polygon(rect: Rect2) -> PackedVector2Array:
	return PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	])

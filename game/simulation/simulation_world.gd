extends RefCounted
class_name SimulationWorld
## Authoritative fixed-step Phase 0 simulation state.

const START_POSITION := Vector2(220.0, 390.0)
const START_VELOCITY := Vector2(360.0, -30.0)
const PULL_CLEARANCE := 10.0
const GUIDED_ANCHOR_Y := 112.0
const FIXED_DELTA := 1.0 / 60.0
const HIGHWAY_ANCHOR_SPEED := 410.0
## The old kill line is the bird's leading contact point, not its body centre.
## Keeping that point explicit makes the visible beak agree with the existing
## death seam while the 280 px sprite can bank and flap around it.
const BIRD_CONTACT_LEAD_X := 82.0
const BIRD_VERTICAL_STIFFNESS := 10.0
const BIRD_VERTICAL_DAMPING := 6.25
const BIRD_MAXIMUM_VERTICAL_SPEED := 520.0
const BIRD_FLAP_CLOCK_UNITS := 60000

var config: SwingConfig
var position: Vector2 = START_POSITION
var velocity: Vector2 = START_VELOCITY
var target_speed: float = 0.0
var distance_pixels: float = 0.0
var furthest_x: float = START_POSITION.x
var tick: int = 0
var bird_position: Vector2 = Vector2.ZERO
var bird_velocity: Vector2 = Vector2.ZERO
var bird_flap_phase: float = 0.0
var bird_flap_rate: float = 0.0
var bird_closing: bool = false
var anchors: PackedVector2Array = PackedVector2Array()
var surfaces: Array[PackedVector2Array] = []
var surface_ids: Array[StringName] = []
var surface_anchor_classes: Array[StringName] = []
var surface_visual_ids: Array[StringName] = []
var decorations: Array[PackedVector2Array] = []
var decoration_ids: Array[StringName] = []
var decoration_visual_ids: Array[StringName] = []
var boundary_surfaces: Array[PackedVector2Array] = []
var obstacles: Array[PackedVector2Array] = []
## Parallel to `obstacles`: 1 when the hazard answers web taps, 0 when it is
## lethal-but-untappable. Absent entries read as tappable so geometry built
## without the flag keeps its original behaviour.
var obstacle_anchorable: PackedByteArray = PackedByteArray()
## Presentation-only semantic kind copied with each authoritative polygon.
var obstacle_kinds: Array[StringName] = []
var obstacle_ids: Array[StringName] = []
var obstacle_anchor_classes: Array[StringName] = []
var obstacle_visual_ids: Array[StringName] = []
var fly_positions: PackedVector2Array = PackedVector2Array()
var boost_positions: PackedVector2Array = PackedVector2Array()
var run_flies: int = 0
var burst_cooldown_remaining: float = 0.0
var burst_charges: int = 1
var dive_ready: bool = true
var surface_bounce_ready: bool = false
var rescue_shield_remaining: float = 0.0
var glide_remaining: float = 0.0
var pull_active: bool = false
var pull_kind: StringName = &""
var pull_anchor: Vector2 = Vector2.ZERO
var pull_distance_total: float = 0.0
var pull_distance_remaining: float = 0.0
var pull_duration_remaining: float = 0.0
var web := WebConstraint.new()
var _pull_direction: Vector2 = Vector2.ZERO
var _pull_tangential_velocity: Vector2 = Vector2.ZERO
var _pull_radial_speed: float = 0.0
var _pull_exit_speed: float = 0.0
var _commands: Array[InputCommand] = []
var _collected_pickups: Dictionary = {}
var _burst_cooldown_suppressed: bool = false
var _run_start_x: float = START_POSITION.x
var _course_seed: int = 0
var _base_surfaces: Array[PackedVector2Array] = []
var _surface_motion_specs: Array[Dictionary] = []
var _surface_source_keys: Array[String] = []
var _next_surfaces: Array[PackedVector2Array] = []
var _base_decorations: Array[PackedVector2Array] = []
var _decoration_motion_specs: Array[Dictionary] = []
var _next_decorations: Array[PackedVector2Array] = []
var _decoration_active: PackedByteArray = PackedByteArray()
var _next_decoration_active: PackedByteArray = PackedByteArray()
var _base_obstacles: Array[PackedVector2Array] = []
var _obstacle_motion_specs: Array[Dictionary] = []
var _obstacle_source_keys: Array[String] = []
var _next_obstacles: Array[PackedVector2Array] = []
var _obstacle_active: PackedByteArray = PackedByteArray()
var _next_obstacle_active: PackedByteArray = PackedByteArray()
var _web_anchor_source_key: String = ""
var _web_anchor_source_kind: StringName = &""
var _web_anchor_class: StringName = CourseGeometry.ANCHOR_FIXED
var _web_anchor_offset: Vector2 = Vector2.ZERO
var _web_anchor_expiry_tick: int = -1
var _web_anchor_attached_tick: int = -1
var _web_anchor_initial_position: Vector2 = Vector2.ZERO
var _spent_anchor_sources: Dictionary = {}
var _emitted_zone_cues: Dictionary = {}
var _bird_flap_clock: int = 0


func reset(
	active_config: SwingConfig,
	geometry: CourseGeometry,
	start_distance_pixels: float = 0.0,
) -> void:
	config = active_config
	var start_distance := maxf(0.0, start_distance_pixels)
	_run_start_x = START_POSITION.x + start_distance
	position = Vector2(_run_start_x, START_POSITION.y)
	target_speed = config.target_speed_at(start_distance)
	velocity = Vector2(target_speed, START_VELOCITY.y)
	distance_pixels = start_distance
	furthest_x = _run_start_x
	tick = 0
	_reset_bird_state()
	run_flies = 0
	_collected_pickups.clear()
	_spent_anchor_sources.clear()
	_emitted_zone_cues.clear()
	_clear_web_anchor_binding()
	set_course_geometry(geometry)
	burst_cooldown_remaining = 0.0
	burst_charges = config.burst_charge_capacity
	dive_ready = true
	surface_bounce_ready = config.surface_bounce_enabled
	_burst_cooldown_suppressed = false
	_cancel_pull()
	web.reset(config)
	rescue_shield_remaining = 0.0
	glide_remaining = config.glide_duration
	_commands.clear()


func set_course_geometry(geometry: CourseGeometry) -> void:
	_course_seed = geometry.course_seed
	anchors = geometry.aim_guides.duplicate()
	_base_surfaces.clear()
	surface_ids.clear()
	surface_anchor_classes.clear()
	surface_visual_ids.clear()
	_surface_motion_specs.clear()
	_surface_source_keys.clear()
	for index in range(geometry.surfaces.size()):
		var surface := geometry.surfaces[index].duplicate()
		_base_surfaces.append(surface)
		surface_ids.append(geometry.surface_id(index))
		surface_anchor_classes.append(geometry.surface_anchor_class(index))
		surface_visual_ids.append(geometry.surface_visual_id(index))
		_surface_motion_specs.append(geometry.surface_motion_spec(index))
		_surface_source_keys.append(_source_key(
			&"surface", geometry.surface_id(index), surface,
			geometry.surface_motion_spec(index)))
	_base_decorations.clear()
	decoration_ids.clear()
	decoration_visual_ids.clear()
	_decoration_motion_specs.clear()
	for index in range(geometry.decorations.size()):
		_base_decorations.append(geometry.decorations[index].duplicate())
		decoration_ids.append(geometry.decoration_id(index))
		decoration_visual_ids.append(geometry.decoration_visual_id(index))
		_decoration_motion_specs.append(geometry.decoration_motion_spec(index))
	boundary_surfaces.clear()
	for surface: PackedVector2Array in geometry.boundary_surfaces:
		boundary_surfaces.append(surface.duplicate())
	_base_obstacles.clear()
	obstacle_anchorable.clear()
	obstacle_kinds.clear()
	obstacle_ids.clear()
	obstacle_anchor_classes.clear()
	obstacle_visual_ids.clear()
	_obstacle_motion_specs.clear()
	_obstacle_source_keys.clear()
	for index in range(geometry.obstacles.size()):
		var obstacle := geometry.obstacles[index].duplicate()
		_base_obstacles.append(obstacle)
		obstacle_anchorable.append(
			1 if geometry.is_obstacle_anchorable(index) else 0)
		obstacle_kinds.append(geometry.obstacle_kind(index))
		obstacle_ids.append(geometry.obstacle_id(index))
		obstacle_anchor_classes.append(geometry.obstacle_anchor_class(index))
		obstacle_visual_ids.append(geometry.obstacle_visual_id(index))
		_obstacle_motion_specs.append(geometry.obstacle_motion_spec(index))
		_obstacle_source_keys.append(_source_key(
			&"obstacle", geometry.obstacle_id(index), obstacle,
			geometry.obstacle_motion_spec(index)))
	_sample_course_motion()
	fly_positions.clear()
	for fly: Vector2 in geometry.fly_positions:
		if not _collected_pickups.has(_pickup_key(&"fly", fly)):
			fly_positions.append(fly)
	boost_positions.clear()
	for boost: Vector2 in geometry.boost_positions:
		if not _collected_pickups.has(_pickup_key(&"boost", boost)):
			boost_positions.append(boost)


func _sample_course_motion() -> void:
	surfaces.clear()
	_next_surfaces.clear()
	for index in range(_base_surfaces.size()):
		var sample := CourseMotion.sample_polygon(
			_base_surfaces[index], _surface_motion_specs[index], tick, FIXED_DELTA)
		surfaces.append(PackedVector2Array(sample["current"]))
		_next_surfaces.append(PackedVector2Array(sample["next"]))
	decorations.clear()
	_next_decorations.clear()
	_decoration_active.clear()
	_next_decoration_active.clear()
	for index in range(_base_decorations.size()):
		var sample := CourseMotion.sample_polygon(
			_base_decorations[index], _decoration_motion_specs[index],
			tick, FIXED_DELTA)
		decorations.append(PackedVector2Array(sample["current"]))
		_next_decorations.append(PackedVector2Array(sample["next"]))
		_decoration_active.append(1 if bool(sample["active"]) else 0)
		_next_decoration_active.append(1 if bool(sample["next_active"]) else 0)
	obstacles.clear()
	_next_obstacles.clear()
	_obstacle_active.clear()
	_next_obstacle_active.clear()
	for index in range(_base_obstacles.size()):
		var sample := CourseMotion.sample_polygon(
			_base_obstacles[index], _obstacle_motion_specs[index], tick, FIXED_DELTA)
		obstacles.append(PackedVector2Array(sample["current"]))
		_next_obstacles.append(PackedVector2Array(sample["next"]))
		_obstacle_active.append(1 if bool(sample["active"]) else 0)
		_next_obstacle_active.append(1 if bool(sample["next_active"]) else 0)


func _commit_next_course_motion() -> void:
	surfaces.clear()
	for polygon: PackedVector2Array in _next_surfaces:
		surfaces.append(polygon.duplicate())
	decorations.clear()
	for polygon: PackedVector2Array in _next_decorations:
		decorations.append(polygon.duplicate())
	_decoration_active = _next_decoration_active.duplicate()
	obstacles.clear()
	for polygon: PackedVector2Array in _next_obstacles:
		obstacles.append(polygon.duplicate())
	_obstacle_active = _next_obstacle_active.duplicate()


func _source_key(
	kind: StringName,
	content_id: StringName,
	polygon: PackedVector2Array,
	motion_spec: Dictionary,
) -> String:
	var bounds := SolidGeometry.bounds(polygon)
	var centre := bounds.position + bounds.size * 0.5
	return "%s:%s:%d:%.3f:%.3f" % [
		kind,
		content_id,
		int(motion_spec.get("chunk_index", -1)),
		centre.x,
		centre.y,
	]


func _polygon_centre(polygon: PackedVector2Array) -> Vector2:
	if polygon.is_empty():
		return Vector2.ZERO
	var bounds := SolidGeometry.bounds(polygon)
	return bounds.position + bounds.size * 0.5


func _prepare_web_anchor(events: Array[SimulationEvent]) -> void:
	if not web.attached:
		_clear_web_anchor_binding(true)
		return
	if _web_anchor_expiry_tick >= 0 and tick >= _web_anchor_expiry_tick:
		var failed_class := _web_anchor_class
		var failed_position := web.anchor
		_clear_web_anchor_binding(true)
		web.release()
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.ANCHOR_FAILED,
			failed_position,
			"Collapsing span failed" if \
				failed_class == CourseGeometry.ANCHOR_COLLAPSING \
				else "Rotten branch broke",
			{"anchor_class": failed_class},
		))
		return
	if _web_anchor_source_key.is_empty():
		return
	var current := _bound_source_polygon(false)
	if current.is_empty():
		web.release()
		_clear_web_anchor_binding()
		return
	if _web_anchor_class != CourseGeometry.ANCHOR_HIGHWAY:
		web.anchor = _polygon_centre(current) + _web_anchor_offset


func _web_anchor_motion(delta: float) -> Dictionary:
	if not web.attached or _web_anchor_source_key.is_empty():
		return {"next_anchor": web.anchor, "velocity": Vector2.ZERO}
	var current := _bound_source_polygon(false)
	var next := _bound_source_polygon(true)
	if current.is_empty() or next.is_empty():
		return {"next_anchor": web.anchor, "velocity": Vector2.ZERO}
	var current_anchor := _polygon_centre(current) + _web_anchor_offset
	var next_anchor := _polygon_centre(next) + _web_anchor_offset
	if _web_anchor_class == CourseGeometry.ANCHOR_HIGHWAY:
		var bounds := SolidGeometry.bounds(current)
		var elapsed_ticks := maxi(0, tick - _web_anchor_attached_tick)
		current_anchor = _web_anchor_initial_position
		current_anchor.x = minf(
			bounds.end.x - 12.0,
			_web_anchor_initial_position.x + \
				float(elapsed_ticks) * HIGHWAY_ANCHOR_SPEED * delta,
		)
		next_anchor = current_anchor
		next_anchor.x = minf(
			bounds.end.x - 12.0,
			current_anchor.x + HIGHWAY_ANCHOR_SPEED * delta,
		)
		web.anchor = current_anchor
	return {
		"next_anchor": next_anchor,
		"velocity": (next_anchor - current_anchor) / maxf(delta, 0.000001),
	}


func _bound_source_polygon(next_tick: bool) -> PackedVector2Array:
	if _web_anchor_source_kind == &"surface":
		var surface_index := _surface_source_keys.find(_web_anchor_source_key)
		if surface_index < 0:
			return PackedVector2Array()
		return (
			_next_surfaces[surface_index]
			if next_tick else surfaces[surface_index]
		)
	if _web_anchor_source_kind == &"obstacle":
		var obstacle_index := _obstacle_source_keys.find(_web_anchor_source_key)
		if obstacle_index < 0:
			return PackedVector2Array()
		return (
			_next_obstacles[obstacle_index]
			if next_tick else obstacles[obstacle_index]
		)
	return PackedVector2Array()


func _bind_web_anchor(metadata: Dictionary, selected_anchor: Vector2) -> void:
	_clear_web_anchor_binding(true)
	var source_key := str(metadata.get("source_key", ""))
	if source_key.is_empty():
		return
	_web_anchor_source_key = source_key
	_web_anchor_source_kind = StringName(metadata.get("source_kind", &""))
	_web_anchor_class = StringName(metadata.get(
		"anchor_class", CourseGeometry.ANCHOR_FIXED))
	_web_anchor_attached_tick = tick
	_web_anchor_initial_position = selected_anchor
	var source := _bound_source_polygon(false)
	if not source.is_empty():
		_web_anchor_offset = selected_anchor - _polygon_centre(source)
	var motion_spec: Dictionary = metadata.get("motion_spec", {})
	if _web_anchor_class in [
		CourseGeometry.ANCHOR_ROTTEN,
		CourseGeometry.ANCHOR_COLLAPSING,
	]:
		_web_anchor_expiry_tick = tick + maxi(
			1, int(motion_spec.get("lifetime_ticks", 60)))


func _clear_web_anchor_binding(mark_spent: bool = false) -> void:
	if mark_spent and not _web_anchor_source_key.is_empty() and \
			_web_anchor_class in [
				CourseGeometry.ANCHOR_ROTTEN,
				CourseGeometry.ANCHOR_COLLAPSING,
			]:
		_spent_anchor_sources[_web_anchor_source_key] = true
	_web_anchor_source_key = ""
	_web_anchor_source_kind = &""
	_web_anchor_class = CourseGeometry.ANCHOR_FIXED
	_web_anchor_offset = Vector2.ZERO
	_web_anchor_expiry_tick = -1
	_web_anchor_attached_tick = -1
	_web_anchor_initial_position = Vector2.ZERO


func set_burst_cooldown_suppressed(active: bool) -> void:
	_burst_cooldown_suppressed = active
	if active:
		burst_cooldown_remaining = 0.0
		burst_charges = config.burst_charge_capacity


func queue_command(command: InputCommand) -> void:
	_commands.append(command)


func step(delta: float) -> Array[SimulationEvent]:
	var events: Array[SimulationEvent] = []
	_sample_course_motion()
	_prepare_web_anchor(events)
	_emit_zone_cues(events)
	rescue_shield_remaining = maxf(0.0, rescue_shield_remaining - delta)
	if _burst_cooldown_suppressed:
		burst_cooldown_remaining = 0.0
		burst_charges = config.burst_charge_capacity
	elif burst_cooldown_remaining > 0.0:
		# One serial refill timer: each completion returns one charge, and
		# the timer restarts only while charges are still missing.
		burst_cooldown_remaining = maxf(0.0, burst_cooldown_remaining - delta)
		if burst_cooldown_remaining <= 0.0:
			burst_charges = mini(config.burst_charge_capacity, burst_charges + 1)
			if burst_charges < config.burst_charge_capacity:
				burst_cooldown_remaining = config.burst_cooldown
	_commands.sort_custom(func(a: InputCommand, b: InputCommand) -> bool:
		return a.sequence < b.sequence)
	for command: InputCommand in _commands:
		_consume(command, events)
	_commands.clear()

	var step_start := position
	var hit_obstacle := false
	if pull_active:
		hit_obstacle = _advance_pull(delta, events)
	else:
		var previous_position := position
		var gravity_scale := 1.0
		if not web.attached and glide_remaining > 0.0:
			gravity_scale = config.detached_gravity_scale
			glide_remaining = maxf(0.0, glide_remaining - delta)
		var motor_result := SpiderMotor.apply_forces(
			velocity, distance_pixels, delta, config, gravity_scale)
		velocity = motor_result["velocity"]
		target_speed = float(motor_result["target_speed"])
		velocity += ZoneMechanics.wind_acceleration(
			distance_pixels, _course_seed, tick, web.attached) * delta
		if web.attached and _web_anchor_class == CourseGeometry.ANCHOR_STICKY:
			velocity = ZoneMechanics.apply_sticky_bleed(velocity, delta)

		if web.advance_resource(delta, config):
			events.append(SimulationEvent.make(
				SimulationEvent.Kind.REEL_EMPTY,
				position,
				"Reel energy empty",
			))

		var anchor_motion := _web_anchor_motion(delta)
		var constraint_result := web.solve_moving_anchor(
			position,
			velocity,
			delta,
			config,
			Vector2(anchor_motion["next_anchor"]),
			Vector2(anchor_motion["velocity"]),
		)
		position = constraint_result["position"]
		velocity = constraint_result["velocity"]
		var contact := _first_obstacle_contact(previous_position, position)
		if bool(contact["found"]):
			if StringName(contact["kind"]) == &"boundary" and \
					_try_surface_bounce(contact, events):
				position = contact["surface_point"] + \
					Vector2(contact["normal"]) * \
					(config.player_collision_radius + 1.0)
			else:
				position = contact["position"]
				hit_obstacle = true
				events.append(_collision_death_event(contact))

	furthest_x = maxf(furthest_x, position.x)
	distance_pixels = maxf(0.0, furthest_x - START_POSITION.x)
	_advance_bird(delta)
	tick += 1
	_commit_next_course_motion()

	if hit_obstacle:
		return events
	_collect_pickups(step_start, position, events)
	if position.y > config.lower_world_boundary:
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.DEATH_REQUESTED,
			position,
			"Fell below the laboratory",
			{"cause": &"lower_boundary"},
		))
	elif position.x < left_kill_boundary():
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.DEATH_REQUESTED,
			position,
			"Caught by the pursuing bird",
			{"cause": &"camera_boundary"},
		))
	return events


func _emit_zone_cues(events: Array[SimulationEvent]) -> void:
	_emit_storm_gust_cue(events)
	for index in range(obstacles.size()):
		if index >= obstacle_ids.size() or obstacle_ids[index].is_empty():
			continue
		var key := _obstacle_source_keys[index]
		if _emitted_zone_cues.has(key):
			continue
		var bounds := SolidGeometry.bounds(obstacles[index])
		var lead := bounds.position.x - position.x
		if lead < 700.0 or lead > 820.0:
			continue
		var cue := &""
		var message := ""
		var region_id := StringName(
			CourseRegionCatalog.region_for_distance(distance_pixels)["id"])
		if region_id == CourseRegionCatalog.DEEP_MIST:
			cue = &"mist_echo"
			message = "Echo ahead"
		elif region_id == CourseRegionCatalog.RUINED_ARBORETUM and \
				not _obstacle_motion_specs[index].is_empty():
			cue = &"glass_phase"
			message = "Moving gap ahead"
		elif region_id == CourseRegionCatalog.ASHEN_HOLLOW and \
				obstacle_anchor_classes[index] in [
					CourseGeometry.ANCHOR_ROTTEN,
					CourseGeometry.ANCHOR_COLLAPSING,
				]:
			cue = &"rotten_crack"
			message = "Weak anchor ahead"
		elif region_id == CourseRegionCatalog.STORM_RIDGE and \
				obstacle_ids[index] == &"ridge_lightning":
			cue = &"storm_charge"
			message = "Charged spire ahead"
		if cue.is_empty():
			continue
		_emitted_zone_cues[key] = true
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.HAZARD_CUE,
			Vector2(bounds.position.x, bounds.get_center().y),
			message,
			{"cue": cue, "lead_pixels": lead},
		))


func _emit_storm_gust_cue(events: Array[SimulationEvent]) -> void:
	if distance_pixels < ZoneMechanics.FIRST_GUST_PIXELS or \
			distance_pixels >= ZoneMechanics.STORM_END_PIXELS:
		return
	var current := ZoneMechanics.gust_strength(
		distance_pixels, _course_seed, tick)
	var previous := ZoneMechanics.gust_strength(
		distance_pixels, _course_seed, tick - 1)
	if current < 0.16 or previous >= 0.16:
		return
	var distance_cell := floori(
		(distance_pixels - ZoneMechanics.STORM_START_PIXELS) / 960.0)
	var phase_tick := tick + CourseMotion.phase_offset_ticks(
		distance_cell, _course_seed, ZoneMechanics.GUST_PERIOD_TICKS, 41)
	var cycle := floori(float(phase_tick) / \
		float(ZoneMechanics.GUST_PERIOD_TICKS))
	var key := "storm_gust:%d:%d" % [distance_cell, cycle]
	if _emitted_zone_cues.has(key):
		return
	_emitted_zone_cues[key] = true
	events.append(SimulationEvent.make(
		SimulationEvent.Kind.HAZARD_CUE,
		position + Vector2(760.0, -80.0),
		"Gust rising",
		{"cue": &"storm_gust", "lead_pixels": 760.0},
	))


func left_kill_boundary() -> float:
	if not bird_enabled():
		return -1000000000.0
	return bird_position.x + BIRD_CONTACT_LEAD_X


func bird_enabled() -> bool:
	return config != null and config.bird_speed > 0.0


func bird_gap() -> float:
	if not bird_enabled():
		return INF
	return position.x - left_kill_boundary()


func _reset_bird_state() -> void:
	_bird_flap_clock = 0
	bird_flap_phase = 0.0
	bird_closing = false
	if not bird_enabled():
		bird_position = Vector2(
			position.x - config.bird_start_offset - BIRD_CONTACT_LEAD_X,
			position.y,
		)
		bird_velocity = Vector2.ZERO
		bird_flap_rate = 0.0
		return
	bird_position = Vector2(
		position.x - config.bird_start_offset - BIRD_CONTACT_LEAD_X,
		position.y,
	)
	bird_velocity = Vector2(config.bird_speed_at(distance_pixels), 0.0)
	bird_flap_rate = 1.15


## Advance the visible kill line as authoritative world state. X follows only
## its own position law; Y is a critically damped pursuit of player height.
## The flap clock uses integer fixed-tick units so replay paths cannot drift.
func _advance_bird(delta: float) -> void:
	if not bird_enabled():
		bird_velocity = Vector2.ZERO
		bird_flap_rate = 0.0
		bird_flap_phase = 0.0
		bird_closing = false
		return
	bird_velocity.x = config.bird_speed_at(distance_pixels)
	bird_position.x += bird_velocity.x * delta

	var target_y := clampf(position.y, 150.0, config.lower_world_boundary - 110.0)
	var vertical_acceleration := \
		(target_y - bird_position.y) * BIRD_VERTICAL_STIFFNESS \
		- bird_velocity.y * BIRD_VERTICAL_DAMPING
	bird_velocity.y = clampf(
		bird_velocity.y + vertical_acceleration * delta,
		-BIRD_MAXIMUM_VERTICAL_SPEED,
		BIRD_MAXIMUM_VERTICAL_SPEED,
	)
	bird_position.y += bird_velocity.y * delta

	var gap := maxf(0.0, bird_gap())
	var closing_speed := bird_velocity.x - velocity.x
	bird_closing = closing_speed > 5.0 or \
		gap < config.bird_start_offset * 0.55
	var gap_danger := 1.0 - clampf(
		(gap - 100.0) / maxf(config.bird_start_offset, 1.0), 0.0, 1.0)
	var closing_danger := clampf(closing_speed / 240.0, 0.0, 1.0)
	var danger := maxf(gap_danger, closing_danger)
	bird_flap_rate = lerpf(1.15, 5.0, danger)
	if not bird_closing and gap > config.bird_start_offset * 0.85:
		bird_flap_rate = 0.70
	_bird_flap_clock = posmod(
		_bird_flap_clock + roundi(bird_flap_rate * 1000.0),
		BIRD_FLAP_CLOCK_UNITS,
	)
	bird_flap_phase = float(_bird_flap_clock) / \
		float(BIRD_FLAP_CLOCK_UNITS)


func nearest_solid_point(target: Vector2) -> Dictionary:
	var best_distance := INF
	var best := Vector2.ZERO
	var best_kind: StringName = &""
	var best_source_kind: StringName = &""
	var best_source_key := ""
	var best_anchor_class: StringName = CourseGeometry.ANCHOR_FIXED
	var best_motion_spec: Dictionary = {}
	for index in range(surfaces.size()):
		var source_key := _surface_source_keys[index]
		if _spent_anchor_sources.has(source_key):
			continue
		var candidate := SolidGeometry.closest_point_on_polygon(
			target, surfaces[index])
		if bool(candidate["found"]) and float(candidate["distance"]) < best_distance:
			best_distance = float(candidate["distance"])
			best = candidate["point"]
			best_kind = &"surface"
			best_source_kind = &"surface"
			best_source_key = source_key
			best_anchor_class = surface_anchor_classes[index]
			best_motion_spec = _surface_motion_specs[index].duplicate(true)
	if config.course_boundaries_enabled:
		for surface: PackedVector2Array in boundary_surfaces:
			var candidate := SolidGeometry.closest_point_on_polygon(target, surface)
			if bool(candidate["found"]) and float(candidate["distance"]) < best_distance:
				best_distance = float(candidate["distance"])
				best = candidate["point"]
				best_kind = &"boundary"
				best_source_kind = &""
				best_source_key = ""
				best_anchor_class = CourseGeometry.ANCHOR_FIXED
				best_motion_spec = {}
	for index in range(obstacles.size()):
		# Floor-grown hazards are lethal but not tappable. A release tap and a
		# web tap are aimed at the same area, so a hazard rising from the floor
		# just below the spider used to convert releases into Dive Pulls. Only
		# the anchor search skips them; `_collision_at` still sees every
		# obstacle, so nothing became safe to touch.
		if not _obstacle_anchorable(index) or \
				(index < _obstacle_active.size() and _obstacle_active[index] == 0):
			continue
		var source_key := _obstacle_source_keys[index]
		if _spent_anchor_sources.has(source_key):
			continue
		var candidate := SolidGeometry.closest_point_on_polygon(
			target, obstacles[index])
		if bool(candidate["found"]) and float(candidate["distance"]) < best_distance:
			best_distance = float(candidate["distance"])
			best = candidate["point"]
			best_kind = &"obstacle"
			best_source_kind = &"obstacle"
			best_source_key = source_key
			best_anchor_class = obstacle_anchor_classes[index]
			best_motion_spec = _obstacle_motion_specs[index].duplicate(true)
	return {
		"found": best_distance <= config.surface_snap_distance,
		"anchor": best,
		"distance": best_distance,
		"kind": best_kind,
		"source_kind": best_source_kind,
		"source_key": best_source_key,
		"anchor_class": best_anchor_class,
		"motion_spec": best_motion_spec,
	}


func _obstacle_anchorable(index: int) -> bool:
	if index < 0 or index >= obstacle_anchorable.size():
		return true
	return obstacle_anchorable[index] != 0


func _collides_with_obstacle(center: Vector2) -> bool:
	return bool(_collision_at(center)["found"])


func _collision_at(center: Vector2, motion_fraction: float = 0.0) -> Dictionary:
	for index in range(obstacles.size()):
		var obstacle := _obstacle_polygon_at(index, motion_fraction)
		if obstacle.is_empty():
			continue
		if not SolidGeometry.circle_intersects_polygon(
			center,
			config.player_collision_radius,
			obstacle,
		):
			continue
		return _collision_details(center, obstacle, &"obstacle")
	if config.course_boundaries_enabled and config.course_boundaries_lethal:
		for boundary: PackedVector2Array in boundary_surfaces:
			if not SolidGeometry.circle_intersects_polygon(
				center,
				config.player_collision_radius,
				boundary,
			):
				continue
			return _collision_details(center, boundary, &"boundary")
	return {
		"found": false,
		"position": center,
		"surface_point": center,
		"normal": Vector2.ZERO,
		"kind": &"",
	}


func _obstacle_polygon_at(
	index: int,
	motion_fraction: float,
) -> PackedVector2Array:
	var current_active := index >= _obstacle_active.size() or \
		_obstacle_active[index] != 0
	var next_active := index >= _next_obstacle_active.size() or \
		_next_obstacle_active[index] != 0
	if not current_active and not next_active:
		return PackedVector2Array()
	if not current_active:
		return _next_obstacles[index]
	if not next_active:
		return obstacles[index]
	var current := obstacles[index]
	var next := _next_obstacles[index]
	if current.size() != next.size() or is_zero_approx(motion_fraction):
		return current
	var polygon := PackedVector2Array()
	for point_index in range(current.size()):
		polygon.append(current[point_index].lerp(
			next[point_index], clampf(motion_fraction, 0.0, 1.0)))
	return polygon


func _collision_details(
	center: Vector2,
	polygon: PackedVector2Array,
	kind: StringName,
) -> Dictionary:
	var nearest := SolidGeometry.closest_point_on_polygon(center, polygon)
	var surface_point: Vector2 = nearest["point"]
	var normal := center - surface_point
	if normal.length_squared() <= 0.000001:
		normal = -velocity.normalized()
	else:
		normal = normal.normalized()
	if normal.dot(velocity) > 0.0:
		normal = -normal
	return {
		"found": true,
		"position": center,
		"surface_point": surface_point,
		"normal": normal,
		"kind": kind,
	}


func _first_obstacle_contact(start: Vector2, finish: Vector2) -> Dictionary:
	if rescue_shield_remaining > 0.0:
		return {"found": false, "position": finish}
	var motion := finish - start
	var maximum_step := maxf(config.player_collision_radius * 0.5, 4.0)
	var sweep_length := maxf(motion.length(), _maximum_obstacle_motion())
	var samples := maxi(1, ceili(sweep_length / maximum_step))
	for sample in range(1, samples + 1):
		var progress := float(sample) / float(samples)
		var candidate := start.lerp(finish, progress)
		var collision := _collision_at(candidate, progress)
		if bool(collision["found"]):
			collision["position"] = candidate
			return collision
	return {
		"found": false,
		"position": finish,
		"surface_point": finish,
		"normal": Vector2.ZERO,
		"kind": &"",
	}


func _maximum_obstacle_motion() -> float:
	var maximum := 0.0
	for index in range(mini(obstacles.size(), _next_obstacles.size())):
		var current := obstacles[index]
		var next := _next_obstacles[index]
		if current.size() != next.size():
			continue
		for point_index in range(current.size()):
			maximum = maxf(
				maximum,
				current[point_index].distance_to(next[point_index]),
			)
	return maximum


func _try_surface_bounce(
	contact: Dictionary,
	events: Array[SimulationEvent],
) -> bool:
	if not config.surface_bounce_enabled or not surface_bounce_ready:
		return false
	var normal := Vector2(contact["normal"])
	if normal.length_squared() <= 0.000001:
		return false
	var impact_speed := maxf(0.0, -velocity.dot(normal))
	if impact_speed > config.surface_bounce_max_impact_speed:
		return false
	var reflected := velocity.bounce(normal)
	var returned_speed := maxf(
		impact_speed * config.surface_bounce_retention,
		config.surface_bounce_minimum_speed,
	)
	var tangent := reflected - normal * reflected.dot(normal)
	velocity = (
		tangent * config.surface_bounce_tangent_retention
		+ normal * returned_speed
	)
	surface_bounce_ready = false
	web.release()
	_clear_web_anchor_binding(true)
	events.append(SimulationEvent.make(
		SimulationEvent.Kind.SURFACE_BOUNCED,
		contact["surface_point"],
		"Impact shell spent · attach an upper web to recharge",
		{
			"impact_speed": impact_speed,
			"bounce_speed": returned_speed,
			"normal_x": normal.x,
			"normal_y": normal.y,
		},
	))
	return true


func _consume(
	command: InputCommand,
	events: Array[SimulationEvent],
) -> void:
	match command.kind:
		InputCommand.Kind.ATTACH:
			_consume_web_tap(command.world_target, events)
		InputCommand.Kind.RELEASE:
			_release_web(events)
		InputCommand.Kind.REEL_START:
			if pull_active or not web.attached:
				events.append(SimulationEvent.make(
					SimulationEvent.Kind.REEL_UNAVAILABLE,
					position,
					"Attach a web before Reel-In",
				))
			else:
				var was_reeling := web.reel_active
				var reel_velocity_before := velocity
				velocity = web.engage_reel(position, velocity, config)
				if not was_reeling and web.reel_active:
					events.append(SimulationEvent.make(
						SimulationEvent.Kind.REEL_STARTED,
						web.anchor,
						"Reel shortening",
						{
							"origin_x": position.x,
							"origin_y": position.y,
							"velocity_before_x": reel_velocity_before.x,
							"velocity_before_y": reel_velocity_before.y,
							"velocity_after_x": velocity.x,
							"velocity_after_y": velocity.y,
						},
					))
		InputCommand.Kind.REEL_STOP:
			web.set_reel_active(false)
		InputCommand.Kind.BURST:
			_consume_burst(command, events)


func _consume_web_tap(
	world_target: Vector2,
	events: Array[SimulationEvent],
) -> void:
	var nearest := nearest_solid_point(world_target)
	if pull_active:
		if not bool(nearest["found"]):
			events.append(SimulationEvent.make(
				SimulationEvent.Kind.INVALID_TARGET,
				world_target,
				"No solid surface near that recovery tap",
			))
			return
		var recovery_anchor: Vector2 = nearest["anchor"]
		if _is_downward_target(recovery_anchor):
			_interrupt_pull(events)
			return
		_try_attach(
			recovery_anchor,
			events,
			StringName(nearest["kind"]),
			true,
			false,
			nearest,
		)
		return

	if web.attached:
		if bool(nearest["found"]) and _is_downward_target(nearest["anchor"]):
			_try_start_dive(nearest["anchor"], events)
			return
		if bool(nearest["found"]) and \
				config.web_tap_retargets_when_attached:
			_try_attach(
				nearest["anchor"],
				events,
				StringName(nearest["kind"]),
				false,
				true,
				nearest,
			)
			return
		_release_web(events)
		return

	if not bool(nearest["found"]):
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.INVALID_TARGET,
			world_target,
			"No solid surface near that tap",
		))
		return
	var selected_anchor: Vector2 = nearest["anchor"]
	if _is_downward_target(selected_anchor):
		_try_start_dive(selected_anchor, events)
		return
	_try_attach(
		selected_anchor,
		events,
		StringName(nearest["kind"]),
		false,
		false,
		nearest,
	)


func _try_attach(
	selected_anchor: Vector2,
	events: Array[SimulationEvent],
	surface_kind: StringName = &"",
	recovery: bool = false,
	retarget: bool = false,
	anchor_metadata: Dictionary = {},
) -> void:
	var result := web.try_attach(position, selected_anchor, config)
	match result:
		WebConstraint.AttachResult.ATTACHED:
			_bind_web_anchor(anchor_metadata, selected_anchor)
			if recovery:
				_interrupt_pull(events, false)
			var dive_rearmed := not dive_ready
			var bounce_rearmed := (
				config.surface_bounce_enabled and not surface_bounce_ready
			)
			dive_ready = true
			surface_bounce_ready = config.surface_bounce_enabled
			glide_remaining = config.glide_duration
			var timed_anchor := _web_anchor_class in [
				CourseGeometry.ANCHOR_ROTTEN,
				CourseGeometry.ANCHOR_COLLAPSING,
			]
			var message := "Recovery web attached" if recovery else (
				"Web retargeted" if retarget else "Web attached")
			if timed_anchor:
				message = "Weak span holding · release before it breaks"
			if dive_rearmed:
				message += " · Dive ready"
			if bounce_rearmed:
				message += " · shell recharged"
			events.append(SimulationEvent.make(
				SimulationEvent.Kind.ATTACHED,
				selected_anchor,
				message,
				{
					"interrupted_pull": recovery,
					"retargeted": retarget,
					"surface_kind": surface_kind,
					"anchor_class": _web_anchor_class,
					"dive_rearmed": dive_rearmed,
					"surface_bounce_rearmed": bounce_rearmed,
				},
			))
			if timed_anchor:
				events.append(SimulationEvent.make(
					SimulationEvent.Kind.HAZARD_CUE,
					selected_anchor,
					"The anchor cracks",
					{
						"cue": &"rotten_crack",
						"lifetime_ticks": maxi(
							0, _web_anchor_expiry_tick - tick),
					},
				))
		WebConstraint.AttachResult.OUT_OF_RANGE:
			events.append(SimulationEvent.make(
				SimulationEvent.Kind.OUT_OF_RANGE,
				selected_anchor,
				"Solid target out of range",
			))
		_:
			events.append(SimulationEvent.make(
				SimulationEvent.Kind.INVALID_TARGET,
				selected_anchor,
				"Target outside attachment cone",
			))


func _interrupt_pull(
	events: Array[SimulationEvent],
	emit_cancel_feedback: bool = true,
) -> void:
	if not pull_active:
		return
	velocity = _pull_tangential_velocity + _pull_direction * _pull_exit_speed
	var interrupted_kind := pull_kind
	_cancel_pull(false)
	if emit_cancel_feedback:
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.RELEASED,
			position,
			"%s cancelled" % (
				"Dive Pull" if interrupted_kind == &"dive" else "Anchor Burst"),
			{"interrupted_pull": true, "pull_kind": interrupted_kind},
		))


func _consume_burst(
	command: InputCommand,
	events: Array[SimulationEvent],
) -> void:
	if pull_active:
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.BURST_UNAVAILABLE,
			position,
			"Pull already active",
		))
		return
	var selected_anchor := Vector2.ZERO
	if command.has_world_target:
		var nearest := nearest_solid_point(command.world_target)
		if not bool(nearest["found"]):
			events.append(SimulationEvent.make(
				SimulationEvent.Kind.BURST_UNAVAILABLE,
				command.world_target,
				"No solid target near that double-tap",
			))
			return
		selected_anchor = nearest["anchor"]
	elif web.attached:
		selected_anchor = web.anchor
	else:
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.BURST_UNAVAILABLE,
			position,
			"Aim with a double-tap or attach first",
		))
		return

	if not _target_within_web_range(selected_anchor):
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.OUT_OF_RANGE,
			selected_anchor,
			"Solid target out of range",
		))
		return
	if _is_downward_target(selected_anchor):
		_try_start_dive(selected_anchor, events)
		return
	if burst_charges <= 0:
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.BURST_UNAVAILABLE,
			position,
			"Anchor Burst recharging",
			{"remaining": burst_cooldown_remaining},
		))
		return
	if _start_pull(
		selected_anchor,
		config.burst_distance_fraction,
		config.burst_pull_duration,
		config.burst_exit_speed,
		config.burst_tangential_retention,
		&"burst",
		config.burst_minimum_distance,
	):
		if not _burst_cooldown_suppressed:
			# A successful Burst alone spends a charge; an already-running
			# refill timer keeps its progress instead of resetting.
			burst_charges = maxi(0, burst_charges - 1)
			if burst_cooldown_remaining <= 0.0:
				burst_cooldown_remaining = config.burst_cooldown
		events.append(_pull_started_event(
			SimulationEvent.Kind.BURST_STARTED,
			selected_anchor,
			"Anchor Burst %.0f%%" % (config.burst_distance_fraction * 100.0),
		))
	else:
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.BURST_UNAVAILABLE,
			selected_anchor,
			"Target is too close for Burst",
		))


func _try_start_dive(
	selected_anchor: Vector2,
	events: Array[SimulationEvent],
) -> void:
	if pull_active:
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.DIVE_UNAVAILABLE,
			selected_anchor,
			"Pull already active",
		))
		return
	if not dive_ready:
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.DIVE_UNAVAILABLE,
			selected_anchor,
			"Attach an upper web before another Dive Pull",
			{"requires_web_contact": true},
		))
		return
	if not _target_within_web_range(selected_anchor):
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.OUT_OF_RANGE,
			selected_anchor,
			"Downward target out of range",
		))
		return
	if _start_pull(
		selected_anchor,
		config.dive_distance_fraction,
		config.dive_pull_duration,
		config.dive_exit_speed,
		config.dive_tangential_retention,
		&"dive",
	):
		dive_ready = false
		events.append(_pull_started_event(
			SimulationEvent.Kind.DIVE_STARTED,
			selected_anchor,
			"Dive Pull %.0f%%" % (config.dive_distance_fraction * 100.0),
		))
	else:
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.DIVE_UNAVAILABLE,
			selected_anchor,
			"Target is too close for Dive Pull",
		))


func _start_pull(
	selected_anchor: Vector2,
	distance_fraction: float,
	duration: float,
	exit_speed: float,
	tangential_retention: float,
	mode: StringName,
	minimum_distance: float = 0.0,
) -> bool:
	var to_anchor := selected_anchor - position
	var anchor_distance := to_anchor.length()
	var maximum_travel := maxf(
		0.0,
		anchor_distance - config.player_collision_radius - PULL_CLEARANCE,
	)
	var requested_travel := minf(
		maxf(anchor_distance * distance_fraction, minimum_distance),
		maximum_travel,
	)
	if requested_travel < 4.0 or duration <= 0.0:
		return false

	_pull_direction = to_anchor / anchor_distance
	var inward_speed := velocity.dot(_pull_direction)
	_pull_tangential_velocity = (
		velocity - _pull_direction * inward_speed
	) * tangential_retention
	_pull_radial_speed = requested_travel / duration
	_pull_exit_speed = exit_speed
	pull_active = true
	pull_kind = mode
	pull_anchor = selected_anchor
	pull_distance_total = requested_travel
	pull_distance_remaining = requested_travel
	pull_duration_remaining = duration
	web.release()
	_clear_web_anchor_binding(true)
	return true


func _advance_pull(
	delta: float,
	events: Array[SimulationEvent],
) -> bool:
	var radial_step := minf(_pull_radial_speed * delta, pull_distance_remaining)
	var proposed := (
		position
		+ _pull_direction * radial_step
		+ _pull_tangential_velocity * delta
	)
	var contact := _first_obstacle_contact(position, proposed)
	if bool(contact["found"]):
		position = contact["position"]
		velocity = Vector2.ZERO
		_cancel_pull()
		events.append(_collision_death_event(contact))
		return true

	position = proposed
	pull_distance_remaining = maxf(0.0, pull_distance_remaining - radial_step)
	pull_duration_remaining = maxf(0.0, pull_duration_remaining - delta)
	if pull_distance_remaining <= 0.001 or pull_duration_remaining <= 0.001:
		velocity = (
			_pull_tangential_velocity
			+ _pull_direction * _pull_exit_speed
		)
		_cancel_pull(false)
	return false


func _cancel_pull(clear_identity: bool = true) -> void:
	pull_active = false
	pull_distance_remaining = 0.0
	pull_duration_remaining = 0.0
	_pull_direction = Vector2.ZERO
	_pull_tangential_velocity = Vector2.ZERO
	_pull_radial_speed = 0.0
	_pull_exit_speed = 0.0
	if clear_identity:
		pull_kind = &""
		pull_anchor = Vector2.ZERO
		pull_distance_total = 0.0


func _release_web(events: Array[SimulationEvent]) -> void:
	if not web.attached:
		return
	var velocity_before := velocity
	var release := web.release_quality(position, velocity)
	var requested_bonus := (
		config.release_momentum_bonus_speed * float(release["quality"])
	)
	# One cap in the game, not two. This used to be the run-wide maximum
	# reference plus overspeed — a flat 1120 px/s — while the motor corrected
	# toward a *distance-local* ceiling, so a release near the start could push
	# to 112 m/s against a limiter aiming at 73 and then be dragged back for
	# seconds. Both now read `spider_speed_cap_at`, so the award stops exactly
	# where the limiter starts and the two can never disagree.
	#
	# The original comment's worry — that a local ceiling would throttle normal
	# opening play — is answered by the cap curve rather than by a second
	# number: its opening value is `starting_target_speed +
	# maximum_horizontal_overspeed`, unchanged at 720 px/s.
	var forward_cap := config.spider_speed_cap_at(distance_pixels)
	var forward_bonus := minf(
		requested_bonus,
		maxf(0.0, forward_cap - velocity.x),
	)
	velocity.x += forward_bonus
	web.release()
	_clear_web_anchor_binding(true)
	events.append(SimulationEvent.make(
		SimulationEvent.Kind.RELEASED,
		position,
		"Rising release carried momentum forward"
			if forward_bonus > 0.001 else "Momentum preserved",
		{
			"release_arc_degrees": rad_to_deg(float(release["arc_radians"])),
			"arc_quality": float(release["arc_quality"]),
			"rise_quality": float(release["rise_quality"]),
			"release_quality": float(release["quality"]),
			"forward_bonus": forward_bonus,
			"velocity_before_x": velocity_before.x,
			"velocity_before_y": velocity_before.y,
			"velocity_after_x": velocity.x,
			"velocity_after_y": velocity.y,
		},
	))


func _is_downward_target(target: Vector2) -> bool:
	return target.y >= position.y + config.downward_target_threshold


func _target_within_web_range(target: Vector2) -> bool:
	var distance := position.distance_to(target)
	return distance >= config.web_minimum_length and \
		distance <= config.web_maximum_length


func _pull_started_event(
	event_kind: int,
	selected_anchor: Vector2,
	message: String,
) -> SimulationEvent:
	var preview := preview_pull(selected_anchor, (
		config.dive_distance_fraction
		if pull_kind == &"dive"
		else config.burst_distance_fraction
	), 0.0 if pull_kind == &"dive" else config.burst_minimum_distance)
	return SimulationEvent.make(
		event_kind,
		selected_anchor,
		message,
		{
			"direction_x": _pull_direction.x,
			"direction_y": _pull_direction.y,
			"origin_x": position.x,
			"origin_y": position.y,
			"travel_distance": pull_distance_total,
			"anchor_distance": position.distance_to(selected_anchor),
			"pull_kind": pull_kind,
			"endpoint_x": Vector2(preview["endpoint"]).x,
			"endpoint_y": Vector2(preview["endpoint"]).y,
			"path_safe": bool(preview["safe"]),
		},
	)


func preview_pull(
	selected_anchor: Vector2,
	distance_fraction: float,
	minimum_distance: float = 0.0,
) -> Dictionary:
	var to_anchor := selected_anchor - position
	var anchor_distance := to_anchor.length()
	if anchor_distance <= 0.001:
		return {"endpoint": position, "safe": false}
	var maximum_travel := maxf(
		0.0,
		anchor_distance - config.player_collision_radius - PULL_CLEARANCE,
	)
	var requested_travel := minf(
		maxf(anchor_distance * distance_fraction, minimum_distance),
		maximum_travel,
	)
	var endpoint := position + to_anchor / anchor_distance * requested_travel
	var contact := _first_obstacle_contact(position, endpoint)
	return {
		"endpoint": endpoint,
		"safe": not bool(contact["found"]),
	}


func _collect_pickups(
	start: Vector2,
	finish: Vector2,
	events: Array[SimulationEvent],
) -> void:
	var remaining_flies := PackedVector2Array()
	for fly: Vector2 in fly_positions:
		if SolidGeometry.distance_to_segment(fly, start, finish) <= \
				config.pickup_collision_radius:
			_collected_pickups[_pickup_key(&"fly", fly)] = true
			run_flies += 1
			events.append(SimulationEvent.make(
				SimulationEvent.Kind.FLY_COLLECTED,
				fly,
				"Fly collected",
				{"run_flies": run_flies},
			))
		else:
			remaining_flies.append(fly)
	fly_positions = remaining_flies

	var remaining_boosts := PackedVector2Array()
	for boost: Vector2 in boost_positions:
		if SolidGeometry.distance_to_segment(boost, start, finish) <= \
				config.pickup_collision_radius:
			_collected_pickups[_pickup_key(&"boost", boost)] = true
			events.append(SimulationEvent.make(
				SimulationEvent.Kind.BOOST_COLLECTED,
				boost,
				"Burst Frenzy",
			))
		else:
			remaining_boosts.append(boost)
	boost_positions = remaining_boosts


func _pickup_key(kind: StringName, pickup_position: Vector2) -> String:
	return "%s:%d:%d" % [
		kind,
		roundi(pickup_position.x),
		roundi(pickup_position.y),
	]


func _collision_death_event(contact: Dictionary) -> SimulationEvent:
	var cause := StringName(contact.get("kind", &"obstacle"))
	return SimulationEvent.make(
		SimulationEvent.Kind.DEATH_REQUESTED,
		position,
		"Hit the solid ceiling or floor"
			if cause == &"boundary"
			else "Hit a laboratory obstacle",
		{"cause": cause},
	)


func rescue_after_death() -> SimulationEvent:
	web.release()
	_clear_web_anchor_binding(true)
	_cancel_pull()
	burst_cooldown_remaining = 0.0
	burst_charges = config.burst_charge_capacity
	dive_ready = true
	surface_bounce_ready = config.surface_bounce_enabled
	glide_remaining = config.glide_duration
	var rescue_position := _find_rescue_position()
	position = rescue_position
	velocity = Vector2(maxf(300.0, target_speed * 0.88), -110.0)
	# The rescue is the anti-death-spiral valve: it restores both a viable
	# reference launch and the complete configured pursuer gap.
	_reset_bird_gap_after_rescue()
	rescue_shield_remaining = config.rescue_shield_duration
	return SimulationEvent.make(
		SimulationEvent.Kind.RESCUE_USED,
		position,
		"Rescue silk caught you · life spent",
		{
			"shield_seconds": rescue_shield_remaining,
			"rescue_x": position.x,
			"rescue_y": position.y,
		},
	)


func _reset_bird_gap_after_rescue() -> void:
	if not bird_enabled():
		return
	bird_position.x = position.x - config.bird_start_offset - \
		BIRD_CONTACT_LEAD_X
	bird_position.y = lerpf(bird_position.y, position.y, 0.35)
	bird_velocity = Vector2(config.bird_speed_at(distance_pixels), 0.0)


func _find_rescue_position() -> Vector2:
	var base_x := maxf(_run_start_x, position.x - 150.0)
	var candidates := [
		Vector2(base_x, 390.0),
		Vector2(base_x - 90.0, 330.0),
		Vector2(base_x + 90.0, 330.0),
		Vector2(base_x - 90.0, 470.0),
		Vector2(base_x + 90.0, 470.0),
		Vector2(maxf(_run_start_x, base_x - 180.0), 390.0),
	]
	for candidate: Vector2 in candidates:
		if not _collides_with_obstacle(candidate):
			return candidate
	return Vector2(_run_start_x, START_POSITION.y)


func begin_guided_opening() -> bool:
	if not config.guided_start_enabled or \
			not config.course_boundaries_enabled:
		return false
	var target := Vector2(position.x + 280.0, GUIDED_ANCHOR_Y)
	var nearest := nearest_solid_point(target)
	if not bool(nearest["found"]) or StringName(nearest["kind"]) != &"boundary":
		return false
	if web.try_attach(position, nearest["anchor"], config) == \
			WebConstraint.AttachResult.ATTACHED:
		velocity = Vector2(config.target_speed_at(distance_pixels), -40.0)
		return true
	return false

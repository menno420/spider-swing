extends RefCounted
class_name SimulationWorld
## Authoritative fixed-step Phase 0 simulation state.

const START_POSITION := Vector2(220.0, 390.0)
const START_VELOCITY := Vector2(360.0, -30.0)
const PULL_CLEARANCE := 10.0
const GUIDED_ANCHOR_Y := 112.0

var config: SwingConfig
var position: Vector2 = START_POSITION
var velocity: Vector2 = START_VELOCITY
var target_speed: float = 0.0
var distance_pixels: float = 0.0
var furthest_x: float = START_POSITION.x
var tick: int = 0
var anchors: PackedVector2Array = PackedVector2Array()
var surfaces: Array[PackedVector2Array] = []
var boundary_surfaces: Array[PackedVector2Array] = []
var obstacles: Array[PackedVector2Array] = []
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
	run_flies = 0
	_collected_pickups.clear()
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
	anchors = geometry.aim_guides.duplicate()
	surfaces.clear()
	for surface: PackedVector2Array in geometry.surfaces:
		surfaces.append(surface.duplicate())
	boundary_surfaces.clear()
	for surface: PackedVector2Array in geometry.boundary_surfaces:
		boundary_surfaces.append(surface.duplicate())
	obstacles.clear()
	for obstacle: PackedVector2Array in geometry.obstacles:
		obstacles.append(obstacle.duplicate())
	fly_positions.clear()
	for fly: Vector2 in geometry.fly_positions:
		if not _collected_pickups.has(_pickup_key(&"fly", fly)):
			fly_positions.append(fly)
	boost_positions.clear()
	for boost: Vector2 in geometry.boost_positions:
		if not _collected_pickups.has(_pickup_key(&"boost", boost)):
			boost_positions.append(boost)


func set_burst_cooldown_suppressed(active: bool) -> void:
	_burst_cooldown_suppressed = active
	if active:
		burst_cooldown_remaining = 0.0
		burst_charges = config.burst_charge_capacity


func queue_command(command: InputCommand) -> void:
	_commands.append(command)


func step(delta: float) -> Array[SimulationEvent]:
	var events: Array[SimulationEvent] = []
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

		if web.advance_resource(delta, config):
			events.append(SimulationEvent.make(
				SimulationEvent.Kind.REEL_EMPTY,
				position,
				"Reel energy empty",
			))

		var constraint_result := web.solve(position, velocity, delta, config)
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
	tick += 1

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
			"Lost behind the camera",
			{"cause": &"camera_boundary"},
		))
	return events


func left_kill_boundary() -> float:
	return furthest_x - config.camera_left_kill_distance


func nearest_solid_point(target: Vector2) -> Dictionary:
	var best_distance := INF
	var best := Vector2.ZERO
	var best_kind: StringName = &""
	for surface: PackedVector2Array in surfaces:
		var candidate := SolidGeometry.closest_point_on_polygon(target, surface)
		if bool(candidate["found"]) and float(candidate["distance"]) < best_distance:
			best_distance = float(candidate["distance"])
			best = candidate["point"]
			best_kind = &"surface"
	if config.course_boundaries_enabled:
		for surface: PackedVector2Array in boundary_surfaces:
			var candidate := SolidGeometry.closest_point_on_polygon(target, surface)
			if bool(candidate["found"]) and float(candidate["distance"]) < best_distance:
				best_distance = float(candidate["distance"])
				best = candidate["point"]
				best_kind = &"boundary"
	for obstacle: PackedVector2Array in obstacles:
		var candidate := SolidGeometry.closest_point_on_polygon(target, obstacle)
		if bool(candidate["found"]) and float(candidate["distance"]) < best_distance:
			best_distance = float(candidate["distance"])
			best = candidate["point"]
			best_kind = &"obstacle"
	return {
		"found": best_distance <= config.surface_snap_distance,
		"anchor": best,
		"distance": best_distance,
		"kind": best_kind,
	}


func _collides_with_obstacle(center: Vector2) -> bool:
	return bool(_collision_at(center)["found"])


func _collision_at(center: Vector2) -> Dictionary:
	for obstacle: PackedVector2Array in obstacles:
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
	var samples := maxi(1, ceili(motion.length() / maximum_step))
	for sample in range(1, samples + 1):
		var candidate := start.lerp(finish, float(sample) / float(samples))
		var collision := _collision_at(candidate)
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
	)


func _try_attach(
	selected_anchor: Vector2,
	events: Array[SimulationEvent],
	surface_kind: StringName = &"",
	recovery: bool = false,
	retarget: bool = false,
) -> void:
	var result := web.try_attach(position, selected_anchor, config)
	match result:
		WebConstraint.AttachResult.ATTACHED:
			if recovery:
				_interrupt_pull(events, false)
			var dive_rearmed := not dive_ready
			var bounce_rearmed := (
				config.surface_bounce_enabled and not surface_bounce_ready
			)
			dive_ready = true
			surface_bounce_ready = config.surface_bounce_enabled
			glide_remaining = config.glide_duration
			var message := "Recovery web attached" if recovery else (
				"Web retargeted" if retarget else "Web attached")
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
					"dive_rearmed": dive_rearmed,
					"surface_bounce_rearmed": bounce_rearmed,
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
	web.release()
	events.append(SimulationEvent.make(
		SimulationEvent.Kind.RELEASED,
		position,
		"Momentum preserved",
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
	_cancel_pull()
	burst_cooldown_remaining = 0.0
	burst_charges = config.burst_charge_capacity
	dive_ready = true
	surface_bounce_ready = config.surface_bounce_enabled
	glide_remaining = config.glide_duration
	var rescue_position := _find_rescue_position()
	position = rescue_position
	velocity = Vector2(maxf(300.0, target_speed * 0.88), -110.0)
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

extends RefCounted
class_name Phase0PhysicsTests
## Deterministic regression suite for GDD Phase 0 contracts.

const FIXED_DELTA := 1.0 / 60.0
const TRACE_PATH := "res://tests/fixtures/phase0_trace.json"


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0

	passed += _test_presets(failures)
	passed += _test_release_preserves_velocity(failures)
	passed += _test_reel_shortens_without_teleport(failures)
	passed += _test_reel_does_not_add_speed(failures)
	passed += _test_detached_reel_reports_unavailable(failures)
	passed += _test_invalid_target_is_inert(failures)
	passed += _test_continuous_surface_attachment(failures)
	passed += _test_aim_forgiveness_extends_beyond_old_band(failures)
	passed += _test_extended_web_reach(failures)
	passed += _test_burst_crosses_configured_fraction(failures)
	passed += _test_downward_web_is_a_short_one_shot_pull(failures)
	passed += _test_obstacle_is_a_valid_anchor(failures)
	passed += _test_pull_tuning_controls(failures)
	passed += _test_course_stream_is_endless_and_bounded(failures)
	passed += _test_obstacle_collision_is_authoritative(failures)
	passed += _test_attach_release_does_not_inject_energy(failures)
	passed += _test_top_is_not_lethal(failures)
	passed += _test_lower_boundary_is_lethal(failures)
	passed += _test_render_rate_independence(failures)

	return {"passed": passed, "failures": failures}


static func _test_presets(failures: PackedStringArray) -> int:
	for name: StringName in SwingConfig.preset_names():
		var config := SwingConfig.from_preset(name)
		if not config.validate().is_empty():
			failures.append("preset %s fails validation: %s" % [
				name, ", ".join(config.validate())])
			return 0
	return 1


static func _test_release_preserves_velocity(failures: PackedStringArray) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	var geometry := _test_geometry()
	var released := SimulationWorld.new()
	var control := SimulationWorld.new()
	released.reset(config, geometry)
	control.reset(config, geometry)
	released.velocity = Vector2(512.0, -147.0)
	control.velocity = released.velocity
	released.web.try_attach(released.position, Vector2(480.0, 150.0), config)
	released.queue_command(InputCommand.release(1, 0))
	released.step(FIXED_DELTA)
	control.step(FIXED_DELTA)
	if released.velocity.distance_to(control.velocity) > 0.001:
		failures.append("release changed velocity: released=%s control=%s" % [
			released.velocity, control.velocity])
		return 0
	return 1


static func _test_reel_shortens_without_teleport(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	var geometry := _test_geometry()
	var world := SimulationWorld.new()
	world.reset(config, geometry)
	world.web.try_attach(world.position, Vector2(480.0, 150.0), config)
	var length_before := world.web.rope_length
	var position_before := world.position
	world.queue_command(InputCommand.reel(true, 1, 0))
	world.step(FIXED_DELTA)
	var expected := config.reel_retraction_rate * FIXED_DELTA
	var actual := length_before - world.web.rope_length
	if absf(actual - expected) > 0.001:
		failures.append("Reel shortened %.4f, expected %.4f" % [actual, expected])
		return 0
	var maximum_motion := (
		world.velocity.length() * FIXED_DELTA
		+ config.attachment_correction_cap * FIXED_DELTA
		+ 1.0
	)
	if world.position.distance_to(position_before) > maximum_motion:
		failures.append("Reel teleported the spider by %.3f px" %
			world.position.distance_to(position_before))
		return 0
	return 1


static func _test_reel_does_not_add_speed(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	var geometry := _test_geometry()
	var reeled := SimulationWorld.new()
	var control := SimulationWorld.new()
	reeled.reset(config, geometry)
	control.reset(config, geometry)
	reeled.position = Vector2(220.0, 600.0)
	control.position = reeled.position
	reeled.velocity = Vector2(380.0, 260.0)
	control.velocity = reeled.velocity
	var anchor := Vector2(480.0, 150.0)
	reeled.web.try_attach(reeled.position, anchor, config)
	control.web.try_attach(control.position, anchor, config)
	var speed_before := reeled.velocity.length()
	reeled.queue_command(InputCommand.reel(true, 1, 0))
	var events := reeled.step(FIXED_DELTA)
	control.step(FIXED_DELTA)
	if reeled.velocity.length() > maxf(speed_before, control.velocity.length()) + 0.01:
		failures.append("Reel added speed instead of only shortening the rope")
		return 0
	if reeled.web.rope_length >= control.web.rope_length:
		failures.append("Reel did not shorten the rope on its first tick")
		return 0
	if not _contains_event(events, SimulationEvent.Kind.REEL_STARTED):
		failures.append("Reel shortening emitted no success feedback event")
		return 0
	reeled.queue_command(InputCommand.reel(true, 2, reeled.tick))
	events = reeled.step(FIXED_DELTA)
	if _contains_event(events, SimulationEvent.Kind.REEL_STARTED):
		failures.append("held Reel emitted duplicate success feedback")
		return 0
	return 1


static func _test_detached_reel_reports_unavailable(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var world := SimulationWorld.new()
	world.reset(config, _test_geometry())
	var energy_before := world.web.reel_energy
	world.queue_command(InputCommand.reel(true, 1, 0))
	var events := world.step(FIXED_DELTA)
	if world.web.reel_active:
		failures.append("detached Reel incorrectly became active")
		return 0
	if absf(world.web.reel_energy - energy_before) > 0.001:
		failures.append("detached Reel consumed energy")
		return 0
	if not _contains_event(events, SimulationEvent.Kind.REEL_UNAVAILABLE):
		failures.append("detached Reel emitted no attach-first feedback")
		return 0
	return 1


static func _test_invalid_target_is_inert(failures: PackedStringArray) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var geometry := _test_geometry()
	var invalid := SimulationWorld.new()
	var control := SimulationWorld.new()
	invalid.reset(config, geometry)
	control.reset(config, geometry)
	invalid.queue_command(InputCommand.attach(Vector2(900.0, 650.0), 1, 0))
	var events := invalid.step(FIXED_DELTA)
	control.step(FIXED_DELTA)
	if invalid.web.attached:
		failures.append("invalid target created a constraint")
		return 0
	if invalid.position.distance_to(control.position) > 0.001 or \
			invalid.velocity.distance_to(control.velocity) > 0.001:
		failures.append("invalid target altered trajectory")
		return 0
	if not _contains_event(events, SimulationEvent.Kind.INVALID_TARGET):
		failures.append("invalid target emitted no feedback event")
		return 0
	return 1


static func _test_continuous_surface_attachment(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var world := SimulationWorld.new()
	world.reset(config, _test_geometry())
	var target := Vector2(537.0, 154.0)
	world.queue_command(InputCommand.attach(target, 1, 0))
	var events := world.step(FIXED_DELTA)
	if not world.web.attached:
		failures.append("an arbitrary point on the ceiling surface did not attach")
		return 0
	if absf(world.web.anchor.x - target.x) > 0.001 or \
			absf(world.web.anchor.y - 150.0) > 0.001:
		failures.append("surface attachment snapped to a guide instead of the tap")
		return 0
	if not _contains_event(events, SimulationEvent.Kind.ATTACHED):
		failures.append("surface attachment emitted no ATTACHED event")
		return 0
	return 1


static func _test_aim_forgiveness_extends_beyond_old_band(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var world := SimulationWorld.new()
	world.reset(config, _test_geometry())
	var target := Vector2(537.0, 340.0)
	if target.distance_to(Vector2(target.x, 150.0)) <= 170.0:
		failures.append("aim-forgiveness fixture does not exceed the old band")
		return 0
	world.queue_command(InputCommand.attach(target, 1, 0))
	world.step(FIXED_DELTA)
	if not world.web.attached:
		failures.append("a near-ceiling tap inside the larger aim band was rejected")
		return 0
	if world.web.anchor.distance_to(Vector2(target.x, 150.0)) > 0.001:
		failures.append("forgiven ceiling tap resolved to the wrong solid point")
		return 0
	return 1


static func _test_extended_web_reach(failures: PackedStringArray) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var world := SimulationWorld.new()
	world.reset(config, _test_geometry())
	var target := Vector2(950.0, 150.0)
	if target.distance_to(world.position) <= 620.0:
		failures.append("extended-reach fixture does not exceed the old limit")
		return 0
	world.queue_command(InputCommand.attach(target, 1, 0))
	var events := world.step(FIXED_DELTA)
	if not world.web.attached:
		failures.append("natural forward target beyond the old range did not attach")
		return 0
	if world.web.rope_length > config.web_maximum_length:
		failures.append("extended attachment exceeded the configured range")
		return 0
	if not _contains_event(events, SimulationEvent.Kind.ATTACHED):
		failures.append("extended attachment emitted no ATTACHED event")
		return 0
	return 1


static func _test_burst_crosses_configured_fraction(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	config.maximum_horizontal_overspeed = 2000.0
	var world := SimulationWorld.new()
	world.reset(config, _test_geometry())
	var anchor := Vector2(640.0, 150.0)
	var origin := world.position
	world.velocity = Vector2(120.0, 90.0)
	var pull_direction := (anchor - world.position).normalized()
	var anchor_distance := origin.distance_to(anchor)
	world.queue_command(InputCommand.burst_at(anchor, 1, 0))
	var events := world.step(FIXED_DELTA)
	if world.web.attached:
		failures.append("targeted Burst incorrectly left a persistent web")
		return 0
	if not world.pull_active:
		failures.append("detached targeted Burst did not start atomically")
		return 0
	if not _contains_event(events, SimulationEvent.Kind.BURST_STARTED):
		failures.append("targeted Burst emitted no success event")
		return 0
	var safety := 0
	while world.pull_active and safety < 60:
		world.step(FIXED_DELTA)
		safety += 1
	if world.pull_active:
		failures.append("Burst did not finish within its configured duration")
		return 0
	var expected_travel := anchor_distance * config.burst_distance_fraction
	var actual_travel := (world.position - origin).dot(pull_direction)
	if absf(actual_travel - expected_travel) > 0.75:
		failures.append("Burst crossed %.2f px, expected %.2f px (%.0f%%)" % [
			actual_travel,
			expected_travel,
			config.burst_distance_fraction * 100.0,
		])
		return 0
	if absf(world.velocity.dot(pull_direction) - config.burst_exit_speed) > 0.01:
		failures.append("Burst exit speed is not predictable")
		return 0
	var position_after := world.position
	world.queue_command(InputCommand.burst(2, world.tick))
	events = world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.BURST_UNAVAILABLE):
		failures.append("Burst cooldown did not reject a repeated activation")
		return 0
	if world.pull_active or world.position.distance_to(position_after) > \
			world.velocity.length() * FIXED_DELTA + 0.1:
		failures.append("rejected Burst still started a pull")
		return 0

	var detached := SimulationWorld.new()
	detached.reset(config, _test_geometry())
	detached.queue_command(InputCommand.burst(1, 0))
	events = detached.step(FIXED_DELTA)
	if detached.burst_cooldown_remaining > 0.0:
		failures.append("untargeted detached Burst started its cooldown")
		return 0
	if not _contains_event(events, SimulationEvent.Kind.BURST_UNAVAILABLE):
		failures.append("untargeted detached Burst emitted no aiming feedback")
		return 0
	return 1


static func _test_downward_web_is_a_short_one_shot_pull(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	var geometry := _test_geometry()
	geometry.surfaces.append(_rectangle_polygon(Rect2(260.0, 570.0, 520.0, 42.0)))
	var world := SimulationWorld.new()
	world.reset(config, geometry)
	world.velocity = Vector2(300.0, -80.0)
	var origin := world.position
	var target := Vector2(560.0, 570.0)
	var resolved_anchor := Vector2(target.x, 570.0)
	var direction := (resolved_anchor - origin).normalized()
	var anchor_distance := origin.distance_to(resolved_anchor)
	world.queue_command(InputCommand.attach(target, 1, 0))
	var events := world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.DIVE_STARTED):
		failures.append("downward single tap did not start a Dive Pull")
		return 0
	if world.web.attached:
		failures.append("downward web incorrectly stayed attached")
		return 0
	var safety := 0
	while world.pull_active and safety < 60:
		world.step(FIXED_DELTA)
		safety += 1
	var expected_travel := anchor_distance * config.dive_distance_fraction
	var actual_travel := (world.position - origin).dot(direction)
	if absf(actual_travel - expected_travel) > 0.75:
		failures.append("Dive Pull crossed %.2f px, expected %.2f px (%.0f%%)" % [
			actual_travel,
			expected_travel,
			config.dive_distance_fraction * 100.0,
		])
		return 0
	if world.web.attached or world.pull_active:
		failures.append("Dive Pull left a persistent rope or pull state")
		return 0
	return 1


static func _test_obstacle_is_a_valid_anchor(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var geometry := _test_geometry()
	var obstacle := PackedVector2Array([
		Vector2(520.0, 210.0),
		Vector2(680.0, 230.0),
		Vector2(620.0, 320.0),
	])
	geometry.obstacles.append(obstacle)
	var world := SimulationWorld.new()
	world.reset(config, geometry)
	world.queue_command(InputCommand.attach(Vector2(600.0, 225.0), 1, 0))
	var events := world.step(FIXED_DELTA)
	if not world.web.attached:
		failures.append("an upper solid obstacle was not accepted as an anchor")
		return 0
	if not _contains_event(events, SimulationEvent.Kind.ATTACHED):
		failures.append("obstacle attachment emitted no ATTACHED event")
		return 0
	return 1


static func _test_pull_tuning_controls(failures: PackedStringArray) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var burst_before := config.burst_distance_fraction
	var dive_before := config.dive_distance_fraction
	var reel_before := config.reel_retraction_rate
	config.adjust(&"burst_pull_pct", 1.0)
	config.adjust(&"dive_pull_pct", -1.0)
	config.adjust(&"reel_rate", 1.0)
	if absf(config.burst_distance_fraction - (burst_before + 0.05)) > 0.001:
		failures.append("debug Burst percentage adjustment is not 5%")
		return 0
	if absf(config.dive_distance_fraction - (dive_before - 0.05)) > 0.001:
		failures.append("debug Dive percentage adjustment is not 5%")
		return 0
	if absf(config.reel_retraction_rate - (reel_before + 20.0)) > 0.001:
		failures.append("debug Reel shortening adjustment is not 20 px/s")
		return 0
	for parameter: StringName in [
		&"burst_pull_pct",
		&"dive_pull_pct",
		&"burst_duration",
		&"dive_duration",
		&"reel_rate",
		&"aim_forgiveness",
		&"attach_catch_pct",
	]:
		if parameter not in SwingLabSession.TUNING_PARAMETERS:
			failures.append("debug menu is missing %s" % parameter)
			return 0
	return 1


static func _test_course_stream_is_endless_and_bounded(
	failures: PackedStringArray,
) -> int:
	var stream := CourseStream.new()
	stream.reset()
	var geometry := stream.update_for_position(100000.0)
	var furthest_surface_x := -INF
	for surface: PackedVector2Array in geometry.surfaces:
		furthest_surface_x = maxf(
			furthest_surface_x,
			SolidGeometry.bounds(surface).end.x,
		)
	if geometry.surfaces.is_empty() or furthest_surface_x <= 100000.0:
		failures.append("course stream has no web surface beyond 10,000 m")
		return 0
	if stream.retained_chunk_count() > \
			CourseStream.KEEP_BEHIND + CourseStream.GENERATE_AHEAD + 1:
		failures.append("course stream grows without a bounded chunk window")
		return 0
	if geometry.obstacles.is_empty():
		failures.append("distant streamed chunks contain no test obstacles")
		return 0
	var found_non_rectangular := false
	for obstacle: PackedVector2Array in geometry.obstacles:
		if obstacle.size() != 4:
			found_non_rectangular = true
			break
	if not found_non_rectangular:
		failures.append("streamed obstacle vocabulary is still rectangle-only")
		return 0
	return 1


static func _test_obstacle_collision_is_authoritative(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	var geometry := _test_geometry()
	geometry.obstacles.append(
		_rectangle_polygon(Rect2(300.0, 320.0, 120.0, 150.0)))
	var world := SimulationWorld.new()
	world.reset(config, geometry)
	world.position = Vector2(350.0, 390.0)
	world.velocity = Vector2.ZERO
	var events := world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.DEATH_REQUESTED):
		failures.append("obstacle contact did not request death")
		return 0
	for event: SimulationEvent in events:
		if event.kind == SimulationEvent.Kind.DEATH_REQUESTED and \
				event.data.get("cause", &"") != &"obstacle":
			failures.append("obstacle death reported the wrong cause")
			return 0
	return 1


static func _test_attach_release_does_not_inject_energy(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var web := WebConstraint.new()
	web.reset(config)
	var position := Vector2(220.0, 390.0)
	var anchor := Vector2(480.0, 150.0)
	var velocity := Vector2(530.0, -210.0)
	var energy_before := velocity.length_squared()
	for _index in range(200):
		if web.try_attach(position, anchor, config) != \
				WebConstraint.AttachResult.ATTACHED:
			failures.append("valid repeated attachment unexpectedly failed")
			return 0
		web.release()
	if absf(velocity.length_squared() - energy_before) > 0.0001:
		failures.append("attach/release injected energy")
		return 0
	return 1


static func _test_top_is_not_lethal(failures: PackedStringArray) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var world := SimulationWorld.new()
	world.reset(config, _test_geometry())
	world.position.y = -500.0
	var events := world.step(FIXED_DELTA)
	if _contains_event(events, SimulationEvent.Kind.DEATH_REQUESTED):
		failures.append("top of screen incorrectly requested death")
		return 0
	return 1


static func _test_lower_boundary_is_lethal(failures: PackedStringArray) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var world := SimulationWorld.new()
	world.reset(config, _test_geometry())
	world.position.y = config.lower_world_boundary + 5.0
	var events := world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.DEATH_REQUESTED):
		failures.append("lower boundary did not request death")
		return 0
	return 1


static func _test_render_rate_independence(
	failures: PackedStringArray,
) -> int:
	var trace := _load_trace(failures)
	if trace.is_empty():
		return 0
	var rates := [30.0, 60.0, 90.0, 120.0]
	var baseline: Dictionary = {}
	for rate: float in rates:
		var result := _simulate_trace(trace, rate)
		if baseline.is_empty():
			baseline = result
			continue
		if Vector2(result["position"]).distance_to(
				Vector2(baseline["position"])) > 0.001:
			failures.append("trajectory differs at %.0f Hz rendering" % rate)
			return 0
		if Vector2(result["velocity"]).distance_to(
				Vector2(baseline["velocity"])) > 0.001:
			failures.append("velocity differs at %.0f Hz rendering" % rate)
			return 0
		if absf(float(result["rope_length"]) -
				float(baseline["rope_length"])) > 0.001:
			failures.append("rope length differs at %.0f Hz rendering" % rate)
			return 0
	return 1


static func _simulate_trace(trace: Dictionary, render_rate: float) -> Dictionary:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var world := SimulationWorld.new()
	world.reset(config, _test_geometry())
	var commands: Array = trace.get("commands", [])
	var cursor := 0
	var duration_ticks := int(trace.get("duration_ticks", 180))
	var accumulator := 0.0
	var render_delta := 1.0 / render_rate
	while world.tick < duration_ticks:
		accumulator += render_delta
		while accumulator + 0.0000001 >= FIXED_DELTA and \
				world.tick < duration_ticks:
			while cursor < commands.size() and int(
					commands[cursor].get("playback_tick", 0)) <= world.tick:
				world.queue_command(InputCommand.from_record(commands[cursor]))
				cursor += 1
			world.step(FIXED_DELTA)
			accumulator -= FIXED_DELTA
	return {
		"position": world.position,
		"velocity": world.velocity,
		"rope_length": world.web.rope_length,
	}


static func _load_trace(failures: PackedStringArray) -> Dictionary:
	var file := FileAccess.open(TRACE_PATH, FileAccess.READ)
	if file == null:
		failures.append("missing recorded trace: %s" % TRACE_PATH)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		failures.append("recorded trace is not a JSON object")
		return {}
	return parsed as Dictionary


static func _contains_event(events: Array[SimulationEvent], kind: int) -> bool:
	for event: SimulationEvent in events:
		if event.kind == kind:
			return true
	return false


static func _test_geometry() -> CourseGeometry:
	var geometry := CourseGeometry.new()
	geometry.surfaces.append(
		_rectangle_polygon(Rect2(0.0, 112.0, 960.0, 38.0)))
	geometry.aim_guides.append_array(PackedVector2Array([
		Vector2(320.0, 150.0),
		Vector2(480.0, 150.0),
		Vector2(640.0, 150.0),
	]))
	return geometry


static func _rectangle_polygon(rect: Rect2) -> PackedVector2Array:
	return PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	])

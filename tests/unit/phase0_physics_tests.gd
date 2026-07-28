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
	passed += _test_invalid_target_is_inert(failures)
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
	var anchors := PackedVector2Array([Vector2(480.0, 150.0)])
	var released := SimulationWorld.new()
	var control := SimulationWorld.new()
	released.reset(config, anchors)
	control.reset(config, anchors)
	released.velocity = Vector2(512.0, -147.0)
	control.velocity = released.velocity
	released.web.try_attach(released.position, anchors[0], config)
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
	var anchors := PackedVector2Array([Vector2(480.0, 150.0)])
	var world := SimulationWorld.new()
	world.reset(config, anchors)
	world.web.try_attach(world.position, anchors[0], config)
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


static func _test_invalid_target_is_inert(failures: PackedStringArray) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var anchors := PackedVector2Array([Vector2(480.0, 150.0)])
	var invalid := SimulationWorld.new()
	var control := SimulationWorld.new()
	invalid.reset(config, anchors)
	control.reset(config, anchors)
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
	world.reset(config, PackedVector2Array())
	world.position.y = -500.0
	var events := world.step(FIXED_DELTA)
	if _contains_event(events, SimulationEvent.Kind.DEATH_REQUESTED):
		failures.append("top of screen incorrectly requested death")
		return 0
	return 1


static func _test_lower_boundary_is_lethal(failures: PackedStringArray) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var world := SimulationWorld.new()
	world.reset(config, PackedVector2Array())
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
	var anchors := PackedVector2Array([Vector2(480.0, 150.0)])
	var world := SimulationWorld.new()
	world.reset(config, anchors)
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

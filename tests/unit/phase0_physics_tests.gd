extends RefCounted
class_name Phase0PhysicsTests
## Deterministic regression suite for GDD Phase 0 contracts.

const FIXED_DELTA := 1.0 / 60.0
const TRACE_PATH := "res://tests/fixtures/phase0_trace.json"


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0

	passed += _test_presets(failures)
	passed += _test_gradual_speed_curve_reaches_full_pace_at_five_kilometres(
		failures)
	passed += _test_release_preserves_velocity(failures)
	passed += _test_reel_shortens_without_teleport(failures)
	passed += _test_reel_does_not_add_speed(failures)
	passed += _test_automatic_take_up_ratchets_slack_without_speed(failures)
	passed += _test_balanced_flow_shortens_web_more_at_max_level(failures)
	passed += _test_detached_reel_reports_unavailable(failures)
	passed += _test_invalid_target_is_inert(failures)
	passed += _test_continuous_surface_attachment(failures)
	passed += _test_aim_forgiveness_extends_beyond_old_band(failures)
	passed += _test_extended_web_reach(failures)
	passed += _test_burst_crosses_configured_fraction(failures)
	passed += _test_minimum_burst_travel_is_real_and_upgradeable(failures)
	passed += _test_upgrade_catalog_has_shared_core_and_breakthroughs(
		failures)
	passed += _test_pull_can_be_interrupted_by_recovery_web(failures)
	passed += _test_double_tap_falls_back_to_recovery_web(failures)
	passed += _test_downward_web_is_a_short_one_shot_pull(failures)
	passed += _test_dive_rearms_only_after_upper_web_contact(failures)
	passed += _test_obstacle_is_a_valid_anchor(failures)
	passed += _test_attached_tap_modes_are_explicit(failures)
	passed += _test_pull_tuning_controls(failures)
	passed += _test_course_stream_is_endless_and_bounded(failures)
	passed += _test_opening_runway_has_no_middle_hazards(failures)
	passed += _test_obstacle_scales_change_authoritative_polygons(failures)
	passed += _test_guided_opening_swings_safely_without_input_lock(failures)
	passed += _test_one_rescue_is_consumed_before_death(failures)
	passed += _test_spider_profiles_and_glide_share_one_config(failures)
	passed += _test_creator_pattern_drives_deterministic_chunks(failures)
	passed += _test_course_stream_places_lower_anchor_windows(failures)
	passed += _test_early_routes_are_obstacle_aware_and_late_gaps_are_clear(
		failures)
	passed += _test_gate_fly_route_is_traversable(failures)
	passed += _test_curated_pattern_catalog_is_banded_and_varied(failures)
	passed += _test_authored_weaves_and_small_silk_burrs_are_fair(failures)
	passed += _test_contoured_rails_are_continuous_and_varied(failures)
	passed += _test_obstacle_collision_is_authoritative(failures)
	passed += _test_boundary_lethality_is_a_toggle(failures)
	passed += _test_springtail_impact_shell_is_bounded(failures)
	passed += _test_collectibles_are_swept_and_not_respawned(failures)
	passed += _test_burst_frenzy_suppresses_only_cooldown(failures)
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
	var balanced := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	if not is_equal_approx(balanced.gravity, 1120.0) or \
			not is_equal_approx(balanced.dive_distance_fraction, 0.40) or \
			not is_equal_approx(balanced.reel_retraction_rate, 400.0) or \
			not is_equal_approx(balanced.burst_distance_fraction, 0.40) or \
			not is_equal_approx(balanced.burst_minimum_distance, 80.0) or \
			not is_equal_approx(balanced.speed_curve_distance, 50000.0) or \
			not is_equal_approx(
				balanced.tight_corridor_start_distance, 20000.0) or \
			not balanced.course_boundaries_lethal:
		failures.append(
			"balanced candidate lost its weaker base, pacing, or rail defaults")
		return 0
	return 1


static func _test_gradual_speed_curve_reaches_full_pace_at_five_kilometres(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var speeds := [
		config.target_speed_at(0.0),
		config.target_speed_at(10000.0),
		config.target_speed_at(30000.0),
		config.target_speed_at(50000.0),
		config.target_speed_at(80000.0),
	]
	if not is_equal_approx(float(speeds[0]), config.starting_target_speed) or \
			float(speeds[1]) >= 440.0 or \
			float(speeds[2]) >= config.maximum_target_speed or \
			not is_equal_approx(float(speeds[3]), config.maximum_target_speed) or \
			not is_equal_approx(float(speeds[4]), config.maximum_target_speed):
		failures.append("target speed no longer grows gradually to full pace at 5,000 m")
		return 0
	for index in range(speeds.size() - 1):
		if float(speeds[index]) > float(speeds[index + 1]):
			failures.append("target speed curve is not monotonic")
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


static func _test_automatic_take_up_ratchets_slack_without_speed(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.automatic_take_up_enabled = true
	config.automatic_take_up_retention = 0.80
	var web := WebConstraint.new()
	web.reset(config)
	var anchor := Vector2(600.0, 140.0)
	var position := Vector2(220.0, 390.0)
	if web.try_attach(position, anchor, config) != \
			WebConstraint.AttachResult.ATTACHED:
		failures.append("automatic take-up fixture could not attach")
		return 0
	var attached_distance := position.distance_to(anchor)
	web.rope_length = 500.0
	var direction := (position - anchor).normalized()
	position = anchor + direction * (attached_distance - 20.0)
	var velocity := Vector2.ZERO
	var result := web.solve(position, velocity, FIXED_DELTA, config)
	var expected := 500.0 - 20.0 * 0.80
	if absf(web.rope_length - expected) > 0.001:
		failures.append("automatic take-up did not retain the configured slack share")
		return 0
	if Vector2(result["velocity"]).distance_to(velocity) > 0.001:
		failures.append("automatic take-up injected speed while the rope remained slack")
		return 0
	web.solve(position, velocity, FIXED_DELTA, config)
	if absf(web.rope_length - expected) > 0.001:
		failures.append("static slack kept shrinking after inward movement stopped")
		return 0
	config.automatic_take_up_enabled = false
	web.rope_length = 500.0
	web.solve(position, velocity, FIXED_DELTA, config)
	if absf(web.rope_length - 500.0) > 0.001:
		failures.append("automatic take-up OFF still changed rope length")
		return 0
	return 1


static func _test_balanced_flow_shortens_web_more_at_max_level(
	failures: PackedStringArray,
) -> int:
	var upgrade := SpiderCatalog.upgrade(&"classic_flow")
	var description := str(upgrade.get("description", "")).to_lower()
	if not description.contains("less slack") or \
			not description.contains("shortening the web"):
		failures.append(
			"Balanced Flow copy does not explain its shorter-web direction")
		return 0

	var base_config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var progress := PlayerProgress.defaults()
	progress.upgrade_levels["classic_flow"] = SpiderCatalog.MAX_UPGRADE_LEVEL
	var max_config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	SpiderCatalog.apply_to_config(max_config, progress)
	if not is_equal_approx(base_config.automatic_take_up_retention, 0.85) or \
			not is_equal_approx(max_config.automatic_take_up_retention, 0.91):
		failures.append("Balanced Flow retention no longer scales from 85% to 91%")
		return 0

	var base_web := WebConstraint.new()
	var max_web := WebConstraint.new()
	base_web.reset(base_config)
	max_web.reset(max_config)
	var anchor := Vector2(600.0, 140.0)
	var position := Vector2(220.0, 390.0)
	if base_web.try_attach(position, anchor, base_config) != \
			WebConstraint.AttachResult.ATTACHED or \
			max_web.try_attach(position, anchor, max_config) != \
			WebConstraint.AttachResult.ATTACHED:
		failures.append("Balanced Flow take-up fixture could not attach")
		return 0
	var attached_distance := position.distance_to(anchor)
	base_web.rope_length = 500.0
	max_web.rope_length = 500.0
	var direction := (position - anchor).normalized()
	var inward_position := anchor + direction * (attached_distance - 20.0)
	base_web.solve(inward_position, Vector2.ZERO, FIXED_DELTA, base_config)
	max_web.solve(inward_position, Vector2.ZERO, FIXED_DELTA, max_config)
	if max_web.rope_length >= base_web.rope_length or \
			not is_equal_approx(base_web.rope_length, 483.0) or \
			not is_equal_approx(max_web.rope_length, 481.8):
		failures.append(
			"maxed Balanced Flow did not leave a shorter web than level zero")
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
	var target := Vector2(1180.0, 150.0)
	if target.distance_to(world.position) <= 820.0:
		failures.append("right-hand reach fixture does not exceed the old limit")
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


static func _test_minimum_burst_travel_is_real_and_upgradeable(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var world := SimulationWorld.new()
	world.reset(config, _test_geometry())
	var close_anchor := world.position + Vector2(120.0, 0.0)
	if not world._start_pull(
		close_anchor,
		config.burst_distance_fraction,
		config.burst_pull_duration,
		config.burst_exit_speed,
		config.burst_tangential_retention,
		&"burst",
		config.burst_minimum_distance,
	):
		failures.append("valid close-range Burst did not start")
		return 0
	if absf(world.pull_distance_total - config.burst_minimum_distance) > 0.001:
		failures.append("close-range Burst ignored its minimum useful travel")
		return 0

	var progress := PlayerProgress.defaults()
	progress.upgrade_levels["classic_burst_floor"] = \
		SpiderCatalog.MAX_UPGRADE_LEVEL
	var upgraded := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	SpiderCatalog.apply_to_config(upgraded, progress)
	if upgraded.burst_minimum_distance <= config.burst_minimum_distance or \
			not is_equal_approx(upgraded.burst_minimum_distance, 200.0):
		failures.append("Reliable Launch did not raise minimum Burst travel by level")
		return 0
	return 1


static func _test_upgrade_catalog_has_shared_core_and_breakthroughs(
	failures: PackedStringArray,
) -> int:
	if SpiderCatalog.MAX_UPGRADE_LEVEL != 20 or \
			SpiderCatalog.UPGRADE_COSTS.size() != 20 or \
			SpiderCatalog.cost_for_level(0) != 2 or \
			SpiderCatalog.cost_for_level(4) != 5 or \
			SpiderCatalog.cost_for_level(19) != 20 or \
			SpiderCatalog.cost_for_level(20) != 0:
		failures.append("twenty-level upgrade pacing or its bounded costs regressed")
		return 0
	if SpiderCatalog.effective_steps(4) != 4 or \
			SpiderCatalog.effective_steps(5) != 6 or \
			SpiderCatalog.effective_steps(10) != 12 or \
			SpiderCatalog.effective_steps(20) != 24:
		failures.append("five-level breakthroughs do not grant a real tuning step")
		return 0
	for level in [5, 10, 15, 20]:
		if not SpiderCatalog.is_breakthrough_level(level):
			failures.append("level %d is not marked as a breakthrough" % level)
			return 0
	if SpiderCatalog.is_breakthrough_level(4) or \
			SpiderCatalog.next_breakthrough_level(6) != 10 or \
			SpiderCatalog.next_breakthrough_level(20) != 20:
		failures.append("breakthrough boundaries are not deterministic")
		return 0

	var expected_core: Array[StringName] = [
		SpiderCatalog.REEL_SPEED,
		SpiderCatalog.BURST_REACH,
		SpiderCatalog.BURST_FLOOR,
		SpiderCatalog.REEL_CAPACITY,
		SpiderCatalog.REEL_RECOVERY,
	]
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var tracks := SpiderCatalog.upgrades_for(spider_id)
		if tracks.size() != 7:
			failures.append("%s does not expose seven upgrade paths" % spider_id)
			return 0
		var core_kinds: Array[StringName] = []
		var identity_count := 0
		for track: Dictionary in tracks:
			var scope := StringName(track["scope"])
			if scope == SpiderCatalog.SCOPE_CORE:
				core_kinds.append(StringName(track["kind"]))
			elif scope == SpiderCatalog.SCOPE_IDENTITY:
				identity_count += 1
		if core_kinds != expected_core or identity_count != 2:
			failures.append(
				"%s does not have the shared five-core/two-identity structure" %
					spider_id)
			return 0
	if SpiderCatalog.all_upgrades().size() != 35:
		failures.append("upgrade catalog does not contain five complete profiles")
		return 0

	var base := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var zero_level := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	SpiderCatalog.apply_to_config(zero_level, PlayerProgress.defaults())
	if not is_equal_approx(
		base.reel_retraction_rate,
		zero_level.reel_retraction_rate,
	) or not is_equal_approx(
		base.burst_distance_fraction,
		zero_level.burst_distance_fraction,
	) or not is_equal_approx(
		base.burst_minimum_distance,
		zero_level.burst_minimum_distance,
	):
		failures.append("new progression changed the level-zero Garden Spider")
		return 0

	var identity_expectations := [
		[SpiderCatalog.CLASSIC, &"classic_flow",
			&"automatic_take_up_retention", 1.0],
		[SpiderCatalog.CLASSIC, &"classic_rhythm",
			&"burst_cooldown", -1.0],
		[SpiderCatalog.SKITTER, &"skitter_size",
			&"player_collision_radius", -1.0],
		[SpiderCatalog.SKITTER, &"skitter_drive",
			&"horizontal_drive_acceleration", 1.0],
		[SpiderCatalog.ANCHORITE, &"anchorite_momentum",
			&"burst_exit_speed", 1.0],
		[SpiderCatalog.ANCHORITE, &"anchorite_pendulum",
			&"burst_tangential_retention", 1.0],
		[SpiderCatalog.BALLOONER, &"ballooner_glide",
			&"glide_duration", 1.0],
		[SpiderCatalog.BALLOONER, &"ballooner_reach",
			&"web_maximum_length", 1.0],
		[SpiderCatalog.SPRINGTAIL, &"springtail_shell",
			&"surface_bounce_max_impact_speed", 1.0],
		[SpiderCatalog.SPRINGTAIL, &"springtail_bounce",
			&"surface_bounce_retention", 1.0],
	]
	for expectation: Array in identity_expectations:
		var profile_id := StringName(expectation[0])
		var upgrade_id := StringName(expectation[1])
		var property := StringName(expectation[2])
		var direction := float(expectation[3])
		var profile_progress := PlayerProgress.defaults()
		profile_progress.selected_spider_id = profile_id
		var profile_base := SwingConfig.from_preset(
			SwingConfig.PRESET_BALANCED)
		SpiderCatalog.apply_to_config(profile_base, profile_progress)
		profile_progress.upgrade_levels[str(upgrade_id)] = \
			SpiderCatalog.MAX_UPGRADE_LEVEL
		var identity_max := SwingConfig.from_preset(
			SwingConfig.PRESET_BALANCED)
		SpiderCatalog.apply_to_config(identity_max, profile_progress)
		var delta := float(identity_max.get(property)) - \
			float(profile_base.get(property))
		if delta * direction <= 0.0:
			failures.append("%s identity track has no intended effect" % upgrade_id)
			return 0
	return 1


static func _test_pull_can_be_interrupted_by_recovery_web(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	var world := SimulationWorld.new()
	world.reset(config, _test_geometry())
	world.queue_command(InputCommand.burst_at(Vector2(640.0, 150.0), 1, 0))
	world.step(FIXED_DELTA)
	if not world.pull_active or world.web.attached:
		failures.append("recovery fixture did not begin with an active detached Burst")
		return 0
	var cooldown_before := world.burst_cooldown_remaining
	var recovery_anchor := Vector2(1080.0, 150.0)
	world.queue_command(InputCommand.attach(
		recovery_anchor,
		2,
		world.tick,
	))
	var events := world.step(FIXED_DELTA)
	if world.pull_active or not world.web.attached:
		failures.append("a normal tap did not interrupt Burst with a recovery web")
		return 0
	if world.web.anchor.distance_to(recovery_anchor) > 0.001:
		failures.append("recovery web resolved to the wrong solid point")
		return 0
	if not _contains_event(events, SimulationEvent.Kind.ATTACHED) or \
			_contains_event(events, SimulationEvent.Kind.BURST_UNAVAILABLE):
		failures.append("recovery web did not report one accepted attach")
		return 0
	if world.burst_cooldown_remaining >= cooldown_before or \
			world.burst_cooldown_remaining <= 0.0:
		failures.append("recovery attach reset or removed the Burst cooldown")
		return 0
	return 1


static func _test_double_tap_falls_back_to_recovery_web(
	failures: PackedStringArray,
) -> int:
	var session := SwingLabSession.new()
	session._reset_run()
	session._world.pull_active = true
	session.request_burst_from_gesture(Vector2(720.0, 150.0))
	if session._command_buffer.size() != 1 or \
			session._command_buffer[0].kind != InputCommand.Kind.ATTACH:
		failures.append("double-tap during an active pull did not become recovery")
		session.free()
		return 0
	session._command_buffer.clear()
	session._world.pull_active = false
	session._world.web.release()
	session._world.burst_cooldown_remaining = 1.0
	session.request_burst_from_gesture(Vector2(720.0, 150.0))
	if session._command_buffer.size() != 1 or \
			session._command_buffer[0].kind != InputCommand.Kind.ATTACH:
		failures.append(
			"detached double-tap during cooldown swallowed the recovery web")
		session.free()
		return 0
	session._command_buffer.clear()
	session._world.burst_cooldown_remaining = 0.0
	session.request_burst_from_gesture(Vector2(720.0, 150.0))
	if session._command_buffer.size() != 1 or \
			session._command_buffer[0].kind != InputCommand.Kind.BURST:
		failures.append("ready detached double-tap no longer requests Burst")
		session.free()
		return 0
	session.free()
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
	if world.dive_ready or world.burst_cooldown_remaining > 0.0:
		failures.append("Dive Pull used a timer instead of spending its web charge")
		return 0
	return 1


static func _test_dive_rearms_only_after_upper_web_contact(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	var geometry := _test_geometry()
	geometry.surfaces.append(
		_rectangle_polygon(Rect2(260.0, 570.0, 720.0, 42.0)))
	var world := SimulationWorld.new()
	world.reset(config, geometry)
	world.velocity = Vector2(260.0, -60.0)
	world.burst_cooldown_remaining = config.burst_cooldown
	var lower_target := Vector2(560.0, 570.0)

	# A downward double-tap follows Dive rules even while Anchor Burst is
	# recharging; the two abilities intentionally do not share a timer.
	world.queue_command(InputCommand.burst_at(lower_target, 1, world.tick))
	var events := world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.DIVE_STARTED) or \
			not world.pull_active or world.dive_ready:
		failures.append("Dive did not start independently of Burst cooldown")
		return 0
	var cooldown_after_dive := world.burst_cooldown_remaining
	var safety := 0
	while world.pull_active and safety < 60:
		world.step(FIXED_DELTA)
		safety += 1

	world.queue_command(InputCommand.burst_at(lower_target, 2, world.tick))
	events = world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.DIVE_UNAVAILABLE) or \
			world.pull_active:
		failures.append("spent Dive did not require an upper web contact")
		return 0
	if world.burst_cooldown_remaining >= cooldown_after_dive:
		failures.append("spent Dive accidentally reset the Burst timer")
		return 0

	var upper_target := Vector2(720.0, 150.0)
	world.queue_command(InputCommand.attach(upper_target, 3, world.tick))
	events = world.step(FIXED_DELTA)
	if not world.web.attached or not world.dive_ready or \
			not _contains_event(events, SimulationEvent.Kind.ATTACHED):
		failures.append("successful upper web contact did not rearm Dive")
		return 0
	var reported_rearm := false
	for event: SimulationEvent in events:
		if event.kind == SimulationEvent.Kind.ATTACHED and \
				bool(event.data.get("dive_rearmed", false)):
			reported_rearm = true
			break
	if not reported_rearm:
		failures.append("upper web rearm was not exposed to feedback")
		return 0

	world.queue_command(InputCommand.burst_at(lower_target, 4, world.tick))
	events = world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.DIVE_STARTED) or \
			world.dive_ready or world.web.attached:
		failures.append("rearmed Dive did not become immediately usable")
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


static func _test_attached_tap_modes_are_explicit(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	var release_world := SimulationWorld.new()
	release_world.reset(config, _test_geometry())
	release_world.web.try_attach(
		release_world.position,
		Vector2(480.0, 150.0),
		config,
	)
	release_world.queue_command(InputCommand.attach(
		Vector2(720.0, 150.0),
		1,
		0,
	))
	release_world.step(FIXED_DELTA)
	if release_world.web.attached:
		failures.append("default attached tap no longer performs deliberate release")
		return 0

	var retarget_config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	retarget_config.web_tap_retargets_when_attached = true
	retarget_config.gravity = 0.0001
	retarget_config.horizontal_drive_acceleration = 0.0001
	retarget_config.air_drag = 0.0
	var retarget_world := SimulationWorld.new()
	retarget_world.reset(retarget_config, _test_geometry())
	retarget_world.web.try_attach(
		retarget_world.position,
		Vector2(480.0, 150.0),
		retarget_config,
	)
	retarget_world.queue_command(InputCommand.attach(
		Vector2(720.0, 150.0),
		1,
		0,
	))
	var events := retarget_world.step(FIXED_DELTA)
	if not retarget_world.web.attached or \
			retarget_world.web.anchor.distance_to(Vector2(720.0, 150.0)) > 0.001:
		failures.append("RETARGET mode did not replace the web atomically")
		return 0
	if not _contains_event(events, SimulationEvent.Kind.ATTACHED):
		failures.append("RETARGET mode emitted no accepted attach")
		return 0
	return 1


static func _test_pull_tuning_controls(failures: PackedStringArray) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var burst_before := config.burst_distance_fraction
	var dive_before := config.dive_distance_fraction
	var reel_before := config.reel_retraction_rate
	var range_before := config.web_maximum_length
	var cooldown_before := config.burst_cooldown
	var burst_minimum_before := config.burst_minimum_distance
	var full_speed_before := config.speed_curve_distance
	var tight_corridor_before := config.tight_corridor_start_distance
	config.adjust(&"burst_pull_pct", 1.0)
	config.adjust(&"burst_minimum", 1.0)
	config.adjust(&"dive_pull_pct", -1.0)
	config.adjust(&"reel_rate", 1.0)
	config.adjust(&"web_range", 1.0)
	config.adjust(&"pull_cooldown", -1.0)
	config.adjust(&"tap_retarget", 1.0)
	config.adjust(&"auto_take_up", -1.0)
	config.adjust(&"take_up_pct", -1.0)
	config.adjust(&"course_rails", -1.0)
	config.adjust(&"lethal_rails", 1.0)
	config.adjust(&"route_clearance", 1.0)
	config.adjust(&"tight_corridor_m", 1.0)
	config.adjust(&"full_speed_m", 1.0)
	config.adjust(&"impact_shell", 1.0)
	if absf(config.burst_distance_fraction - (burst_before + 0.05)) > 0.001:
		failures.append("debug Burst percentage adjustment is not 5%")
		return 0
	if absf(config.burst_minimum_distance - (burst_minimum_before + 10.0)) > \
			0.001:
		failures.append("debug minimum Burst adjustment is not 10 px")
		return 0
	if absf(config.dive_distance_fraction - (dive_before - 0.05)) > 0.001:
		failures.append("debug Dive percentage adjustment is not 5%")
		return 0
	if absf(config.reel_retraction_rate - (reel_before + 20.0)) > 0.001:
		failures.append("debug Reel shortening adjustment is not 20 px/s")
		return 0
	if absf(config.web_maximum_length - (range_before + 50.0)) > 0.001:
		failures.append("debug web range adjustment is not 50 px")
		return 0
	if absf(config.burst_cooldown - (cooldown_before - 0.10)) > 0.001:
		failures.append("debug pull cooldown adjustment is not 0.10 seconds")
		return 0
	if absf(config.speed_curve_distance - (full_speed_before + 5000.0)) > 0.001:
		failures.append("debug full-speed distance adjustment is not 500 m")
		return 0
	if absf(
		config.tight_corridor_start_distance -
			(tight_corridor_before + 2500.0)
	) > 0.001:
		failures.append("debug inward-rail threshold adjustment is not 250 m")
		return 0
	if not config.web_tap_retargets_when_attached:
		failures.append("debug tap mode did not enable RETARGET")
		return 0
	if config.automatic_take_up_enabled or config.course_boundaries_enabled or \
			not config.course_boundaries_lethal or \
			not config.surface_bounce_enabled:
		failures.append("debug toggles did not update take-up, rail, and shell policies")
		return 0
	for parameter: StringName in [
		&"burst_pull_pct",
		&"burst_minimum",
		&"dive_pull_pct",
		&"burst_duration",
		&"pull_cooldown",
		&"dive_duration",
		&"reel_rate",
		&"web_range",
		&"tap_retarget",
		&"aim_forgiveness",
		&"attach_catch_pct",
		&"auto_take_up",
		&"take_up_pct",
		&"course_rails",
		&"lethal_rails",
		&"mid_hazard_m",
		&"start_speed",
		&"maximum_speed",
		&"full_speed_m",
		&"corridor_contours",
		&"route_clearance",
		&"tight_gap_size",
		&"tight_corridor_m",
		&"impact_shell",
		&"safe_impact_speed",
		&"bounce_strength",
		&"boost_duration",
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
	for surface: PackedVector2Array in geometry.boundary_surfaces:
		furthest_surface_x = maxf(
			furthest_surface_x,
			SolidGeometry.bounds(surface).end.x,
		)
	if geometry.boundary_surfaces.is_empty() or furthest_surface_x <= 100000.0:
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


static func _test_opening_runway_has_no_middle_hazards(
	failures: PackedStringArray,
) -> int:
	var stream := CourseStream.new()
	stream.reset(10000.0)
	for metres in [100.0, 450.0, 900.0]:
		var geometry := stream.update_for_position(
			metres * 10.0 + SimulationWorld.START_POSITION.x,
			10000.0,
		)
		for obstacle: PackedVector2Array in geometry.obstacles:
			var bounds := SolidGeometry.bounds(obstacle)
			if bounds.position.x >= SimulationWorld.START_POSITION.x + 10000.0:
				continue
			var touches_ceiling := bounds.position.y <= 210.0
			var touches_floor := bounds.end.y >= 620.0
			if not touches_ceiling and not touches_floor:
				failures.append(
					"opening runway spawned a detached middle hazard at %.0f m" %
						metres)
				return 0
	var later := stream.update_for_position(12000.0, 10000.0)
	var found_lane_intrusion := false
	for obstacle: PackedVector2Array in later.obstacles:
		var bounds := SolidGeometry.bounds(obstacle)
		var hangs_into_lane := \
			bounds.position.y <= CourseStream.CEILING_Y + 1.0 and \
			bounds.end.y >= CourseStream.CEILING_Y + 180.0
		var grows_into_lane := \
			bounds.end.y >= CourseStream.FLOOR_Y - 1.0 and \
			bounds.position.y <= CourseStream.FLOOR_Y - 180.0
		if hangs_into_lane or grows_into_lane:
			found_lane_intrusion = true
			break
	if not found_lane_intrusion:
		failures.append("course never introduces rail-grown challenges after the runway")
		return 0
	return 1


static func _test_course_stream_places_lower_anchor_windows(
	failures: PackedStringArray,
) -> int:
	var stream := CourseStream.new()
	stream.reset()
	var geometry := stream.update_for_position(
		CourseStream.CHUNK_WIDTH * 3.0 + 100.0)
	for chunk_index in range(
		geometry.first_chunk_index,
		geometry.last_chunk_index + 1,
	):
		var chunk_start := float(chunk_index) * CourseStream.CHUNK_WIDTH
		var chunk_end := chunk_start + CourseStream.CHUNK_WIDTH
		var found_window := false
		for surface: PackedVector2Array in geometry.boundary_surfaces:
			var bounds := SolidGeometry.bounds(surface)
			if bounds.end.x <= chunk_start or bounds.position.x >= chunk_end:
				continue
			if bounds.position.y >= 560.0 and bounds.size.x >= 250.0:
				found_window = true
				break
		if not found_window:
			failures.append(
				"chunk %d has no authored lower anchor before its hazards" %
				chunk_index)
			return 0
	return 1


static func _test_contoured_rails_are_continuous_and_varied(
	failures: PackedStringArray,
) -> int:
	var stream := CourseStream.new()
	stream.reset()
	var geometry := stream.update_for_position(23000.0)
	var found_open_route := false
	var found_tight_route := false
	for chunk_index in range(
		geometry.first_chunk_index,
		geometry.last_chunk_index + 1,
	):
		var chunk_start := float(chunk_index) * CourseStream.CHUNK_WIDTH
		var chunk_surfaces: Array[PackedVector2Array] = []
		for boundary: PackedVector2Array in geometry.boundary_surfaces:
			var bounds := SolidGeometry.bounds(boundary)
			if absf(bounds.position.x - chunk_start) <= 0.01:
				chunk_surfaces.append(boundary)
		if chunk_surfaces.size() != 2:
			failures.append(
				"chunk %d does not own one continuous ceiling and floor" %
					chunk_index)
			return 0
		for boundary: PackedVector2Array in chunk_surfaces:
			var bounds := SolidGeometry.bounds(boundary)
			if bounds.size.x < CourseStream.CHUNK_WIDTH - 0.01:
				failures.append("a shaped rail leaves a horizontal hole")
				return 0
			if boundary.size() < 10 or \
					not is_equal_approx(boundary[0].x, chunk_start) or \
					not is_equal_approx(
						boundary[4].x,
						chunk_start + CourseStream.CHUNK_WIDTH,
					):
				failures.append("a shaped rail does not join both chunk seams")
				return 0
			for point_index in range(5):
				var y := boundary[point_index].y
				if y < CourseStream.CEILING_Y - 20.0 or \
						y > CourseStream.FLOOR_Y + 20.0:
					found_open_route = true
				if y > 200.0 and y < 590.0:
					found_tight_route = true
	if not found_open_route or not found_tight_route:
		failures.append("corridor stream lacks both open bypasses and late tight gaps")
		return 0
	return 1


static func _test_early_routes_are_obstacle_aware_and_late_gaps_are_clear(
	failures: PackedStringArray,
) -> int:
	var stream := CourseStream.new()
	stream.reset()
	var route_margin := 30.0
	for chunk_index in range(22):
		var chunk_start := float(chunk_index) * CourseStream.CHUNK_WIDTH
		var chunk_end := chunk_start + CourseStream.CHUNK_WIDTH
		var geometry := stream.update_for_position(chunk_start + 1.0)
		var ceiling := PackedVector2Array()
		var floor := PackedVector2Array()
		for boundary: PackedVector2Array in geometry.boundary_surfaces:
			var bounds := SolidGeometry.bounds(boundary)
			if absf(bounds.position.x - chunk_start) > 0.01:
				continue
			if boundary[0].y < 400.0:
				ceiling = boundary
			else:
				floor = boundary
		if ceiling.is_empty() or floor.is_empty():
			failures.append(
				"early chunk %d is missing a continuous route boundary" %
					chunk_index)
			return 0
		for point_index in range(5):
			if ceiling[point_index].y > CourseStream.CEILING_Y + 0.01 or \
					floor[point_index].y < CourseStream.FLOOR_Y - 0.01:
				failures.append(
					"chunk %d moves lethal rails inward before 2000 m" %
						chunk_index)
				return 0
		var chunk_obstacles: Array[PackedVector2Array] = []
		for obstacle: PackedVector2Array in geometry.obstacles:
			var obstacle_bounds := SolidGeometry.bounds(obstacle)
			if obstacle_bounds.get_center().x >= chunk_start and \
					obstacle_bounds.get_center().x < chunk_end:
				chunk_obstacles.append(obstacle)
		for fly: Vector2 in geometry.fly_positions:
			if fly.x < chunk_start or fly.x >= chunk_end:
				continue
			for obstacle: PackedVector2Array in chunk_obstacles:
				if SolidGeometry.circle_intersects_polygon(
					fly,
					route_margin,
					obstacle,
				):
					failures.append(
						"chunk %d guides its route into an obstacle" %
							chunk_index)
					return 0

	var tight_chunk_index := 23
	var tight_chunk_start := \
		float(tight_chunk_index) * CourseStream.CHUNK_WIDTH
	var later := stream.update_for_position(tight_chunk_start + 1.0)
	var found_inward_ceiling := false
	var found_inward_floor := false
	for boundary: PackedVector2Array in later.boundary_surfaces:
		var bounds := SolidGeometry.bounds(boundary)
		if absf(bounds.position.x - tight_chunk_start) > 0.01:
			continue
		if boundary[0].y < 400.0:
			for point_index in range(5):
				found_inward_ceiling = found_inward_ceiling or \
					boundary[point_index].y > 200.0
		else:
			for point_index in range(5):
				found_inward_floor = found_inward_floor or \
					boundary[point_index].y < 590.0
	if not found_inward_ceiling or not found_inward_floor:
		failures.append("late course never introduces the configured tight corridor")
		return 0
	for obstacle: PackedVector2Array in later.obstacles:
		var bounds := SolidGeometry.bounds(obstacle)
		if bounds.get_center().x >= tight_chunk_start and \
				bounds.get_center().x < \
					tight_chunk_start + CourseStream.CHUNK_WIDTH:
			failures.append("late tight corridor still overlaps a floating obstacle")
			return 0
	return 1


static func _test_gate_fly_route_is_traversable(
	failures: PackedStringArray,
) -> int:
	var gate_center := Vector2(CourseStream.CHUNK_WIDTH + 690.0, 370.0)
	var classic := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var route_radius := classic.player_collision_radius + 8.0
	for opening_scale in [0.80, 1.12, 1.40]:
		var stream := CourseStream.new()
		var pattern: Array[StringName] = [&"gate"]
		stream.reset(10000.0, 0.94, 0.90, opening_scale, pattern)
		var geometry := stream.update_for_position(1300.0)
		var gate_pieces: Array[PackedVector2Array] = []
		for obstacle: PackedVector2Array in geometry.obstacles:
			var obstacle_bounds := SolidGeometry.bounds(obstacle)
			if absf(obstacle_bounds.get_center().x - gate_center.x) <= 130.0:
				gate_pieces.append(obstacle)
		if gate_pieces.size() != 2:
			failures.append("gate route fixture did not produce two rail-grown pieces")
			return 0
		var upper_bounds := SolidGeometry.bounds(gate_pieces[0])
		var lower_bounds := SolidGeometry.bounds(gate_pieces[1])
		if upper_bounds.position.y > CourseStream.CEILING_Y + 1.0 or \
				lower_bounds.end.y < CourseStream.FLOOR_Y - 1.0:
			failures.append(
				"gate pieces still float instead of growing from both rails")
			return 0
		var steering_half_band := 60.0
		if is_equal_approx(opening_scale, 1.12):
			steering_half_band = 96.0
		elif opening_scale > 1.12:
			steering_half_band = 124.0
		for lane_y in [
			gate_center.y - steering_half_band,
			gate_center.y,
			gate_center.y + steering_half_band,
		]:
			for sample_index in range(61):
				var sample_x := lerpf(
					gate_center.x - 150.0,
					gate_center.x + 150.0,
					float(sample_index) / 60.0,
				)
				var route_sample := Vector2(sample_x, lane_y)
				for boundary: PackedVector2Array in geometry.boundary_surfaces:
					if SolidGeometry.circle_intersects_polygon(
						route_sample,
						route_radius,
						boundary,
					):
						failures.append(
							"gate steering envelope meets a rail at %.0f%%" %
							(opening_scale * 100.0))
						return 0
				for obstacle: PackedVector2Array in gate_pieces:
					if SolidGeometry.circle_intersects_polygon(
						route_sample,
						route_radius,
						obstacle,
					):
						failures.append(
							"gate blocks the %.0f px steering lane at %.0f%%" % [
								steering_half_band,
								opening_scale * 100.0,
							])
						return 0
	return 1


static func _test_curated_pattern_catalog_is_banded_and_varied(
	failures: PackedStringArray,
) -> int:
	var catalog_path := \
		"res://game/application/course_pattern_catalog.gd"
	if not ResourceLoader.exists(catalog_path):
		failures.append("curated course pattern catalog is missing")
		return 0
	var stream := CourseStream.new()
	stream.reset()
	if not stream.has_method("pattern_id_for_chunk"):
		failures.append("course stream does not expose deterministic pattern IDs")
		return 0
	var unique_patterns := {}
	var previous := &""
	var paired_chunks := 0
	var single_chunks := 0
	for chunk_index in range(11, 46):
		var pattern_id := StringName(stream.call(
			"pattern_id_for_chunk",
			chunk_index,
		))
		if pattern_id.is_empty():
			failures.append("chunk %d has no curated pattern" % chunk_index)
			return 0
		if pattern_id == previous:
			failures.append(
				"curated pattern %s repeats in adjacent chunks" % pattern_id)
			return 0
		previous = pattern_id
		unique_patterns[pattern_id] = true
		var chunk_start := float(chunk_index) * CourseStream.CHUNK_WIDTH
		var geometry := stream.update_for_position(chunk_start + 1.0)
		var count := 0
		for obstacle: PackedVector2Array in geometry.obstacles:
			var bounds := SolidGeometry.bounds(obstacle)
			if bounds.get_center().x >= chunk_start and \
					bounds.get_center().x < \
						chunk_start + CourseStream.CHUNK_WIDTH:
				count += 1
		if count >= 2:
			paired_chunks += 1
		elif count == 1:
			single_chunks += 1
	if unique_patterns.size() < 10:
		failures.append(
			"curated late course exposes only %d pattern IDs" %
			unique_patterns.size())
		return 0
	if paired_chunks < 4 or single_chunks < 4:
		failures.append(
			"late course lost the intended mix of single and paired challenges")
		return 0
	return 1


static func _test_authored_weaves_and_small_silk_burrs_are_fair(
	failures: PackedStringArray,
) -> int:
	var pattern_ids := [
		&"high_low_weave",
		&"low_high_weave",
		&"silk_burr_high",
		&"silk_burr_low",
	]
	var stream := CourseStream.new()
	stream.reset()
	for chunk_index in range(22):
		if stream.pattern_id_for_chunk(chunk_index) in pattern_ids:
			failures.append("height-switch pattern entered the protected opening")
			return 0
	var found := {}
	for chunk_index in range(22, 92):
		var pattern_id := stream.pattern_id_for_chunk(chunk_index)
		if pattern_id not in pattern_ids or found.has(pattern_id):
			continue
		var chunk_start := float(chunk_index) * CourseStream.CHUNK_WIDTH
		var chunk_end := chunk_start + CourseStream.CHUNK_WIDTH
		var geometry := stream.update_for_position(chunk_start + 1.0)
		var obstacles: Array[PackedVector2Array] = []
		var route_flies: Array[Vector2] = []
		for obstacle: PackedVector2Array in geometry.obstacles:
			var bounds := SolidGeometry.bounds(obstacle)
			if bounds.get_center().x >= chunk_start and \
					bounds.get_center().x < chunk_end:
				obstacles.append(obstacle)
		for fly: Vector2 in geometry.fly_positions:
			if fly.x >= chunk_start and fly.x < chunk_end:
				route_flies.append(fly)
		for fly: Vector2 in route_flies:
			for obstacle: PackedVector2Array in obstacles:
				if SolidGeometry.circle_intersects_polygon(fly, 30.0, obstacle):
					failures.append(
						"%s guides its fly route into collision" % pattern_id)
					return 0
		if pattern_id == &"high_low_weave" or \
				pattern_id == &"low_high_weave":
			if obstacles.size() != 2 or route_flies.size() != 7:
				failures.append("%s lost its authored two-part cue" % pattern_id)
				return 0
			var first := obstacles[0]
			var second := obstacles[1]
			if SolidGeometry.bounds(first).get_center().x > \
					SolidGeometry.bounds(second).get_center().x:
				var swap := first
				first = second
				second = swap
			var first_bounds := SolidGeometry.bounds(first)
			var second_bounds := SolidGeometry.bounds(second)
			if second_bounds.get_center().x - first_bounds.get_center().x < 400.0:
				failures.append(
					"%s no longer gives a readable height-change runway" %
						pattern_id)
				return 0
			var high_to_low := pattern_id == &"high_low_weave"
			var first_is_floor := \
				first_bounds.end.y >= CourseStream.FLOOR_Y - 0.01
			var second_is_floor := \
				second_bounds.end.y >= CourseStream.FLOOR_Y - 0.01
			if first_is_floor != high_to_low or \
					second_is_floor == high_to_low:
				failures.append("%s obstacles do not alternate rail height" % pattern_id)
				return 0
			var floor_bounds := first_bounds if first_is_floor else second_bounds
			var ceiling_bounds := second_bounds if first_is_floor else first_bounds
			if floor_bounds.position.y - ceiling_bounds.end.y < 72.0 or \
					maxf(first_bounds.size.y, second_bounds.size.y) > 252.0:
				failures.append(
					"%s no longer leaves a forgiving central transition band" %
						pattern_id)
				return 0
			var route_delta := route_flies[-1].y - route_flies[0].y
			if absf(route_delta) < 280.0 or \
					(route_delta > 0.0) != high_to_low:
				failures.append("%s does not clearly cue the required height change" %
					pattern_id)
				return 0
			for sample_index in range(41):
				var progress := float(sample_index) / 40.0
				var eased := progress * progress * (3.0 - 2.0 * progress)
				var route_sample := Vector2(
					lerpf(route_flies[0].x, route_flies[-1].x, progress),
					lerpf(
						route_flies[0].y,
						route_flies[-1].y,
						eased,
					),
				)
				for obstacle: PackedVector2Array in obstacles:
					if SolidGeometry.circle_intersects_polygon(
						route_sample,
						30.0,
						obstacle,
					):
						failures.append(
							"%s blocks its Classic-sized steering envelope" %
								pattern_id)
						return 0
		else:
			if obstacles.size() != 1 or route_flies.size() != 5:
				failures.append("%s lost its single compact burr" % pattern_id)
				return 0
			var burr_bounds := SolidGeometry.bounds(obstacles[0])
			if burr_bounds.size.x > 110.0 or burr_bounds.size.y > 96.0 or \
					burr_bounds.position.y <= CourseStream.CEILING_Y or \
					burr_bounds.end.y >= CourseStream.FLOOR_Y:
				failures.append("%s is no longer a small middle obstacle" % pattern_id)
				return 0
		found[pattern_id] = true
	if found.size() != pattern_ids.size():
		failures.append("deterministic late course does not expose every new pattern")
		return 0
	return 1


static func _test_obstacle_scales_change_authoritative_polygons(
	failures: PackedStringArray,
) -> int:
	var full := CourseStream.new()
	full.reset(0.0, 1.0, 1.0, 1.0, [&"pod"])
	var full_geometry := full.update_for_position(1300.0)
	var smaller := CourseStream.new()
	smaller.reset(0.0, 0.94, 0.90, 1.12, [&"pod"])
	var smaller_geometry := smaller.update_for_position(1300.0)
	if full_geometry.obstacles.is_empty() or smaller_geometry.obstacles.is_empty():
		failures.append("obstacle scaling fixture produced no creator pod")
		return 0
	var full_bounds := SolidGeometry.bounds(full_geometry.obstacles[0])
	var smaller_bounds := SolidGeometry.bounds(smaller_geometry.obstacles[0])
	if smaller_bounds.size.x >= full_bounds.size.x or \
			smaller_bounds.size.y >= full_bounds.size.y:
		failures.append("smaller floating setting did not shrink collision polygons")
		return 0
	if absf(smaller_bounds.size.x / full_bounds.size.x - 0.90) > 0.01 or \
			absf(smaller_bounds.size.y / full_bounds.size.y - 0.90) > 0.01:
		failures.append("floating obstacle size is not applied predictably")
		return 0
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	if not is_equal_approx(config.floating_obstacle_scale, 0.90) or \
			not is_equal_approx(config.gate_opening_scale, 1.12):
		failures.append("roomier obstacle defaults drifted from the comparison build")
		return 0
	return 1


static func _test_guided_opening_swings_safely_without_input_lock(
	failures: PackedStringArray,
) -> int:
	var session := SwingLabSession.new()
	session._reset_run()
	if not session._world.web.attached or \
			session._world.web.anchor.distance_to(Vector2(500.0, 112.0)) > 0.1:
		failures.append("run did not begin on the deterministic opening web")
		session.free()
		return 0
	for _index in range(60):
		session._step_once()
	if session._run.state != RunStateMachine.State.ACTIVE or \
			session._world.distance_pixels < 350.0:
		failures.append("guided opening failed to provide one safe second of travel")
		session.free()
		return 0
	session.request_web_tap(Vector2(-200.0, 360.0))
	session._step_once()
	if session._world.web.attached:
		failures.append("guided opening locked out an early release input")
		session.free()
		return 0
	session.free()
	return 1


static func _test_one_rescue_is_consumed_before_death(
	failures: PackedStringArray,
) -> int:
	var session := SwingLabSession.new()
	session._reset_run()
	session._world.web.release()
	session._world.position.y = session._config.lower_world_boundary + 5.0
	session._step_once()
	if session._run.state != RunStateMachine.State.ACTIVE or \
			session._rescue_available or \
			session._world.rescue_shield_remaining <= 0.0:
		failures.append("first lethal mistake did not consume one safe rescue")
		session.free()
		return 0
	session._world.rescue_shield_remaining = 0.0
	session._world.position.y = session._config.lower_world_boundary + 5.0
	session._step_once()
	if session._run.state != RunStateMachine.State.DYING:
		failures.append("second lethal mistake did not continue into normal death")
		session.free()
		return 0
	session.free()
	return 1


static func _test_spider_profiles_and_glide_share_one_config(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	progress.selected_spider_id = SpiderCatalog.SKITTER
	var agile := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	SpiderCatalog.apply_to_config(agile, progress)
	progress.selected_spider_id = SpiderCatalog.ANCHORITE
	var heavy := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	SpiderCatalog.apply_to_config(heavy, progress)
	progress.selected_spider_id = SpiderCatalog.BALLOONER
	var glider := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	SpiderCatalog.apply_to_config(glider, progress)
	progress.selected_spider_id = SpiderCatalog.SPRINGTAIL
	var springtail := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	SpiderCatalog.apply_to_config(springtail, progress)
	if agile.player_collision_radius >= 18.0 or \
			agile.horizontal_drive_acceleration <= 470.0:
		failures.append("Skitter lost its smaller, more agile profile")
		return 0
	if heavy.player_collision_radius <= 18.0 or heavy.gravity <= 1120.0 or \
			heavy.reel_retraction_rate <= 400.0:
		failures.append("Anchorite lost its heavy Reel-In trade-off")
		return 0
	if glider.glide_duration <= 1.0 or glider.detached_gravity_scale >= 0.60:
		failures.append("Ballooner does not resolve to a real detached glide")
		return 0
	if SpiderCatalog.ALL_IDS.size() != 5 or \
			not springtail.surface_bounce_enabled or \
			springtail.horizontal_drive_acceleration >= 470.0:
		failures.append("Springtail lost its bounded recovery trade-off")
		return 0
	var world := SimulationWorld.new()
	world.reset(glider, _test_geometry())
	var velocity_before := world.velocity.y
	world.step(FIXED_DELTA)
	var gliding_gravity_delta := world.velocity.y - velocity_before
	if gliding_gravity_delta >= glider.gravity * FIXED_DELTA * 0.70:
		failures.append("Ballooner glide did not reduce detached gravity")
		return 0
	return 1


static func _test_creator_pattern_drives_deterministic_chunks(
	failures: PackedStringArray,
) -> int:
	var first := CourseStream.new()
	var pattern: Array[StringName] = [
		&"leaf", &"empty", &"pod", &"vine", &"gate", &"empty",
	]
	first.reset(10000.0, 0.94, 0.90, 1.12, pattern)
	var geometry_a := first.update_for_position(1300.0)
	var second := CourseStream.new()
	second.reset(10000.0, 0.94, 0.90, 1.12, pattern)
	var geometry_b := second.update_for_position(1300.0)
	if geometry_a.obstacles.is_empty() or \
			geometry_a.obstacles != geometry_b.obstacles:
		failures.append("saved creator pattern is not deterministic or playable")
		return 0
	if geometry_a.first_chunk_index != geometry_b.first_chunk_index or \
			geometry_a.last_chunk_index != geometry_b.last_chunk_index:
		failures.append("creator playtest changed bounded stream ownership")
		return 0
	return 1


static func _test_boundary_lethality_is_a_toggle(
	failures: PackedStringArray,
) -> int:
	var geometry := _test_geometry()
	geometry.boundary_surfaces.append(
		_rectangle_polygon(Rect2(0.0, 640.0, 900.0, 60.0)))
	var safe_config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	safe_config.gravity = 0.0001
	safe_config.horizontal_drive_acceleration = 0.0001
	safe_config.air_drag = 0.0
	safe_config.course_boundaries_enabled = true
	safe_config.course_boundaries_lethal = false
	var safe := SimulationWorld.new()
	safe.reset(safe_config, geometry)
	safe.position = Vector2(360.0, 645.0)
	safe.velocity = Vector2.ZERO
	if _contains_event(safe.step(FIXED_DELTA), SimulationEvent.Kind.DEATH_REQUESTED):
		failures.append("safe course rails killed the spider")
		return 0
	var lethal_config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	lethal_config.gravity = 0.0001
	lethal_config.horizontal_drive_acceleration = 0.0001
	lethal_config.air_drag = 0.0
	lethal_config.course_boundaries_enabled = true
	lethal_config.course_boundaries_lethal = true
	var lethal := SimulationWorld.new()
	lethal.reset(lethal_config, geometry)
	lethal.position = Vector2(360.0, 645.0)
	lethal.velocity = Vector2.ZERO
	if not _contains_event(
		lethal.step(FIXED_DELTA), SimulationEvent.Kind.DEATH_REQUESTED):
		failures.append("lethal course rails did not kill the spider")
		return 0
	return 1


static func _test_springtail_impact_shell_is_bounded(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	progress.selected_spider_id = SpiderCatalog.SPRINGTAIL
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	SpiderCatalog.apply_to_config(config, progress)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	config.course_boundaries_enabled = true
	config.course_boundaries_lethal = true
	var geometry := _test_geometry()
	geometry.boundary_surfaces.append(
		_rectangle_polygon(Rect2(0.0, 640.0, 900.0, 60.0)))

	var spent := SimulationWorld.new()
	spent.reset(config, geometry)
	spent.position = Vector2(360.0, 620.0)
	spent.velocity = Vector2(120.0, 600.0)
	var events := spent.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.SURFACE_BOUNCED) or \
			_contains_event(events, SimulationEvent.Kind.DEATH_REQUESTED) or \
			spent.surface_bounce_ready or spent.velocity.y >= 0.0:
		failures.append("charged Springtail did not survive one moderate rail hit")
		return 0
	spent.position = Vector2(360.0, 620.0)
	spent.velocity = Vector2(120.0, 600.0)
	events = spent.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.DEATH_REQUESTED):
		failures.append("spent impact shell survived a second rail hit")
		return 0

	var rearmed := SimulationWorld.new()
	rearmed.reset(config, geometry)
	rearmed.position = Vector2(360.0, 620.0)
	rearmed.velocity = Vector2(120.0, 600.0)
	rearmed.step(FIXED_DELTA)
	rearmed.queue_command(InputCommand.attach(Vector2(480.0, 150.0), 1, 1))
	events = rearmed.step(FIXED_DELTA)
	if not rearmed.web.attached or not rearmed.surface_bounce_ready:
		failures.append("upper web contact did not recharge the impact shell")
		return 0
	var reported_rearm := false
	for event: SimulationEvent in events:
		if event.kind == SimulationEvent.Kind.ATTACHED and \
				bool(event.data.get("surface_bounce_rearmed", false)):
			reported_rearm = true
	if not reported_rearm:
		failures.append("impact shell recharge was not exposed to presentation")
		return 0

	var hard_hit := SimulationWorld.new()
	hard_hit.reset(config, geometry)
	hard_hit.position = Vector2(360.0, 620.0)
	hard_hit.velocity = Vector2(120.0, 900.0)
	events = hard_hit.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.DEATH_REQUESTED) or \
			_contains_event(events, SimulationEvent.Kind.SURFACE_BOUNCED):
		failures.append("impact shell incorrectly survived an excessive rail hit")
		return 0

	var obstacle_geometry := _test_geometry()
	obstacle_geometry.obstacles.append(
		_rectangle_polygon(Rect2(330.0, 350.0, 100.0, 100.0)))
	var obstacle_hit := SimulationWorld.new()
	obstacle_hit.reset(config, obstacle_geometry)
	obstacle_hit.position = Vector2(360.0, 390.0)
	obstacle_hit.velocity = Vector2.ZERO
	events = obstacle_hit.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.DEATH_REQUESTED) or \
			_contains_event(events, SimulationEvent.Kind.SURFACE_BOUNCED):
		failures.append("impact shell incorrectly protected obstacle contact")
		return 0

	var pull_hit := SimulationWorld.new()
	pull_hit.reset(config, geometry)
	if not pull_hit._start_pull(
		Vector2(220.0, 684.0),
		0.95,
		0.20,
		0.0,
		0.0,
		&"dive",
	):
		failures.append("impact shell pull-collision fixture did not start")
		return 0
	var pull_died := false
	for _index in range(20):
		events = pull_hit.step(FIXED_DELTA)
		if _contains_event(events, SimulationEvent.Kind.DEATH_REQUESTED):
			pull_died = true
			break
	if not pull_died:
		failures.append("impact shell incorrectly protected a pull into a rail")
		return 0
	return 1


static func _test_collectibles_are_swept_and_not_respawned(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	var geometry := _test_geometry()
	var fly := Vector2(260.0, 390.0)
	var boost := Vector2(300.0, 390.0)
	geometry.fly_positions.append(fly)
	geometry.boost_positions.append(boost)
	var world := SimulationWorld.new()
	world.reset(config, geometry)
	world.velocity = Vector2(6000.0, 0.0)
	var events := world.step(FIXED_DELTA)
	if world.run_flies != 1 or \
			not _contains_event(events, SimulationEvent.Kind.FLY_COLLECTED) or \
			not _contains_event(events, SimulationEvent.Kind.BOOST_COLLECTED):
		failures.append("swept pickup path missed a fly or boost")
		return 0
	world.set_course_geometry(geometry)
	if not world.fly_positions.is_empty() or not world.boost_positions.is_empty():
		failures.append("stream refresh respawned collected pickups")
		return 0
	return 1


static func _test_burst_frenzy_suppresses_only_cooldown(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	var world := SimulationWorld.new()
	world.reset(config, _test_geometry())
	world.dive_ready = false
	world.set_burst_cooldown_suppressed(true)
	world.queue_command(InputCommand.burst_at(Vector2(640.0, 150.0), 1, 0))
	var events := world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.BURST_STARTED) or \
			world.burst_cooldown_remaining > 0.0:
		failures.append("Burst Frenzy did not suppress Burst cooldown")
		return 0
	if world.dive_ready:
		failures.append("Burst Frenzy incorrectly rearmed the separate Dive charge")
		return 0
	var effects := EffectState.new()
	effects.activate(EffectState.BURST_FRENZY, 0.05)
	if not effects.is_active(EffectState.BURST_FRENZY):
		failures.append("Burst Frenzy did not activate")
		return 0
	if not effects.advance(0.03).is_empty() or \
			effects.advance(0.03) != PackedStringArray([EffectState.BURST_FRENZY]):
		failures.append("Burst Frenzy expiry is not deterministic")
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
		_rectangle_polygon(Rect2(0.0, 112.0, 1400.0, 38.0)))
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

extends RefCounted
class_name Phase0PhysicsTests
## Deterministic regression suite for GDD Phase 0 contracts.

const FIXED_DELTA := 1.0 / 60.0
const TRACE_PATH := "res://tests/fixtures/phase0_trace.json"


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0

	passed += _test_presets(failures)
	passed += _test_forward_drive_is_zero_in_every_preset(failures)
	passed += _test_baseline_preset_id_and_legacy_migration(failures)
	passed += _test_reel_resource_baseline_and_resolution(failures)
	passed += _test_gradual_speed_curve_reaches_full_pace_at_ten_kilometres(
		failures)
	passed += _test_bird_can_never_outrun_the_spider_ceiling(failures)
	passed += _test_overspeed_is_corrected_independently_of_drive(failures)
	passed += _test_bird_x_uses_its_own_world_law(failures)
	passed += _test_bird_world_rate_rises_with_distance(failures)
	passed += _test_bird_y_follows_with_damped_lag(failures)
	passed += _test_bird_contact_reuses_camera_boundary_death(failures)
	passed += _test_zero_bird_speed_disables_contact_and_motion(failures)
	passed += _test_rescue_restores_the_configured_bird_gap(failures)
	passed += _test_bird_flap_clock_and_state_are_deterministic(failures)
	passed += _test_release_quality_rewards_wide_rising_arc(failures)
	passed += _test_release_quality_rejects_poor_timing(failures)
	passed += _test_release_quality_is_capped_and_resets(failures)
	passed += _test_release_arc_is_wrap_safe_and_jitter_bounded(failures)
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
	passed += _test_level_zero_burst_cadence_is_unchanged(failures)
	passed += _test_reserve_burst_stores_and_refills_serially(failures)
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
	passed += _test_region_pattern_pools_stay_varied(failures)
	passed += _test_floor_grown_hazards_are_lethal_but_not_tappable(failures)
	passed += _test_dying_window_is_not_eaten_by_an_in_flight_tap(failures)
	passed += _test_spider_profiles_and_glide_share_one_config(failures)
	passed += _test_creator_pattern_drives_deterministic_chunks(failures)
	passed += _test_course_stream_places_lower_anchor_windows(failures)
	passed += _test_early_routes_are_obstacle_aware_and_late_gaps_are_clear(
		failures)
	passed += _test_gate_fly_route_is_traversable(failures)
	passed += _test_curated_pattern_catalog_is_banded_and_varied(failures)
	passed += _test_course_regions_are_seeded_distinct_and_recoverable(
		failures)
	passed += _test_bramble_owns_distinct_obstacle_vocabulary(failures)
	passed += _test_bramble_clearance_has_reaction_and_recovery_time(failures)
	passed += _test_checkpoint_practice_starts_safe_and_is_non_record(
		failures)
	passed += _test_debug_start_awards_nothing_and_sets_no_record(failures)
	passed += _test_debug_start_matches_seeded_geometry_from_zero(failures)
	passed += _test_authored_weaves_and_small_silk_burrs_are_fair(failures)
	passed += _test_contoured_rails_are_continuous_and_varied(failures)
	passed += _test_obstacle_collision_is_authoritative(failures)
	passed += _test_boundary_lethality_is_a_toggle(failures)
	passed += _test_buckler_impact_shell_is_bounded(failures)
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
			not is_equal_approx(balanced.reel_retraction_rate, 320.0) or \
			not is_equal_approx(balanced.reel_energy_capacity, 60.0) or \
			not is_equal_approx(balanced.burst_distance_fraction, 0.40) or \
			not is_equal_approx(balanced.burst_minimum_distance, 80.0) or \
			not is_equal_approx(balanced.release_momentum_bonus_speed, 100.0) or \
			not is_equal_approx(balanced.speed_curve_distance, 100000.0) or \
			not is_equal_approx(
				balanced.overspeed_correction_acceleration, 117.5) or \
			not is_equal_approx(balanced.bird_ceiling_share, 0.62) or \
			not is_equal_approx(balanced.maximum_speed_cap, 900.0) or \
			not is_equal_approx(
				balanced.tight_corridor_start_distance, 20000.0) or \
			not balanced.course_boundaries_lethal:
		failures.append(
			"balanced baseline lost its weaker base, pacing, or rail defaults")
		return 0
	return 1


static func _test_forward_drive_is_zero_in_every_preset(
	failures: PackedStringArray,
) -> int:
	for name: StringName in SwingConfig.preset_names():
		var config := SwingConfig.from_preset(name)
		if not is_zero_approx(config.horizontal_drive_acceleration):
			failures.append("preset %s still grants continuous forward drive" % name)
			return 0
		config.gravity = 0.0001
		config.air_drag = 0.0
		var result := SpiderMotor.apply_forces(
			Vector2(100.0, 0.0), 0.0, FIXED_DELTA, config)
		var resolved_velocity: Vector2 = result["velocity"]
		if resolved_velocity.x > 100.001:
			failures.append("preset %s rebuilt speed below its reference curve" % name)
			return 0
	return 1


static func _test_baseline_preset_id_and_legacy_migration(
	failures: PackedStringArray,
) -> int:
	if SwingConfig.PRESET_BALANCED != &"balanced_baseline":
		failures.append(
			"the approved baseline preset must be named balanced_baseline")
		return 0
	# A save written before the 2026-07-31 promotion carries the old id. It has
	# to land on the baseline deliberately, not by falling through an
	# unknown-name default that happens to point at the same preset.
	if SwingConfig.resolve_preset(&"balanced_candidate") \
			!= SwingConfig.PRESET_BALANCED:
		failures.append("legacy balanced_candidate no longer resolves to the baseline")
		return 0
	if SwingConfig.resolve_preset(&"weighty_candidate") \
			!= SwingConfig.PRESET_WEIGHTY:
		failures.append("a current preset id must resolve to itself")
		return 0
	if SwingConfig.resolve_preset(&"not_a_preset") != &"":
		failures.append(
			"an unknown preset must resolve to the empty name so callers can reject it")
		return 0
	var migrated := PlayerSettings.from_dictionary({
		"swing_preset": "balanced_candidate",
	})
	if migrated.swing_preset != SwingConfig.PRESET_BALANCED:
		failures.append("a pre-rename save did not migrate onto the baseline preset")
		return 0
	var kept := PlayerSettings.from_dictionary({"swing_preset": "agile_candidate"})
	if kept.swing_preset != SwingConfig.PRESET_AGILE:
		failures.append("migration clobbered a still-valid stored preset")
		return 0
	return 1


static func _test_reel_resource_baseline_and_resolution(
	failures: PackedStringArray,
) -> int:
	var base := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var base_seconds := base.reel_energy_capacity / base.reel_drain_rate
	var base_shortening_budget := base_seconds * base.reel_retraction_rate
	if not is_equal_approx(base_seconds, 2.0) or \
			not is_equal_approx(base_shortening_budget, 640.0):
		failures.append(
			"level-zero Reel is not the corrected 2.0 s / 640 px baseline")
		return 0

	var weighty := SwingConfig.from_preset(SwingConfig.PRESET_WEIGHTY)
	var agile := SwingConfig.from_preset(SwingConfig.PRESET_AGILE)
	if not is_equal_approx(weighty.reel_retraction_rate, 335.0) or \
			not is_equal_approx(agile.reel_retraction_rate, 350.0):
		failures.append(
			"named Reel presets lost their response ordering after correction")
		return 0

	var progress := PlayerProgress.defaults()
	for upgrade_id: String in [
		"classic_reel",
		"classic_reel_capacity",
		"classic_reel_recovery",
	]:
		progress.upgrade_levels[upgrade_id] = SpiderCatalog.MAX_UPGRADE_LEVEL
	var resolved := SpiderCatalog.resolved_config(
		SwingConfig.PRESET_BALANCED,
		progress,
	)
	var max_seconds := (
		resolved.reel_energy_capacity / resolved.reel_drain_rate)
	var max_shortening_budget := (
		max_seconds * resolved.reel_retraction_rate)
	if not is_equal_approx(resolved.reel_retraction_rate, 454.4) or \
			not is_equal_approx(max_seconds, 2.672) or \
			absf(max_shortening_budget - 1214.1568) > 0.01 or \
			resolved.reel_retraction_rate < 450.0 or \
			resolved.reel_retraction_rate > 470.0:
		failures.append(
			"maxed Garden Reel does not deliver the bounded forty-level gain")
		return 0

	var reused := SpiderCatalog.resolved_config(
		SwingConfig.PRESET_BALANCED,
		progress,
	)
	reused.apply_preset(SwingConfig.PRESET_BALANCED)
	SpiderCatalog.apply_to_config(reused, progress)
	if not is_equal_approx(
			reused.reel_energy_capacity,
			resolved.reel_energy_capacity,
	) or not is_equal_approx(
			reused.reel_regeneration_rate,
			resolved.reel_regeneration_rate,
	) or not is_equal_approx(
			reused.reel_empty_lockout,
			resolved.reel_empty_lockout,
	):
		failures.append("preset reapplication compounded Reel upgrade modifiers")
		return 0

	base.set_tuning_value(&"reel_capacity_seconds", 1.4)
	if not is_equal_approx(
			base.value_for(&"reel_capacity_seconds"),
			1.4,
	) or not is_equal_approx(base.reel_energy_capacity, 42.0):
		failures.append("Full Reel time debug tuning is not authoritative")
		return 0
	return 1


## Owner directive 2026-08-02: pace rises more gradually and reaches its
## maximum at 10 km, not 5 km. The midpoint assertion is what makes this a
## curve test rather than an endpoint test — a linear ramp would pass the ends.
static func _test_gradual_speed_curve_reaches_full_pace_at_ten_kilometres(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var speeds := [
		config.target_speed_at(0.0),
		config.target_speed_at(20000.0),
		config.target_speed_at(60000.0),
		config.target_speed_at(100000.0),
		config.target_speed_at(160000.0),
	]
	if not is_equal_approx(float(speeds[0]), config.starting_target_speed) or \
			float(speeds[1]) >= 440.0 or \
			float(speeds[2]) >= config.maximum_target_speed or \
			not is_equal_approx(float(speeds[3]), config.maximum_target_speed) or \
			not is_equal_approx(float(speeds[4]), config.maximum_target_speed):
		failures.append("target speed no longer grows gradually to full pace at 10,000 m")
		return 0
	for index in range(speeds.size() - 1):
		if float(speeds[index]) > float(speeds[index + 1]):
			failures.append("target speed curve is not monotonic")
			return 0
	return 1


## The invariant the owner asked for, proved rather than tuned.
##
## A linear pursuer against a spider whose pace curve flattens is a guaranteed
## wall: before this bound the bird overtook the spider ceiling at roughly
## 68 km, so a good enough run ended on arithmetic. The bird exists to make
## dangling and ceiling-hauling non-viable, never to outrun a spider that is
## swinging well.
##
## Swept far past the authored 35 km precisely because the old failure was
## invisible inside the authored range.
static func _test_bird_can_never_outrun_the_spider_ceiling(
	failures: PackedStringArray,
) -> int:
	for preset: String in SwingConfig.preset_names():
		var config := SwingConfig.from_preset(StringName(preset))
		var distance := 0.0
		while distance <= 2000000.0:
			var bird := config.bird_speed_at(distance)
			var cap := config.spider_speed_cap_at(distance)
			if bird >= cap:
				failures.append(
					("pursuer reaches %.1f px/s against a spider ceiling of "
						+ "%.1f px/s at %.0f m on preset %s — a well-swung run "
						+ "would become unwinnable by arithmetic")
						% [bird, cap, distance / 10.0, preset])
				return 0
			distance += 5000.0
	# The bound must be structural, not a coincidence of the shipped numbers:
	# a pursuer configured absurdly fast still may not pass the ceiling.
	var extreme := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	extreme.bird_speed = 900.0
	extreme.bird_acceleration = 100.0
	for sample in [0.0, 50000.0, 250000.0, 1000000.0]:
		if extreme.bird_speed_at(float(sample)) >= \
				extreme.spider_speed_cap_at(float(sample)):
			failures.append(
				"an extreme pursuer configuration escaped the spider ceiling")
			return 0
	# The cap is its own curve now, not an offset from the reference. Its
	# opening value must stay where it was (the reference no longer describes
	# how fast the spider actually travels, so a fixed offset was tight at the
	# start and inert past 3 km), and it must rise monotonically to its top.
	var shaped := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var opening := shaped.starting_target_speed + \
		shaped.maximum_horizontal_overspeed
	if not is_equal_approx(shaped.spider_speed_cap_at(0.0), opening):
		failures.append("the opening speed cap moved off starting + overspeed")
		return 0
	if not is_equal_approx(
			shaped.spider_speed_cap_at(shaped.speed_curve_distance),
			shaped.maximum_speed_cap):
		failures.append("the speed cap does not reach its top at full distance")
		return 0
	var previous := 0.0
	for step in range(0, 21):
		var here := shaped.spider_speed_cap_at(
			float(step) * shaped.speed_curve_distance / 10.0)
		if here < previous - 0.0001:
			failures.append("the speed cap curve is not monotonic")
			return 0
		previous = here
	# A cap top below the opening cap is incoherent and must be rejected.
	var inverted := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	inverted.maximum_speed_cap = 100.0
	if inverted.validate().is_empty():
		failures.append("a speed cap below the opening cap was accepted")
		return 0
	# And a share at or above 1.0 must be rejected outright rather than clamped.
	var invalid := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	invalid.bird_ceiling_share = 1.0
	if invalid.validate().is_empty():
		failures.append("a bird ceiling share of 1.0 was accepted as valid")
		return 0
	return 1


## The ceiling is independent of the floor, which is the repair this contract
## exists to hold. Both branches of `SpiderMotor.apply_forces` were scaled by
## `horizontal_drive_acceleration` until 2026-08-02, so zeroing the drive to
## remove the free forward push silently removed the speed limit too. Drive
## must stay zero AND overspeed must still be corrected.
static func _test_overspeed_is_corrected_independently_of_drive(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	if not is_equal_approx(config.horizontal_drive_acceleration, 0.0):
		failures.append("the free forward drive is no longer zero")
		return 0
	var cap := config.spider_speed_cap_at(0.0)
	# Well above the cap: the correction must pull it down.
	var fast := SpiderMotor.apply_forces(
		Vector2(cap + 300.0, 0.0), 0.0, 1.0 / 60.0, config)
	var fast_x := float(Vector2(fast["velocity"]).x)
	if fast_x >= cap + 300.0:
		failures.append(
			"speed above the cap was not corrected downward (%.1f px/s)"
				% fast_x)
		return 0
	# Comfortably below the cap: nothing may push it up, because the floor is
	# deliberately gone. Drag alone may still bleed it.
	var slow_start := cap - 200.0
	var slow := SpiderMotor.apply_forces(
		Vector2(slow_start, 0.0), 0.0, 1.0 / 60.0, config)
	if float(Vector2(slow["velocity"]).x) > slow_start:
		failures.append("a free forward push has returned below the cap")
		return 0
	# Zero disables the limiter, reproducing the accidental post-#102 world.
	var unlimited := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	unlimited.overspeed_correction_acceleration = 0.0
	unlimited.air_drag = 0.0
	var runaway := SpiderMotor.apply_forces(
		Vector2(cap + 300.0, 0.0), 0.0, 1.0 / 60.0, unlimited)
	if not is_equal_approx(float(Vector2(runaway["velocity"]).x), cap + 300.0):
		failures.append("zero pull-back no longer disables the speed limiter")
		return 0
	return 1


static func _bird_test_config() -> SwingConfig:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.air_drag = 0.0
	config.guided_start_enabled = false
	config.course_boundaries_enabled = false
	config.rescue_life_enabled = false
	config.bird_speed = 300.0
	config.bird_acceleration = 0.0
	config.bird_start_offset = 760.0
	return config


static func _test_bird_x_uses_its_own_world_law(
	failures: PackedStringArray,
) -> int:
	var config := _bird_test_config()
	var slow := SimulationWorld.new()
	var fast := SimulationWorld.new()
	slow.reset(config, CourseGeometry.new())
	fast.reset(config, CourseGeometry.new())
	slow.velocity = Vector2.ZERO
	fast.velocity = Vector2(900.0, 0.0)
	var start_x := slow.bird_position.x
	for _index in range(30):
		slow.step(FIXED_DELTA)
		fast.step(FIXED_DELTA)
	if absf(slow.bird_position.x - fast.bird_position.x) > 0.001 or \
			absf(slow.bird_position.x - start_x - 150.0) > 0.001:
		failures.append("bird X matched player speed instead of its own world law")
		return 0
	return 1


static func _test_bird_world_rate_rises_with_distance(
	failures: PackedStringArray,
) -> int:
	var config := _bird_test_config()
	config.bird_acceleration = 12.0
	var opening := SimulationWorld.new()
	var late := SimulationWorld.new()
	opening.reset(config, CourseGeometry.new(), 0.0)
	late.reset(config, CourseGeometry.new(), 50000.0)
	# Hold player distance fixed so this contract measures the bird law at the
	# stated 0.001 px/s resolution, not the opening launch's first-tick travel.
	opening.velocity = Vector2.ZERO
	late.velocity = Vector2.ZERO
	opening.step(FIXED_DELTA)
	late.step(FIXED_DELTA)
	# `measured` from the config law at 0.001 px/s resolution: +12 px/s per
	# 1,000 m makes the 5,000 m bird exactly 60 px/s faster.
	if absf(opening.bird_velocity.x - 300.0) > 0.001 or \
			absf(late.bird_velocity.x - 360.0) > 0.001:
		failures.append("bird pressure no longer rises predictably with distance")
		return 0
	return 1


static func _test_bird_y_follows_with_damped_lag(
	failures: PackedStringArray,
) -> int:
	var config := _bird_test_config()
	config.bird_start_offset = 1600.0
	var world := SimulationWorld.new()
	world.reset(config, CourseGeometry.new())
	world.velocity = Vector2(900.0, 0.0)
	world.position.y = 600.0
	var initial_y := world.bird_position.y
	world.step(FIXED_DELTA)
	if world.bird_position.y <= initial_y or \
			world.bird_position.y >= world.position.y or \
			world.bird_velocity.y <= 0.0:
		failures.append("bird Y snapped to the spider instead of beginning a damped follow")
		return 0
	for _index in range(59):
		world.step(FIXED_DELTA)
	if absf(world.position.y - world.bird_position.y) >= \
			absf(world.position.y - initial_y):
		failures.append("damped bird follow did not converge on player height")
		return 0
	return 1


static func _test_bird_contact_reuses_camera_boundary_death(
	failures: PackedStringArray,
) -> int:
	var config := _bird_test_config()
	config.bird_speed = 1.0
	config.bird_start_offset = 300.0
	var world := SimulationWorld.new()
	world.reset(config, CourseGeometry.new())
	world.position.x = world.left_kill_boundary() - 10.0
	world.velocity = Vector2.ZERO
	var events := world.step(FIXED_DELTA)
	var death := _first_event(events, SimulationEvent.Kind.DEATH_REQUESTED)
	if death == null or StringName(death.data.get("cause", &"")) != \
			&"camera_boundary" or not death.message.contains("bird"):
		failures.append("visible bird contact bypassed the existing death path")
		return 0
	return 1


static func _test_zero_bird_speed_disables_contact_and_motion(
	failures: PackedStringArray,
) -> int:
	var config := _bird_test_config()
	config.bird_speed = 0.0
	config.bird_acceleration = 100.0
	var world := SimulationWorld.new()
	world.reset(config, CourseGeometry.new(), 50000.0)
	var start := world.bird_position
	world.position.x = start.x - 500.0
	for _index in range(120):
		var events := world.step(FIXED_DELTA)
		if _contains_event(events, SimulationEvent.Kind.DEATH_REQUESTED):
			failures.append("bird-off run still emitted a pursuer death")
			return 0
	if world.bird_enabled() or world.bird_position != start or \
			world.bird_velocity != Vector2.ZERO or \
			not is_zero_approx(world.bird_flap_rate):
		failures.append("bird speed zero did not disable state, drawing eligibility, and death")
		return 0
	return 1


static func _test_rescue_restores_the_configured_bird_gap(
	failures: PackedStringArray,
) -> int:
	var config := _bird_test_config()
	config.bird_start_offset = 880.0
	var world := SimulationWorld.new()
	world.reset(config, CourseGeometry.new())
	world.position = Vector2(1400.0, 640.0)
	world.bird_position.x = world.position.x - 40.0 - \
		SimulationWorld.BIRD_CONTACT_LEAD_X
	world.rescue_after_death()
	if absf(world.bird_gap() - 880.0) > 0.001 or \
			absf(world.bird_velocity.x - config.bird_speed_at(
				world.distance_pixels)) > 0.001:
		failures.append("rescue did not restore the configured bird buffer")
		return 0
	return 1


static func _test_bird_flap_clock_and_state_are_deterministic(
	failures: PackedStringArray,
) -> int:
	var config := _bird_test_config()
	var first := SimulationWorld.new()
	var second := SimulationWorld.new()
	for world: SimulationWorld in [first, second]:
		world.reset(config, CourseGeometry.new())
		world.velocity = Vector2(900.0, 0.0)
	for _index in range(90):
		first.step(FIXED_DELTA)
		second.step(FIXED_DELTA)
	if first.bird_position != second.bird_position or \
			first.bird_velocity != second.bird_velocity or \
			first.bird_flap_phase != second.bird_flap_phase or \
			first.bird_flap_rate != second.bird_flap_rate:
		failures.append("identical fixed-tick bird histories diverged")
		return 0
	# `measured` at one fixed-tick resolution: 90 ticks × 700 clock units,
	# wrapped on the 60,000-unit phase clock, is exactly 0.05.
	if first.bird_closing or first.bird_flap_rate > 0.71 or \
			absf(first.bird_flap_phase - 0.05) > 0.000001:
		failures.append("well-buffered bird did not ease into its glide cadence")
		return 0
	first.velocity = Vector2.ZERO
	first.bird_position.x = first.position.x - 180.0 - \
		SimulationWorld.BIRD_CONTACT_LEAD_X
	first.step(FIXED_DELTA)
	if not first.bird_closing or first.bird_flap_rate <= 0.71 or \
			first.bird_flap_phase < 0.0 or first.bird_flap_phase >= 1.0:
		failures.append("closing bird did not raise its deterministic flap cadence")
		return 0
	return 1


static func _test_release_quality_rewards_wide_rising_arc(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	var explicit := SimulationWorld.new()
	if not _prime_release_world(
			explicit, config, Vector2(700.0, 390.0), Vector2(400.0, -300.0)):
		failures.append("release-quality fixture could not attach its opening web")
		return 0
	explicit.queue_command(InputCommand.release(1, 0))
	var events := explicit.step(FIXED_DELTA)
	var release_event := _first_event(events, SimulationEvent.Kind.RELEASED)
	if release_event == null:
		failures.append("explicit release emitted no authoritative RELEASED event")
		return 0
	# `measured` by the pinned 60 Hz fixture at 0.001 px/s resolution: a 90°
	# arc and (400, -300) velocity produce rise quality 0.6, hence 60 px/s
	# from the `assumed` 100 px/s maximum award.
	if absf(float(release_event.data.get("release_arc_degrees", 0.0)) - 90.0) \
			> 0.001 or \
			absf(float(release_event.data.get("release_quality", 0.0)) - 0.6) \
			> 0.001 or \
			absf(float(release_event.data.get("forward_bonus", 0.0)) - 60.0) \
			> 0.001 or \
			absf(float(release_event.data.get("velocity_after_x", 0.0)) - 460.0) \
			> 0.001 or \
			absf(float(release_event.data.get("velocity_after_y", 0.0)) + 300.0) \
			> 0.001:
		failures.append(
			"wide rising release did not convert its measured quality into 60 px/s")
		return 0

	# Device taps arrive as ATTACH commands even when the web is already held.
	# That live route and the replay/bot RELEASE route must resolve identically.
	var tapped := SimulationWorld.new()
	if not _prime_release_world(
			tapped, config, Vector2(700.0, 390.0), Vector2(400.0, -300.0)):
		failures.append("attached-tap release fixture could not attach its opening web")
		return 0
	tapped.queue_command(InputCommand.attach(Vector2(900.0, 150.0), 1, 0))
	var tap_event := _first_event(
		tapped.step(FIXED_DELTA), SimulationEvent.Kind.RELEASED)
	if tap_event == null or \
			absf(float(tap_event.data.get("forward_bonus", 0.0)) - 60.0) > 0.001 or \
			tapped.velocity.distance_to(explicit.velocity) > 0.001:
		failures.append(
			"attached tap and explicit release produced different momentum")
		return 0
	return 1


static func _test_release_quality_rejects_poor_timing(
	failures: PackedStringArray,
) -> int:
	var base := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	base.gravity = 0.0001
	base.horizontal_drive_acceleration = 0.0001
	base.air_drag = 0.0
	var cases := [
		{
			"name": "falling",
			"position": Vector2(700.0, 390.0),
			"velocity": Vector2(400.0, 300.0),
			"bonus": 100.0,
		},
		{
			"name": "immediate",
			"position": Vector2(220.0, 390.0),
			"velocity": Vector2(400.0, -300.0),
			"bonus": 100.0,
		},
		{
			"name": "backward",
			"position": Vector2(700.0, 390.0),
			"velocity": Vector2(-400.0, -300.0),
			"bonus": 100.0,
		},
		{
			"name": "disabled",
			"position": Vector2(700.0, 390.0),
			"velocity": Vector2(400.0, -300.0),
			"bonus": 0.0,
		},
	]
	for item: Dictionary in cases:
		var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
		config.gravity = base.gravity
		config.horizontal_drive_acceleration = base.horizontal_drive_acceleration
		config.air_drag = base.air_drag
		config.release_momentum_bonus_speed = float(item["bonus"])
		var world := SimulationWorld.new()
		if not _prime_release_world(
				world, config, item["position"], item["velocity"]):
			failures.append("%s release fixture could not attach" % item["name"])
			return 0
		world.queue_command(InputCommand.release(1, 0))
		var event := _first_event(world.step(FIXED_DELTA), SimulationEvent.Kind.RELEASED)
		if event == null or \
				absf(float(event.data.get("forward_bonus", -1.0))) > 0.001 or \
				absf(float(event.data.get("velocity_after_x", 0.0)) - \
					float(event.data.get("velocity_before_x", 1.0))) > 0.001:
			failures.append("%s release manufactured forward momentum" % item["name"])
			return 0

	# Stay on the eligible side of the anchor so this fixture isolates arc
	# quality. `Inferred` from the constructed ±1 px horizontal crossing at a
	# 240 px vertical offset: the covered arc is below 1° and therefore earns
	# below 1 px/s at the `assumed` 100 px/s maximum. Assertions resolve 0.001.
	# Without this case, the side gate could hide a broken arc multiplier.
	var narrow_config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	narrow_config.gravity = base.gravity
	narrow_config.horizontal_drive_acceleration = base.horizontal_drive_acceleration
	narrow_config.air_drag = base.air_drag
	var narrow := SimulationWorld.new()
	var narrow_attach_position := Vector2(459.0, 390.0)
	var narrow_release_position := Vector2(461.0, 390.0)
	if not _prime_release_world(
			narrow,
			narrow_config,
			narrow_release_position,
			Vector2(400.0, -300.0),
			narrow_attach_position,
	):
		failures.append("narrow release fixture could not attach")
		return 0
	narrow.queue_command(InputCommand.release(1, 0))
	var narrow_event := _first_event(
		narrow.step(FIXED_DELTA), SimulationEvent.Kind.RELEASED)
	if narrow_event == null or \
			float(narrow_event.data.get("release_arc_degrees", 90.0)) >= 1.0 or \
			float(narrow_event.data.get("forward_bonus", 100.0)) >= 1.0:
		failures.append("sub-degree rising release received a wide-arc award")
		return 0

	# Burst and Dive own separate exit-speed laws. Their forced rope detach must
	# not also collect a manual-release award on the way into the pull.
	var burst := SimulationWorld.new()
	if not _prime_release_world(
			burst,
			base,
			Vector2(700.0, 390.0),
			Vector2(400.0, -300.0),
	):
		failures.append("forced-detach release fixture could not attach")
		return 0
	burst.queue_command(InputCommand.burst(1, 0))
	var burst_events := burst.step(FIXED_DELTA)
	if not _contains_event(burst_events, SimulationEvent.Kind.BURST_STARTED) or \
			_contains_event(burst_events, SimulationEvent.Kind.RELEASED) or \
			absf(burst.velocity.x - 400.0) > 0.001:
		failures.append("forced Burst detach collected a manual-release award")
		return 0
	return 1


static func _test_release_quality_is_capped_and_resets(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	# 2026-08-02: the award is bounded by `spider_speed_cap_at`, the same curve
	# the motor corrects toward, so the game has one ceiling instead of two that
	# could disagree. Asserted against the function rather than a literal, so a
	# retune of the cap cannot silently make this contract vacuous.
	config.maximum_horizontal_overspeed = 450.0
	var capped := SimulationWorld.new()
	if not _prime_release_world(
			capped, config, Vector2(700.0, 390.0), Vector2(800.0, -600.0)):
		failures.append("capped release fixture could not attach")
		return 0
	var cap_here := config.spider_speed_cap_at(capped.distance_pixels)
	capped.queue_command(InputCommand.release(1, 0))
	capped.queue_command(InputCommand.release(2, 0))
	var events := capped.step(FIXED_DELTA)
	var release_count := 0
	var release_event: SimulationEvent = null
	for event: SimulationEvent in events:
		if event.kind == SimulationEvent.Kind.RELEASED:
			release_count += 1
			release_event = event
	if release_event == null or release_count != 1:
		failures.append("release award duplicated or did not fire")
		return 0
	var before_x := float(release_event.data.get("velocity_before_x", 0.0))
	var after_x := float(release_event.data.get("velocity_after_x", 0.0))
	var bonus := float(release_event.data.get("forward_bonus", 0.0))
	if after_x > cap_here + 0.05 or \
			absf(after_x - cap_here) > 0.05 or \
			absf(bonus - (cap_here - before_x)) > 0.05:
		failures.append("release award ignored the shared speed cap or duplicated")
		return 0

	# Reset and reuse the same world, then compare it with a fresh world. Old arc
	# history must not leak into the next attachment or replay.
	var reused := capped
	var fresh := SimulationWorld.new()
	for world: SimulationWorld in [reused, fresh]:
		if not _prime_release_world(
				world, config, Vector2(220.0, 390.0), Vector2(400.0, -300.0)):
			failures.append("reset release fixture could not attach")
			return 0
		world.queue_command(InputCommand.release(1, 0))
	var reused_event := _first_event(
		reused.step(FIXED_DELTA), SimulationEvent.Kind.RELEASED)
	var fresh_event := _first_event(
		fresh.step(FIXED_DELTA), SimulationEvent.Kind.RELEASED)
	if reused_event == null or fresh_event == null or \
			reused.velocity.distance_to(fresh.velocity) > 0.001 or \
			float(reused_event.data.get("release_arc_degrees", -1.0)) != \
			float(fresh_event.data.get("release_arc_degrees", -2.0)) or \
			absf(float(reused_event.data.get("forward_bonus", -1.0))) > 0.001:
		failures.append("reset world inherited release arc or momentum")
		return 0
	return 1


static func _test_release_arc_is_wrap_safe_and_jitter_bounded(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.automatic_take_up_enabled = false
	var web := WebConstraint.new()
	web.reset(config)
	var start := Vector2(220.0, 390.0)
	var anchor := Vector2(460.0, 150.0)
	if web.try_attach(start, anchor, config) != WebConstraint.AttachResult.ATTACHED:
		failures.append("wrap-safe arc fixture could not attach")
		return 0
	var radius := start.distance_to(anchor)
	for degrees: float in [179.0, -179.0]:
		web.solve(
			anchor + Vector2.from_angle(deg_to_rad(degrees)) * radius,
			Vector2.ZERO,
			FIXED_DELTA,
			config,
		)
	# `inferred` from the constructed 135° → 179° → -179° geometry: the
	# wrap-safe covered range is 46°, not an almost-complete turn.
	var wrap_arc := rad_to_deg(web.swing_arc_radians())
	if wrap_arc < 45.0 or wrap_arc > 47.0:
		failures.append(
			"arc wrap read %.3f°, expected the small 46° unwrapped range" % wrap_arc)
		return 0

	web.release()
	web.reset(config)
	web.try_attach(start, anchor, config)
	for _cycle in range(40):
		for degrees: float in [130.0, 135.0]:
			web.solve(
				anchor + Vector2.from_angle(deg_to_rad(degrees)) * radius,
				Vector2.ZERO,
				FIXED_DELTA,
				config,
			)
	var jitter_arc := rad_to_deg(web.swing_arc_radians())
	# `Inferred` from the constructed 130°↔135° band: repeating it 40 times
	# remains a 5° range. The extra 0.001° is a comparison tolerance, not tuning.
	if jitter_arc > 5.001:
		failures.append(
			"small-band jitter accumulated into a fake %.3f° wide swing" % jitter_arc)
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
			not is_equal_approx(max_config.automatic_take_up_retention, 0.934):
		failures.append("Balanced Flow retention no longer scales from 85% to 93.4%")
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
			not is_equal_approx(max_web.rope_length, 481.32):
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
			not is_equal_approx(upgraded.burst_minimum_distance, 248.0):
		failures.append("Reliable Launch did not raise minimum Burst travel by level")
		return 0
	return 1


static func _test_upgrade_catalog_has_shared_core_and_breakthroughs(
	failures: PackedStringArray,
) -> int:
	if SpiderCatalog.MAX_UPGRADE_LEVEL != 40 or \
			SpiderCatalog.UPGRADE_COSTS.size() != 40 or \
			SpiderCatalog.UPGRADE_COSTS.reduce(func(total, cost):
				return int(total) + int(cost), 0) != 490 or \
			SpiderCatalog.cost_for_level(0) != 1 or \
			SpiderCatalog.cost_for_level(4) != 5 or \
			SpiderCatalog.cost_for_level(19) != 14 or \
			SpiderCatalog.cost_for_level(39) != 46 or \
			SpiderCatalog.cost_for_level(40) != 0:
		failures.append("forty-level upgrade pacing or its bounded costs regressed")
		return 0
	if SpiderCatalog.effective_steps(4) != 4 or \
			SpiderCatalog.effective_steps(5) != 6 or \
			SpiderCatalog.effective_steps(10) != 12 or \
			SpiderCatalog.effective_steps(20) != 24 or \
			SpiderCatalog.effective_steps(40) != 48:
		failures.append("five-level breakthroughs do not grant a real tuning step")
		return 0
	var old_maximum_steps := 24.0
	var new_maximum_strength := (
		float(SpiderCatalog.effective_steps(40)) *
		SpiderCatalog.EXTENDED_LEVEL_STEP_SCALE)
	if not is_equal_approx(SpiderCatalog.EXTENDED_LEVEL_STEP_SCALE, 0.70) or \
			not is_equal_approx(new_maximum_strength / old_maximum_steps, 1.40):
		failures.append(
			"forty levels no longer give smaller steps and a 40% stronger maximum")
		return 0
	for level in [5, 10, 15, 20, 25, 30, 35, 40]:
		if not SpiderCatalog.is_breakthrough_level(level):
			failures.append("level %d is not marked as a breakthrough" % level)
			return 0
	if SpiderCatalog.is_breakthrough_level(4) or \
			SpiderCatalog.next_breakthrough_level(6) != 10 or \
			SpiderCatalog.next_breakthrough_level(20) != 25 or \
			SpiderCatalog.next_breakthrough_level(40) != 40:
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
		# OQ-13 deliberately leaves persisted `skitter_drive` inert until the
		# owner chooses which earned-speed term Quick Feet should buy.
		[SpiderCatalog.ANCHORITE, &"anchorite_momentum",
			&"burst_exit_speed", 1.0],
		[SpiderCatalog.ANCHORITE, &"anchorite_pendulum",
			&"burst_tangential_retention", 1.0],
		[SpiderCatalog.BALLOONER, &"ballooner_glide",
			&"glide_duration", 1.0],
		[SpiderCatalog.BALLOONER, &"ballooner_reach",
			&"web_maximum_length", 1.0],
		[SpiderCatalog.BUCKLER, &"springtail_shell",
			&"surface_bounce_max_impact_speed", 1.0],
		[SpiderCatalog.BUCKLER, &"springtail_bounce",
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


static func _test_level_zero_burst_cadence_is_unchanged(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	if config.burst_charge_capacity != 1:
		failures.append("level-zero Burst capacity is no longer one charge")
		return 0
	var world := SimulationWorld.new()
	world.reset(config, _test_geometry())
	if world.burst_charges != 1 or world.burst_cooldown_remaining > 0.0:
		failures.append("a fresh run did not start with one idle Burst charge")
		return 0
	world.queue_command(InputCommand.burst_at(Vector2(640.0, 150.0), 1, 0))
	var events := world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.BURST_STARTED) or \
			world.burst_charges != 0:
		failures.append("level-zero Burst did not spend its only charge")
		return 0
	var guard := 0
	while world.pull_active and guard < 120:
		world.step(FIXED_DELTA)
		guard += 1
	world.velocity = Vector2.ZERO
	world.queue_command(InputCommand.burst_at(Vector2(1080.0, 150.0), 2, world.tick))
	events = world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.BURST_UNAVAILABLE):
		failures.append("a spent level-zero Burst was not gated by the cooldown")
		return 0
	guard = 0
	while world.burst_charges < 1 and guard < 200:
		world.step(FIXED_DELTA)
		guard += 1
	world.velocity = Vector2.ZERO
	if world.burst_charges != 1 or world.burst_cooldown_remaining > 0.0:
		failures.append(
			"the level-zero charge did not return exactly once, with an idle timer")
		return 0
	world.queue_command(InputCommand.burst_at(Vector2(1080.0, 150.0), 3, world.tick))
	events = world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.BURST_STARTED):
		failures.append("the refilled level-zero Burst was not usable again")
		return 0
	return 1


static func _test_reserve_burst_stores_and_refills_serially(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	progress.upgrade_levels[&"classic_burst"] = 19
	var below := SpiderCatalog.resolved_config(
		SwingConfig.PRESET_BALANCED, progress)
	if below.burst_charge_capacity != 1:
		failures.append("Anchor Drive level 19 must not grant the reserve Burst")
		return 0
	progress.upgrade_levels[&"classic_burst"] = 20
	var config := SpiderCatalog.resolved_config(
		SwingConfig.PRESET_BALANCED, progress)
	if config.burst_charge_capacity != 2:
		failures.append("Anchor Drive level 20 did not store a second Burst")
		return 0
	config.gravity = 0.0001
	config.horizontal_drive_acceleration = 0.0001
	config.air_drag = 0.0
	var world := SimulationWorld.new()
	world.reset(config, _test_geometry())
	world.queue_command(InputCommand.burst_at(Vector2(640.0, 150.0), 1, 0))
	var events := world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.BURST_STARTED) or \
			world.burst_charges != 1 or world.burst_cooldown_remaining <= 0.0:
		failures.append("the first Burst did not leave one stored charge refilling")
		return 0
	var guard := 0
	while world.pull_active and guard < 120:
		world.step(FIXED_DELTA)
		guard += 1
	world.velocity = Vector2.ZERO
	var timer_before := world.burst_cooldown_remaining
	world.queue_command(InputCommand.burst_at(Vector2(1080.0, 150.0), 2, world.tick))
	events = world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.BURST_STARTED) or \
			world.burst_charges != 0:
		failures.append("the stored Burst was not immediately spendable")
		return 0
	if world.burst_cooldown_remaining > timer_before:
		failures.append("spending the reserve reset the serial refill timer")
		return 0
	guard = 0
	while world.pull_active and guard < 120:
		world.step(FIXED_DELTA)
		guard += 1
	world.velocity = Vector2.ZERO
	guard = 0
	while world.burst_charges < 1 and guard < 200:
		world.step(FIXED_DELTA)
		guard += 1
	world.velocity = Vector2.ZERO
	if world.burst_charges != 1 or \
			world.burst_cooldown_remaining < config.burst_cooldown - 0.05:
		failures.append(
			"the first refilled charge did not restart one full serial window")
		return 0
	guard = 0
	while world.burst_charges < 2 and guard < 200:
		world.step(FIXED_DELTA)
		guard += 1
	world.velocity = Vector2.ZERO
	if world.burst_charges != 2 or world.burst_cooldown_remaining > 0.0:
		failures.append("the reserve did not refill serially to an idle full pool")
		return 0
	world.queue_command(InputCommand.burst_at(Vector2(1080.0, 150.0), 3, world.tick))
	events = world.step(FIXED_DELTA)
	if not _contains_event(events, SimulationEvent.Kind.BURST_STARTED):
		failures.append("the refilled reserve pool was not spendable again")
		return 0
	world.set_burst_cooldown_suppressed(true)
	world.step(FIXED_DELTA)
	if world.burst_charges != 2 or world.burst_cooldown_remaining > 0.0:
		failures.append("Burst Frenzy did not pin the stored charges full")
		return 0
	world.set_burst_cooldown_suppressed(false)
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
	session._world.burst_charges = 0
	session._world.burst_cooldown_remaining = 1.0
	session.request_burst_from_gesture(Vector2(720.0, 150.0))
	if session._command_buffer.size() != 1 or \
			session._command_buffer[0].kind != InputCommand.Kind.ATTACH:
		failures.append(
			"detached double-tap during cooldown swallowed the recovery web")
		session.free()
		return 0
	session._command_buffer.clear()
	session._world.burst_charges = 1
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


static func _test_course_regions_are_seeded_distinct_and_recoverable(
	failures: PackedStringArray,
) -> int:
	var same_a: Array[StringName] = []
	var same_b: Array[StringName] = []
	var different: Array[StringName] = []
	var differences := 0
	var previous := &""
	var hard_streak := 0
	var maximum_hard_streak := 0
	var bramble_ids := {}
	var hollow_ids := {}
	var first_checkpoint_pattern := &""
	for chunk_index in range(11, 130):
		var distance := maxf(
			0.0,
			float(chunk_index) * CourseStream.CHUNK_WIDTH
				- CourseStream.START_X,
		)
		var first := CoursePatternCatalog.pattern_id_for_chunk(
			chunk_index, distance, 77)
		var repeated := CoursePatternCatalog.pattern_id_for_chunk(
			chunk_index, distance, 77)
		var alternate := CoursePatternCatalog.pattern_id_for_chunk(
			chunk_index, distance, 91)
		same_a.append(first)
		same_b.append(repeated)
		different.append(alternate)
		if first != alternate:
			differences += 1
		if first == previous:
			failures.append(
				"seeded director repeated %s in adjacent chunks" % first)
			return 0
		previous = first
		var region := CourseRegionCatalog.region_for_distance(
			distance + CourseStream.CHUNK_WIDTH * 0.5)
		var region_id := StringName(region["id"])
		if bool(region["checkpoint"]) and first_checkpoint_pattern.is_empty():
			first_checkpoint_pattern = first
		if region_id == CourseRegionCatalog.BRAMBLE_CANOPY:
			bramble_ids[first] = true
		elif region_id == CourseRegionCatalog.SILK_HOLLOW:
			hollow_ids[first] = true
		if first == &"open_recovery":
			maximum_hard_streak = maxi(maximum_hard_streak, hard_streak)
			hard_streak = 0
		elif region_id != CourseRegionCatalog.ANCIENT_FOREST:
			hard_streak += 1
	maximum_hard_streak = maxi(maximum_hard_streak, hard_streak)
	if same_a != same_b or differences < 12:
		failures.append(
			"course seeds are not reproducible or do not vary enough chunks")
		return 0
	if first_checkpoint_pattern != &"open_recovery" or \
			maximum_hard_streak > 5:
		failures.append(
			"checkpoint entry or later-region recovery cadence is unsafe")
		return 0
	var has_bramble_hook := bramble_ids.has(&"canopy_hook_high") or \
		bramble_ids.has(&"canopy_hook_low")
	var has_bramble_leaf := bramble_ids.has(&"canopy_leaf_high") or \
		bramble_ids.has(&"canopy_leaf_low")
	var has_bramble_pair := \
		bramble_ids.has(&"canopy_hook_high_low") or \
		bramble_ids.has(&"canopy_hook_low_high") or \
		bramble_ids.has(&"canopy_shutter_high_low") or \
		bramble_ids.has(&"canopy_shutter_low_high")
	if not has_bramble_hook or not has_bramble_leaf or \
			not has_bramble_pair or \
			bramble_ids.has(&"rooted_gate"):
		failures.append(
			"Bramble Canopy lost its high↔low identity")
		return 0
	if not hollow_ids.has(&"hollow_thread_eye") or \
			not (
				hollow_ids.has(&"hollow_cocoon_chute")
					or hollow_ids.has(&"hollow_twin_sacs")
			) or \
			not (
				hollow_ids.has(&"hollow_lattice_high")
					or hollow_ids.has(&"hollow_lattice_low")
			):
		failures.append(
			"Silk Hollow lost its suspended/lattice/thread-eye identity: %s" %
				[hollow_ids.keys()])
		return 0

	var classic := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var route_radius := classic.player_collision_radius + 8.0
	for seed in [7, 77, 707]:
		var stream := CourseStream.new()
		stream.reset(
			10000.0, 0.94, 0.90, 1.12, [], true, 1.0, 1.0,
			20000.0, seed,
		)
		for chunk_index in range(52, 66):
			var chunk_start := float(chunk_index) * CourseStream.CHUNK_WIDTH
			var chunk_end := chunk_start + CourseStream.CHUNK_WIDTH
			var geometry := stream.update_for_position(chunk_start + 1.0)
			for fly: Vector2 in geometry.fly_positions:
				if fly.x < chunk_start or fly.x >= chunk_end:
					continue
				for obstacle: PackedVector2Array in geometry.obstacles:
					var bounds := SolidGeometry.bounds(obstacle)
					if bounds.get_center().x < chunk_start or \
							bounds.get_center().x >= chunk_end:
						continue
					if SolidGeometry.circle_intersects_polygon(
						fly,
						route_radius,
						obstacle,
					):
						failures.append(
							"seed %d guides region route into a hazard" % seed)
						return 0
	return 1


static func _test_bramble_owns_distinct_obstacle_vocabulary(
	failures: PackedStringArray,
) -> int:
	var inherited_ids := {}
	for pool: Array in [
		CoursePatternCatalog.CONTROL_PATTERNS,
		CoursePatternCatalog.MASTERY_PATTERNS,
		CoursePatternCatalog.DEEP_FOREST_PATTERNS,
	]:
		for pattern: Dictionary in pool:
			inherited_ids[StringName(pattern["id"])] = true
	var expected := {
		&"canopy_hook_high": CourseObstacleCatalog.CANOPY_HOOK_VINE_RIGHT,
		&"canopy_hook_low": CourseObstacleCatalog.CANOPY_HOOK_VINE_RIGHT,
		&"canopy_leaf_high": CourseObstacleCatalog.CANOPY_LEAF_SHUTTER_RIGHT,
		&"canopy_leaf_low": CourseObstacleCatalog.CANOPY_LEAF_SHUTTER_RIGHT,
		&"canopy_hook_high_low": CourseObstacleCatalog.CANOPY_HOOK_VINE_LEFT,
		&"canopy_hook_low_high": CourseObstacleCatalog.CANOPY_HOOK_VINE_LEFT,
		&"canopy_shutter_high_low": CourseObstacleCatalog.CANOPY_LEAF_SHUTTER_LEFT,
		&"canopy_shutter_low_high": CourseObstacleCatalog.CANOPY_LEAF_SHUTTER_LEFT,
	}
	for pattern: Dictionary in CoursePatternCatalog.BRAMBLE_CANOPY_PATTERNS:
		var pattern_id := StringName(pattern["id"])
		if inherited_ids.has(pattern_id) or not expected.has(pattern_id):
			failures.append(
				"Bramble still inherits an Ancient Forest obstacle id: %s" %
					pattern_id)
			return 0
	if CoursePatternCatalog.BRAMBLE_CANOPY_PATTERNS.size() != expected.size():
		failures.append("Bramble pattern pool and owned vocabulary drifted")
		return 0

	var found := {}
	var route_radius := \
		SwingConfig.from_preset(SwingConfig.PRESET_BALANCED).player_collision_radius \
			+ 8.0
	for seed in [0, 7, 77, 707]:
		var stream := CourseStream.new()
		stream.reset(
			10000.0, 0.94, 0.90, 1.12, [], true, 1.0, 1.0,
			20000.0, seed,
		)
		for chunk_index in range(52, 105):
			var pattern_id := stream.pattern_id_for_chunk(chunk_index)
			if not expected.has(pattern_id):
				continue
			found[pattern_id] = true
			var chunk_start := float(chunk_index) * CourseStream.CHUNK_WIDTH
			var chunk_end := chunk_start + CourseStream.CHUNK_WIDTH
			var geometry := stream.update_for_position(chunk_start + 1.0)
			var obstacles: Array[PackedVector2Array] = []
			var kinds: Array[StringName] = []
			for obstacle_index in range(geometry.obstacles.size()):
				var obstacle := geometry.obstacles[obstacle_index]
				var bounds := SolidGeometry.bounds(obstacle)
				if bounds.get_center().x < chunk_start or \
						bounds.get_center().x >= chunk_end:
					continue
				obstacles.append(obstacle)
				kinds.append(geometry.obstacle_kind(obstacle_index))
			var is_pair := pattern_id in [
				&"canopy_hook_high_low",
				&"canopy_hook_low_high",
				&"canopy_shutter_high_low",
				&"canopy_shutter_low_high",
			]
			if obstacles.size() != (2 if is_pair else 1):
				failures.append("%s lost its distinct obstacle count" % pattern_id)
				return 0
			var hook_pair := pattern_id in [
				&"canopy_hook_high_low",
				&"canopy_hook_low_high",
			]
			var shutter_pair := pattern_id in [
				&"canopy_shutter_high_low",
				&"canopy_shutter_low_high",
			]
			if hook_pair and (
				not kinds.has(CourseObstacleCatalog.CANOPY_HOOK_VINE_LEFT) or
				not kinds.has(CourseObstacleCatalog.CANOPY_HOOK_VINE_RIGHT)
			):
				failures.append("%s lost its mirrored hook silhouettes" % pattern_id)
				return 0
			if shutter_pair and (
				not kinds.has(CourseObstacleCatalog.CANOPY_LEAF_SHUTTER_LEFT) or
				not kinds.has(CourseObstacleCatalog.CANOPY_LEAF_SHUTTER_RIGHT)
			):
				failures.append("%s lost its mirrored shutter silhouettes" % pattern_id)
				return 0
			for obstacle_index in range(obstacles.size()):
				if not shutter_pair and not hook_pair and \
						kinds[obstacle_index] != StringName(expected[pattern_id]):
					failures.append("%s lost its explicit visual kind" % pattern_id)
					return 0
				var obstacle := obstacles[obstacle_index]
				if not _obstacle_blocks_neutral_lane(obstacle, route_radius):
					failures.append(
						"%s still permits a neutral-centre coast" % pattern_id)
					return 0
			var route_flies: Array[Vector2] = []
			for fly: Vector2 in geometry.fly_positions:
				if fly.x >= chunk_start and fly.x < chunk_end:
					route_flies.append(fly)
			for fly_index in range(route_flies.size() - 1):
				for sample_index in range(11):
					var sample := route_flies[fly_index].lerp(
						route_flies[fly_index + 1],
						float(sample_index) / 10.0,
					)
					for obstacle: PackedVector2Array in obstacles:
						if SolidGeometry.circle_intersects_polygon(
							sample,
							route_radius,
							obstacle,
						):
							failures.append(
								"%s blocks its Garden-sized authored route" %
									pattern_id)
							return 0
	if found.size() != expected.size():
		failures.append(
			"representative seeds do not expose every Bramble family: %s" %
				[found.keys()])
		return 0
	return 1


static func _test_bramble_clearance_has_reaction_and_recovery_time(
	failures: PackedStringArray,
) -> int:
	# Owner-device evidence supersedes the old point-guide proof: the shipped
	# hook/shutter course could place several hard chunks back-to-back, grow a
	# shape over half the usable corridor, and allow only 0.55 s between the two
	# opposite commitments in a pair. Validate the timed route envelope the
	# player actually receives at full pace, while leaving the physics untouched.
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var corridor_height := CourseStream.FLOOR_Y - CourseStream.CEILING_Y
	var maximum_width := 340.0
	var maximum_height := corridor_height * 0.48
	var minimum_pair_spacing := config.maximum_target_speed * 0.85
	var observed_maximum_width := 0.0
	var observed_maximum_height := 0.0
	var observed_minimum_pair_spacing := 1.0e20
	var adjacent_hard_chunks := 0
	var pair_count := 0
	for seed in [0, 7, 77, 707]:
		var stream := CourseStream.new()
		stream.reset(
			10000.0, 0.94, 0.90, 1.12, [], true, 1.0, 1.0,
			20000.0, seed,
		)
		var patterns := {}
		for chunk_index in range(52, 105):
			var distance := maxf(
				0.0,
				float(chunk_index) * CourseStream.CHUNK_WIDTH
					- CourseStream.START_X,
			)
			if StringName(CourseRegionCatalog.region_for_distance(
				distance + CourseStream.CHUNK_WIDTH * 0.5,
			)["id"]) != CourseRegionCatalog.BRAMBLE_CANOPY:
				continue
			patterns[chunk_index] = stream.pattern_id_for_chunk(chunk_index)
		for chunk_index: int in patterns:
			var pattern_id := StringName(patterns[chunk_index])
			if pattern_id == &"open_recovery":
				continue
			if patterns.has(chunk_index + 1) and \
					StringName(patterns[chunk_index + 1]) != &"open_recovery":
				adjacent_hard_chunks += 1
			var chunk_start := float(chunk_index) * CourseStream.CHUNK_WIDTH
			var chunk_end := chunk_start + CourseStream.CHUNK_WIDTH
			var geometry := stream.update_for_position(chunk_start + 1.0)
			var obstacle_centres: Array[float] = []
			for obstacle: PackedVector2Array in geometry.obstacles:
				var bounds := SolidGeometry.bounds(obstacle)
				if bounds.get_center().x < chunk_start or \
						bounds.get_center().x >= chunk_end:
					continue
				obstacle_centres.append(bounds.get_center().x)
				observed_maximum_width = maxf(
					observed_maximum_width, bounds.size.x)
				observed_maximum_height = maxf(
					observed_maximum_height, bounds.size.y)
			if obstacle_centres.size() == 2:
				pair_count += 1
				obstacle_centres.sort()
				observed_minimum_pair_spacing = minf(
					observed_minimum_pair_spacing,
					obstacle_centres[1] - obstacle_centres[0],
				)
	if pair_count == 0 or adjacent_hard_chunks > 0 or \
			observed_minimum_pair_spacing + 0.01 < minimum_pair_spacing or \
			observed_maximum_width > maximum_width + 0.01 or \
			observed_maximum_height > maximum_height + 0.01:
		failures.append(
			("Bramble device envelope is still overcrowded: adjacent=%d, "
				+ "pair gap %.0f/%.0f px, max %.0f×%.0f px "
				+ "(limits %.0f×%.0f)") % [
				adjacent_hard_chunks,
				observed_minimum_pair_spacing,
				minimum_pair_spacing,
				observed_maximum_width,
				observed_maximum_height,
				maximum_width,
				maximum_height,
			],
		)
		return 0
	return 1


static func _test_checkpoint_practice_starts_safe_and_is_non_record(
	failures: PackedStringArray,
) -> int:
	var start := CourseRegionCatalog.checkpoint_start(
		CourseRegionCatalog.BRAMBLE_CANOPY)
	var session := SwingLabSession.new()
	session.configure_run(SwingLabSession.RUN_PRACTICE, start, 77)
	session._reset_run()
	var snapshot := session.current_snapshot()
	if not is_equal_approx(snapshot.distance_pixels, start) or \
			snapshot.run_mode != SwingLabSession.RUN_PRACTICE or \
			snapshot.records_eligible or \
			snapshot.region_id != CourseRegionCatalog.BRAMBLE_CANOPY or \
			not session._world.web.attached or \
			session._world._collides_with_obstacle(session._world.position):
		failures.append(
			"practice checkpoint did not start safely in its named region")
		session.free()
		return 0
	var settlements: Array[RunSettlement] = []
	session.settlement_created.connect(func(value: RunSettlement) -> void:
		settlements.append(value))
	session._emit_settlement(&"test")
	if settlements.size() != 1 or \
			settlements[0].rewards_eligible or \
			settlements[0].records_eligible or \
			settlements[0].leaderboards_eligible or \
			settlements[0].run_mode != SwingLabSession.RUN_PRACTICE:
		failures.append("practice settlement remained progression or record eligible")
		session.free()
		return 0

	var standard := SwingLabSession.new()
	standard.configure_run(SwingLabSession.RUN_STANDARD, 0.0, 77)
	standard._reset_run()
	var reached: Array[StringName] = []
	standard.checkpoint_reached.connect(
		func(region_id: StringName, _distance: float) -> void:
			reached.append(region_id))
	standard._world.distance_pixels = start
	standard._update_region_progress()
	standard._update_region_progress()
	if reached != [CourseRegionCatalog.BRAMBLE_CANOPY]:
		failures.append("standard checkpoint did not emit exactly once")
		session.free()
		standard.free()
		return 0
	session.free()
	standard.free()
	return 1


static func _test_debug_start_awards_nothing_and_sets_no_record(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	progress.total_flies = 14
	progress.spendable_flies = 9
	progress.best_distance_pixels = 4200.0
	var service := ProgressionService.new()
	var session := SwingLabSession.new()
	session.configure_progress(progress, service)
	session.configure_run(SwingLabSession.RUN_STANDARD, 0.0, 77)
	session._reset_run()
	var checkpoints: Array[StringName] = []
	session.checkpoint_reached.connect(func(
		region_id: StringName,
		_distance: float,
	) -> void:
		checkpoints.append(region_id))
	var start_distance := 123450.0
	session.set_tuning_parameter(
		TuningCatalog.DEBUG_START_DISTANCE,
		start_distance,
	)
	var snapshot := session.current_snapshot()
	if not snapshot.debug_start_active or \
			snapshot.run_mode != SwingLabSession.RUN_PRACTICE or \
			snapshot.records_eligible or \
			not is_equal_approx(snapshot.start_distance_pixels, start_distance) or \
			not is_equal_approx(snapshot.distance_pixels, start_distance):
		failures.append("arbitrary debug start did not inherit practice ownership")
		session.free()
		return 0

	session._world.run_flies = 88
	session._world.distance_pixels = start_distance + 80000.0
	session._update_region_progress()
	var settlements: Array[RunSettlement] = []
	session.settlement_created.connect(func(value: RunSettlement) -> void:
		settlements.append(value))
	session._emit_settlement(&"test")
	if settlements.size() != 1 or settlements[0].rewards_eligible or \
			settlements[0].records_eligible or \
			settlements[0].leaderboards_eligible or \
			settlements[0].run_mode != SwingLabSession.RUN_PRACTICE or \
			not checkpoints.is_empty():
		failures.append(
			"debug start could award rewards, records, leaderboards, or checkpoints")
		session.free()
		return 0
	var result := service.apply_settlement(progress, settlements[0])
	if not bool(result.get("applied", false)) or \
			int(result.get("flies_granted", -1)) != 0 or \
			progress.total_flies != 14 or progress.spendable_flies != 9 or \
			not is_equal_approx(progress.best_distance_pixels, 4200.0):
		failures.append("debug start settlement changed saved economy or record")
		session.free()
		return 0
	session.free()
	return 1


static func _test_debug_start_matches_seeded_geometry_from_zero(
	failures: PackedStringArray,
) -> int:
	var seed := 707
	var starts := [
		137430.0, 177430.0, 237430.0,
		287430.0, 337430.0, 377430.0,
	]
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var from_zero := CourseStream.new()
	from_zero.reset(
		config.middle_hazard_start_distance,
		config.edge_obstacle_scale,
		config.floating_obstacle_scale,
		config.gate_opening_scale,
		[],
		config.corridor_contours_enabled,
		config.corridor_clearance_scale,
		config.corridor_tight_gap_scale,
		config.tight_corridor_start_distance,
		seed,
		SimulationWorld.START_POSITION.x,
	)
	var walked_x := SimulationWorld.START_POSITION.x
	for start_distance: float in starts:
		var target_x := SimulationWorld.START_POSITION.x + start_distance
		while walked_x < target_x:
			walked_x = minf(
				target_x,
				walked_x + CourseStream.CHUNK_WIDTH * 0.75,
			)
			from_zero.update_for_position(walked_x)
		var expected := from_zero.geometry()
		var session := SwingLabSession.new()
		session.configure_run(SwingLabSession.RUN_STANDARD, 0.0, seed)
		session._reset_run()
		session.set_tuning_parameter(
			TuningCatalog.DEBUG_START_DISTANCE,
			start_distance,
		)
		var actual := session._course_stream.geometry()
		if not _course_geometry_matches_exactly(actual, expected):
			failures.append(
				("debug start at %.0f px differs in polygons, anchor flags, "
				+ "identity, or motion descriptors from the same seed traversed "
				+ "from zero") % start_distance)
			session.free()
			return 0
		session.free()
	return 1


static func _course_geometry_matches_exactly(
	actual: CourseGeometry,
	expected: CourseGeometry,
) -> bool:
	return actual.first_chunk_index == expected.first_chunk_index and \
		actual.last_chunk_index == expected.last_chunk_index and \
		actual.course_seed == expected.course_seed and \
		actual.surfaces == expected.surfaces and \
		actual.surface_ids == expected.surface_ids and \
		actual.surface_anchor_classes == expected.surface_anchor_classes and \
		actual.surface_visual_ids == expected.surface_visual_ids and \
		actual.surface_motion_specs == expected.surface_motion_specs and \
		actual.decorations == expected.decorations and \
		actual.decoration_ids == expected.decoration_ids and \
		actual.decoration_visual_ids == expected.decoration_visual_ids and \
		actual.decoration_motion_specs == expected.decoration_motion_specs and \
		actual.boundary_surfaces == expected.boundary_surfaces and \
		actual.aim_guides == expected.aim_guides and \
		actual.obstacles == expected.obstacles and \
		actual.obstacle_anchorable == expected.obstacle_anchorable and \
		actual.obstacle_kinds == expected.obstacle_kinds and \
		actual.obstacle_ids == expected.obstacle_ids and \
		actual.obstacle_anchor_classes == expected.obstacle_anchor_classes and \
		actual.obstacle_visual_ids == expected.obstacle_visual_ids and \
		actual.obstacle_motion_specs == expected.obstacle_motion_specs and \
		actual.fly_positions == expected.fly_positions and \
		actual.boost_positions == expected.boost_positions


static func _test_authored_weaves_and_small_silk_burrs_are_fair(
	failures: PackedStringArray,
) -> int:
	var pattern_ids := [
		&"high_low_weave",
		&"low_high_weave",
		&"canopy_hook_high_low",
		&"canopy_hook_low_high",
		&"canopy_shutter_high_low",
		&"canopy_shutter_low_high",
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
	for seed in [0, 7, 77]:
		stream.reset(
			10000.0, 0.94, 0.90, 1.12, [], true, 1.0, 1.0,
			20000.0, seed,
		)
		for chunk_index in range(22, 130):
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
					if SolidGeometry.circle_intersects_polygon(
						fly,
						30.0,
						obstacle,
					):
						failures.append(
							"%s guides its fly route into collision" % pattern_id)
						return 0
			var is_weave := pattern_id in [
				&"high_low_weave",
				&"low_high_weave",
				&"canopy_hook_high_low",
				&"canopy_hook_low_high",
				&"canopy_shutter_high_low",
				&"canopy_shutter_low_high",
		]
			if is_weave:
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
				var high_to_low := pattern_id in [
					&"high_low_weave",
					&"canopy_hook_high_low",
					&"canopy_shutter_high_low",
				]
				var first_is_floor := \
				first_bounds.end.y >= CourseStream.FLOOR_Y - 0.01
				var second_is_floor := \
				second_bounds.end.y >= CourseStream.FLOOR_Y - 0.01
				if first_is_floor != high_to_low or \
					second_is_floor == high_to_low:
					failures.append(
						"%s obstacles do not alternate rail height" % pattern_id)
					return 0
				var canopy_weave := pattern_id in [
					&"canopy_hook_high_low",
					&"canopy_hook_low_high",
					&"canopy_shutter_high_low",
					&"canopy_shutter_low_high",
			]
				if canopy_weave:
					for obstacle: PackedVector2Array in obstacles:
						if not _obstacle_blocks_neutral_lane(obstacle, 18.0):
							failures.append(
								"%s still leaves a neutral middle line" % pattern_id)
							return 0
				elif first_bounds.size.y > 252.0 or \
						second_bounds.size.y > 252.0:
					failures.append(
						"%s no longer leaves a forgiving central transition band" %
							pattern_id)
					return 0
				var route_delta := route_flies[-1].y - route_flies[0].y
				if absf(route_delta) < 280.0 or \
					(route_delta > 0.0) != high_to_low:
					failures.append(
						"%s does not clearly cue the required height change" % pattern_id)
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
		failures.append(
			"deterministic late course does not expose every new pattern: %s" %
				[found.keys()])
		return 0
	return 1


static func _obstacle_blocks_neutral_lane(
	obstacle: PackedVector2Array,
	radius: float,
) -> bool:
	# A concave hook is intentionally open at its own bounds centre. A player
	# coasting horizontally must cross the whole x-span, so sample that path
	# instead of requiring the polygon to fill its visual pocket at one x.
	var bounds := SolidGeometry.bounds(obstacle)
	for sample_index in range(25):
		var centre := Vector2(
			lerpf(
				bounds.position.x,
				bounds.end.x,
				float(sample_index) / 24.0,
			),
			398.0,
		)
		if SolidGeometry.circle_intersects_polygon(centre, radius, obstacle):
			return true
	return false


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


static func _test_region_pattern_pools_stay_varied(
	failures: PackedStringArray,
) -> int:
	# `_seeded_pattern` walks a pool with a coprime stride, which is a
	# full-cycle permutation — so the visible cycle length IS the pool size.
	# At CHUNK_WIDTH 960 px (96 m) a pool of four repeats a zone's whole
	# sequence every ~384 m, roughly five seconds at full pace. Shrinking a pool
	# to differentiate a zone therefore trades one identity problem for a worse
	# one, and it is invisible in review — it only shows up as "this zone feels
	# repetitive" on device.
	var minimum_pool := 7
	var pools := {
		&"control": CoursePatternCatalog.CONTROL_PATTERNS,
		&"mastery": CoursePatternCatalog.MASTERY_PATTERNS,
		&"deep_forest": CoursePatternCatalog.DEEP_FOREST_PATTERNS,
		&"bramble_canopy": CoursePatternCatalog.BRAMBLE_CANOPY_PATTERNS,
		&"silk_hollow": CoursePatternCatalog.SILK_HOLLOW_PATTERNS,
		&"arboretum_opening": CoursePatternCatalog.ARBORETUM_OPENING_PATTERNS,
		&"ruined_arboretum": CoursePatternCatalog.RUINED_ARBORETUM_PATTERNS,
		&"storm_ridge": CoursePatternCatalog.STORM_RIDGE_PATTERNS,
		&"web_city": CoursePatternCatalog.WEB_CITY_PATTERNS,
		&"ashen_hollow": CoursePatternCatalog.ASHEN_HOLLOW_PATTERNS,
		&"deep_mist": CoursePatternCatalog.DEEP_MIST_PATTERNS,
	}
	for name: StringName in pools:
		var pool: Array = pools[name]
		if pool.size() < minimum_pool:
			failures.append(
				"pattern pool %s has %d patterns; below %d the zone's sequence "
				% [name, pool.size(), minimum_pool]
				+ "visibly loops (cycle length equals pool size)")
			return 0
		# The course seed must genuinely reorder a pool, not merely rotate it.
		# Some composite sizes collapse to exactly one legal stride — 3, 4 and 6
		# all do — which silently drops the seeded-variety property that
		# docs/current-state.md records as live.
		var strides := {}
		for seed_value in range(40):
			strides[CoursePatternCatalog._coprime_stride(
				pool.size(), seed_value)] = true
		if strides.size() < 2:
			failures.append(
				"pattern pool %s (size %d) admits only one coprime stride, so "
				% [name, pool.size()]
				+ "the course seed can no longer vary its pattern order")
			return 0
	return 1


static func _test_floor_grown_hazards_are_lethal_but_not_tappable(
	failures: PackedStringArray,
) -> int:
	var world := SimulationWorld.new()
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var geometry := CourseGeometry.new()
	# One hazard rising from the floor and one hanging from the ceiling, the
	# same shape and the same distance from the tap, so only the flag differs.
	var floor_grown := PackedVector2Array([
		Vector2(560.0, 460.0), Vector2(640.0, 460.0),
		Vector2(640.0, 560.0), Vector2(560.0, 560.0),
	])
	var ceiling_grown := PackedVector2Array([
		Vector2(560.0, 140.0), Vector2(640.0, 140.0),
		Vector2(640.0, 240.0), Vector2(560.0, 240.0),
	])
	geometry.append_obstacle(
		floor_grown,
		false,
		CourseObstacleCatalog.CANOPY_LEAF_SHUTTER_RIGHT,
	)
	geometry.append_obstacle(ceiling_grown, true)
	world.reset(config, geometry)

	if world.obstacles.size() != 2:
		failures.append("floor-grown hazard was dropped from collision geometry")
		return 0
	# The ceiling-grown hazard still answers a tap aimed at it.
	var upper := world.nearest_solid_point(Vector2(600.0, 190.0))
	if not bool(upper["found"]) or StringName(upper["kind"]) != &"obstacle":
		failures.append("ceiling-grown hazard stopped being a valid web anchor")
		return 0
	# The floor-grown one does not, even aimed dead centre.
	var lower := world.nearest_solid_point(Vector2(600.0, 510.0))
	if bool(lower["found"]) and StringName(lower["kind"]) == &"obstacle":
		failures.append("floor-grown hazard still answered a tap and can steal a release")
		return 0
	# But it is still solid: untappable must never mean safe to touch.
	if not world._collides_with_obstacle(Vector2(600.0, 510.0)):
		failures.append("floor-grown hazard stopped being lethal — untappable is not safe")
		return 0
	# The flag survives a geometry copy.
	var copy := geometry.duplicate_geometry()
	if copy.is_obstacle_anchorable(0) or \
			not copy.is_obstacle_anchorable(1) or \
			copy.obstacle_kind(0) != \
				CourseObstacleCatalog.CANOPY_LEAF_SHUTTER_RIGHT:
		failures.append(
			"anchor eligibility or visual kind did not survive duplicate_geometry")
		return 0
	# Geometry built without the flag keeps the original behaviour.
	var legacy := CourseGeometry.new()
	legacy.obstacles.append(floor_grown)
	if not legacy.is_obstacle_anchorable(0):
		failures.append("untagged geometry must default to tappable")
		return 0
	return 1


static func _test_dying_window_is_not_eaten_by_an_in_flight_tap(
	failures: PackedStringArray,
) -> int:
	var session := SwingLabSession.new()
	session._reset_run()
	# Reach DYING the ordinary way: spend the one rescue, then die again.
	session._world.web.release()
	session._world.position.y = session._config.lower_world_boundary + 5.0
	session._step_once()
	session._world.rescue_shield_remaining = 0.0
	session._world.position.y = session._config.lower_world_boundary + 5.0
	session._step_once()
	if session._run.state != RunStateMachine.State.DYING:
		failures.append("could not reach DYING to exercise the confirmation window")
		session.free()
		return 0
	# A tap already in flight when the run ended must not restart it — the
	# window is the only chance the player has to see the cause.
	session.request_web_tap(Vector2(400.0, 200.0))
	if session._run.state != RunStateMachine.State.DYING:
		failures.append("a tap during DYING restarted the run and ate the death confirmation")
		session.free()
		return 0
	# The window must still expire on its own clock.
	var steps := int(ceil(session._config.death_confirmation_seconds / FIXED_DELTA)) + 2
	for _index in range(steps):
		session._step_once()
	if session._run.state != RunStateMachine.State.DEAD:
		failures.append("the dying window did not expire into DEAD on its own")
		session.free()
		return 0
	# And once DEAD, the advertised "tap anywhere to restart" must work.
	session.request_web_tap(Vector2(400.0, 200.0))
	if session._run.state != RunStateMachine.State.ACTIVE:
		failures.append("a tap after death did not restart the run")
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
	progress.selected_spider_id = SpiderCatalog.BUCKLER
	var buckler := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	SpiderCatalog.apply_to_config(buckler, progress)
	if agile.player_collision_radius >= 18.0 or \
			not is_zero_approx(agile.horizontal_drive_acceleration) or \
			agile.starting_target_speed <= 360.0:
		failures.append("Magnolia Green Jumper lost its smaller, more agile profile")
		return 0
	if heavy.player_collision_radius <= 18.0 or heavy.gravity <= 1120.0 or \
			heavy.reel_retraction_rate <= SwingConfig.BASE_REEL_RETRACTION_RATE:
		failures.append("Anchorite lost its heavy Reel-In trade-off")
		return 0
	if glider.glide_duration <= 1.0 or glider.detached_gravity_scale >= 0.60:
		failures.append("Ballooner does not resolve to a real detached glide")
		return 0
	if SpiderCatalog.ALL_IDS.size() != 5 or \
			not buckler.surface_bounce_enabled or \
			not is_zero_approx(buckler.horizontal_drive_acceleration):
		failures.append("Buckler lost its bounded recovery trade-off")
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


static func _test_buckler_impact_shell_is_bounded(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	progress.selected_spider_id = SpiderCatalog.BUCKLER
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
		failures.append("charged Buckler did not survive one moderate rail hit")
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


static func _prime_release_world(
	world: SimulationWorld,
	config: SwingConfig,
	release_position: Vector2,
	release_velocity: Vector2,
	attach_position: Vector2 = Vector2(220.0, 390.0),
) -> bool:
	world.reset(config, _test_geometry())
	world.position = attach_position
	if world.web.try_attach(
			world.position,
			Vector2(460.0, 150.0),
			config,
	) != WebConstraint.AttachResult.ATTACHED:
		return false
	world.position = release_position
	world.velocity = release_velocity
	return true


static func _first_event(
	events: Array[SimulationEvent],
	kind: int,
) -> SimulationEvent:
	for event: SimulationEvent in events:
		if event.kind == kind:
			return event
	return null


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

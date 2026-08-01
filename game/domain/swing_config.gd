extends Resource
class_name SwingConfig
## Versioned Phase 0 gameplay configuration.
##
## Every physics value named by GDD §6.6 has one home here.
##
## `balanced_baseline` is the approved baseline (owner, 2026-07-31 — the GDD §23
## exit-gate item "the team approves one named physics preset as the baseline").
## Read the approval precisely: it is NOT the outcome of a three-way comparison.
## Balanced is the only preset that was ever played and tuned, so it has drifted
## a long way from the shared starting point the three were forked from, while
## `weighty_candidate` and `agile_candidate` sat untouched. They stay in the set
## as candidates — deliberately not deleted — but they are STALE relative to the
## baseline and were never evaluated against it. Do not present them as vetted
## alternatives, and do not treat a difference between them and the baseline as
## a tuning signal; it is mostly just the tuning balanced received and they did
## not. Re-forking them from the baseline is a real piece of future work.
##
## They are NOT presented as vetted options: Settings labels them
## "WEIGHTY UNTUNED" and "AGILE UNTUNED" and says in copy that they were
## "forked early and never tuned — kept for future work, not offered as tested
## alternatives". An external review (2026-08-01) read this comment without the
## UI and recommended hiding them behind a debug flag; the disclosure already
## exists, which is why they stay visible.

const SCHEMA_VERSION := 11
const PRESET_BALANCED := &"balanced_baseline"
const PRESET_WEIGHTY := &"weighty_candidate"
const PRESET_AGILE := &"agile_candidate"

## Preset ids that shipped before the baseline promotion, mapped to their
## current id. Saved settings and `--preset=` invocations from before
## 2026-07-31 carry `balanced_candidate`; they must keep resolving to the same
## physics rather than silently falling back through an unknown-name path.
const LEGACY_PRESET_IDS := {
	&"balanced_candidate": PRESET_BALANCED,
}
const BASE_REEL_RETRACTION_RATE := 320.0
const BASE_REEL_ENERGY_CAPACITY := 60.0
const BASE_REEL_DRAIN_RATE := 30.0
const BASE_REEL_REGENERATION_RATE := 18.0
const BASE_REEL_EMPTY_LOCKOUT := 0.75
## `assumed`: device feel must settle the award strength. The bot cannot pump,
## so it is not a tuning instrument for this value.
const DEFAULT_RELEASE_MOMENTUM_BONUS_SPEED := 100.0
## `assumed`: bounded debug/schema guardrail, not a recommended tuning target.
const MAX_RELEASE_MOMENTUM_BONUS_SPEED := 300.0
## `assumed`: the bot cannot pump, so it cannot tune the pursuing bird. These
## three placeholders exist to produce a device-testable baseline; the Test Run
## screen exposes every one and speed zero disables the bird completely.
const DEFAULT_BIRD_SPEED := 300.0
const DEFAULT_BIRD_ACCELERATION := 12.0
const DEFAULT_BIRD_START_OFFSET := 760.0

@export var schema_version: int = SCHEMA_VERSION
@export var preset_name: StringName = PRESET_BALANCED
@export var gravity: float = 1120.0
@export var spider_mass: float = 1.0
## Continuous forward drive is deliberately zero: horizontal pace is earned
## through pendulum conversion, Reel work, pulls, and qualified releases. Keep
## the field as the single reversible experiment switch and as a debug control.
@export var horizontal_drive_acceleration: float = 0.0
@export var starting_target_speed: float = 360.0
@export var maximum_target_speed: float = 760.0
@export var speed_curve_distance: float = 50000.0
@export var maximum_horizontal_overspeed: float = 360.0
## `assumed`: maximum horizontal award from one fully qualified release.
## Zero disables the slice completely. Device feel, not the bot, decides whether
## 100 px/s is the right strength; the deterministic contracts only prove the
## formula, bounds, and eligibility rules.
@export var release_momentum_bonus_speed: float = \
	DEFAULT_RELEASE_MOMENTUM_BONUS_SPEED
## Horizontal world speed at the start, in px/s. Zero is the authoritative
## bird-off switch even when acceleration is non-zero.
@export var bird_speed: float = DEFAULT_BIRD_SPEED
## Extra px/s per 1,000 m of furthest progress. It reads position, never player
## velocity, so banked distance remains a real buffer.
@export var bird_acceleration: float = DEFAULT_BIRD_ACCELERATION
## Initial distance from the spider to the bird's contact line, in pixels.
@export var bird_start_offset: float = DEFAULT_BIRD_START_OFFSET
@export var air_drag: float = 0.055
@export var web_minimum_length: float = 90.0
@export var web_maximum_length: float = 1000.0
@export var web_tap_retargets_when_attached: bool = false
@export var attachment_cone_degrees: float = 155.0
@export var attachment_snap_radius: float = 76.0
@export var attachment_correction_cap: float = 720.0
@export var attachment_catch_fraction: float = 0.08
@export var rope_elasticity_allowance: float = 10.0
@export var rope_damping: float = 0.035
@export var reel_retraction_rate: float = BASE_REEL_RETRACTION_RATE
@export var reel_energy_capacity: float = BASE_REEL_ENERGY_CAPACITY
@export var reel_drain_rate: float = BASE_REEL_DRAIN_RATE
@export var reel_regeneration_rate: float = BASE_REEL_REGENERATION_RATE
@export var reel_empty_lockout: float = BASE_REEL_EMPTY_LOCKOUT
@export var automatic_take_up_enabled: bool = true
@export var automatic_take_up_retention: float = 0.85
@export var burst_distance_fraction: float = 0.40
@export var burst_minimum_distance: float = 80.0
@export var burst_pull_duration: float = 0.20
@export var burst_exit_speed: float = 420.0
@export var burst_tangential_retention: float = 0.62
@export var burst_cooldown: float = 1.65
@export var burst_charge_capacity: int = 1
@export var dive_distance_fraction: float = 0.40
@export var dive_pull_duration: float = 0.16
@export var dive_exit_speed: float = 280.0
@export var dive_tangential_retention: float = 0.50
@export var downward_target_threshold: float = 28.0
@export var camera_follow_strength: float = 8.0
@export var camera_look_ahead: float = 0.22
@export var player_collision_radius: float = 18.0
@export var input_buffer_duration: float = 0.25
@export var lower_world_boundary: float = 780.0
@export var camera_left_kill_distance: float = 520.0
@export var death_confirmation_seconds: float = 0.45
@export var surface_snap_distance: float = 220.0
@export var course_boundaries_enabled: bool = true
@export var course_boundaries_lethal: bool = true
@export var corridor_contours_enabled: bool = true
@export var corridor_clearance_scale: float = 1.0
@export var corridor_tight_gap_scale: float = 1.0
@export var tight_corridor_start_distance: float = 20000.0
@export var middle_hazard_start_distance: float = 10000.0
@export var edge_obstacle_scale: float = 0.94
@export var floating_obstacle_scale: float = 0.90
@export var gate_opening_scale: float = 1.12
@export var guided_start_enabled: bool = true
@export var rescue_life_enabled: bool = true
@export var rescue_shield_duration: float = 0.90
@export var pickup_collision_radius: float = 32.0
@export var burst_frenzy_duration: float = 4.0
@export var detached_gravity_scale: float = 1.0
@export var glide_duration: float = 0.0
@export var surface_bounce_enabled: bool = false
@export var surface_bounce_max_impact_speed: float = 680.0
@export var surface_bounce_retention: float = 0.42
@export var surface_bounce_minimum_speed: float = 220.0
@export var surface_bounce_tangent_retention: float = 0.88


static func preset_names() -> PackedStringArray:
	return PackedStringArray([PRESET_BALANCED, PRESET_WEIGHTY, PRESET_AGILE])


## Map a stored or command-line preset id onto a current one.
##
## Returns `&""` for a name that is neither current nor a known legacy id, so
## callers can tell "this save predates the rename" (migrate it) apart from
## "this is not a preset at all" (reject it). `apply_preset` would quietly land
## both cases on balanced physics anyway; routing through here keeps that
## outcome deliberate and testable rather than a side effect of its `_:` arm.
static func resolve_preset(name: StringName) -> StringName:
	if name in preset_names():
		return name
	return LEGACY_PRESET_IDS.get(name, &"")


static func from_preset(name: StringName) -> SwingConfig:
	var config := SwingConfig.new()
	config.apply_preset(name)
	return config


func apply_preset(name: StringName) -> void:
	preset_name = name
	web_maximum_length = 1000.0
	player_collision_radius = 18.0
	web_tap_retargets_when_attached = false
	attachment_catch_fraction = 0.08
	reel_energy_capacity = BASE_REEL_ENERGY_CAPACITY
	reel_regeneration_rate = BASE_REEL_REGENERATION_RATE
	reel_empty_lockout = BASE_REEL_EMPTY_LOCKOUT
	automatic_take_up_enabled = true
	automatic_take_up_retention = 0.85
	release_momentum_bonus_speed = DEFAULT_RELEASE_MOMENTUM_BONUS_SPEED
	bird_speed = DEFAULT_BIRD_SPEED
	bird_acceleration = DEFAULT_BIRD_ACCELERATION
	bird_start_offset = DEFAULT_BIRD_START_OFFSET
	burst_distance_fraction = 0.40
	burst_minimum_distance = 80.0
	burst_pull_duration = 0.20
	burst_exit_speed = 420.0
	burst_tangential_retention = 0.62
	burst_cooldown = 1.65
	burst_charge_capacity = 1
	dive_distance_fraction = 0.40
	dive_pull_duration = 0.16
	dive_exit_speed = 280.0
	dive_tangential_retention = 0.50
	surface_snap_distance = 220.0
	course_boundaries_enabled = true
	course_boundaries_lethal = true
	corridor_contours_enabled = true
	corridor_clearance_scale = 1.0
	corridor_tight_gap_scale = 1.0
	tight_corridor_start_distance = 20000.0
	middle_hazard_start_distance = 10000.0
	edge_obstacle_scale = 0.94
	floating_obstacle_scale = 0.90
	gate_opening_scale = 1.12
	guided_start_enabled = true
	rescue_life_enabled = true
	rescue_shield_duration = 0.90
	pickup_collision_radius = 32.0
	burst_frenzy_duration = 4.0
	detached_gravity_scale = 1.0
	glide_duration = 0.0
	surface_bounce_enabled = false
	surface_bounce_max_impact_speed = 680.0
	surface_bounce_retention = 0.42
	surface_bounce_minimum_speed = 220.0
	surface_bounce_tangent_retention = 0.88
	speed_curve_distance = 50000.0
	match name:
		PRESET_WEIGHTY:
			gravity = 1320.0
			spider_mass = 1.35
			horizontal_drive_acceleration = 0.0
			starting_target_speed = 350.0
			maximum_target_speed = 750.0
			air_drag = 0.04
			rope_elasticity_allowance = 7.0
			rope_damping = 0.025
			reel_retraction_rate = 335.0
			reel_drain_rate = 32.0
		PRESET_AGILE:
			gravity = 980.0
			spider_mass = 0.8
			horizontal_drive_acceleration = 0.0
			starting_target_speed = 390.0
			maximum_target_speed = 800.0
			air_drag = 0.07
			rope_elasticity_allowance = 13.0
			rope_damping = 0.05
			reel_retraction_rate = 350.0
			reel_drain_rate = 35.0
		_:
			preset_name = PRESET_BALANCED
			gravity = 1120.0
			spider_mass = 1.0
			horizontal_drive_acceleration = 0.0
			starting_target_speed = 360.0
			maximum_target_speed = 760.0
			air_drag = 0.055
			rope_elasticity_allowance = 10.0
			rope_damping = 0.035
			reel_retraction_rate = BASE_REEL_RETRACTION_RATE
			reel_drain_rate = BASE_REEL_DRAIN_RATE


func target_speed_at(distance_pixels: float) -> float:
	var linear_progress := clampf(
		maxf(distance_pixels, 0.0) / speed_curve_distance,
		0.0,
		1.0,
	)
	var smooth_progress := (
		linear_progress * linear_progress * (3.0 - 2.0 * linear_progress)
	)
	return lerpf(starting_target_speed, maximum_target_speed, smooth_progress)


## Position-based pursuer law. `bird_acceleration` is deliberately a gain per
## 1,000 m rather than an acceleration toward player speed.
func bird_speed_at(distance_pixels: float) -> float:
	if bird_speed <= 0.0:
		return 0.0
	var kilometres := maxf(distance_pixels, 0.0) / 10000.0
	return bird_speed + bird_acceleration * kilometres


func adjust(parameter: StringName, direction: float) -> float:
	var descriptor := TuningCatalog.descriptor(parameter)
	if descriptor.is_empty():
		return 0.0
	return set_tuning_value(
		parameter,
		value_for(parameter) + float(descriptor["step"]) * direction,
	)


func set_tuning_value(parameter: StringName, value: float) -> float:
	var safe_value := TuningCatalog.clamp_value(parameter, value)
	match parameter:
		&"gravity":
			gravity = safe_value
			return gravity
		&"drive":
			horizontal_drive_acceleration = safe_value
			return horizontal_drive_acceleration
		&"start_speed":
			starting_target_speed = safe_value
			return starting_target_speed
		&"maximum_speed":
			maximum_target_speed = safe_value
			return maximum_target_speed
		&"full_speed_m":
			speed_curve_distance = safe_value
			return speed_curve_distance
		&"bird_speed":
			bird_speed = safe_value
			return bird_speed
		&"bird_acceleration":
			bird_acceleration = safe_value
			return bird_acceleration
		&"bird_start_offset":
			bird_start_offset = safe_value
			return bird_start_offset
		&"web_range":
			web_maximum_length = safe_value
			return web_maximum_length
		&"tap_retarget":
			web_tap_retargets_when_attached = safe_value >= 0.5
			return 1.0 if web_tap_retargets_when_attached else 0.0
		&"reel_rate":
			reel_retraction_rate = safe_value
			return reel_retraction_rate
		&"reel_capacity_seconds":
			reel_energy_capacity = safe_value * reel_drain_rate
			return reel_energy_capacity / reel_drain_rate
		&"auto_take_up":
			automatic_take_up_enabled = safe_value >= 0.5
			return 1.0 if automatic_take_up_enabled else 0.0
		&"take_up_pct":
			automatic_take_up_retention = safe_value
			return automatic_take_up_retention
		&"aim_forgiveness":
			surface_snap_distance = safe_value
			return surface_snap_distance
		&"attach_catch_pct":
			attachment_catch_fraction = safe_value
			return attachment_catch_fraction
		&"burst_pull_pct":
			burst_distance_fraction = safe_value
			return burst_distance_fraction
		&"burst_minimum":
			burst_minimum_distance = safe_value
			return burst_minimum_distance
		&"burst_duration":
			burst_pull_duration = safe_value
			return burst_pull_duration
		&"pull_cooldown":
			burst_cooldown = safe_value
			return burst_cooldown
		&"burst_charges":
			burst_charge_capacity = roundi(safe_value)
			return float(burst_charge_capacity)
		&"dive_pull_pct":
			dive_distance_fraction = safe_value
			return dive_distance_fraction
		&"dive_duration":
			dive_pull_duration = safe_value
			return dive_pull_duration
		&"rope_damping":
			rope_damping = safe_value
			return rope_damping
		&"course_rails":
			course_boundaries_enabled = safe_value >= 0.5
			return 1.0 if course_boundaries_enabled else 0.0
		&"lethal_rails":
			course_boundaries_lethal = safe_value >= 0.5
			return 1.0 if course_boundaries_lethal else 0.0
		&"mid_hazard_m":
			middle_hazard_start_distance = safe_value
			return middle_hazard_start_distance
		&"edge_obstacle_size":
			edge_obstacle_scale = safe_value
			return edge_obstacle_scale
		&"floating_obstacle_size":
			floating_obstacle_scale = safe_value
			return floating_obstacle_scale
		&"gate_opening_size":
			gate_opening_scale = safe_value
			return gate_opening_scale
		&"corridor_contours":
			corridor_contours_enabled = safe_value >= 0.5
			return 1.0 if corridor_contours_enabled else 0.0
		&"route_clearance":
			corridor_clearance_scale = safe_value
			return corridor_clearance_scale
		&"tight_gap_size":
			corridor_tight_gap_scale = safe_value
			return corridor_tight_gap_scale
		&"tight_corridor_m":
			tight_corridor_start_distance = safe_value
			return tight_corridor_start_distance
		&"guided_start":
			guided_start_enabled = safe_value >= 0.5
			return 1.0 if guided_start_enabled else 0.0
		&"rescue_life":
			rescue_life_enabled = safe_value >= 0.5
			return 1.0 if rescue_life_enabled else 0.0
		&"boost_duration":
			burst_frenzy_duration = safe_value
			return burst_frenzy_duration
		&"impact_shell":
			surface_bounce_enabled = safe_value >= 0.5
			return 1.0 if surface_bounce_enabled else 0.0
		&"safe_impact_speed":
			surface_bounce_max_impact_speed = safe_value
			return surface_bounce_max_impact_speed
		&"bounce_strength":
			surface_bounce_retention = safe_value
			return surface_bounce_retention
	return 0.0


func value_for(parameter: StringName) -> float:
	match parameter:
		&"gravity":
			return gravity
		&"drive":
			return horizontal_drive_acceleration
		&"start_speed":
			return starting_target_speed
		&"maximum_speed":
			return maximum_target_speed
		&"full_speed_m":
			return speed_curve_distance
		&"bird_speed":
			return bird_speed
		&"bird_acceleration":
			return bird_acceleration
		&"bird_start_offset":
			return bird_start_offset
		&"web_range":
			return web_maximum_length
		&"tap_retarget":
			return 1.0 if web_tap_retargets_when_attached else 0.0
		&"reel_rate":
			return reel_retraction_rate
		&"reel_capacity_seconds":
			return reel_energy_capacity / reel_drain_rate
		&"auto_take_up":
			return 1.0 if automatic_take_up_enabled else 0.0
		&"take_up_pct":
			return automatic_take_up_retention
		&"aim_forgiveness":
			return surface_snap_distance
		&"attach_catch_pct":
			return attachment_catch_fraction
		&"burst_pull_pct":
			return burst_distance_fraction
		&"burst_minimum":
			return burst_minimum_distance
		&"burst_duration":
			return burst_pull_duration
		&"pull_cooldown":
			return burst_cooldown
		&"burst_charges":
			return float(burst_charge_capacity)
		&"dive_pull_pct":
			return dive_distance_fraction
		&"dive_duration":
			return dive_pull_duration
		&"rope_damping":
			return rope_damping
		&"course_rails":
			return 1.0 if course_boundaries_enabled else 0.0
		&"lethal_rails":
			return 1.0 if course_boundaries_lethal else 0.0
		&"mid_hazard_m":
			return middle_hazard_start_distance
		&"edge_obstacle_size":
			return edge_obstacle_scale
		&"floating_obstacle_size":
			return floating_obstacle_scale
		&"gate_opening_size":
			return gate_opening_scale
		&"corridor_contours":
			return 1.0 if corridor_contours_enabled else 0.0
		&"route_clearance":
			return corridor_clearance_scale
		&"tight_gap_size":
			return corridor_tight_gap_scale
		&"tight_corridor_m":
			return tight_corridor_start_distance
		&"guided_start":
			return 1.0 if guided_start_enabled else 0.0
		&"rescue_life":
			return 1.0 if rescue_life_enabled else 0.0
		&"boost_duration":
			return burst_frenzy_duration
		&"impact_shell":
			return 1.0 if surface_bounce_enabled else 0.0
		&"safe_impact_speed":
			return surface_bounce_max_impact_speed
		&"bounce_strength":
			return surface_bounce_retention
	return 0.0


func validate() -> PackedStringArray:
	var failures := PackedStringArray()
	if schema_version != SCHEMA_VERSION:
		failures.append("unsupported config schema version %d" % schema_version)
	if gravity <= 0.0:
		failures.append("gravity must be positive")
	if starting_target_speed <= 0.0 or \
			maximum_target_speed < starting_target_speed or \
			speed_curve_distance <= 0.0:
		failures.append("speed progression values are invalid")
	if release_momentum_bonus_speed < 0.0 or \
			release_momentum_bonus_speed > MAX_RELEASE_MOMENTUM_BONUS_SPEED:
		failures.append("release momentum bonus is invalid")
	if bird_speed < 0.0 or bird_acceleration < 0.0 or \
			bird_start_offset <= 0.0:
		failures.append("pursuing bird values are invalid")
	if web_minimum_length <= 0.0 or web_maximum_length <= web_minimum_length:
		failures.append("web length range is invalid")
	if reel_energy_capacity <= 0.0 or reel_drain_rate <= 0.0 or \
			reel_regeneration_rate <= 0.0 or reel_empty_lockout < 0.0:
		failures.append("Reel resource values are invalid")
	if reel_retraction_rate <= 0.0:
		failures.append("Reel response values are invalid")
	if automatic_take_up_retention < 0.0 or automatic_take_up_retention > 1.0:
		failures.append("automatic take-up retention is invalid")
	if burst_distance_fraction <= 0.0 or burst_distance_fraction >= 1.0 or \
			burst_minimum_distance < 0.0 or \
			burst_pull_duration <= 0.0 or burst_exit_speed < 0.0 or \
			burst_tangential_retention < 0.0 or \
			burst_tangential_retention > 1.0 or burst_cooldown <= 0.0 or \
			burst_charge_capacity < 1 or burst_charge_capacity > 3:
		failures.append("Burst response values are invalid")
	if dive_distance_fraction <= 0.0 or dive_distance_fraction >= 1.0 or \
			dive_pull_duration <= 0.0 or dive_exit_speed < 0.0 or \
			dive_tangential_retention < 0.0 or \
			dive_tangential_retention > 1.0:
		failures.append("Dive Pull response values are invalid")
	if attachment_catch_fraction < 0.0 or attachment_catch_fraction >= 1.0:
		failures.append("attachment catch fraction is invalid")
	if attachment_correction_cap <= 0.0:
		failures.append("attachment correction cap must be positive")
	if input_buffer_duration <= 0.0:
		failures.append("input buffer duration must be positive")
	if middle_hazard_start_distance < 0.0:
		failures.append("middle hazard start distance must not be negative")
	if tight_corridor_start_distance < 0.0:
		failures.append("tight corridor start distance must not be negative")
	if edge_obstacle_scale < 0.5 or edge_obstacle_scale > 1.3 or \
			floating_obstacle_scale < 0.5 or floating_obstacle_scale > 1.3 or \
			gate_opening_scale < 0.75 or gate_opening_scale > 1.5:
		failures.append("course obstacle scaling is invalid")
	if corridor_clearance_scale < 0.5 or corridor_clearance_scale > 1.5 or \
			corridor_tight_gap_scale < 0.75 or \
			corridor_tight_gap_scale > 1.4:
		failures.append("corridor contour scaling is invalid")
	if rescue_shield_duration <= 0.0:
		failures.append("rescue shield duration must be positive")
	if pickup_collision_radius <= 0.0 or burst_frenzy_duration <= 0.0:
		failures.append("pickup response values are invalid")
	if detached_gravity_scale <= 0.0 or detached_gravity_scale > 1.0 or \
			glide_duration < 0.0:
		failures.append("glide response values are invalid")
	if surface_bounce_max_impact_speed <= 0.0 or \
			surface_bounce_retention <= 0.0 or \
			surface_bounce_retention > 1.0 or \
			surface_bounce_minimum_speed <= 0.0 or \
			surface_bounce_tangent_retention < 0.0 or \
			surface_bounce_tangent_retention > 1.0:
		failures.append("impact shell response values are invalid")
	return failures

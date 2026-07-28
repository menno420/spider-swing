extends Resource
class_name SwingConfig
## Versioned Phase 0 gameplay configuration.
##
## Every physics value named by GDD §6.6 has one home here. Candidate presets
## are deliberately not called "baseline": only the owner can approve that
## label after real-device playtesting.

const SCHEMA_VERSION := 6
const PRESET_BALANCED := &"balanced_candidate"
const PRESET_WEIGHTY := &"weighty_candidate"
const PRESET_AGILE := &"agile_candidate"

@export var schema_version: int = SCHEMA_VERSION
@export var preset_name: StringName = PRESET_BALANCED
@export var gravity: float = 1120.0
@export var spider_mass: float = 1.0
@export var horizontal_drive_acceleration: float = 470.0
@export var starting_target_speed: float = 360.0
@export var maximum_target_speed: float = 760.0
@export var speed_curve_distance: float = 1600.0
@export var maximum_horizontal_overspeed: float = 360.0
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
@export var reel_retraction_rate: float = 480.0
@export var reel_energy_capacity: float = 100.0
@export var reel_drain_rate: float = 30.0
@export var reel_regeneration_rate: float = 18.0
@export var reel_empty_lockout: float = 0.75
@export var automatic_take_up_enabled: bool = true
@export var automatic_take_up_retention: float = 0.85
@export var burst_distance_fraction: float = 0.50
@export var burst_pull_duration: float = 0.20
@export var burst_exit_speed: float = 420.0
@export var burst_tangential_retention: float = 0.62
@export var burst_cooldown: float = 1.65
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
@export var course_boundaries_lethal: bool = false
@export var middle_hazard_start_distance: float = 10000.0
@export var pickup_collision_radius: float = 32.0
@export var burst_frenzy_duration: float = 4.0


static func preset_names() -> PackedStringArray:
	return PackedStringArray([PRESET_BALANCED, PRESET_WEIGHTY, PRESET_AGILE])


static func from_preset(name: StringName) -> SwingConfig:
	var config := SwingConfig.new()
	config.apply_preset(name)
	return config


func apply_preset(name: StringName) -> void:
	preset_name = name
	web_maximum_length = 1000.0
	web_tap_retargets_when_attached = false
	attachment_catch_fraction = 0.08
	automatic_take_up_enabled = true
	automatic_take_up_retention = 0.85
	burst_distance_fraction = 0.50
	burst_pull_duration = 0.20
	burst_exit_speed = 420.0
	burst_tangential_retention = 0.62
	burst_cooldown = 1.65
	dive_distance_fraction = 0.40
	dive_pull_duration = 0.16
	dive_exit_speed = 280.0
	dive_tangential_retention = 0.50
	surface_snap_distance = 220.0
	course_boundaries_enabled = true
	course_boundaries_lethal = false
	middle_hazard_start_distance = 10000.0
	pickup_collision_radius = 32.0
	burst_frenzy_duration = 4.0
	match name:
		PRESET_WEIGHTY:
			gravity = 1320.0
			spider_mass = 1.35
			horizontal_drive_acceleration = 410.0
			starting_target_speed = 350.0
			maximum_target_speed = 750.0
			air_drag = 0.04
			rope_elasticity_allowance = 7.0
			rope_damping = 0.025
			reel_retraction_rate = 460.0
			reel_drain_rate = 32.0
		PRESET_AGILE:
			gravity = 980.0
			spider_mass = 0.8
			horizontal_drive_acceleration = 570.0
			starting_target_speed = 390.0
			maximum_target_speed = 800.0
			air_drag = 0.07
			rope_elasticity_allowance = 13.0
			rope_damping = 0.05
			reel_retraction_rate = 520.0
			reel_drain_rate = 35.0
		_:
			preset_name = PRESET_BALANCED
			gravity = 1120.0
			spider_mass = 1.0
			horizontal_drive_acceleration = 470.0
			starting_target_speed = 360.0
			maximum_target_speed = 760.0
			air_drag = 0.055
			rope_elasticity_allowance = 10.0
			rope_damping = 0.035
			reel_retraction_rate = 480.0
			reel_drain_rate = 30.0


func target_speed_at(distance_pixels: float) -> float:
	var progress := 1.0 - exp(-maxf(distance_pixels, 0.0) / speed_curve_distance)
	return lerpf(starting_target_speed, maximum_target_speed, progress)


func adjust(parameter: StringName, direction: float) -> float:
	match parameter:
		&"gravity":
			gravity = clampf(gravity + 40.0 * direction, 400.0, 1800.0)
			return gravity
		&"drive":
			horizontal_drive_acceleration = clampf(
				horizontal_drive_acceleration + 25.0 * direction, 100.0, 1000.0)
			return horizontal_drive_acceleration
		&"web_range":
			web_maximum_length = clampf(
				web_maximum_length + 50.0 * direction, 500.0, 1400.0)
			return web_maximum_length
		&"tap_retarget":
			web_tap_retargets_when_attached = direction > 0.0
			return 1.0 if web_tap_retargets_when_attached else 0.0
		&"reel_rate":
			reel_retraction_rate = clampf(
				reel_retraction_rate + 20.0 * direction, 80.0, 720.0)
			return reel_retraction_rate
		&"auto_take_up":
			automatic_take_up_enabled = direction > 0.0
			return 1.0 if automatic_take_up_enabled else 0.0
		&"take_up_pct":
			automatic_take_up_retention = clampf(
				automatic_take_up_retention + 0.05 * direction, 0.0, 1.0)
			return automatic_take_up_retention
		&"aim_forgiveness":
			surface_snap_distance = clampf(
				surface_snap_distance + 10.0 * direction, 80.0, 320.0)
			return surface_snap_distance
		&"attach_catch_pct":
			attachment_catch_fraction = clampf(
				attachment_catch_fraction + 0.01 * direction, 0.0, 0.20)
			return attachment_catch_fraction
		&"burst_pull_pct":
			burst_distance_fraction = clampf(
				burst_distance_fraction + 0.05 * direction, 0.10, 0.80)
			return burst_distance_fraction
		&"burst_duration":
			burst_pull_duration = clampf(
				burst_pull_duration + 0.02 * direction, 0.08, 0.40)
			return burst_pull_duration
		&"pull_cooldown":
			burst_cooldown = clampf(
				burst_cooldown + 0.10 * direction, 0.30, 2.50)
			return burst_cooldown
		&"dive_pull_pct":
			dive_distance_fraction = clampf(
				dive_distance_fraction + 0.05 * direction, 0.05, 0.50)
			return dive_distance_fraction
		&"dive_duration":
			dive_pull_duration = clampf(
				dive_pull_duration + 0.02 * direction, 0.08, 0.32)
			return dive_pull_duration
		&"rope_damping":
			rope_damping = clampf(rope_damping + 0.01 * direction, 0.0, 0.3)
			return rope_damping
		&"course_rails":
			course_boundaries_enabled = direction > 0.0
			return 1.0 if course_boundaries_enabled else 0.0
		&"lethal_rails":
			course_boundaries_lethal = direction > 0.0
			return 1.0 if course_boundaries_lethal else 0.0
		&"mid_hazard_m":
			middle_hazard_start_distance = clampf(
				middle_hazard_start_distance + 1000.0 * direction,
				2500.0,
				20000.0,
			)
			return middle_hazard_start_distance
		&"boost_duration":
			burst_frenzy_duration = clampf(
				burst_frenzy_duration + 0.5 * direction, 1.0, 10.0)
			return burst_frenzy_duration
	return 0.0


func value_for(parameter: StringName) -> float:
	match parameter:
		&"gravity":
			return gravity
		&"drive":
			return horizontal_drive_acceleration
		&"web_range":
			return web_maximum_length
		&"tap_retarget":
			return 1.0 if web_tap_retargets_when_attached else 0.0
		&"reel_rate":
			return reel_retraction_rate
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
		&"burst_duration":
			return burst_pull_duration
		&"pull_cooldown":
			return burst_cooldown
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
		&"boost_duration":
			return burst_frenzy_duration
	return 0.0


func validate() -> PackedStringArray:
	var failures := PackedStringArray()
	if schema_version != SCHEMA_VERSION:
		failures.append("unsupported config schema version %d" % schema_version)
	if gravity <= 0.0:
		failures.append("gravity must be positive")
	if web_minimum_length <= 0.0 or web_maximum_length <= web_minimum_length:
		failures.append("web length range is invalid")
	if reel_energy_capacity <= 0.0:
		failures.append("Reel energy capacity must be positive")
	if reel_retraction_rate <= 0.0:
		failures.append("Reel response values are invalid")
	if automatic_take_up_retention < 0.0 or automatic_take_up_retention > 1.0:
		failures.append("automatic take-up retention is invalid")
	if burst_distance_fraction <= 0.0 or burst_distance_fraction >= 1.0 or \
			burst_pull_duration <= 0.0 or burst_exit_speed < 0.0 or \
			burst_tangential_retention < 0.0 or \
			burst_tangential_retention > 1.0 or burst_cooldown <= 0.0:
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
	if pickup_collision_radius <= 0.0 or burst_frenzy_duration <= 0.0:
		failures.append("pickup response values are invalid")
	return failures

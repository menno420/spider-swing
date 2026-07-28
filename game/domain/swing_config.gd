extends Resource
class_name SwingConfig
## Versioned Phase 0 gameplay configuration.
##
## Every physics value named by GDD §6.6 has one home here. Candidate presets
## are deliberately not called "baseline": only the owner can approve that
## label after real-device playtesting.

const SCHEMA_VERSION := 1
const PRESET_BALANCED := &"balanced_candidate"
const PRESET_WEIGHTY := &"weighty_candidate"
const PRESET_AGILE := &"agile_candidate"

@export var schema_version: int = SCHEMA_VERSION
@export var preset_name: StringName = PRESET_BALANCED
@export var gravity: float = 1080.0
@export var spider_mass: float = 1.0
@export var horizontal_drive_acceleration: float = 470.0
@export var starting_target_speed: float = 360.0
@export var maximum_target_speed: float = 760.0
@export var speed_curve_distance: float = 1600.0
@export var maximum_horizontal_overspeed: float = 360.0
@export var air_drag: float = 0.055
@export var web_minimum_length: float = 90.0
@export var web_maximum_length: float = 620.0
@export var attachment_cone_degrees: float = 155.0
@export var attachment_snap_radius: float = 76.0
@export var attachment_correction_cap: float = 720.0
@export var rope_elasticity_allowance: float = 10.0
@export var rope_damping: float = 0.035
@export var reel_retraction_rate: float = 215.0
@export var reel_energy_capacity: float = 100.0
@export var reel_drain_rate: float = 30.0
@export var reel_regeneration_rate: float = 18.0
@export var reel_empty_lockout: float = 0.75
@export var burst_impulse: float = 390.0
@export var burst_lift: float = 75.0
@export var burst_cooldown: float = 1.65
@export var camera_follow_strength: float = 8.0
@export var camera_look_ahead: float = 0.22
@export var player_collision_radius: float = 18.0
@export var input_buffer_duration: float = 0.25
@export var lower_world_boundary: float = 780.0
@export var camera_left_kill_distance: float = 520.0
@export var death_confirmation_seconds: float = 0.45
@export var surface_snap_distance: float = 170.0


static func preset_names() -> PackedStringArray:
	return PackedStringArray([PRESET_BALANCED, PRESET_WEIGHTY, PRESET_AGILE])


static func from_preset(name: StringName) -> SwingConfig:
	var config := SwingConfig.new()
	config.apply_preset(name)
	return config


func apply_preset(name: StringName) -> void:
	preset_name = name
	match name:
		PRESET_WEIGHTY:
			gravity = 1240.0
			spider_mass = 1.35
			horizontal_drive_acceleration = 410.0
			starting_target_speed = 350.0
			maximum_target_speed = 750.0
			air_drag = 0.04
			rope_elasticity_allowance = 7.0
			rope_damping = 0.025
			reel_retraction_rate = 185.0
			reel_drain_rate = 32.0
		PRESET_AGILE:
			gravity = 940.0
			spider_mass = 0.8
			horizontal_drive_acceleration = 570.0
			starting_target_speed = 390.0
			maximum_target_speed = 800.0
			air_drag = 0.07
			rope_elasticity_allowance = 13.0
			rope_damping = 0.05
			reel_retraction_rate = 255.0
			reel_drain_rate = 35.0
		_:
			preset_name = PRESET_BALANCED
			gravity = 1080.0
			spider_mass = 1.0
			horizontal_drive_acceleration = 470.0
			starting_target_speed = 360.0
			maximum_target_speed = 760.0
			air_drag = 0.055
			rope_elasticity_allowance = 10.0
			rope_damping = 0.035
			reel_retraction_rate = 215.0
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
		&"reel_rate":
			reel_retraction_rate = clampf(
				reel_retraction_rate + 15.0 * direction, 60.0, 500.0)
			return reel_retraction_rate
		&"rope_damping":
			rope_damping = clampf(rope_damping + 0.01 * direction, 0.0, 0.3)
			return rope_damping
	return 0.0


func value_for(parameter: StringName) -> float:
	match parameter:
		&"gravity":
			return gravity
		&"drive":
			return horizontal_drive_acceleration
		&"reel_rate":
			return reel_retraction_rate
		&"rope_damping":
			return rope_damping
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
	if burst_impulse <= 0.0 or burst_cooldown <= 0.0:
		failures.append("Burst impulse and cooldown must be positive")
	if attachment_correction_cap <= 0.0:
		failures.append("attachment correction cap must be positive")
	if input_buffer_duration <= 0.0:
		failures.append("input buffer duration must be positive")
	return failures

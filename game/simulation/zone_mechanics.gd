extends RefCounted
class_name ZoneMechanics
## Pure fixed-step zone effects layered on the owner-approved SwingConfig.
##
## These constants are environmental authored values, not changes to the
## balanced baseline. Every result depends only on authoritative simulation
## state and never on frame rate, elapsed wall time, or an RNG draw.

const STORM_START_PIXELS := 200000.0
const FIRST_GUST_PIXELS := 210000.0
const STORM_END_PIXELS := 250000.0
const BASE_WIND_ACCELERATION := Vector2(-86.0, -14.0)
const GUST_ACCELERATION := Vector2(-310.0, -52.0)
const ATTACHED_WIND_FACTOR := 0.18
const GUST_PERIOD_TICKS := 300
const STICKY_SPEED_BLEED_PER_SECOND := 0.42


static func wind_acceleration(
	distance_pixels: float,
	course_seed: int,
	tick: int,
	attached: bool,
) -> Vector2:
	if distance_pixels < STORM_START_PIXELS or \
			distance_pixels >= STORM_END_PIXELS:
		return Vector2.ZERO
	var acceleration := BASE_WIND_ACCELERATION
	acceleration += GUST_ACCELERATION * gust_strength(
		distance_pixels, course_seed, tick)
	if attached:
		acceleration *= ATTACHED_WIND_FACTOR
	return acceleration


static func gust_strength(
	distance_pixels: float,
	course_seed: int,
	tick: int,
) -> float:
	if distance_pixels < FIRST_GUST_PIXELS or \
			distance_pixels >= STORM_END_PIXELS:
		return 0.0
	var distance_cell := floori(
		(distance_pixels - STORM_START_PIXELS) / 960.0)
	var phase_tick := tick + CourseMotion.phase_offset_ticks(
		distance_cell, course_seed, GUST_PERIOD_TICKS, 41)
	var phase := TAU * float(posmod(phase_tick, GUST_PERIOD_TICKS)) / \
		float(GUST_PERIOD_TICKS)
	# The first 760 px repay the one-second warning budget by fading the field
	# in from exactly zero, even for an off-grid debug start at the boundary.
	var entry_ramp := clampf(
		(distance_pixels - FIRST_GUST_PIXELS) / 760.0, 0.0, 1.0)
	return pow(maxf(0.0, sin(phase)), 2.0) * entry_ramp


static func apply_sticky_bleed(
	velocity: Vector2,
	delta: float,
) -> Vector2:
	var retention := maxf(0.0, 1.0 - STICKY_SPEED_BLEED_PER_SECOND * delta)
	return velocity * retention

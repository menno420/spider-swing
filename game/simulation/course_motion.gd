extends RefCounted
class_name CourseMotion
## Pure fixed-tick sampling for authored environmental motion.
##
## No method stores phase or draws randomness. Re-evaluating the same
## `(chunk_index, course_seed, tick)` inputs returns the same sample.


static func phase_offset_ticks(
	chunk_index: int,
	course_seed: int,
	period_ticks: int,
	phase_salt: int = 0,
) -> int:
	var safe_period := maxi(1, period_ticks)
	# Integer mixing is deliberate: Godot's runtime RNG state and call order are
	# not inputs, and all platforms perform these bounded integer operations in
	# exactly the same order.
	return posmod(
		chunk_index * 97 + course_seed * 131 + phase_salt * 53,
		safe_period,
	)


static func pendulum_anchor(
	origin: Vector2,
	radius: float,
	amplitude_radians: float,
	period_ticks: int,
	chunk_index: int,
	course_seed: int,
	tick: int,
	fixed_delta: float,
	phase_salt: int = 0,
) -> Dictionary:
	var current := _pendulum_position(
		origin,
		radius,
		amplitude_radians,
		period_ticks,
		chunk_index,
		course_seed,
		tick,
		phase_salt,
	)
	var next := _pendulum_position(
		origin,
		radius,
		amplitude_radians,
		period_ticks,
		chunk_index,
		course_seed,
		tick + 1,
		phase_salt,
	)
	return {
		"position": current,
		"next_position": next,
		"velocity": (next - current) / maxf(fixed_delta, 0.000001),
	}


static func _pendulum_position(
	origin: Vector2,
	radius: float,
	amplitude_radians: float,
	period_ticks: int,
	chunk_index: int,
	course_seed: int,
	tick: int,
	phase_salt: int,
) -> Vector2:
	var safe_period := maxi(1, period_ticks)
	var phase_tick := tick + phase_offset_ticks(
		chunk_index,
		course_seed,
		safe_period,
		phase_salt,
	)
	var phase := TAU * float(posmod(phase_tick, safe_period)) / \
		float(safe_period)
	var angle := sin(phase) * amplitude_radians
	return origin + Vector2(sin(angle), cos(angle)) * radius

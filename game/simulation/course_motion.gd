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


## Sample an authored polygon at the current and next fixed tick. `active`
## gates collision without deleting geometry, so off-grid stream rebuilds keep
## exact array identity and phase hazards never depend on call order.
static func sample_polygon(
	base_polygon: PackedVector2Array,
	motion_spec: Dictionary,
	tick: int,
	fixed_delta: float,
) -> Dictionary:
	if motion_spec.is_empty():
		return {
			"current": base_polygon.duplicate(),
			"next": base_polygon.duplicate(),
			"active": true,
			"next_active": true,
		}
	var kind := StringName(motion_spec.get("kind", &""))
	match kind:
		&"pendulum":
			return _sample_pendulum_polygon(
				base_polygon, motion_spec, tick, fixed_delta)
		&"rotate":
			return _sample_rotating_polygon(base_polygon, motion_spec, tick)
		&"translate_sine":
			return _sample_sine_translation(base_polygon, motion_spec, tick)
		&"fall_loop":
			return _sample_fall_loop(base_polygon, motion_spec, tick)
		&"phase_active":
			var current_active := _phase_active(motion_spec, tick)
			var next_active := _phase_active(motion_spec, tick + 1)
			return {
				"current": base_polygon.duplicate(),
				"next": base_polygon.duplicate(),
				"active": current_active,
				"next_active": next_active,
			}
		_:
			return {
				"current": base_polygon.duplicate(),
				"next": base_polygon.duplicate(),
				"active": true,
				"next_active": true,
			}


static func _sample_pendulum_polygon(
	base_polygon: PackedVector2Array,
	spec: Dictionary,
	tick: int,
	fixed_delta: float,
) -> Dictionary:
	var origin := Vector2(spec["origin"])
	var rest_pivot := Vector2(spec["rest_pivot"])
	var sample := pendulum_anchor(
		origin,
		float(spec["radius"]),
		float(spec["amplitude_radians"]),
		int(spec["period_ticks"]),
		int(spec["chunk_index"]),
		int(spec["course_seed"]),
		tick,
		fixed_delta,
		int(spec.get("phase_salt", 0)),
	)
	var next_sample := pendulum_anchor(
		origin,
		float(spec["radius"]),
		float(spec["amplitude_radians"]),
		int(spec["period_ticks"]),
		int(spec["chunk_index"]),
		int(spec["course_seed"]),
		tick + 1,
		fixed_delta,
		int(spec.get("phase_salt", 0)),
	)
	var current_pivot := Vector2(sample["position"])
	var next_pivot := Vector2(next_sample["position"])
	var current_angle := (current_pivot - origin).angle() - PI * 0.5
	var next_angle := (next_pivot - origin).angle() - PI * 0.5
	return {
		"current": _transform_polygon(
			base_polygon, rest_pivot, current_pivot, current_angle),
		"next": _transform_polygon(
			base_polygon, rest_pivot, next_pivot, next_angle),
		"active": true,
		"next_active": true,
	}


static func _sample_rotating_polygon(
	base_polygon: PackedVector2Array,
	spec: Dictionary,
	tick: int,
) -> Dictionary:
	var pivot := Vector2(spec["pivot"])
	var current_angle := _rotation_angle(spec, tick)
	var next_angle := _rotation_angle(spec, tick + 1)
	return {
		"current": _transform_polygon(
			base_polygon, pivot, pivot, current_angle),
		"next": _transform_polygon(base_polygon, pivot, pivot, next_angle),
		"active": true,
		"next_active": true,
	}


static func _rotation_angle(spec: Dictionary, tick: int) -> float:
	var period := maxi(1, int(spec["period_ticks"]))
	var phase_tick := tick + phase_offset_ticks(
		int(spec["chunk_index"]),
		int(spec["course_seed"]),
		period,
		int(spec.get("phase_salt", 0)),
	)
	return TAU * float(posmod(phase_tick, period)) / float(period)


static func _sample_sine_translation(
	base_polygon: PackedVector2Array,
	spec: Dictionary,
	tick: int,
) -> Dictionary:
	var current_offset := _sine_offset(spec, tick)
	var next_offset := _sine_offset(spec, tick + 1)
	return {
		"current": _translated_polygon(base_polygon, current_offset),
		"next": _translated_polygon(base_polygon, next_offset),
		"active": true,
		"next_active": true,
	}


static func _sine_offset(spec: Dictionary, tick: int) -> Vector2:
	var period := maxi(1, int(spec["period_ticks"]))
	var phase_tick := tick + phase_offset_ticks(
		int(spec["chunk_index"]),
		int(spec["course_seed"]),
		period,
		int(spec.get("phase_salt", 0)),
	)
	var phase := TAU * float(posmod(phase_tick, period)) / float(period)
	return Vector2(spec["axis"]).normalized() * float(spec["amplitude"]) * sin(phase)


static func _sample_fall_loop(
	base_polygon: PackedVector2Array,
	spec: Dictionary,
	tick: int,
) -> Dictionary:
	var current := _fall_sample(spec, tick)
	var next := _fall_sample(spec, tick + 1)
	return {
		"current": _translated_polygon(
			base_polygon, Vector2.DOWN * float(current["distance"])),
		"next": _translated_polygon(
			base_polygon, Vector2.DOWN * float(next["distance"])),
		"active": bool(current["active"]),
		"next_active": bool(next["active"]),
	}


static func _fall_sample(spec: Dictionary, tick: int) -> Dictionary:
	var period := maxi(1, int(spec["period_ticks"]))
	var phase_tick := tick + phase_offset_ticks(
		int(spec["chunk_index"]),
		int(spec["course_seed"]),
		period,
		int(spec.get("phase_salt", 0)),
	)
	var local_tick := posmod(phase_tick, period)
	var visible_ticks := clampi(int(spec["visible_ticks"]), 1, period)
	var progress := minf(1.0, float(local_tick) / float(visible_ticks))
	return {
		"distance": float(spec["distance"]) * progress,
		"active": local_tick < visible_ticks,
	}


static func _phase_active(spec: Dictionary, tick: int) -> bool:
	var period := maxi(1, int(spec["period_ticks"]))
	var phase_tick := tick + phase_offset_ticks(
		int(spec["chunk_index"]),
		int(spec["course_seed"]),
		period,
		int(spec.get("phase_salt", 0)),
	)
	return posmod(phase_tick, period) < int(spec["active_ticks"])


static func _transform_polygon(
	polygon: PackedVector2Array,
	from_pivot: Vector2,
	to_pivot: Vector2,
	angle: float,
) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point: Vector2 in polygon:
		result.append(to_pivot + (point - from_pivot).rotated(angle))
	return result


static func _translated_polygon(
	polygon: PackedVector2Array,
	offset: Vector2,
) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point: Vector2 in polygon:
		result.append(point + offset)
	return result


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

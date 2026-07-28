extends RefCounted
class_name WebConstraint
## Maximum-length rope constraint with capped correction and Reel-In energy.

enum AttachResult {
	ATTACHED,
	OUT_OF_RANGE,
	INVALID_DIRECTION,
}

var attached: bool = false
var anchor: Vector2 = Vector2.ZERO
var rope_length: float = 0.0
var tension: float = 0.0
var reel_energy: float = 0.0
var reel_active: bool = false
var reel_lockout_remaining: float = 0.0
var _empty_event_armed: bool = true


func reset(config: SwingConfig) -> void:
	attached = false
	anchor = Vector2.ZERO
	rope_length = 0.0
	tension = 0.0
	reel_energy = config.reel_energy_capacity
	reel_active = false
	reel_lockout_remaining = 0.0
	_empty_event_armed = true


func try_attach(
	position: Vector2,
	target: Vector2,
	config: SwingConfig,
) -> int:
	var offset := target - position
	var distance := offset.length()
	if distance < config.web_minimum_length or distance > config.web_maximum_length:
		return AttachResult.OUT_OF_RANGE

	var aim_axis := Vector2(1.0, -0.38).normalized()
	var angle := absf(aim_axis.angle_to(offset.normalized()))
	if angle > deg_to_rad(config.attachment_cone_degrees * 0.5):
		return AttachResult.INVALID_DIRECTION

	attached = true
	anchor = target
	rope_length = clampf(distance, config.web_minimum_length, config.web_maximum_length)
	tension = 0.0
	return AttachResult.ATTACHED


func release() -> void:
	attached = false
	reel_active = false
	tension = 0.0


func set_reel_active(active: bool) -> void:
	reel_active = active and attached and reel_energy > 0.0


func engage_reel(
	position: Vector2,
	velocity: Vector2,
	config: SwingConfig,
) -> Vector2:
	if reel_active:
		return velocity
	set_reel_active(true)
	if not reel_active:
		return velocity
	var to_anchor := anchor - position
	if to_anchor.length_squared() <= 0.0001:
		return velocity
	return _add_bounded_inward_speed(
		velocity,
		to_anchor.normalized(),
		config.reel_engage_impulse,
		config.reel_maximum_pull_speed,
	)


func advance_resource(delta: float, config: SwingConfig) -> bool:
	var became_empty := false
	if reel_lockout_remaining > 0.0:
		reel_lockout_remaining = maxf(0.0, reel_lockout_remaining - delta)

	if attached and reel_active and reel_energy > 0.0:
		rope_length = maxf(
			config.web_minimum_length,
			rope_length - config.reel_retraction_rate * delta,
		)
		reel_energy = maxf(0.0, reel_energy - config.reel_drain_rate * delta)
		if reel_energy <= 0.0:
			reel_active = false
			reel_lockout_remaining = config.reel_empty_lockout
			if _empty_event_armed:
				became_empty = true
				_empty_event_armed = false
	elif reel_lockout_remaining <= 0.0:
		reel_energy = minf(
			config.reel_energy_capacity,
			reel_energy + config.reel_regeneration_rate * delta,
		)
		if reel_energy > config.reel_energy_capacity * 0.1:
			_empty_event_armed = true
	return became_empty


func solve(
	position: Vector2,
	velocity: Vector2,
	delta: float,
	config: SwingConfig,
) -> Dictionary:
	tension = 0.0
	if attached and reel_active and reel_energy > 0.0:
		var to_anchor := anchor - position
		if to_anchor.length_squared() > 0.0001:
			velocity = _add_bounded_inward_speed(
				velocity,
				to_anchor.normalized(),
				config.reel_pull_acceleration * delta,
				config.reel_maximum_pull_speed,
			)
	var predicted := position + velocity * delta
	if not attached:
		return {"position": predicted, "velocity": velocity}

	var offset := predicted - anchor
	var distance := offset.length()
	if distance <= 0.0001:
		return {"position": predicted, "velocity": velocity}

	var allowed_length := rope_length + config.rope_elasticity_allowance
	if distance <= allowed_length:
		return {"position": predicted, "velocity": velocity}

	var radial_direction := offset / distance
	var excess := distance - allowed_length
	var maximum_correction := config.attachment_correction_cap * delta
	var correction := minf(excess, maximum_correction)
	predicted -= radial_direction * correction

	var outward_speed := velocity.dot(radial_direction)
	if outward_speed > 0.0:
		velocity -= radial_direction * outward_speed

	var damping_factor := maxf(0.0, 1.0 - config.rope_damping * delta)
	velocity *= damping_factor
	tension = (
		(outward_speed * config.spider_mass / maxf(delta, 0.0001))
		+ (excess * config.spider_mass / maxf(delta * delta, 0.0001))
	)

	return {"position": predicted, "velocity": velocity}


func _add_bounded_inward_speed(
	velocity: Vector2,
	inward_direction: Vector2,
	requested_speed: float,
	maximum_speed: float,
) -> Vector2:
	var inward_speed := velocity.dot(inward_direction)
	var available := maxf(0.0, maximum_speed - inward_speed)
	return velocity + inward_direction * minf(requested_speed, available)

extends RefCounted
class_name WebConstraint
## Maximum-length rope constraint with capped correction and Reel-In energy.

## `assumed`: a 90° covered arc earns full arc quality. Device feel may move
## this threshold; deterministic contracts prove the formula, not its tuning.
const FULL_RELEASE_ARC_RADIANS := PI * 0.5

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
var _last_distance_to_anchor: float = 0.0
var _arc_tracking: bool = false
var _arc_previous_angle: float = 0.0
var _arc_unwrapped_angle: float = 0.0
var _arc_minimum_angle: float = 0.0
var _arc_maximum_angle: float = 0.0


func reset(config: SwingConfig) -> void:
	attached = false
	anchor = Vector2.ZERO
	rope_length = 0.0
	tension = 0.0
	reel_energy = config.reel_energy_capacity
	reel_active = false
	reel_lockout_remaining = 0.0
	_empty_event_armed = true
	_last_distance_to_anchor = 0.0
	_reset_swing_arc()


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
	rope_length = clampf(
		distance * (1.0 - config.attachment_catch_fraction),
		config.web_minimum_length,
		config.web_maximum_length,
	)
	tension = 0.0
	_last_distance_to_anchor = distance
	_begin_swing_arc(position - target)
	return AttachResult.ATTACHED


func release() -> void:
	attached = false
	reel_active = false
	tension = 0.0
	_last_distance_to_anchor = 0.0
	_reset_swing_arc()


## Authoritative release-quality inputs for this attachment. The rope owns the
## arc because it owns attachment history; SimulationWorld owns the actual speed
## award and its reference-speed cap.
func release_quality(position: Vector2, velocity: Vector2) -> Dictionary:
	if not attached:
		return {
			"arc_radians": 0.0,
			"arc_quality": 0.0,
			"rise_quality": 0.0,
			"quality": 0.0,
		}
	_track_swing_arc(position - anchor)
	var arc_radians := swing_arc_radians()
	var arc_quality := clampf(
		arc_radians / FULL_RELEASE_ARC_RADIANS,
		0.0,
		1.0,
	)
	var speed := velocity.length()
	var rise_quality := clampf(
		-velocity.y / maxf(speed, 0.0001),
		0.0,
		1.0,
	)
	var quality := arc_quality * rise_quality
	if velocity.x <= 0.0 or position.x <= anchor.x:
		quality = 0.0
	return {
		"arc_radians": arc_radians,
		"arc_quality": arc_quality,
		"rise_quality": rise_quality,
		"quality": quality,
	}


func swing_arc_radians() -> float:
	if not attached or not _arc_tracking:
		return 0.0
	return maxf(0.0, _arc_maximum_angle - _arc_minimum_angle)


func _begin_swing_arc(offset: Vector2) -> void:
	if offset.length_squared() <= 0.000001:
		_reset_swing_arc()
		return
	var angle := offset.angle()
	_arc_tracking = true
	_arc_previous_angle = angle
	_arc_unwrapped_angle = angle
	_arc_minimum_angle = angle
	_arc_maximum_angle = angle


func _track_swing_arc(offset: Vector2) -> void:
	if offset.length_squared() <= 0.000001:
		return
	if not _arc_tracking:
		_begin_swing_arc(offset)
		return
	var angle := offset.angle()
	var delta_angle := wrapf(angle - _arc_previous_angle, -PI, PI)
	_arc_unwrapped_angle += delta_angle
	_arc_previous_angle = angle
	_arc_minimum_angle = minf(_arc_minimum_angle, _arc_unwrapped_angle)
	_arc_maximum_angle = maxf(_arc_maximum_angle, _arc_unwrapped_angle)


func _reset_swing_arc() -> void:
	_arc_tracking = false
	_arc_previous_angle = 0.0
	_arc_unwrapped_angle = 0.0
	_arc_minimum_angle = 0.0
	_arc_maximum_angle = 0.0


func set_reel_active(active: bool) -> void:
	reel_active = active and attached and reel_energy > 0.0


func engage_reel(
	_position: Vector2,
	velocity: Vector2,
	_config: SwingConfig,
) -> Vector2:
	set_reel_active(true)
	return velocity


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
	return solve_moving_anchor(
		position,
		velocity,
		delta,
		config,
		anchor,
		Vector2.ZERO,
	)


## Solve the same maximum-length constraint in a moving support's reference
## frame. `next_anchor` and `anchor_velocity` come from the pure fixed-tick
## phase evaluator; no transform is accumulated here.
func solve_moving_anchor(
	position: Vector2,
	velocity: Vector2,
	delta: float,
	config: SwingConfig,
	next_anchor: Vector2,
	anchor_velocity: Vector2,
) -> Dictionary:
	tension = 0.0
	var predicted := position + velocity * delta
	if not attached:
		return {"position": predicted, "velocity": velocity}

	var offset := predicted - next_anchor
	var distance := offset.length()
	# Retain a configurable share of new inward movement exactly once. Static
	# slack does not keep shrinking on later ticks, so a percentage below 100%
	# leaves real elastic give instead of merely slowing a full ratchet.
	if config.automatic_take_up_enabled and \
			distance < _last_distance_to_anchor and distance < rope_length:
		var inward_movement := _last_distance_to_anchor - distance
		rope_length = maxf(
			config.web_minimum_length,
			rope_length - inward_movement * config.automatic_take_up_retention,
		)

	if distance <= 0.0001:
		_track_swing_arc(predicted - next_anchor)
		_last_distance_to_anchor = distance
		anchor = next_anchor
		return {"position": predicted, "velocity": velocity}

	var allowed_length := rope_length + config.rope_elasticity_allowance
	if distance <= allowed_length:
		_track_swing_arc(predicted - next_anchor)
		_last_distance_to_anchor = distance
		anchor = next_anchor
		return {"position": predicted, "velocity": velocity}

	var radial_direction := offset / distance
	var excess := distance - allowed_length
	var maximum_correction := config.attachment_correction_cap * delta
	var correction := minf(excess, maximum_correction)
	predicted -= radial_direction * correction

	var relative_velocity := velocity - anchor_velocity
	var outward_speed := relative_velocity.dot(radial_direction)
	if outward_speed > 0.0:
		relative_velocity -= radial_direction * outward_speed

	var damping_factor := maxf(0.0, 1.0 - config.rope_damping * delta)
	relative_velocity *= damping_factor
	velocity = relative_velocity + anchor_velocity
	tension = (
		(outward_speed * config.spider_mass / maxf(delta, 0.0001))
		+ (excess * config.spider_mass / maxf(delta * delta, 0.0001))
	)
	_track_swing_arc(predicted - next_anchor)
	anchor = next_anchor
	_last_distance_to_anchor = predicted.distance_to(anchor)

	return {"position": predicted, "velocity": velocity}

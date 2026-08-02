extends RefCounted
class_name SpiderMotor
## Deterministic point-mass motor. It owns forces, never web state.


static func apply_forces(
	current_velocity: Vector2,
	distance_pixels: float,
	delta: float,
	config: SwingConfig,
	gravity_scale: float = 1.0,
) -> Dictionary:
	var velocity := current_velocity
	var target_speed := config.target_speed_at(distance_pixels)

	# The floor and the ceiling are deliberately independent. Continuous drive
	# is zero because speed must be earned; the ceiling is not, because a
	# runaway the player cannot correct is a different problem from a free
	# push. Both branches shared `horizontal_drive_acceleration` until
	# 2026-08-02, so zeroing the drive silently removed the speed limit too —
	# after which only air drag acted on overspeed, proportionally, and
	# therefore never as a ceiling at all.
	if velocity.x < target_speed:
		velocity.x = move_toward(
			velocity.x,
			target_speed,
			config.horizontal_drive_acceleration * delta,
		)
	else:
		var speed_cap := config.spider_speed_cap_at(distance_pixels)
		if velocity.x > speed_cap:
			velocity.x = move_toward(
				velocity.x,
				speed_cap,
				config.overspeed_correction_acceleration * delta,
			)

	velocity.y += config.gravity * gravity_scale * delta
	var drag_factor := 1.0 / (1.0 + config.air_drag * delta)
	velocity *= drag_factor

	return {
		"velocity": velocity,
		"target_speed": target_speed,
	}

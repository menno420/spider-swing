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

	if velocity.x < target_speed:
		velocity.x = move_toward(
			velocity.x,
			target_speed,
			config.horizontal_drive_acceleration * delta,
		)
	elif velocity.x > target_speed + config.maximum_horizontal_overspeed:
		velocity.x = move_toward(
			velocity.x,
			target_speed + config.maximum_horizontal_overspeed,
			config.horizontal_drive_acceleration * 0.25 * delta,
		)

	velocity.y += config.gravity * gravity_scale * delta
	var drag_factor := 1.0 / (1.0 + config.air_drag * delta)
	velocity *= drag_factor

	return {
		"velocity": velocity,
		"target_speed": target_speed,
	}

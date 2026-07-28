extends RefCounted
class_name SimulationWorld
## Authoritative fixed-step Phase 0 simulation state.

const START_POSITION := Vector2(220.0, 390.0)
const START_VELOCITY := Vector2(360.0, -30.0)

var config: SwingConfig
var position: Vector2 = START_POSITION
var velocity: Vector2 = START_VELOCITY
var target_speed: float = 0.0
var distance_pixels: float = 0.0
var furthest_x: float = START_POSITION.x
var tick: int = 0
var anchors: PackedVector2Array = PackedVector2Array()
var web := WebConstraint.new()
var _commands: Array[InputCommand] = []


func reset(active_config: SwingConfig, course_anchors: PackedVector2Array) -> void:
	config = active_config
	position = START_POSITION
	velocity = START_VELOCITY
	target_speed = config.starting_target_speed
	distance_pixels = 0.0
	furthest_x = START_POSITION.x
	tick = 0
	anchors = course_anchors.duplicate()
	web.reset(config)
	_commands.clear()


func queue_command(command: InputCommand) -> void:
	_commands.append(command)


func step(delta: float) -> Array[SimulationEvent]:
	var events: Array[SimulationEvent] = []
	_commands.sort_custom(func(a: InputCommand, b: InputCommand) -> bool:
		return a.sequence < b.sequence)
	for command: InputCommand in _commands:
		_consume(command, events)
	_commands.clear()

	var motor_result := SpiderMotor.apply_forces(
		velocity, distance_pixels, delta, config)
	velocity = motor_result["velocity"]
	target_speed = float(motor_result["target_speed"])

	if web.advance_resource(delta, config):
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.REEL_EMPTY,
			position,
			"Reel energy empty",
		))

	var constraint_result := web.solve(position, velocity, delta, config)
	position = constraint_result["position"]
	velocity = constraint_result["velocity"]

	furthest_x = maxf(furthest_x, position.x)
	distance_pixels = maxf(0.0, furthest_x - START_POSITION.x)
	tick += 1

	if position.y > config.lower_world_boundary:
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.DEATH_REQUESTED,
			position,
			"Fell below the laboratory",
			{"cause": &"lower_boundary"},
		))
	elif position.x < left_kill_boundary():
		events.append(SimulationEvent.make(
			SimulationEvent.Kind.DEATH_REQUESTED,
			position,
			"Lost behind the camera",
			{"cause": &"camera_boundary"},
		))

	return events


func left_kill_boundary() -> float:
	return furthest_x - config.camera_left_kill_distance


func nearest_anchor(target: Vector2) -> Dictionary:
	var best_distance := INF
	var best := Vector2.ZERO
	for candidate: Vector2 in anchors:
		var distance := candidate.distance_to(target)
		if distance < best_distance:
			best_distance = distance
			best = candidate
	return {
		"found": best_distance <= config.attachment_snap_radius,
		"anchor": best,
		"distance": best_distance,
	}


func _consume(
	command: InputCommand,
	events: Array[SimulationEvent],
) -> void:
	match command.kind:
		InputCommand.Kind.ATTACH:
			var nearest := nearest_anchor(command.world_target)
			if not bool(nearest["found"]):
				events.append(SimulationEvent.make(
					SimulationEvent.Kind.INVALID_TARGET,
					command.world_target,
					"No web-compatible anchor",
				))
				return
			var selected_anchor: Vector2 = nearest["anchor"]
			var result := web.try_attach(position, selected_anchor, config)
			match result:
				WebConstraint.AttachResult.ATTACHED:
					events.append(SimulationEvent.make(
						SimulationEvent.Kind.ATTACHED,
						selected_anchor,
						"Web attached",
					))
				WebConstraint.AttachResult.OUT_OF_RANGE:
					events.append(SimulationEvent.make(
						SimulationEvent.Kind.OUT_OF_RANGE,
						selected_anchor,
						"Anchor out of range",
					))
				_:
					events.append(SimulationEvent.make(
						SimulationEvent.Kind.INVALID_TARGET,
						selected_anchor,
						"Anchor outside attachment cone",
					))
		InputCommand.Kind.RELEASE:
			if web.attached:
				web.release()
				events.append(SimulationEvent.make(
					SimulationEvent.Kind.RELEASED,
					position,
					"Momentum preserved",
				))
		InputCommand.Kind.REEL_START:
			web.set_reel_active(true)
		InputCommand.Kind.REEL_STOP:
			web.set_reel_active(false)

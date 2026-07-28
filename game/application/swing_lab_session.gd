extends Node
class_name SwingLabSession
## Phase 0 application orchestrator.
##
## Owns the command buffer, run lifecycle, fixed-step call order, named tuning
## presets, recording/replay, and snapshot publication. It never reads input or
## draws; adapters and presentation are wired by the bootstrap composition root.

signal snapshot_published(snapshot: SimulationSnapshot)
signal event_published(event: SimulationEvent)

const FIXED_DELTA := 1.0 / 60.0
const COURSE_SEED := 1337
const TUNING_PARAMETERS := LabLayout.TUNING_PARAMETERS

var _config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
var _world := SimulationWorld.new()
var _course_stream := CourseStream.new()
var _course_chunk_index: int = -1
var _run := RunStateMachine.new()
var _command_buffer: Array[InputCommand] = []
var _sequence: int = 0
var _debug_visible: bool = false
var _debug_paused: bool = false
var _slow_motion: bool = false
var _slow_motion_phase: int = 0
var _selected_parameter_index: int = 0
var _recording: bool = false
var _recorded_commands: Array[Dictionary] = []
var _replaying: bool = false
var _replay_commands: Array[Dictionary] = []
var _replay_cursor: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_reset_run()


func _physics_process(_delta: float) -> void:
	if _debug_paused:
		_publish_snapshot()
		return
	if _slow_motion:
		_slow_motion_phase = (_slow_motion_phase + 1) % 4
		if _slow_motion_phase != 0:
			_publish_snapshot()
			return
	_step_once()


func request_web_tap(world_target: Vector2) -> void:
	if _run.state != RunStateMachine.State.ACTIVE:
		request_restart()
		return
	_buffer(InputCommand.attach(world_target, _next_sequence(), _world.tick))


func set_reel_active(active: bool) -> void:
	if _run.state != RunStateMachine.State.ACTIVE:
		return
	_buffer(InputCommand.reel(active, _next_sequence(), _world.tick))


func request_burst() -> void:
	if _run.state != RunStateMachine.State.ACTIVE:
		return
	_buffer(InputCommand.burst(_next_sequence(), _world.tick))


func request_burst_from_gesture(world_target: Vector2) -> void:
	if _run.state != RunStateMachine.State.ACTIVE:
		return
	_buffer(InputCommand.burst_at(
		world_target,
		_next_sequence(),
		_world.tick,
	))


func request_restart() -> void:
	_reset_run()


func toggle_debug() -> void:
	_debug_visible = not _debug_visible
	_publish_snapshot()


func toggle_debug_pause() -> void:
	_debug_paused = not _debug_paused
	_publish_snapshot()


func step_debug_frame() -> void:
	if not _debug_paused:
		_debug_paused = true
	_step_once()


func toggle_slow_motion() -> void:
	_slow_motion = not _slow_motion
	_slow_motion_phase = 0
	_publish_snapshot()


func apply_preset(name: StringName) -> void:
	_config.apply_preset(name)
	_world.config = _config
	event_published.emit(SimulationEvent.make(
		SimulationEvent.Kind.PRESET_CHANGED,
		_world.position,
		"Preset: %s" % name,
	))
	_publish_snapshot()


func select_tuning_parameter(direction: int) -> void:
	_selected_parameter_index = posmod(
		_selected_parameter_index + direction, TUNING_PARAMETERS.size())
	_publish_snapshot()


func adjust_selected_parameter(direction: float) -> void:
	_config.adjust(TUNING_PARAMETERS[_selected_parameter_index], direction)
	_publish_snapshot()


func toggle_recording() -> void:
	if _replaying:
		return
	_recording = not _recording
	if _recording:
		_recorded_commands.clear()
	event_published.emit(SimulationEvent.make(
		SimulationEvent.Kind.RECORDING_CHANGED,
		_world.position,
		"Recording started" if _recording else "Recording stopped",
	))
	_publish_snapshot()


func replay_recording() -> void:
	if _recorded_commands.is_empty():
		event_published.emit(SimulationEvent.make(
			SimulationEvent.Kind.INVALID_TARGET,
			_world.position,
			"No recorded input trace",
		))
		return
	_recording = false
	_replay_commands = _recorded_commands.duplicate(true)
	_replay_cursor = 0
	_replaying = true
	_reset_run(false)
	event_published.emit(SimulationEvent.make(
		SimulationEvent.Kind.REPLAY_STARTED,
		_world.position,
		"Replaying %d commands" % _replay_commands.size(),
	))


func export_diagnostic() -> void:
	var geometry := _course_stream.geometry()
	var payload := {
		"format": "spider-swing-phase0-diagnostic",
		"version": 1,
		"seed": COURSE_SEED,
		"preset": str(_config.preset_name),
		"tick": _world.tick,
		"position": [_world.position.x, _world.position.y],
		"velocity": [_world.velocity.x, _world.velocity.y],
		"rope_length": _world.web.rope_length,
		"reel_energy": _world.web.reel_energy,
		"burst_cooldown": _world.burst_cooldown_remaining,
		"pull": {
			"active": _world.pull_active,
			"kind": str(_world.pull_kind),
			"travel_distance": _world.pull_distance_total,
			"remaining_distance": _world.pull_distance_remaining,
		},
		"tuning": {
			"burst_distance_fraction": _config.burst_distance_fraction,
			"dive_distance_fraction": _config.dive_distance_fraction,
			"reel_retraction_rate": _config.reel_retraction_rate,
			"surface_snap_distance": _config.surface_snap_distance,
		},
		"stream_chunks": [
			geometry.first_chunk_index,
			geometry.last_chunk_index,
		],
		"commands": _recorded_commands,
	}
	var path := "user://swing_lab_diagnostic.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload, "\t"))
		file.close()
		event_published.emit(SimulationEvent.make(
			SimulationEvent.Kind.DIAGNOSTIC_EXPORTED,
			_world.position,
			"Diagnostic saved",
			{"path": ProjectSettings.globalize_path(path)},
		))


func current_snapshot() -> SimulationSnapshot:
	return _make_snapshot()


func _step_once() -> void:
	if _run.state == RunStateMachine.State.ACTIVE:
		_feed_replay_commands()
		_command_buffer = _discard_expired_commands(_command_buffer)
		for command: InputCommand in _command_buffer:
			_world.queue_command(command)
		_command_buffer.clear()

		var next_chunk_index := maxi(
			0, floori(_world.position.x / CourseStream.CHUNK_WIDTH))
		if next_chunk_index != _course_chunk_index:
			_course_chunk_index = next_chunk_index
			_world.set_course_geometry(
				_course_stream.update_for_position(_world.position.x))
		var events := _world.step(FIXED_DELTA)
		for event: SimulationEvent in events:
			if event.kind == SimulationEvent.Kind.DEATH_REQUESTED:
				var cause := StringName(event.data.get("cause", &"unknown"))
				if not _run.request_death(cause, _config.death_confirmation_seconds):
					continue
				_world.web.release()
			event_published.emit(event)
	elif _run.state == RunStateMachine.State.DYING:
		_run.advance(FIXED_DELTA)
	_publish_snapshot()


func _buffer(command: InputCommand) -> void:
	if _recording:
		var record := command.to_record()
		record["playback_tick"] = _world.tick
		_recorded_commands.append(record)
	_command_buffer.append(command)


func _feed_replay_commands() -> void:
	if not _replaying:
		return
	while _replay_cursor < _replay_commands.size():
		var record: Dictionary = _replay_commands[_replay_cursor]
		if int(record.get("playback_tick", 0)) > _world.tick:
			break
		_command_buffer.append(InputCommand.from_record(record))
		_replay_cursor += 1
	if _replay_cursor >= _replay_commands.size():
		_replaying = false


func _discard_expired_commands(commands: Array[InputCommand]) -> Array[InputCommand]:
	var kept: Array[InputCommand] = []
	var maximum_ticks := ceili(_config.input_buffer_duration / FIXED_DELTA)
	for command: InputCommand in commands:
		if _world.tick - command.captured_tick <= maximum_ticks:
			kept.append(command)
	return kept


func _reset_run(clear_replay: bool = true) -> void:
	_run.reset()
	_course_stream.reset()
	_world.reset(_config, _course_stream.geometry())
	_course_chunk_index = maxi(
		0, floori(_world.position.x / CourseStream.CHUNK_WIDTH))
	_command_buffer.clear()
	_sequence = 0
	if clear_replay:
		_replaying = false
		_replay_cursor = 0
	event_published.emit(SimulationEvent.make(
		SimulationEvent.Kind.RUN_RESTARTED,
		_world.position,
		"Swing Laboratory ready",
	))
	_publish_snapshot()

func _make_snapshot() -> SimulationSnapshot:
	var snapshot := SimulationSnapshot.new()
	snapshot.tick = _world.tick
	snapshot.position = _world.position
	snapshot.velocity = _world.velocity
	snapshot.target_speed = _world.target_speed
	snapshot.distance_pixels = _world.distance_pixels
	snapshot.furthest_x = _world.furthest_x
	snapshot.left_kill_boundary = _world.left_kill_boundary()
	snapshot.web_attached = _world.web.attached
	snapshot.anchor = _world.web.anchor
	snapshot.rope_length = _world.web.rope_length
	snapshot.web_maximum_length = _config.web_maximum_length
	snapshot.tension = _world.web.tension
	snapshot.reel_energy = _world.web.reel_energy
	snapshot.reel_capacity = _config.reel_energy_capacity
	snapshot.reel_active = _world.web.reel_active
	snapshot.reel_lockout = _world.web.reel_lockout_remaining
	snapshot.burst_cooldown = _world.burst_cooldown_remaining
	snapshot.burst_cooldown_capacity = _config.burst_cooldown
	snapshot.pull_active = _world.pull_active
	snapshot.pull_kind = _world.pull_kind
	snapshot.pull_anchor = _world.pull_anchor
	snapshot.pull_distance_total = _world.pull_distance_total
	snapshot.pull_distance_remaining = _world.pull_distance_remaining
	snapshot.run_state = _run.state_name()
	snapshot.death_cause = _run.death_cause
	snapshot.preset_name = _config.preset_name
	snapshot.anchors = _world.anchors.duplicate()
	for surface: PackedVector2Array in _world.surfaces:
		snapshot.surfaces.append(surface.duplicate())
	for obstacle: PackedVector2Array in _world.obstacles:
		snapshot.obstacles.append(obstacle.duplicate())
	snapshot.debug_visible = _debug_visible
	snapshot.debug_paused = _debug_paused
	snapshot.slow_motion = _slow_motion
	snapshot.recording = _recording
	snapshot.replaying = _replaying
	snapshot.selected_parameter = TUNING_PARAMETERS[_selected_parameter_index]
	snapshot.selected_parameter_value = _config.value_for(snapshot.selected_parameter)
	snapshot.seed = COURSE_SEED
	snapshot.camera_follow_strength = _config.camera_follow_strength
	snapshot.camera_look_ahead = _config.camera_look_ahead
	return snapshot


func _publish_snapshot() -> void:
	snapshot_published.emit(_make_snapshot())


func _next_sequence() -> int:
	_sequence += 1
	return _sequence

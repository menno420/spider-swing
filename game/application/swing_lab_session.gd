extends Node
class_name SwingLabSession
## Phase 0 application orchestrator.
##
## Owns the command buffer, run lifecycle, fixed-step call order, named tuning
## presets, recording/replay, and snapshot publication. It never reads input or
## draws; adapters and presentation are wired by the bootstrap composition root.

signal snapshot_published(snapshot: SimulationSnapshot)
signal event_published(event: SimulationEvent)
signal settlement_created(settlement: RunSettlement)

const FIXED_DELTA := 1.0 / 60.0
const COURSE_SEED := 1337
static var TUNING_PARAMETERS: Array[StringName] = TuningCatalog.parameter_ids()

var _config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
var _world := SimulationWorld.new()
var _course_stream := CourseStream.new()
var _course_chunk_index: int = -1
var _run := RunStateMachine.new()
var _effects := EffectState.new()
var _progress := PlayerProgress.defaults()
var _creator_pattern: Array[StringName] = []
var _rescue_available: bool = true
var _command_buffer: Array[InputCommand] = []
var _sequence: int = 0
var _debug_visible: bool = false
var _collision_outlines_visible: bool = false
var _web_guides_visible: bool = false
var _debug_paused: bool = false
var _slow_motion: bool = false
var _slow_motion_phase: int = 0
var _debug_category_index: int = 0
var _selected_parameter_index: int = 0
var _recording: bool = false
var _recorded_commands: Array[Dictionary] = []
var _replaying: bool = false
var _replay_commands: Array[Dictionary] = []
var _replay_cursor: int = 0
var _run_sequence: int = 0
var _settlement_emitted: bool = false
var _session_id: String = "%d-%d" % [
	Time.get_unix_time_from_system(),
	Time.get_ticks_usec(),
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_reset_run()


func configure_progress(progress: PlayerProgress) -> void:
	_progress = progress.copy()
	_config = SpiderCatalog.resolved_config(_config.preset_name, _progress)
	if is_inside_tree():
		_world.config = _config


func configure_creator_pattern(pattern: Array[StringName]) -> void:
	_creator_pattern = pattern.duplicate()


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
	# A platform-classified double tap must never swallow the ordinary web that
	# can recover from a pull. While a pull owns motion, or while an empty
	# charge pool leaves a detached spider unable to Burst, reinterpret the
	# target as the immediately useful web intent.
	if _world.pull_active or (
		not _world.web.attached and _world.burst_charges <= 0
	):
		_buffer(InputCommand.attach(
			world_target,
			_next_sequence(),
			_world.tick,
		))
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


func toggle_collision_outlines() -> void:
	_collision_outlines_visible = not _collision_outlines_visible
	_publish_snapshot()


func toggle_web_guides() -> void:
	_web_guides_visible = not _web_guides_visible
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
	_config = SpiderCatalog.resolved_config(name, _progress)
	_world.config = _config
	_world.surface_bounce_ready = _config.surface_bounce_enabled
	_reset_course_stream()
	_world.set_course_geometry(_course_stream.geometry())
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
	var parameter: StringName = TUNING_PARAMETERS[_selected_parameter_index]
	_config.adjust(parameter, direction)
	_after_tuning_change(parameter)
	_publish_snapshot()


func select_tuning_category(index: int) -> void:
	_debug_category_index = clampi(
		index,
		0,
		TuningCatalog.category_count() - 1,
	)
	_publish_snapshot()


func adjust_tuning_parameter(
	parameter: StringName,
	direction: float,
) -> void:
	if parameter not in TUNING_PARAMETERS:
		return
	_selected_parameter_index = TUNING_PARAMETERS.find(parameter)
	_config.adjust(parameter, direction)
	_after_tuning_change(parameter)
	_publish_snapshot()


func set_tuning_parameter(parameter: StringName, value: float) -> void:
	if parameter not in TUNING_PARAMETERS:
		return
	_selected_parameter_index = TUNING_PARAMETERS.find(parameter)
	_config.set_tuning_value(parameter, value)
	_after_tuning_change(parameter)
	_publish_snapshot()


func _after_tuning_change(parameter: StringName) -> void:
	if parameter in [
		&"mid_hazard_m",
		&"edge_obstacle_size",
		&"floating_obstacle_size",
		&"gate_opening_size",
		&"corridor_contours",
		&"route_clearance",
		&"tight_gap_size",
		&"tight_corridor_m",
	]:
		_reset_course_stream()
		_world.set_course_geometry(_course_stream.geometry())
	elif parameter == &"course_rails" and \
			not _config.course_boundaries_enabled:
		_world.web.release()
	elif parameter == &"reel_capacity_seconds":
		_world.web.reel_energy = minf(
			_world.web.reel_energy,
			_config.reel_energy_capacity,
		)
	elif parameter == &"impact_shell":
		_world.surface_bounce_ready = _config.surface_bounce_enabled


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
		"dive_ready": _world.dive_ready,
		"surface_bounce_ready": _world.surface_bounce_ready,
		"pull": {
			"active": _world.pull_active,
			"kind": str(_world.pull_kind),
			"travel_distance": _world.pull_distance_total,
			"remaining_distance": _world.pull_distance_remaining,
		},
			"tuning": {
			"burst_distance_fraction": _config.burst_distance_fraction,
			"burst_minimum_distance": _config.burst_minimum_distance,
			"dive_distance_fraction": _config.dive_distance_fraction,
			"reel_retraction_rate": _config.reel_retraction_rate,
			"surface_snap_distance": _config.surface_snap_distance,
			"web_maximum_length": _config.web_maximum_length,
			"tap_retargets_when_attached":
				_config.web_tap_retargets_when_attached,
				"pull_cooldown": _config.burst_cooldown,
				"automatic_take_up_enabled": _config.automatic_take_up_enabled,
				"automatic_take_up_retention":
					_config.automatic_take_up_retention,
				"course_boundaries_enabled": _config.course_boundaries_enabled,
				"course_boundaries_lethal": _config.course_boundaries_lethal,
				"corridor_contours_enabled":
					_config.corridor_contours_enabled,
				"corridor_clearance_scale":
					_config.corridor_clearance_scale,
				"corridor_tight_gap_scale":
					_config.corridor_tight_gap_scale,
				"tight_corridor_start_distance":
					_config.tight_corridor_start_distance,
				"middle_hazard_start_distance":
					_config.middle_hazard_start_distance,
				"burst_frenzy_duration": _config.burst_frenzy_duration,
				"speed_curve_distance": _config.speed_curve_distance,
				"surface_bounce_enabled": _config.surface_bounce_enabled,
				"surface_bounce_max_impact_speed":
					_config.surface_bounce_max_impact_speed,
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
		for expired: StringName in _effects.advance(FIXED_DELTA):
			if expired == EffectState.BURST_FRENZY:
				event_published.emit(SimulationEvent.make(
					SimulationEvent.Kind.BOOST_EXPIRED,
					_world.position,
					"Burst Frenzy ended",
				))
		_world.set_burst_cooldown_suppressed(
			_effects.is_active(EffectState.BURST_FRENZY))
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
				_course_stream.update_for_position(
					_world.position.x,
					_config.middle_hazard_start_distance,
				))
		var events := _world.step(FIXED_DELTA)
		for event: SimulationEvent in events:
			if event.kind == SimulationEvent.Kind.BOOST_COLLECTED:
				_effects.activate(
					EffectState.BURST_FRENZY,
					_config.burst_frenzy_duration,
				)
			if event.kind == SimulationEvent.Kind.DEATH_REQUESTED:
				if _rescue_available and _config.rescue_life_enabled:
					_rescue_available = false
					event_published.emit(_world.rescue_after_death())
					continue
				var cause := StringName(event.data.get("cause", &"unknown"))
				if not _run.request_death(cause, _config.death_confirmation_seconds):
					continue
				_world.web.release()
				_emit_settlement(cause)
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
	_run_sequence += 1
	_settlement_emitted = false
	_effects.reset()
	_rescue_available = _config.rescue_life_enabled
	_reset_course_stream()
	_world.reset(_config, _course_stream.geometry())
	var guided := _world.begin_guided_opening()
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
		"Opening web ready" if guided else "Swing Laboratory ready",
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
	snapshot.burst_charges = _world.burst_charges
	snapshot.burst_charge_capacity = _config.burst_charge_capacity
	snapshot.dive_ready = _world.dive_ready
	snapshot.surface_bounce_enabled = _config.surface_bounce_enabled
	snapshot.surface_bounce_ready = _world.surface_bounce_ready
	snapshot.rescue_available = _rescue_available
	snapshot.rescue_shield_remaining = _world.rescue_shield_remaining
	snapshot.glide_remaining = _world.glide_remaining
	snapshot.glide_capacity = _config.glide_duration
	snapshot.pull_active = _world.pull_active
	snapshot.pull_kind = _world.pull_kind
	snapshot.pull_anchor = _world.pull_anchor
	snapshot.pull_distance_total = _world.pull_distance_total
	snapshot.pull_distance_remaining = _world.pull_distance_remaining
	snapshot.run_state = _run.state_name()
	snapshot.death_cause = _run.death_cause
	snapshot.preset_name = _config.preset_name
	if _config.course_boundaries_enabled:
		snapshot.anchors = _world.anchors.duplicate()
	for surface: PackedVector2Array in _world.surfaces:
		snapshot.surfaces.append(surface.duplicate())
	if _config.course_boundaries_enabled:
		for boundary: PackedVector2Array in _world.boundary_surfaces:
			snapshot.boundary_surfaces.append(boundary.duplicate())
	for obstacle: PackedVector2Array in _world.obstacles:
		snapshot.obstacles.append(obstacle.duplicate())
	snapshot.fly_positions = _world.fly_positions.duplicate()
	snapshot.boost_positions = _world.boost_positions.duplicate()
	snapshot.run_flies = _world.run_flies
	snapshot.total_flies = _progress.total_flies
	snapshot.burst_frenzy_remaining = _effects.remaining(
		EffectState.BURST_FRENZY)
	snapshot.burst_frenzy_capacity = _config.burst_frenzy_duration
	snapshot.course_boundaries_enabled = _config.course_boundaries_enabled
	snapshot.course_boundaries_lethal = _config.course_boundaries_lethal
	snapshot.automatic_take_up_enabled = _config.automatic_take_up_enabled
	snapshot.automatic_take_up_retention = \
		_config.automatic_take_up_retention
	snapshot.spider_style = _progress.selected_spider_style
	snapshot.spider_id = _progress.selected_spider_id
	snapshot.web_variant = _progress.selected_web_variant
	snapshot.player_collision_radius = _config.player_collision_radius
	_populate_dive_preview(snapshot)
	snapshot.debug_visible = _debug_visible
	snapshot.collision_outlines_visible = _collision_outlines_visible
	snapshot.web_guides_visible = _web_guides_visible
	snapshot.debug_paused = _debug_paused
	snapshot.slow_motion = _slow_motion
	snapshot.recording = _recording
	snapshot.replaying = _replaying
	snapshot.debug_category_index = _debug_category_index
	for parameter: StringName in TUNING_PARAMETERS:
		snapshot.tuning_values[parameter] = _config.value_for(parameter)
	snapshot.selected_parameter = TUNING_PARAMETERS[_selected_parameter_index]
	snapshot.selected_parameter_value = _config.value_for(snapshot.selected_parameter)
	snapshot.seed = COURSE_SEED
	snapshot.camera_follow_strength = _config.camera_follow_strength
	snapshot.camera_look_ahead = _config.camera_look_ahead
	return snapshot


func _populate_dive_preview(snapshot: SimulationSnapshot) -> void:
	if not _config.course_boundaries_enabled or not _world.dive_ready:
		return
	var best_distance := INF
	var best_anchor := Vector2.ZERO
	for anchor: Vector2 in _world.anchors:
		if anchor.x < _world.position.x - 40.0 or \
				anchor.y < _world.position.y + _config.downward_target_threshold:
			continue
		var distance := _world.position.distance_to(anchor)
		if distance < _config.web_minimum_length or \
				distance > _config.web_maximum_length or distance >= best_distance:
			continue
		best_distance = distance
		best_anchor = anchor
	if best_distance == INF:
		return
	var preview := _world.preview_pull(
		best_anchor,
		_config.dive_distance_fraction,
	)
	snapshot.dive_preview_available = true
	snapshot.dive_preview_anchor = best_anchor
	snapshot.dive_preview_endpoint = preview["endpoint"]
	snapshot.dive_preview_safe = bool(preview["safe"])


func _emit_settlement(cause: StringName) -> void:
	if _settlement_emitted:
		return
	_settlement_emitted = true
	settlement_created.emit(RunSettlement.create(
		"%s-run-%d" % [_session_id, _run_sequence],
		_world.distance_pixels,
		_world.run_flies,
		cause,
	))


func _publish_snapshot() -> void:
	snapshot_published.emit(_make_snapshot())


func _reset_course_stream() -> void:
	_course_stream.reset(
		_config.middle_hazard_start_distance,
		_config.edge_obstacle_scale,
		_config.floating_obstacle_scale,
		_config.gate_opening_scale,
		_creator_pattern,
		_config.corridor_contours_enabled,
		_config.corridor_clearance_scale,
		_config.corridor_tight_gap_scale,
		_config.tight_corridor_start_distance,
	)


func _next_sequence() -> int:
	_sequence += 1
	return _sequence

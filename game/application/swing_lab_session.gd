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
signal checkpoint_reached(region_id: StringName, distance_pixels: float)
signal campaign_level_completed(level_id: StringName)

const FIXED_DELTA := 1.0 / 60.0
## Trace identity and scale live in `TraceCatalog`, in domain, because the
## producer and the consumer must agree and neither may own the definition.
const INPUT_TRACE_FORMAT := TraceCatalog.INPUT_TRACE_FORMAT
const TRACE_PIXELS_PER_METRE := TraceCatalog.PIXELS_PER_METRE

const RUN_STANDARD := &"standard"
const RUN_PRACTICE := &"practice"
const RUN_CAMPAIGN := &"campaign"
static var TUNING_PARAMETERS: Array[StringName] = TuningCatalog.parameter_ids()
const BIRD_DEBUG_PARAMETERS := [
	&"bird_speed", &"bird_acceleration", &"bird_start_offset",
]

var _config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
var _world := SimulationWorld.new()
var _course_stream := CourseStream.new()
var _course_chunk_index: int = -1
var _run := RunStateMachine.new()
var _effects := EffectState.new()
var _progress := PlayerProgress.defaults()
var _progression_service := ProgressionService.new()
var _creator_pattern: Array[StringName] = []
var _run_mode: StringName = RUN_STANDARD
var _start_distance_pixels: float = 0.0
var _campaign_level_id: StringName = &""
## Which difficulty the run is played on. Standard until a run is configured.
var _difficulty_mode: StringName = DifficultyCatalog.MODE_STANDARD
## Verbs the player actually performed this run. A campaign level is only
## complete when its taught verb is in here, which is what stops a level
## from being cleared by swinging past the goal.
var _verbs_performed: Array[StringName] = []
var _debug_start_active: bool = false
var _debug_bird_overrides: Dictionary = {}
var _course_seed: int = 1337
var _course_seed_override: int = -1
var _recording_seed: int = 1337
var _last_region_id: StringName = CourseRegionCatalog.ANCIENT_FOREST
var _reached_checkpoint_ids: Array[StringName] = []
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


func configure_progress(
	progress: PlayerProgress,
	progression_service: ProgressionService = null,
) -> void:
	if progression_service != null:
		_progression_service = progression_service
	_progress = progress.copy()
	_config = _resolved_config(_config.preset_name)
	if is_inside_tree():
		_world.config = _config


func configure_creator_pattern(pattern: Array[StringName]) -> void:
	_creator_pattern = pattern.duplicate()


## Session-only owner controls. Keeping these separate from PlayerSettings and
## PlayerProgress guarantees Test Run comparisons never serialize as ownership
## or silently alter normal Play.
func configure_bird_debug_overrides(overrides: Dictionary) -> void:
	_debug_bird_overrides.clear()
	for parameter: StringName in BIRD_DEBUG_PARAMETERS:
		if not overrides.has(parameter) and not overrides.has(str(parameter)):
			continue
		var value: float = float(overrides.get(
			parameter, overrides.get(str(parameter), 0.0)))
		_debug_bird_overrides[parameter] = TuningCatalog.clamp_value(
			parameter, value)


## Apply the pre-run laboratory profile's explicit overrides after the selected
## base preset and owned/debug upgrade resolution. The resolved values shown in
## the editor are deliberately not all passed here: doing so would flatten the
## selected spider and progression curve. The caller may only use this for a
## debug-start practice run, and the batch is complete before its first tick.
func apply_debug_tuning_profile(values: Dictionary) -> void:
	if not _debug_start_active:
		return
	for parameter: StringName in TUNING_PARAMETERS:
		if parameter in [
			TuningCatalog.DEBUG_START_DISTANCE,
			TuningCatalog.DEBUG_UPGRADE_LEVEL,
		]:
			continue
		if not values.has(parameter) and not values.has(str(parameter)):
			continue
		var requested := float(values.get(
			parameter,
			values.get(str(parameter), _config.value_for(parameter)),
		))
		var safe_value := TuningCatalog.clamp_value(parameter, requested)
		_config.set_tuning_value(parameter, safe_value)
		if parameter in BIRD_DEBUG_PARAMETERS:
			_debug_bird_overrides[parameter] = safe_value
	_world.config = _config
	_world.surface_bounce_ready = _config.surface_bounce_enabled
	_reset_run(true, false)


func configure_run(
	mode: StringName = RUN_STANDARD,
	start_distance_pixels: float = 0.0,
	course_seed_override: int = -1,
	debug_start_requested: bool = false,
	campaign_level_id: StringName = &"",
) -> void:
	_debug_start_active = debug_start_requested
	_verbs_performed.clear()
	var requested_campaign := mode == RUN_CAMPAIGN and \
		CampaignCatalog.has_level(campaign_level_id)
	_campaign_level_id = campaign_level_id if requested_campaign else &""
	var requested_practice := mode == RUN_PRACTICE
	if requested_campaign:
		# A campaign level is one fixed course for every player and attempt,
		# so its seed is the level's, not the session's.
		_run_mode = RUN_CAMPAIGN
		# Teaching levels are the same course for everyone, so they ignore the
		# selected difficulty rather than teaching a verb on easier geometry.
		_difficulty_mode = DifficultyCatalog.MODE_STANDARD
		_config = _resolved_config(_config.preset_name)
		if is_inside_tree():
			_world.config = _config
		_start_distance_pixels = 0.0
		_course_seed_override = CampaignCatalog.course_seed(campaign_level_id)
		return
	# A normal run's settlement identity is the difficulty it was played on,
	# which is what gives each mode its own best distance. Practice and
	# campaign keep their own identities and record no per-mode best.
	_difficulty_mode = DifficultyCatalog.resolve(_progress.selected_difficulty)
	_run_mode = (
		RUN_PRACTICE
		if requested_practice or \
			_progression_service.debug_upgrade_overlay_enabled()
		else _difficulty_mode
	)
	_config = _resolved_config(_config.preset_name)
	if is_inside_tree():
		_world.config = _config
	_start_distance_pixels = (
		maxf(0.0, start_distance_pixels)
		if requested_practice
		else 0.0
	)
	_course_seed_override = course_seed_override


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
	if _run.state == RunStateMachine.State.DYING:
		# The dying window exists so the player can read what killed them
		# (`death_confirmation_seconds`, 0.45 s). At full pace the player taps
		# continuously, so a tap already in flight when the run ends would
		# otherwise consume the entire window and start the next run before the
		# cause is legible — measured at roughly 80 ms of a 450 ms window in an
		# owner device recording. DEAD is also the only state whose overlay
		# offers "Tap anywhere to restart", so restarting from DYING contradicts
		# the affordance the player is shown. Swallow the tap instead.
		return
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
	_config = _resolved_config(name)
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
	_apply_tuning_value(
		parameter,
		_tuning_value(parameter) + TuningCatalog.step_for(parameter) * direction,
	)


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
	_apply_tuning_value(
		parameter,
		_tuning_value(parameter) + TuningCatalog.step_for(parameter) * direction,
	)


func set_tuning_parameter(parameter: StringName, value: float) -> void:
	if parameter not in TUNING_PARAMETERS:
		return
	_selected_parameter_index = TUNING_PARAMETERS.find(parameter)
	_apply_tuning_value(parameter, value)


func _apply_tuning_value(parameter: StringName, value: float) -> void:
	var safe_value := TuningCatalog.clamp_value(parameter, value)
	if parameter == TuningCatalog.DEBUG_START_DISTANCE:
		_start_distance_pixels = safe_value
		_debug_start_active = true
		_run_mode = RUN_PRACTICE
		_reset_run(true, false)
		return
	if parameter == TuningCatalog.DEBUG_UPGRADE_LEVEL:
		_progression_service.set_debug_upgrade_overlay_level(roundi(safe_value))
		_config = _resolved_config(_config.preset_name)
		_world.config = _config
		_world.surface_bounce_ready = _config.surface_bounce_enabled
		# Once a mounted run has used an overlay it stays non-competitive even
		# after OWNED levels are restored. A fresh Play from Home starts standard.
		_run_mode = RUN_PRACTICE
		_reset_run(true, false)
		return
	if parameter in BIRD_DEBUG_PARAMETERS:
		_debug_bird_overrides[parameter] = safe_value
	_config.set_tuning_value(parameter, safe_value)
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
		_recording_seed = _course_seed
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
	_course_seed = _recording_seed
	_reset_run(false, false)
	event_published.emit(SimulationEvent.make(
		SimulationEvent.Kind.REPLAY_STARTED,
		_world.position,
		"Replaying %d commands" % _replay_commands.size(),
	))


## Load a trace produced outside this session and replay it here.
##
## `tools/simulate.gd --trace-top` writes the simulation lab's best runs in
## exactly the record shape `toggle_recording` produces, so a bot's run and a
## human's are the same kind of object and this is the same replay path. The
## point is that a search result can be *watched* rather than only read: no
## statistic decides whether a run was played fairly, a person watching it
## does.
##
## Everything that shapes the world is taken from the trace — course seed,
## start distance, difficulty, preset and upgrade level — because a replay
## fed into a different world is not a replay, it is a new run with borrowed
## input. Runs loaded this way go through `RUN_PRACTICE`, so they inherit the
## complete no-awards/no-records policy and cannot touch progression.
##
## Returns `{"ok": bool, "reason": String, "commands": int}`.
func load_input_trace(trace: Dictionary) -> Dictionary:
	if str(trace.get("format", "")) != INPUT_TRACE_FORMAT:
		return {
			"ok": false,
			"reason": "not a %s document" % INPUT_TRACE_FORMAT,
			"commands": 0,
		}
	var commands: Array = trace.get("commands", [])
	if commands.is_empty():
		return {"ok": false, "reason": "trace carries no input", "commands": 0}
	var setup: Dictionary = trace.get("setup", {})
	configure_bird_debug_overrides({
		&"bird_speed": float(setup.get(
			"bird_speed", SwingConfig.DEFAULT_BIRD_SPEED)),
		&"bird_acceleration": float(setup.get(
			"bird_acceleration", SwingConfig.DEFAULT_BIRD_ACCELERATION)),
		&"bird_start_offset": float(setup.get(
			"bird_start_offset", SwingConfig.DEFAULT_BIRD_START_OFFSET)),
	})

	_recording = false
	_difficulty_mode = DifficultyCatalog.resolve(
		StringName(setup.get("difficulty", "standard")))
	var upgrades := int(setup.get("upgrades", 0))
	if upgrades > 0:
		_progression_service.set_debug_upgrade_overlay_level(upgrades)
	else:
		_progression_service.clear_debug_upgrade_overlay()
	_config = _resolved_config(StringName(
		setup.get("preset", str(SwingConfig.PRESET_BALANCED))))
	if is_inside_tree():
		_world.config = _config

	_run_mode = RUN_PRACTICE
	_debug_start_active = int(setup.get("start_m", 0)) > 0
	_campaign_level_id = &""
	_verbs_performed.clear()
	_start_distance_pixels = maxf(
		0.0, float(int(setup.get("start_m", 0))) * TRACE_PIXELS_PER_METRE)
	_course_seed_override = int(setup.get("course_seed", -1))
	_course_seed = _course_seed_override

	# JSON hands back an untyped Array; `_replay_commands` is typed, and an
	# untyped assignment fails at runtime rather than at parse time — which
	# silently aborted the whole load before this was caught by a contract.
	var typed: Array[Dictionary] = []
	for record: Variant in commands:
		if typeof(record) != TYPE_DICTIONARY:
			return {
				"ok": false,
				"reason": "trace holds a non-record entry",
				"commands": 0,
			}
		typed.append(record)
	_replay_commands = typed
	_replay_cursor = 0
	_replaying = true
	# Do not rotate the seed: the trace names the course it was played on.
	_reset_run(false, false)
	event_published.emit(SimulationEvent.make(
		SimulationEvent.Kind.REPLAY_STARTED,
		_world.position,
		"Replaying %d command(s) from a lab trace" % commands.size(),
	))
	return {"ok": true, "reason": "", "commands": commands.size()}


## Read a trace document off disk. `res://` paths work on device, which is
## where a bundled trace lives.
static func read_input_trace(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func export_diagnostic() -> void:
	var geometry := _course_stream.geometry()
	var payload := {
		"format": "spider-swing-phase0-diagnostic",
		"version": 2,
		"seed": _course_seed,
		"run_mode": str(_run_mode),
		"start_distance_pixels": _start_distance_pixels,
		"debug_start_active": _debug_start_active,
		"debug_upgrade_overlay_level":
			_progression_service.debug_upgrade_overlay_level(),
		"records_eligible": _records_eligible(),
		"region": str(_last_region_id),
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
		_update_region_progress()
		for event: SimulationEvent in events:
			if event.kind == SimulationEvent.Kind.BOOST_COLLECTED:
				_effects.activate(
					EffectState.BURST_FRENZY,
					_config.burst_frenzy_duration,
				)
			_note_verb(event)
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
		_check_campaign_completion()
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


func _reset_run(
	clear_replay: bool = true,
	rotate_course_seed: bool = true,
) -> void:
	_run.reset()
	_run_sequence += 1
	if rotate_course_seed:
		_course_seed = _next_course_seed()
	_settlement_emitted = false
	_effects.reset()
	_rescue_available = _config.rescue_life_enabled
	_reached_checkpoint_ids.clear()
	_reset_course_stream()
	_world.reset(
		_config,
		_course_stream.geometry(),
		_start_distance_pixels,
	)
	var guided := _world.begin_guided_opening()
	var region := CourseRegionCatalog.region_for_distance(
		_world.distance_pixels)
	_last_region_id = StringName(region["id"])
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
		_run_start_message(region, guided),
		{
			"course_seed": _course_seed,
			"run_mode": _run_mode,
			"region_id": _last_region_id,
		},
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
	snapshot.bird_enabled = _world.bird_enabled()
	snapshot.bird_position = _world.bird_position
	snapshot.bird_velocity = _world.bird_velocity
	snapshot.bird_gap = _world.bird_gap()
	snapshot.bird_flap_phase = _world.bird_flap_phase
	snapshot.bird_flap_rate = _world.bird_flap_rate
	snapshot.bird_closing = _world.bird_closing
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
	for index in range(_world.surfaces.size()):
		snapshot.surfaces.append(_world.surfaces[index].duplicate())
		snapshot.surface_rest_polygons.append(
			_world._base_surfaces[index].duplicate())
		snapshot.surface_ids.append(_world.surface_ids[index])
		snapshot.surface_anchor_classes.append(
			_world.surface_anchor_classes[index])
		snapshot.surface_visual_ids.append(_world.surface_visual_ids[index])
	for index in range(_world.decorations.size()):
		snapshot.decorations.append(_world.decorations[index].duplicate())
		snapshot.decoration_rest_polygons.append(
			_world._base_decorations[index].duplicate())
		snapshot.decoration_ids.append(_world.decoration_ids[index])
		snapshot.decoration_visual_ids.append(
			_world.decoration_visual_ids[index])
		snapshot.decoration_active.append(
			_world._decoration_active[index]
			if index < _world._decoration_active.size() else 1)
	if _config.course_boundaries_enabled:
		for boundary: PackedVector2Array in _world.boundary_surfaces:
			snapshot.boundary_surfaces.append(boundary.duplicate())
	for index in range(_world.obstacles.size()):
		snapshot.obstacles.append(_world.obstacles[index].duplicate())
		snapshot.obstacle_contact_polygons.append(
			_world.obstacle_contact_polygons[index].duplicate()
			if index < _world.obstacle_contact_polygons.size()
			else _world.obstacles[index].duplicate())
		snapshot.obstacle_kinds.append(
			_world.obstacle_kinds[index]
				if index < _world.obstacle_kinds.size()
				else CourseObstacleCatalog.UNSPECIFIED)
		snapshot.obstacle_rest_polygons.append(
			_world._base_obstacles[index].duplicate())
		snapshot.obstacle_contact_rest_polygons.append(
			_world._base_obstacle_contact_polygons[index].duplicate()
			if index < _world._base_obstacle_contact_polygons.size()
			else _world._base_obstacles[index].duplicate())
		snapshot.obstacle_ids.append(_world.obstacle_ids[index])
		snapshot.obstacle_anchor_classes.append(
			_world.obstacle_anchor_classes[index])
		snapshot.obstacle_visual_ids.append(_world.obstacle_visual_ids[index])
		snapshot.obstacle_anchorable.append(
			_world.obstacle_anchorable[index]
			if index < _world.obstacle_anchorable.size() else 1)
		snapshot.obstacle_active.append(
			_world._obstacle_active[index]
			if index < _world._obstacle_active.size() else 1)
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
	snapshot.obstacle_contact_radius = _world.obstacle_contact_radius()
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
		snapshot.tuning_values[parameter] = _tuning_value(parameter)
	snapshot.selected_parameter = TUNING_PARAMETERS[_selected_parameter_index]
	snapshot.selected_parameter_value = _tuning_value(
		snapshot.selected_parameter)
	snapshot.seed = _course_seed
	snapshot.run_mode = _run_mode
	snapshot.start_distance_pixels = _start_distance_pixels
	snapshot.debug_start_active = _debug_start_active
	snapshot.debug_upgrade_overlay_level = \
		_progression_service.debug_upgrade_overlay_level()
	snapshot.records_eligible = _records_eligible()
	var region := CourseRegionCatalog.region_for_distance(
		_world.distance_pixels)
	snapshot.region_id = StringName(region["id"])
	snapshot.region_name = str(region["name"])
	snapshot.region_focus = str(region["focus"])
	snapshot.region_visual_profile = StringName(region["visual_profile"])
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


## Map a simulation event onto the verb it proves. Only a STARTED event
## counts: an UNAVAILABLE one means the player asked and the game said no,
## which teaches nothing.
func _note_verb(event: SimulationEvent) -> void:
	if _campaign_level_id.is_empty():
		return
	var verb := &""
	match event.kind:
		SimulationEvent.Kind.REEL_STARTED:
			verb = CampaignCatalog.VERB_REEL
		SimulationEvent.Kind.BURST_STARTED:
			verb = CampaignCatalog.VERB_BURST
		SimulationEvent.Kind.DIVE_STARTED:
			verb = CampaignCatalog.VERB_DIVE
		_:
			return
	if not verb in _verbs_performed:
		_verbs_performed.append(verb)


func _check_campaign_completion() -> void:
	if _campaign_level_id.is_empty() or _settlement_emitted:
		return
	if not CampaignCatalog.is_complete(
			_campaign_level_id,
			_world.distance_pixels,
			_verbs_performed):
		return
	var level_id := _campaign_level_id
	_settlement_emitted = true
	settlement_created.emit(RunSettlement.campaign(
		CampaignCatalog.settlement_id(level_id),
		_world.distance_pixels,
		&"campaign_complete",
		level_id,
		_course_seed,
	))
	campaign_level_completed.emit(level_id)


func _emit_settlement(cause: StringName) -> void:
	if _settlement_emitted:
		return
	_settlement_emitted = true
	var settlement := RunSettlement.create(
		"%s-run-%d" % [_session_id, _run_sequence],
		_world.distance_pixels,
		_world.run_flies,
		cause,
		_run_mode,
		_start_distance_pixels,
		_records_eligible(),
		_course_seed,
	)
	# `create` sets all three eligibility flags together; Harsh needs records
	# without a leaderboard slot, so the competitive one is set on its own.
	settlement.leaderboards_eligible = _leaderboards_eligible()
	settlement_created.emit(settlement)


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
		_course_seed,
		SimulationWorld.START_POSITION.x + _start_distance_pixels,
	)


func _update_region_progress() -> void:
	var region := CourseRegionCatalog.region_for_distance(
		_world.distance_pixels)
	var region_id := StringName(region["id"])
	if region_id != _last_region_id:
		_last_region_id = region_id
		event_published.emit(SimulationEvent.make(
			SimulationEvent.Kind.REGION_ENTERED,
			_world.position,
			"%s · %s" % [region["name"], region["focus"]],
			{
				"region_id": region_id,
				"visual_profile": region["visual_profile"],
			},
		))
	if not _records_eligible():
		return
	for checkpoint_id: StringName in \
			CourseRegionCatalog.checkpoint_ids_reached(
				_world.distance_pixels):
		if checkpoint_id in _reached_checkpoint_ids:
			continue
		_reached_checkpoint_ids.append(checkpoint_id)
		var checkpoint := CourseRegionCatalog.region_for_id(checkpoint_id)
		checkpoint_reached.emit(checkpoint_id, _world.distance_pixels)
		event_published.emit(SimulationEvent.make(
			SimulationEvent.Kind.CHECKPOINT_REACHED,
			_world.position,
			"Checkpoint unlocked · %s" % checkpoint["name"],
			{"region_id": checkpoint_id},
		))


func _resolved_config(preset_name: StringName) -> SwingConfig:
	var config := SpiderCatalog.resolved_config(
		preset_name,
		_progression_service.resolved_progress(_progress),
	)
	# Applied last and in one place, so every path that rebuilds the config
	# (preset change, progress change, upgrade overlay) carries the mode.
	DifficultyCatalog.apply_to_config(config, _difficulty_mode)
	for parameter: StringName in _debug_bird_overrides:
		config.set_tuning_value(parameter, float(_debug_bird_overrides[parameter]))
	return config


func _tuning_value(parameter: StringName) -> float:
	if parameter == TuningCatalog.DEBUG_START_DISTANCE:
		return _start_distance_pixels
	if parameter == TuningCatalog.DEBUG_UPGRADE_LEVEL:
		return float(_progression_service.debug_upgrade_overlay_level())
	return _config.value_for(parameter)


func _records_eligible() -> bool:
	return DifficultyCatalog.has_mode(_run_mode) and \
		DifficultyCatalog.records_eligible(_run_mode) and \
		not _debug_start_active and \
		not _progression_service.debug_upgrade_overlay_enabled()


## Only Standard is competitive (D-0033). Kept separate from records so Harsh
## can set a best and unlock checkpoints without claiming a leaderboard slot.
func _leaderboards_eligible() -> bool:
	return _records_eligible() and \
		DifficultyCatalog.leaderboards_eligible(_run_mode)


func _run_start_message(region: Dictionary, guided: bool) -> String:
	var overlay_level := _progression_service.debug_upgrade_overlay_level()
	if _debug_start_active:
		return (
			"DEBUG START %.0f m · UPGRADES L%d · awards nothing" % [
				_start_distance_pixels / 10.0,
				overlay_level,
			]
			if overlay_level >= 0
			else "DEBUG START %.0f m · awards nothing" % (
				_start_distance_pixels / 10.0)
		)
	if overlay_level >= 0:
		return "DEBUG UPGRADE OVERLAY L%d · awards nothing" % overlay_level
	if _run_mode == RUN_PRACTICE:
		return "%s practice · no records or rewards" % region["name"]
	if guided and _config.bird_speed > 0.0:
		return "Opening web ready · wings are already behind you"
	return "Opening web ready" if guided else "%s ready" % region["name"]


func _next_course_seed() -> int:
	if _course_seed_override >= 0:
		return _course_seed_override
	return posmod(
		hash("%s:%d" % [_session_id, _run_sequence]),
		2147483647,
	)


func _next_sequence() -> int:
	_sequence += 1
	return _sequence

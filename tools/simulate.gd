extends SceneTree
## Headless batch-run simulation lab for balance and systems tuning.
##
## Drives the authoritative SimulationWorld + CourseStream with a scripted,
## deliberately imperfect player model (aim error, reaction delay, decision
## cadence) and reports distance, death-cause, and resource metrics over many
## unpaced runs. Diagnostic instrumentation only: it is not part of the verify
## gate, asserts nothing, and SwingLabSession remains the game's only real run
## orchestrator.
##
##   godot --headless --path . --script res://tools/simulate.gd -- [options]
##
## Options (all `--name=value`, all optional):
##   --runs=20            runs per configuration
##   --skill=intermediate novice | intermediate | expert | all
##   --spider=classic     classic | skitter | anchorite | ballooner |
##                        springtail | all
##   --preset=balanced_candidate  named SwingConfig preset
##   --upgrades=0         0..20, applied to EVERY track of the selected spider
##   --seed=1             base seed for the bot-imperfection RNG
##   --max-seconds=240    per-run simulated-time cap (reported as `timeout`,
##                        which means "still alive", not a death)
##   --json=path          also write per-run rows and summaries as JSON
##
## The course itself is deterministic and identical every run; all run-to-run
## variation comes from the seeded imperfection model. That is deliberate:
## identical world, a distribution of player behaviour — so a tuning change
## shifts the metrics, not the luck.

const FIXED_DELTA := 1.0 / 60.0
const PIXELS_PER_METRE := 10.0
const DISTANCE_BANDS_M := [500.0, 1000.0, 2000.0, 3500.0]

## Imperfection model per skill tier. Ticks are 60 Hz simulation ticks.
const SKILL_PROFILES := {
	&"novice": {
		"decision_period_ticks": 10,
		"reaction_delay_ticks": 9,
		"aim_error_px": 46.0,
		"band_px": 72.0,
		"reel_band_px": 96.0,
		"panic_fall_speed": 470.0,
		"release_rise_speed": 150.0,
		"burst_chance": 0.05,
	},
	&"intermediate": {
		"decision_period_ticks": 7,
		"reaction_delay_ticks": 6,
		"aim_error_px": 26.0,
		"band_px": 52.0,
		"reel_band_px": 70.0,
		"panic_fall_speed": 390.0,
		"release_rise_speed": 175.0,
		"burst_chance": 0.16,
	},
	&"expert": {
		"decision_period_ticks": 4,
		"reaction_delay_ticks": 3,
		"aim_error_px": 10.0,
		"band_px": 36.0,
		"reel_band_px": 52.0,
		"panic_fall_speed": 330.0,
		"release_rise_speed": 200.0,
		"burst_chance": 0.30,
	},
}


func _initialize() -> void:
	var options := _parse_options(OS.get_cmdline_user_args())
	var skills := _expand(options["skill"], SKILL_PROFILES.keys())
	var spiders := _expand(options["spider"], SpiderCatalog.ALL_IDS)
	if skills.is_empty() or spiders.is_empty():
		printerr("[simulate] unknown --skill or --spider value")
		quit(2)
		return

	var all_rows: Array[Dictionary] = []
	var summaries: Array[Dictionary] = []
	print("[simulate] preset=%s upgrades=%d runs=%d seed=%d cap=%ds" % [
		options["preset"], options["upgrades"], options["runs"],
		options["seed"], options["max_seconds"],
	])
	for spider: StringName in spiders:
		var config_or_null := _resolve_config(
			StringName(options["preset"]),
			spider,
			int(options["upgrades"]),
		)
		if config_or_null == null:
			printerr("[simulate] configuration failed validation; aborting")
			quit(2)
			return
		for skill: StringName in skills:
			var rows := _run_batch(
				config_or_null,
				spider,
				skill,
				options,
			)
			all_rows.append_array(rows)
			var summary := _summarize(rows, spider, skill)
			summaries.append(summary)
			_print_summary(summary)

	var json_path := str(options["json"])
	if not json_path.is_empty():
		_write_json(json_path, options, all_rows, summaries)
	quit(0)


func _resolve_config(
	preset: StringName,
	spider: StringName,
	upgrade_level: int,
) -> SwingConfig:
	var progress := PlayerProgress.defaults()
	progress.selected_spider_id = spider
	if upgrade_level > 0:
		for upgrade: Dictionary in SpiderCatalog.upgrades_for(spider):
			progress.upgrade_levels[StringName(upgrade["id"])] = mini(
				upgrade_level,
				SpiderCatalog.MAX_UPGRADE_LEVEL,
			)
	var config := SpiderCatalog.resolved_config(preset, progress)
	var failures := config.validate()
	if failures.is_empty():
		return config
	for failure: String in failures:
		printerr("[simulate] config invalid: %s" % failure)
	return null


func _run_batch(
	config: SwingConfig,
	spider: StringName,
	skill: StringName,
	options: Dictionary,
) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var runs := int(options["runs"])
	var max_ticks := int(options["max_seconds"]) * 60
	for run_index in range(runs):
		var driver := RunDriver.new()
		driver.setup(
			config,
			SKILL_PROFILES[skill],
			int(options["seed"]) + run_index,
		)
		var row := driver.run(max_ticks)
		row["spider"] = str(spider)
		row["skill"] = str(skill)
		row["preset"] = str(config.preset_name)
		row["upgrades"] = int(options["upgrades"])
		row["run"] = run_index
		rows.append(row)
	return rows


func _summarize(
	rows: Array[Dictionary],
	spider: StringName,
	skill: StringName,
) -> Dictionary:
	var distances: Array[float] = []
	var causes: Dictionary = {}
	var bands: Dictionary = {}
	var flies := 0.0
	var reel_empties := 0.0
	var bursts := 0.0
	var attaches := 0.0
	var seconds := 0.0
	var rescues := 0
	for row: Dictionary in rows:
		var distance := float(row["distance_m"])
		distances.append(distance)
		var cause := str(row["cause"])
		causes[cause] = int(causes.get(cause, 0)) + 1
		if cause != "timeout":
			var band := _band_label(distance)
			bands[band] = int(bands.get(band, 0)) + 1
		flies += float(row["flies"])
		reel_empties += float(row["reel_empties"])
		bursts += float(row["bursts"])
		attaches += float(row["attaches"])
		seconds += float(row["seconds"])
		if bool(row["rescue_used"]):
			rescues += 1
	distances.sort()
	var count := maxi(1, rows.size())
	return {
		"spider": str(spider),
		"skill": str(skill),
		"runs": rows.size(),
		"distance_mean_m": _mean(distances),
		"distance_median_m": _percentile(distances, 0.5),
		"distance_p10_m": _percentile(distances, 0.10),
		"distance_p90_m": _percentile(distances, 0.90),
		"distance_max_m": 0.0 if distances.is_empty() else distances[-1],
		"mean_seconds": seconds / count,
		"mean_flies": flies / count,
		"mean_reel_empties": reel_empties / count,
		"mean_bursts": bursts / count,
		"mean_attaches": attaches / count,
		"rescue_used_runs": rescues,
		"death_causes": causes,
		"death_distance_bands": bands,
	}


func _print_summary(summary: Dictionary) -> void:
	print("")
	print("[simulate] %s · %s — %d run(s)" % [
		summary["spider"], summary["skill"], summary["runs"]])
	print("  distance m  mean %7.1f · median %7.1f · p10 %7.1f · p90 %7.1f · max %7.1f" % [
		summary["distance_mean_m"], summary["distance_median_m"],
		summary["distance_p10_m"], summary["distance_p90_m"],
		summary["distance_max_m"]])
	print("  per run     %.1fs · %.1f flies · %.2f reel-empty · %.1f bursts · %.1f webs · rescue in %d run(s)" % [
		summary["mean_seconds"], summary["mean_flies"],
		summary["mean_reel_empties"], summary["mean_bursts"],
		summary["mean_attaches"], summary["rescue_used_runs"]])
	print("  deaths      %s" % _histogram_text(summary["death_causes"]))
	print("  death bands %s" % _histogram_text(summary["death_distance_bands"]))


func _histogram_text(histogram: Dictionary) -> String:
	if histogram.is_empty():
		return "none"
	var keys := histogram.keys()
	keys.sort()
	var parts := PackedStringArray()
	for key: Variant in keys:
		parts.append("%s ×%d" % [str(key), int(histogram[key])])
	return " · ".join(parts)


func _band_label(distance_m: float) -> String:
	var lower := 0.0
	for edge: float in DISTANCE_BANDS_M:
		if distance_m < edge:
			return "%d-%dm" % [int(lower), int(edge)]
		lower = edge
	return "%dm+" % int(DISTANCE_BANDS_M[-1])


func _mean(values: Array[float]) -> float:
	if values.is_empty():
		return 0.0
	var total := 0.0
	for value: float in values:
		total += value
	return total / values.size()


func _percentile(sorted_values: Array[float], fraction: float) -> float:
	if sorted_values.is_empty():
		return 0.0
	var index := clampi(
		int(floorf(fraction * (sorted_values.size() - 1))),
		0,
		sorted_values.size() - 1,
	)
	return sorted_values[index]


func _expand(requested: String, known: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	if requested == "all":
		for value: Variant in known:
			result.append(StringName(value))
		return result
	if StringName(requested) in known:
		result.append(StringName(requested))
	return result


func _parse_options(arguments: PackedStringArray) -> Dictionary:
	var options := {
		"runs": 20,
		"skill": "intermediate",
		"spider": "classic",
		"preset": "balanced_candidate",
		"upgrades": 0,
		"seed": 1,
		"max_seconds": 240,
		"json": "",
	}
	for argument: String in arguments:
		if not argument.begins_with("--") or not argument.contains("="):
			continue
		var key := argument.substr(2, argument.find("=") - 2)
		var value := argument.substr(argument.find("=") + 1)
		match key:
			"runs":
				options["runs"] = maxi(1, int(value))
			"skill":
				options["skill"] = value
			"spider":
				options["spider"] = value
			"preset":
				options["preset"] = value
			"upgrades":
				options["upgrades"] = clampi(
					int(value), 0, SpiderCatalog.MAX_UPGRADE_LEVEL)
			"seed":
				options["seed"] = int(value)
			"max-seconds":
				options["max_seconds"] = maxi(10, int(value))
			"json":
				options["json"] = value
			_:
				printerr("[simulate] ignoring unknown option --%s" % key)
	return options


func _write_json(
	path: String,
	options: Dictionary,
	rows: Array[Dictionary],
	summaries: Array[Dictionary],
) -> void:
	var payload := {
		"format": "spider-swing-simulation-lab",
		"version": 1,
		"options": options,
		"summaries": summaries,
		"runs": rows,
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		printerr("[simulate] cannot write %s" % path)
		return
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	print("")
	print("[simulate] wrote %s" % path)


## One simulated run: the authoritative world plus the imperfect player model.
## Mirrors SwingLabSession's per-tick orchestration (effects, streaming,
## rescue) in the minimal form a headless batch needs.
class RunDriver:
	var config: SwingConfig
	var world := SimulationWorld.new()
	var stream := CourseStream.new()
	var effects := EffectState.new()
	var rng := RandomNumberGenerator.new()
	var profile: Dictionary
	var rescue_available := true
	var rescue_used := false
	var chunk_index := -1
	var sequence := 0
	var pending: Array[Dictionary] = []
	var wants_reel := false
	var attaches := 0
	var bursts := 0
	var dives := 0
	var reel_empties := 0

	func setup(
		active_config: SwingConfig,
		skill_profile: Dictionary,
		seed_value: int,
	) -> void:
		config = active_config
		profile = skill_profile
		rng.seed = seed_value
		stream.reset(
			config.middle_hazard_start_distance,
			config.edge_obstacle_scale,
			config.floating_obstacle_scale,
			config.gate_opening_scale,
			[],
			config.corridor_contours_enabled,
			config.corridor_clearance_scale,
			config.corridor_tight_gap_scale,
			config.tight_corridor_start_distance,
		)
		world.reset(config, stream.geometry())
		world.begin_guided_opening()
		rescue_available = config.rescue_life_enabled
		chunk_index = maxi(
			0, floori(world.position.x / CourseStream.CHUNK_WIDTH))

	func run(max_ticks: int) -> Dictionary:
		var cause: StringName = &"timeout"
		var finished := false
		while not finished and world.tick < max_ticks:
			world.set_burst_cooldown_suppressed(
				effects.is_active(EffectState.BURST_FRENZY))
			effects.advance(FIXED_DELTA)
			_deliver_due_commands()
			if world.tick % int(profile["decision_period_ticks"]) == 0:
				_decide()
			var next_chunk := maxi(
				0, floori(world.position.x / CourseStream.CHUNK_WIDTH))
			if next_chunk != chunk_index:
				chunk_index = next_chunk
				world.set_course_geometry(stream.update_for_position(
					world.position.x,
					config.middle_hazard_start_distance,
				))
			for event: SimulationEvent in world.step(FIXED_DELTA):
				match event.kind:
					SimulationEvent.Kind.DEATH_REQUESTED:
						if rescue_available:
							rescue_available = false
							rescue_used = true
							wants_reel = false
							pending.clear()
							world.rescue_after_death()
							continue
						cause = StringName(
							event.data.get("cause", &"unknown"))
						finished = true
					SimulationEvent.Kind.BOOST_COLLECTED:
						effects.activate(
							EffectState.BURST_FRENZY,
							config.burst_frenzy_duration,
						)
					SimulationEvent.Kind.ATTACHED:
						attaches += 1
					SimulationEvent.Kind.RELEASED:
						wants_reel = false
					SimulationEvent.Kind.REEL_EMPTY:
						reel_empties += 1
					SimulationEvent.Kind.BURST_STARTED:
						bursts += 1
					SimulationEvent.Kind.DIVE_STARTED:
						dives += 1
		return {
			"seed": int(rng.seed),
			"distance_m": world.distance_pixels / PIXELS_PER_METRE,
			"seconds": world.tick * FIXED_DELTA,
			"cause": str(cause),
			"flies": world.run_flies,
			"attaches": attaches,
			"bursts": bursts,
			"dives": dives,
			"reel_empties": reel_empties,
			"rescue_used": rescue_used,
		}

	## The whole player model. It reads only what a player could see: its own
	## motion, the fly trail (the game's route language), and solid geometry
	## through the same forgiving nearest-solid query a real tap gets.
	func _decide() -> void:
		var target_y := _route_target_y()
		var band := float(profile["band_px"])
		if world.pull_active:
			return
		if world.web.attached:
			_decide_attached(target_y, band)
		else:
			_decide_detached(target_y, band)

	func _decide_attached(target_y: float, band: float) -> void:
		var rising_fast := world.velocity.y < \
			-float(profile["release_rise_speed"])
		var high_enough := world.position.y < target_y - band
		var near_ceiling := world.position.y < 230.0
		if (rising_fast and world.position.y < target_y + band) or \
				high_enough or near_ceiling:
			_set_reel(false)
			_schedule(InputCommand.release(_next_sequence(), world.tick))
			return
		var too_low := world.position.y > target_y + \
			float(profile["reel_band_px"])
		var energy_fraction := world.web.reel_energy / \
			maxf(0.001, config.reel_energy_capacity)
		if wants_reel:
			if world.position.y <= target_y or energy_fraction <= 0.08 or \
					near_ceiling:
				_set_reel(false)
		elif too_low and energy_fraction > 0.2:
			_set_reel(true)

	func _decide_detached(target_y: float, band: float) -> void:
		var falling_fast := world.velocity.y > \
			float(profile["panic_fall_speed"])
		var below_route := world.position.y > target_y + band
		var floor_danger := world.position.y > 600.0
		if not (falling_fast or below_route or floor_danger):
			if world.burst_cooldown_remaining <= 0.0 and \
					rng.randf() < float(profile["burst_chance"]):
				var burst_tap := _find_tap(Vector2(1.0, -0.35), 460.0)
				if burst_tap != Vector2.INF:
					_schedule(InputCommand.burst_at(
						burst_tap, _next_sequence(), world.tick))
			return
		var tap := _find_attach_tap()
		if tap != Vector2.INF:
			_schedule(InputCommand.attach(tap, _next_sequence(), world.tick))

	## Fan of up-forward taps; the first whose snapped anchor is usable wins.
	func _find_attach_tap() -> Vector2:
		for angle_degrees: float in [-70.0, -52.0, -36.0, -20.0]:
			var direction := Vector2.RIGHT.rotated(deg_to_rad(angle_degrees))
			var tap := _find_tap(direction, 0.62 * config.web_maximum_length)
			if tap != Vector2.INF:
				return tap
		return Vector2.INF

	func _find_tap(direction: Vector2, reach: float) -> Vector2:
		var error := Vector2(
			rng.randfn(0.0, float(profile["aim_error_px"])),
			rng.randfn(0.0, float(profile["aim_error_px"])),
		)
		var tap := world.position + direction.normalized() * reach + error
		var nearest := world.nearest_solid_point(tap)
		if not bool(nearest["found"]):
			return Vector2.INF
		var anchor := Vector2(nearest["anchor"])
		if anchor.y >= world.position.y + config.downward_target_threshold:
			return Vector2.INF
		if anchor.x < world.position.x - 60.0:
			return Vector2.INF
		var distance := world.position.distance_to(anchor)
		if distance < config.web_minimum_length * 1.1 or \
				distance > config.web_maximum_length * 0.98:
			return Vector2.INF
		return tap

	## The fly trail is the authored route language; following it is exactly
	## what the game asks of a player, not a bot cheat.
	func _route_target_y() -> float:
		var total := 0.0
		var count := 0
		for fly: Vector2 in world.fly_positions:
			if fly.x < world.position.x + 40.0 or \
					fly.x > world.position.x + 760.0:
				continue
			total += fly.y
			count += 1
		if count == 0:
			return 398.0
		return total / count

	func _set_reel(active: bool) -> void:
		if wants_reel == active:
			return
		wants_reel = active
		_schedule(InputCommand.reel(active, _next_sequence(), world.tick))

	func _schedule(command: InputCommand) -> void:
		pending.append({
			"deliver_tick": world.tick +
				int(profile["reaction_delay_ticks"]) + rng.randi_range(0, 2),
			"command": command,
		})

	func _deliver_due_commands() -> void:
		var kept: Array[Dictionary] = []
		for entry: Dictionary in pending:
			if int(entry["deliver_tick"]) <= world.tick:
				var command: InputCommand = entry["command"]
				command.captured_tick = world.tick
				world.queue_command(command)
			else:
				kept.append(entry)
		pending = kept

	func _next_sequence() -> int:
		sequence += 1
		return sequence

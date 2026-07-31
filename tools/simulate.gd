extends SceneTree
## Headless batch-run simulation lab for balance and systems tuning (bot v2).
##
## Drives the authoritative SimulationWorld + CourseStream with a scripted,
## deliberately imperfect player model and reports distance, death-cause, and
## resource metrics over many unpaced runs. Diagnostic instrumentation only:
## it is not part of the verify gate, asserts nothing, and SwingLabSession
## remains the game's only real run orchestrator.
##
##   godot --headless --path . --script res://tools/simulate.gd -- [options]
##
## Options (all `--name=value`, all optional):
##   --runs=20            runs per configuration
##   --skill=intermediate novice | intermediate | expert | all
##   --spider=classic     classic | skitter | anchorite | ballooner |
##                        buckler | all
##   --preset=balanced_baseline   named SwingConfig preset
##   --upgrades=0         0..20, applied to EVERY track of the selected spider
##   --seed=1             base seed for the bot-imperfection RNG
##   --course-seed=1337   first production course seed
##   --course-seeds=1     number of consecutive course seeds to rotate through
##   --max-seconds=240    per-run simulated-time cap (reported as `timeout`,
##                        which means "still alive", not a death)
##   --start-m=0          warp the run start this many metres into the course
##                        at the pace curve's speed for that distance — for
##                        testing late-game regimes without surviving to them
##   --reel-style=adaptive  adaptive | tap | hold — how the bot spends Reel
##   --save-bursts=on     on | off — emergency Burst when no web can save it
##   --sweep=SPEC         parameter grid, e.g.
##                        `reel_rate:260:440:4` or
##                        `reel_rate:260:440:4,pull_cooldown:1.2:2.4:3`
##                        (max 60 combined points; needs one skill + spider).
##                        Names: TuningCatalog ids first, else raw SwingConfig
##                        property names (e.g. reel_regeneration_rate).
##   --json=path          write per-run rows and summaries as JSON
##
## Bot v2 adapts to the configuration it is handed, the way a player learns
## their build: its Reel reserve follows the meter's sustainability
## (drain vs regeneration), its Reel engagement follows the retraction rate,
## and its Burst aim shortens as the pull fraction grows — plus a
## skill-scaled habit of checking the game's own pull-safety preview before
## committing. The course is deterministic; all run-to-run variation comes
## from the seeded imperfection model, so a tuning change shifts the
## metrics. `--course-seeds` deliberately sweeps curated course order
## separately from modeled player imperfection.

const BOT_MODEL_VERSION := 2
const FIXED_DELTA := 1.0 / 60.0
const PIXELS_PER_METRE := 10.0
const DISTANCE_BANDS_M := [500.0, 1000.0, 2000.0, 3500.0]
const SWEEP_MAX_POINTS := 60

## Imperfection model per skill tier. Ticks are 60 Hz simulation ticks.
## `care` is the probability of checking the pull-safety preview (the same
## endpoint/safe information the HUD shows) before committing to a Burst.
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
		"care": 0.40,
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
		"care": 0.75,
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
		"care": 0.95,
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
	var sweep := _parse_sweep(str(options["sweep"]))
	if not bool(sweep["ok"]):
		quit(2)
		return
	var sweep_points: Array = sweep["points"]
	if not sweep_points.is_empty() and \
			(skills.size() != 1 or spiders.size() != 1):
		printerr("[simulate] --sweep needs exactly one --skill and one --spider")
		quit(2)
		return

	print("[simulate] bot model v%d · preset=%s upgrades=%d runs=%d seed=%d course=%d..%d cap=%ds reel-style=%s save-bursts=%s" % [
		BOT_MODEL_VERSION, options["preset"], options["upgrades"],
		options["runs"], options["seed"], options["course_seed"],
		int(options["course_seed"]) + int(options["course_seeds"]) - 1,
		options["max_seconds"],
		options["reel_style"], "on" if bool(options["save_bursts"]) else "off",
	])

	var all_rows: Array[Dictionary] = []
	var summaries: Array[Dictionary] = []
	if sweep_points.is_empty():
		for spider: StringName in spiders:
			var config := _resolve_config(
				StringName(options["preset"]), spider,
				int(options["upgrades"]), {})
			if config == null:
				quit(2)
				return
			for skill: StringName in skills:
				var rows := _run_batch(config, spider, skill, options, {})
				all_rows.append_array(rows)
				var summary := _summarize(rows, spider, skill, {})
				summaries.append(summary)
				_print_summary(summary)
	else:
		var spider: StringName = spiders[0]
		var skill: StringName = skills[0]
		for point: Dictionary in sweep_points:
			var config := _resolve_config(
				StringName(options["preset"]), spider,
				int(options["upgrades"]), point)
			if config == null:
				print("[simulate] sweep point %s skipped (invalid config)" %
					_point_text(point))
				continue
			var rows := _run_batch(config, spider, skill, options, point)
			all_rows.append_array(rows)
			var summary := _summarize(rows, spider, skill, point)
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
	overrides: Dictionary,
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
	for name: String in overrides:
		var value := float(overrides[name])
		if not TuningCatalog.descriptor(StringName(name)).is_empty():
			config.set_tuning_value(StringName(name), value)
		elif name in config:
			config.set(name, value)
		else:
			printerr("[simulate] unknown sweep parameter '%s'" % name)
			return null
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
	point: Dictionary,
) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var runs := int(options["runs"])
	var max_ticks := int(options["max_seconds"]) * 60
	for run_index in range(runs):
		var course_seed := int(options["course_seed"]) + \
			posmod(run_index, int(options["course_seeds"]))
		var driver := RunDriver.new()
		driver.setup(
			config,
			SKILL_PROFILES[skill],
			int(options["seed"]) + run_index,
			StringName(options["reel_style"]),
			bool(options["save_bursts"]),
			float(int(options["start_m"])) * PIXELS_PER_METRE,
			course_seed,
		)
		var row := driver.run(max_ticks)
		row["spider"] = str(spider)
		row["skill"] = str(skill)
		row["preset"] = str(config.preset_name)
		row["upgrades"] = int(options["upgrades"])
		row["run"] = run_index
		if not point.is_empty():
			row["sweep"] = point.duplicate(true)
		rows.append(row)
	return rows


func _summarize(
	rows: Array[Dictionary],
	spider: StringName,
	skill: StringName,
	point: Dictionary,
) -> Dictionary:
	var distances: Array[float] = []
	var causes: Dictionary = {}
	var bands: Dictionary = {}
	var regions: Dictionary = {}
	var patterns: Dictionary = {}
	var totals := {
		"flies": 0.0, "reel_empties": 0.0, "bursts": 0.0, "dives": 0.0,
		"attaches": 0.0, "seconds": 0.0, "reel_time_s": 0.0,
		"reel_energy_spent": 0.0, "time_empty_s": 0.0, "save_bursts": 0.0,
	}
	var rescues := 0
	var pull_deaths := 0
	var rescue_distance_total := 0.0
	for row: Dictionary in rows:
		var distance := float(row["distance_m"])
		distances.append(distance)
		var cause := str(row["cause"])
		causes[cause] = int(causes.get(cause, 0)) + 1
		if cause != "timeout":
			var band := _band_label(distance)
			bands[band] = int(bands.get(band, 0)) + 1
			var region := str(row["region"])
			var pattern := str(row["pattern"])
			regions[region] = int(regions.get(region, 0)) + 1
			patterns[pattern] = int(patterns.get(pattern, 0)) + 1
		for key: String in totals:
			totals[key] = float(totals[key]) + float(row[key])
		if bool(row["rescue_used"]):
			rescues += 1
			rescue_distance_total += float(row["rescue_distance_m"])
		if bool(row["death_during_pull"]):
			pull_deaths += 1
	distances.sort()
	var count := maxi(1, rows.size())
	var total_km := 0.0
	for distance: float in distances:
		total_km += distance / 1000.0
	return {
		"spider": str(spider),
		"skill": str(skill),
		"sweep": point.duplicate(true),
		"runs": rows.size(),
		"distance_mean_m": _mean(distances),
		"distance_median_m": _percentile(distances, 0.5),
		"distance_p10_m": _percentile(distances, 0.10),
		"distance_p90_m": _percentile(distances, 0.90),
		"distance_max_m": 0.0 if distances.is_empty() else distances[-1],
		"mean_seconds": float(totals["seconds"]) / count,
		"mean_flies": float(totals["flies"]) / count,
		"flies_per_km": 0.0 if total_km <= 0.0
			else float(totals["flies"]) / total_km,
		"mean_reel_empties": float(totals["reel_empties"]) / count,
		"mean_reel_time_s": float(totals["reel_time_s"]) / count,
		"mean_reel_energy_spent": float(totals["reel_energy_spent"]) / count,
		"mean_time_empty_s": float(totals["time_empty_s"]) / count,
		"mean_bursts": float(totals["bursts"]) / count,
		"mean_dives": float(totals["dives"]) / count,
		"mean_save_bursts": float(totals["save_bursts"]) / count,
		"mean_attaches": float(totals["attaches"]) / count,
		"rescue_used_runs": rescues,
		"rescue_mean_distance_m": 0.0 if rescues == 0
			else rescue_distance_total / rescues,
		"pull_death_runs": pull_deaths,
		"death_causes": causes,
		"death_distance_bands": bands,
		"death_regions": regions,
		"death_patterns": patterns,
	}


func _print_summary(summary: Dictionary) -> void:
	print("")
	var header := "[simulate] %s · %s — %d run(s)" % [
		summary["spider"], summary["skill"], summary["runs"]]
	var point: Dictionary = summary["sweep"]
	if not point.is_empty():
		header += " · %s" % _point_text(point)
	print(header)
	print("  distance m  mean %7.1f · median %7.1f · p10 %7.1f · p90 %7.1f · max %7.1f" % [
		summary["distance_mean_m"], summary["distance_median_m"],
		summary["distance_p10_m"], summary["distance_p90_m"],
		summary["distance_max_m"]])
	print("  per run     %.1fs · %.1f flies (%.1f/km) · %.1f webs · %.1f bursts (%.1f saves) · %.1f dives" % [
		summary["mean_seconds"], summary["mean_flies"],
		summary["flies_per_km"], summary["mean_attaches"],
		summary["mean_bursts"], summary["mean_save_bursts"],
		summary["mean_dives"]])
	print("  reel        %.2fs held · %.1f energy spent · %.2f empties · %.2fs at empty" % [
		summary["mean_reel_time_s"], summary["mean_reel_energy_spent"],
		summary["mean_reel_empties"], summary["mean_time_empty_s"]])
	print("  lives       rescue in %d run(s), mean at %.0f m · %d death(s) mid-pull" % [
		summary["rescue_used_runs"], summary["rescue_mean_distance_m"],
		summary["pull_death_runs"]])
	print("  deaths      %s" % _histogram_text(summary["death_causes"]))
	print("  death bands %s" % _histogram_text(summary["death_distance_bands"]))
	print("  regions     %s" % _histogram_text(summary["death_regions"]))
	print("  patterns    %s" % _histogram_text(summary["death_patterns"]))


func _point_text(point: Dictionary) -> String:
	var parts := PackedStringArray()
	for name: String in point:
		parts.append("%s=%s" % [name, String.num(float(point[name]), 3)])
	return " ".join(parts)


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


## Parse `name:lo:hi:steps[,name2:...]` into the cartesian grid of override
## dictionaries. Returns {"ok": bool, "points": Array[Dictionary]}; an empty
## spec is ok with no points, a malformed spec is not ok.
func _parse_sweep(spec: String) -> Dictionary:
	if spec.is_empty():
		return {"ok": true, "points": [] as Array[Dictionary]}
	var axes: Array[Dictionary] = []
	for part: String in spec.split(","):
		var fields := part.split(":")
		if fields.size() != 4:
			printerr("[simulate] bad --sweep segment '%s' (want name:lo:hi:steps)" % part)
			return {"ok": false, "points": [] as Array[Dictionary]}
		var steps := maxi(1, int(fields[3]))
		var lo := float(fields[1])
		var hi := float(fields[2])
		var values: Array[float] = []
		for index in range(steps):
			var progress := 0.0 if steps == 1 \
				else float(index) / float(steps - 1)
			values.append(lerpf(lo, hi, progress))
		axes.append({"name": fields[0], "values": values})
	var points: Array[Dictionary] = [{}]
	for axis: Dictionary in axes:
		var next_points: Array[Dictionary] = []
		for point: Dictionary in points:
			for value: float in axis["values"]:
				var grown := point.duplicate(true)
				grown[str(axis["name"])] = value
				next_points.append(grown)
		points = next_points
	if points.size() > SWEEP_MAX_POINTS:
		printerr("[simulate] sweep has %d points; the cap is %d" % [
			points.size(), SWEEP_MAX_POINTS])
		return {"ok": false, "points": [] as Array[Dictionary]}
	return {"ok": true, "points": points}


func _parse_options(arguments: PackedStringArray) -> Dictionary:
	var options := {
		"runs": 20,
		"skill": "intermediate",
		"spider": "classic",
		"preset": str(SwingConfig.PRESET_BALANCED),
		"upgrades": 0,
		"seed": 1,
		"course_seed": 1337,
		"course_seeds": 1,
		"max_seconds": 240,
		"start_m": 0,
		"reel_style": "adaptive",
		"save_bursts": true,
		"sweep": "",
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
			"course-seed":
				options["course_seed"] = int(value)
			"course-seeds":
				options["course_seeds"] = maxi(1, int(value))
			"max-seconds":
				options["max_seconds"] = maxi(10, int(value))
			"start-m":
				options["start_m"] = maxi(0, int(value))
			"reel-style":
				if value in ["adaptive", "tap", "hold"]:
					options["reel_style"] = value
				else:
					printerr("[simulate] unknown --reel-style '%s'" % value)
			"save-bursts":
				options["save_bursts"] = value != "off"
			"sweep":
				options["sweep"] = value
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
		"version": 2,
		"bot_model": BOT_MODEL_VERSION,
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
	var reel_style: StringName = &"adaptive"
	var save_bursts_enabled := true
	var rescue_available := true
	var rescue_used := false
	var rescue_distance_m := 0.0
	var chunk_index := -1
	var sequence := 0
	var pending: Array[Dictionary] = []
	var wants_reel := false
	var attaches := 0
	var bursts := 0
	var save_bursts := 0
	var dives := 0
	var reel_empties := 0
	var reel_ticks := 0
	var empty_ticks := 0
	var reel_energy_spent := 0.0
	var reel_reserve := 0.2
	var reel_band_scale := 1.0
	var burst_reach := 460.0
	var course_seed := 1337

	func setup(
		active_config: SwingConfig,
		skill_profile: Dictionary,
		seed_value: int,
		style: StringName,
		defensive_bursts: bool,
		start_offset_px: float = 0.0,
		course_seed_value: int = 1337,
	) -> void:
		config = active_config
		profile = skill_profile
		rng.seed = seed_value
		reel_style = style
		save_bursts_enabled = defensive_bursts
		course_seed = course_seed_value
		_derive_adaptations()
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
			course_seed,
			SimulationWorld.START_POSITION.x + start_offset_px,
		)
		world.reset(config, stream.geometry(), start_offset_px)
		# Late-game warp uses the same checkpoint-safe world reset and ordinary
		# guided web as production practice mode.
		world.begin_guided_opening()
		rescue_available = config.rescue_life_enabled
		chunk_index = maxi(
			0, floori(world.position.x / CourseStream.CHUNK_WIDTH))

	## How a player internalizes their build. Reel: the less sustainable the
	## meter (regeneration vs drain), the bigger the reserve kept before
	## spending; a faster reel is engaged later because it corrects quicker.
	## Burst: the further a pull travels, the closer the chosen anchors, so
	## expected travel stays a controllable hop instead of a leap.
	func _derive_adaptations() -> void:
		match reel_style:
			&"hold":
				reel_reserve = 0.02
			&"tap":
				reel_reserve = 0.20
			_:
				var sustain := config.reel_regeneration_rate / \
					maxf(0.001, config.reel_drain_rate)
				reel_reserve = clampf(0.6 * (1.0 - sustain), 0.10, 0.50)
		reel_band_scale = clampf(
			config.reel_retraction_rate /
				SwingConfig.BASE_REEL_RETRACTION_RATE,
			0.75,
			1.5,
		)
		burst_reach = clampf(
			460.0 * 0.40 / maxf(0.05, config.burst_distance_fraction),
			260.0,
			700.0,
		)

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
			var was_pulling := world.pull_active
			var was_reeling := world.web.reel_active
			var energy_before := world.web.reel_energy
			var events := world.step(FIXED_DELTA)
			if was_reeling:
				reel_ticks += 1
				reel_energy_spent += maxf(
					0.0, energy_before - world.web.reel_energy)
			if world.web.reel_energy <= 0.001:
				empty_ticks += 1
			for event: SimulationEvent in events:
				match event.kind:
					SimulationEvent.Kind.DEATH_REQUESTED:
						if rescue_available:
							rescue_available = false
							rescue_used = true
							rescue_distance_m = world.distance_pixels / \
								PIXELS_PER_METRE
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
			if finished:
				return _result(cause, was_pulling)
		return _result(cause, false)

	func _result(cause: StringName, died_during_pull: bool) -> Dictionary:
		var region := CourseRegionCatalog.region_for_distance(
			world.distance_pixels)
		return {
			"seed": int(rng.seed),
			"course_seed": course_seed,
			"distance_m": world.distance_pixels / PIXELS_PER_METRE,
			"seconds": world.tick * FIXED_DELTA,
			"cause": str(cause),
			"flies": world.run_flies,
			"attaches": attaches,
			"bursts": bursts,
			"save_bursts": save_bursts,
			"dives": dives,
			"reel_empties": reel_empties,
			"reel_time_s": reel_ticks * FIXED_DELTA,
			"reel_energy_spent": reel_energy_spent,
			"time_empty_s": empty_ticks * FIXED_DELTA,
			"rescue_used": rescue_used,
			"rescue_distance_m": rescue_distance_m,
			"death_during_pull": died_during_pull,
			"region": str(region["id"]),
			"pattern": str(stream.pattern_id_for_chunk(chunk_index)),
		}

	## The whole player model. It reads only what a player could see: its own
	## motion, the fly trail (the game's route language), solid geometry
	## through the same forgiving nearest-solid query a real tap gets, and
	## the pull-safety preview the HUD already draws.
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
			float(profile["reel_band_px"]) * reel_band_scale
		var energy_fraction := world.web.reel_energy / \
			maxf(0.001, config.reel_energy_capacity)
		if wants_reel:
			var stop_floor := 0.02 if reel_style == &"hold" else \
				(0.08 if reel_style == &"tap" else 0.06)
			if world.position.y <= target_y or \
					energy_fraction <= stop_floor or near_ceiling:
				_set_reel(false)
		elif too_low and energy_fraction > reel_reserve:
			_set_reel(true)

	func _decide_detached(target_y: float, band: float) -> void:
		var falling_fast := world.velocity.y > \
			float(profile["panic_fall_speed"])
		var below_route := world.position.y > target_y + band
		var floor_danger := world.position.y > 600.0
		if not (falling_fast or below_route or floor_danger):
			if world.burst_charges > 0 and \
					rng.randf() < float(profile["burst_chance"]):
				var burst_tap := _find_tap(Vector2(1.0, -0.35), burst_reach)
				if burst_tap != Vector2.INF and _pull_looks_safe(burst_tap):
					_schedule(InputCommand.burst_at(
						burst_tap, _next_sequence(), world.tick))
			return
		var tap := _find_attach_tap()
		if tap != Vector2.INF:
			_schedule(InputCommand.attach(tap, _next_sequence(), world.tick))
			return
		if save_bursts_enabled and (falling_fast or floor_danger) and \
				world.burst_charges > 0:
			var rescue_tap := _find_emergency_tap()
			if rescue_tap != Vector2.INF:
				save_bursts += 1
				_schedule(InputCommand.burst_at(
					rescue_tap, _next_sequence(), world.tick))

	## The same check the HUD preview draws: does the pull's endpoint stay
	## clear? Skill decides how habitually the bot consults it.
	func _pull_looks_safe(tap: Vector2) -> bool:
		if rng.randf() > float(profile["care"]):
			return true
		var nearest := world.nearest_solid_point(tap)
		if not bool(nearest["found"]):
			return false
		var preview := world.preview_pull(
			Vector2(nearest["anchor"]),
			config.burst_distance_fraction,
			config.burst_minimum_distance,
		)
		return bool(preview["safe"])

	## Fan of up-forward taps; the first whose snapped anchor is usable wins.
	func _find_attach_tap() -> Vector2:
		for angle_degrees: float in [-70.0, -52.0, -36.0, -20.0]:
			var direction := Vector2.RIGHT.rotated(deg_to_rad(angle_degrees))
			var tap := _find_tap(direction, 0.62 * config.web_maximum_length)
			if tap != Vector2.INF:
				return tap
		return Vector2.INF

	## Desperation search: steeper angles and shorter reach than the normal
	## fan, because the normal fan already came up empty.
	func _find_emergency_tap() -> Vector2:
		for reach: float in [300.0, 520.0]:
			for angle_degrees: float in [-80.0, -60.0, -40.0]:
				var direction := Vector2.RIGHT.rotated(
					deg_to_rad(angle_degrees))
				var tap := _find_tap(direction, reach)
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
		var family := _command_family(command)
		if family != &"other":
			for entry: Dictionary in pending:
				var existing: InputCommand = entry["command"]
				if _command_family(existing) == family:
					# The bot reasons again before delayed input lands. Keeping
					# one pending web/Burst intent prevents a successful attach
					# from being undone by a stale duplicate tap.
					return
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

	func _command_family(command: InputCommand) -> StringName:
		match command.kind:
			InputCommand.Kind.ATTACH, InputCommand.Kind.RELEASE:
				return &"web"
			InputCommand.Kind.BURST:
				return &"burst"
		return &"other"

	func _next_sequence() -> int:
		sequence += 1
		return sequence

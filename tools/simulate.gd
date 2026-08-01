extends SceneTree
## Headless batch-run simulation lab for balance and systems tuning (bot v3).
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
##   --track=             isolate ONE upgrade track: `<suffix>` or the full
##                        `<spider>_<suffix>` id (e.g. `reel_capacity`). Only
##                        that track is levelled; every other stays at 0, so a
##                        null result names the track rather than the bundle.
##                        Combines with --upgrades, which then means "the level
##                        for this one track".
##   --seed=1             base seed for the bot-imperfection RNG
##   --course-seed=1337   first production course seed
##   --course-seeds=1     number of consecutive course seeds to rotate through
##   --max-seconds=240    per-run simulated-time cap (reported as `timeout`,
##                        which means "still alive", not a death)
##   --start-m=0          warp the run start this many metres into the course
##                        at the pace curve's speed for that distance — for
##                        testing late-game regimes without surviving to them.
##                        Every per-kilometre rate is normalized on distance
##                        *travelled* (`distance_m - start_m`), never on the
##                        absolute course position, so a warped band's rates
##                        stay comparable with an unwarped one's.
##   --difficulty=standard  relaxed | standard | harsh — the difficulty mode's
##                        content and recovery overrides. Never physics.
##   --ablate=            comma-separated verbs the bot may NOT use:
##                        reel | burst | dive. Bot restriction only — the
##                        simulation is untouched — so a segment can be asked
##                        "is this passable WITHOUT reeling?" instead of just
##                        "is this hard?".
##   --reel-style=adaptive  adaptive | tap | hold — how the bot spends Reel
##   --save-bursts=on     on | off — emergency Burst when no web can save it
##   --moving-anchor-proof  run the deterministic moving-pivot energy probe and
##                          exit without running the player-model batch
##   --sweep=SPEC         parameter grid, e.g.
##                        `reel_rate:260:440:4` or
##                        `reel_rate:260:440:4,pull_cooldown:1.2:2.4:3`
##                        (max 60 combined points; needs one skill + spider).
##                        Names: TuningCatalog ids first, else raw SwingConfig
##                        property names (e.g. reel_regeneration_rate).
##   --bot=k:v,k:v        override the selected tier's POLICY knobs (see
##                        FITTABLE_PROFILE_KEYS). Perception stays guarded:
##                        aim error is refused by name, and the rate knobs
##                        are floored at 2 ticks.
##   --trace-top=N        write the batch's N furthest runs as replayable
##                        input traces (requires --trace-dir)
##   --trace-dir=path     directory the traces are written into
##   --replay=path        replay one trace and exit 0 only if it lands on
##                        its own recorded outcome — the determinism check
##                        behind docs/technical/replay-review-loop.md
##   --json=path          write per-run rows and summaries as JSON
##
## Bot v3 adapts to the configuration it is handed, the way a player learns
## their build: its Reel reserve follows the meter's sustainability
## (drain vs regeneration), its Reel engagement follows the retraction rate,
## and its Burst aim shortens as the pull fraction grows — plus a
## skill-scaled habit of checking the game's own pull-safety preview before
## committing. The course is deterministic; all run-to-run variation comes
## from the seeded imperfection model, so a tuning change shifts the
## metrics. `--course-seeds` deliberately sweeps curated course order
## separately from modeled player imperfection.
##
## v3 closes three structural gaps found by comparing v2 against owner device
## recordings (docs/measurements/2026-08-01-owner-play-calibration.md):
## Dive is a verb it can actually use, its Reel policy is written in absolute
## seconds instead of fractions of the meter, and it reads the anchor class
## zones 4–8 are built out of. It still fails that document's acceptance
## targets by roughly an order of magnitude, so **its output remains
## unpublishable as a claim about difficulty, upgrades or the economy.**
##
## Read `taps_per_second` in the summary against the owner's measured input
## envelope — 6.60/s averaged over a run, 18/s sustained at peak — before
## trusting any run. An input rate far outside that means the model is not
## playing the same game, whatever its distance says.

const BOT_MODEL_VERSION := 3
const FIXED_DELTA := 1.0 / 60.0
const PIXELS_PER_METRE := 10.0
const DISTANCE_BANDS_M := [500.0, 1000.0, 2000.0, 3500.0]
const SWEEP_MAX_POINTS := 60

## Set once from --difficulty before configs resolve; `_resolve_config` is
## static-ish in spirit and reads it rather than threading another parameter.
static var _difficulty_mode: StringName = DifficultyCatalog.MODE_STANDARD

## Set from --track; empty means "every track", the historic behaviour.
static var _isolated_track: String = ""

## Per-run input traces, collected only when --trace-top asks for them. Kept
## on the script rather than threaded through _run_batch's return, because the
## rows are summarized by several callers and none of them want this.
var _traced: Array[Dictionary] = []

## Imperfection model per skill tier. Ticks are 60 Hz simulation ticks.
## `care` is the probability of checking the pull-safety preview (the same
## endpoint/safe information the HUD shows) before committing to a Burst.
## `dive_chance` is the per-decision willingness to spend the one Dive each
## web attach re-arms; `class_read` is how reliably the anchor class the HUD
## cues ("Weak anchor ahead", "Weak span holding") is actually acted on.
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
		"dive_chance": 0.10,
		"care": 0.40,
		"class_read": 0.20,
		"attach_fan_top_deg": -70.0,
		"attach_fan_bottom_deg": -20.0,
		"attach_reach_frac": 0.62,
		"dive_fan_top_deg": 20.0,
		"dive_fan_bottom_deg": 56.0,
		"dive_reach_frac": 0.55,
		"dive_floor_y": 520.0,
		"reel_reserve_scale": 1.0,
		"reel_floor_scale": 1.0,
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
		"dive_chance": 0.35,
		"care": 0.75,
		"class_read": 0.65,
		"attach_fan_top_deg": -70.0,
		"attach_fan_bottom_deg": -20.0,
		"attach_reach_frac": 0.62,
		"dive_fan_top_deg": 20.0,
		"dive_fan_bottom_deg": 56.0,
		"dive_reach_frac": 0.55,
		"dive_floor_y": 520.0,
		"reel_reserve_scale": 1.0,
		"reel_floor_scale": 1.0,
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
		"dive_chance": 0.65,
		"care": 0.95,
		"class_read": 0.95,
		"attach_fan_top_deg": -70.0,
		"attach_fan_bottom_deg": -20.0,
		"attach_reach_frac": 0.62,
		"dive_fan_top_deg": 20.0,
		"dive_fan_bottom_deg": 56.0,
		"dive_reach_frac": 0.55,
		"dive_floor_y": 520.0,
		"reel_reserve_scale": 1.0,
		"reel_floor_scale": 1.0,
	},
}

## Knobs `--bot` may move, the ones it may not, and the human ceiling.
##
## An earlier version of this split froze decision cadence and reaction delay
## alongside aim error, on the theory that all three are perception limits a
## search would otherwise drive to zero. The freeze was set from the owner's
## *average* input rate, and that was the error: **average rate is not
## capability.** Re-measured at the recordings' native 60 fps (the first pass
## sampled at 30 and undercounted by 40%), he averages 6.60 taps/s across a
## run but sustains **18 taps/s for a full second** and 14/s across two, with
## 27.5% of gaps at or under 50 ms and some at zero — both thumbs in the same
## frame. The expert tier was frozen at 4 ticks per decision, 15/s, which is
## *below* what he demonstrably produces. A model capped under the player
## cannot perform the recoveries that make his long runs possible.
##
## So the rate knobs are searchable, bounded by what a human has been observed
## to do rather than by what one averages. Aim error stays frozen: it is
## precision, not speed, and nothing in the tap stream speaks to it.
const FITTABLE_PROFILE_KEYS := [
	"band_px", "reel_band_px", "panic_fall_speed", "release_rise_speed",
	"burst_chance", "dive_chance", "care", "class_read",
	"attach_fan_top_deg", "attach_fan_bottom_deg", "attach_reach_frac",
	"dive_fan_top_deg", "dive_fan_bottom_deg", "dive_reach_frac",
	"dive_floor_y", "reel_reserve_scale", "reel_floor_scale",
	"decision_period_ticks", "reaction_delay_ticks",
]

## Precision, not speed. Nothing measured licenses moving it.
const FROZEN_PROFILE_KEYS := ["aim_error_px"]

## Floors on the rate knobs, in 60 Hz ticks. 2 ticks is 33 ms — a decision
## cadence of 30/s against the 18/s the owner has been recorded sustaining,
## so the search has headroom over him but not an unbounded amount. Anything
## faster is not a player, and a ceiling reached there proves nothing about
## whether the run is possible.
const PROFILE_FLOORS := {
	"decision_period_ticks": 2.0,
	"reaction_delay_ticks": 2.0,
}

## The owner's measured input envelope, for reporting. Peak sustained rates
## come from run 726dcc65 decoded at 60 fps.
const OWNER_TAPS_PER_SECOND_MEAN := 6.60
const OWNER_TAPS_PER_SECOND_PEAK_1S := 18.0

## Set from --bot; applied over the selected tier's profile.
static var _bot_overrides: Dictionary = {}

## How each anchor class is worth choosing, before skill scales the reading.
## Positive prefers, negative avoids. Silk highway carries the anchor forward
## for free; sticky silk bleeds velocity for as long as the web holds; rotten
## and collapsing spans expire on a timer and are then spent for good.
const ANCHOR_CLASS_SCORE := {
	CourseGeometry.ANCHOR_HIGHWAY: 90.0,
	CourseGeometry.ANCHOR_FIXED: 0.0,
	CourseGeometry.ANCHOR_MOVING_PIVOT: -20.0,
	CourseGeometry.ANCHOR_STICKY: -70.0,
	CourseGeometry.ANCHOR_ROTTEN: -120.0,
	CourseGeometry.ANCHOR_COLLAPSING: -150.0,
}

## A web within this many degrees of straight-down counts as "hanging", not
## swinging. Chosen so an ordinary swing's bottom-of-arc passage does not read
## as hanging: a real swing crosses this band briefly every pass, while a
## hauling style sits inside it.
const VERTICAL_HANG_DEGREES := 20.0

## Anchor classes that expire while you hang on them.
const TIMED_ANCHOR_CLASSES := [
	CourseGeometry.ANCHOR_ROTTEN,
	CourseGeometry.ANCHOR_COLLAPSING,
]


func _initialize() -> void:
	var options := _parse_options(OS.get_cmdline_user_args())
	if bool(options["moving_anchor_proof"]):
		var proof := _run_moving_anchor_proof()
		print("[simulate] moving-anchor proof\n%s" % JSON.stringify(proof, "  "))
		quit(0 if bool(proof["passed"]) else 1)
		return
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

	print("[simulate] bot model v%d · preset=%s upgrades=%d runs=%d seed=%d course=%d..%d cap=%ds start=%dm reel-style=%s save-bursts=%s" % [
		BOT_MODEL_VERSION, options["preset"], options["upgrades"],
		options["runs"], options["seed"], options["course_seed"],
		int(options["course_seed"]) + int(options["course_seeds"]) - 1,
		options["max_seconds"], options["start_m"],
		options["reel_style"], "on" if bool(options["save_bursts"]) else "off",
	])
	_difficulty_mode = StringName(options["difficulty"])
	if not str(options["replay"]).is_empty():
		quit(0 if _verify_trace(str(options["replay"])) else 1)
		return
	if not _parse_bot_overrides(str(options["bot"])):
		quit(2)
		return
	_isolated_track = str(options["track"]).strip_edges()
	if not _isolated_track.is_empty():
		print("[simulate] isolated upgrade track: %s @ level %d" % [
			_isolated_track, int(options["upgrades"])])
	if _difficulty_mode != DifficultyCatalog.MODE_STANDARD:
		print("[simulate] difficulty mode: %s" % _difficulty_mode)
	var ablated_verbs := _parse_ablation(str(options["ablate"]))
	if not ablated_verbs.is_empty():
		print("[simulate] ABLATED verbs (bot may not use): %s" %
			", ".join(Array(ablated_verbs).map(func(v): return str(v))))

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
	var trace_dir := str(options["trace_dir"])
	if int(options["trace_top"]) > 0:
		if trace_dir.is_empty():
			printerr("[simulate] --trace-top needs --trace-dir")
		else:
			_write_traces(
				trace_dir, int(options["trace_top"]), options, _traced)
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
		var isolated := _isolated_track
		var matched := isolated.is_empty()
		for upgrade: Dictionary in SpiderCatalog.upgrades_for(spider):
			var upgrade_id := StringName(upgrade["id"])
			if not isolated.is_empty():
				# Accept the bare suffix as well as the full `<spider>_<suffix>`
				# id, so a sweep script does not have to know the spider.
				var full := str(upgrade_id)
				if full != isolated and \
						not full.ends_with("_%s" % isolated):
					continue
				matched = true
			progress.upgrade_levels[upgrade_id] = mini(
				upgrade_level,
				SpiderCatalog.MAX_UPGRADE_LEVEL,
			)
		if not matched:
			printerr("[simulate] --track '%s' matches no track on %s" % [
				isolated, spider])
			return null
	var config := SpiderCatalog.resolved_config(preset, progress)
	DifficultyCatalog.apply_to_config(config, _difficulty_mode)
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
			_profile_for(skill),
			int(options["seed"]) + run_index,
			StringName(options["reel_style"]),
			bool(options["save_bursts"]),
			float(int(options["start_m"])) * PIXELS_PER_METRE,
			course_seed,
			_parse_ablation(str(options["ablate"])),
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
		if int(options["trace_top"]) > 0:
			_traced.append({"row": row, "trace": driver.trace})
	return rows


func _summarize(
	rows: Array[Dictionary],
	spider: StringName,
	skill: StringName,
	point: Dictionary,
) -> Dictionary:
	var distances: Array[float] = []
	var travelled: Array[float] = []
	var causes: Dictionary = {}
	var bands: Dictionary = {}
	var regions: Dictionary = {}
	var patterns: Dictionary = {}
	var totals := {
		"flies": 0.0, "reel_empties": 0.0, "bursts": 0.0, "dives": 0.0,
		"attaches": 0.0, "seconds": 0.0, "reel_time_s": 0.0,
		"reel_energy_spent": 0.0, "time_empty_s": 0.0, "save_bursts": 0.0,
		"travelled_m": 0.0, "deaths": 0.0, "taps": 0.0,
		"timed_anchor_attaches": 0.0, "sticky_attaches": 0.0,
		"highway_attaches": 0.0, "anchor_failures": 0.0,
		"attach_searches": 0.0, "class_choices": 0.0,
		"mean_web_angle_deg": 0.0, "vertical_share": 0.0,
		"mean_swing_arc_deg": 0.0, "mean_web_length_px": 0.0,
		"mean_height_px": 0.0, "height_span_px": 0.0,
		"mean_overspeed_ms": 0.0, "above_target_share": 0.0,
	}
	var rescues := 0
	var pull_deaths := 0
	var timeouts := 0
	var rescue_distance_total := 0.0
	for row: Dictionary in rows:
		var distance := float(row["distance_m"])
		distances.append(distance)
		travelled.append(float(row["travelled_m"]))
		var cause := str(row["cause"])
		causes[cause] = int(causes.get(cause, 0)) + 1
		if cause == "timeout":
			timeouts += 1
		else:
			# Bands describe how far the run got *from where it started*, so a
			# warped band reads the same way an unwarped one does.
			var band := _band_label(float(row["travelled_m"]))
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
	travelled.sort()
	var count := maxi(1, rows.size())
	# Rates normalize on ground actually covered. Warping to 15 000 m and dying
	# 300 m later is 300 m of exposure, not 15 300 m of it.
	var total_km := float(totals["travelled_m"]) / 1000.0
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
		"travelled_mean_m": _mean(travelled),
		"travelled_median_m": _percentile(travelled, 0.5),
		"travelled_p10_m": _percentile(travelled, 0.10),
		"travelled_p90_m": _percentile(travelled, 0.90),
		# The furthest any single run actually covered. Distance is the search
		# signal; THIS is the number that answers "is the run possible at all",
		# and it is an observation rather than anything optimised toward.
		"travelled_max_m": 0.0 if travelled.is_empty() else travelled[-1],
		"travelled_total_km": total_km,
		"deaths": int(totals["deaths"]),
		# Deaths per RUN, not per km. Modes differ in how many lives a run
		# holds (Harsh disables the rescue life), and deaths/km silently
		# rewards the mode with fewer lives — Harsh reads 1.64 against
		# Standard's 2.04 while killing the player twice as fast. Compare
		# modes on distance survived, and read this to see why a rate moved.
		"deaths_per_run": float(totals["deaths"]) / count,
		"deaths_per_km": 0.0 if total_km <= 0.0
			else float(totals["deaths"]) / total_km,
		# Poisson standard error on the rate: deaths are counted events, so the
		# count's error is sqrt(count) and the rate's is rate/sqrt(count). A
		# later slice comparing against this baseline needs to know which
		# band-to-band wobble is signal and which is sample size.
		"deaths_per_km_se": 0.0 if total_km <= 0.0 or totals["deaths"] <= 0.0
			else (float(totals["deaths"]) / total_km) /
				sqrt(float(totals["deaths"])),
		"timeout_runs": timeouts,
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
		# Input rate, so the model can be held against the owner's recovered
		# tap stream rather than only against distance. Seconds are summed
		# across runs so a batch of short runs cannot inflate it.
		"taps_per_second": 0.0 if totals["seconds"] <= 0.0
			else float(totals["taps"]) / float(totals["seconds"]),
		"dives_per_attach": 0.0 if totals["attaches"] <= 0.0
			else float(totals["dives"]) / float(totals["attaches"]),
		"mean_timed_anchor_attaches":
			float(totals["timed_anchor_attaches"]) / count,
		"mean_sticky_attaches": float(totals["sticky_attaches"]) / count,
		"mean_highway_attaches": float(totals["highway_attaches"]) / count,
		"mean_anchor_failures": float(totals["anchor_failures"]) / count,
		# Swing shape. `vertical_share` is the fraction of attached time spent
		# within VERTICAL_HANG_DEGREES of straight down — a hauling style sits
		# high here, a swinging style does not.
		"mean_web_angle_deg": float(totals["mean_web_angle_deg"]) / count,
		"vertical_share": float(totals["vertical_share"]) / count,
		"mean_swing_arc_deg": float(totals["mean_swing_arc_deg"]) / count,
		"mean_web_length_px": float(totals["mean_web_length_px"]) / count,
		"mean_height_px": float(totals["mean_height_px"]) / count,
		"mean_overspeed_ms": float(totals["mean_overspeed_ms"]) / count,
		"above_target_share": float(totals["above_target_share"]) / count,
		"height_span_px": float(totals["height_span_px"]) / count,
		# Share of web searches that offered more than one anchor class, i.e.
		# the share in which the class preference could change anything at all.
		"class_choice_rate": 0.0 if totals["attach_searches"] <= 0.0
			else float(totals["class_choices"]) / float(totals["attach_searches"]),
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
	print("  travelled m mean %7.1f · median %7.1f · p10 %7.1f · p90 %7.1f · %.2f km total" % [
		summary["travelled_mean_m"], summary["travelled_median_m"],
		summary["travelled_p10_m"], summary["travelled_p90_m"],
		summary["travelled_total_km"]])
	print("  difficulty  %.2f ±%.2f deaths/km · %.2f deaths/run (%d over %.2f km) · %d timeout run(s)" % [
		summary["deaths_per_km"], summary["deaths_per_km_se"],
		summary["deaths_per_run"], summary["deaths"],
		summary["travelled_total_km"], summary["timeout_runs"]])
	print("  per run     %.1fs · %.1f flies (%.1f/km) · %.1f webs · %.1f bursts (%.1f saves) · %.1f dives" % [
		summary["mean_seconds"], summary["mean_flies"],
		summary["flies_per_km"], summary["mean_attaches"],
		summary["mean_bursts"], summary["mean_save_bursts"],
		summary["mean_dives"]])
	print("  input       %.2f taps/s · %.2f dives per web (owner: %.2f mean, %.0f peak)" % [
		summary["taps_per_second"], summary["dives_per_attach"],
		OWNER_TAPS_PER_SECOND_MEAN, OWNER_TAPS_PER_SECOND_PEAK_1S])
	print("  anchors     %.1f highway · %.1f sticky · %.1f timed (%.1f failed under load)" % [
		summary["mean_highway_attaches"], summary["mean_sticky_attaches"],
		summary["mean_timed_anchor_attaches"],
		summary["mean_anchor_failures"]])
	print("  anchor pick %.1f%% of web searches offered a class choice" % [
		summary["class_choice_rate"] * 100.0])
	print("  own speed   %+.1f m/s vs the drive's floor · above it %.0f%% of the run" % [
		summary["mean_overspeed_ms"], summary["above_target_share"] * 100.0])
	print("  height      mean y %.0f px · vertical span %.0f px (lower y = higher up)" % [
		summary["mean_height_px"], summary["height_span_px"]])
	print("  swing shape %.1f° mean web angle · %.0f px web · %.1f° arc per web · %.0f%% of hang time near-vertical" % [
		summary["mean_web_angle_deg"], summary["mean_web_length_px"],
		summary["mean_swing_arc_deg"], summary["vertical_share"] * 100.0])
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


## `reel`, `burst`, `dive`, comma-separated — verbs the bot may not use.
## Unknown names are reported and ignored rather than silently dropped, so a
## typo cannot quietly turn an ablation proof into an ordinary run.
## `--bot=key:value,key:value` — override the selected tier's POLICY knobs.
##
## Refuses the perception limits by name rather than silently accepting them.
## A fit that is allowed to sharpen reflexes will always spend its budget
## there first, and the resulting model passes the acceptance table while
## being less like a player than the one it replaced.
func _parse_bot_overrides(spec: String) -> bool:
	_bot_overrides = {}
	var trimmed := spec.strip_edges()
	if trimmed.is_empty():
		return true
	for entry: String in trimmed.split(",", false):
		var pair := entry.split(":", false)
		if pair.size() != 2:
			printerr("[simulate] --bot entry '%s' is not key:value" % entry)
			return false
		var key := pair[0].strip_edges()
		if key in FROZEN_PROFILE_KEYS:
			printerr(
				("[simulate] --bot may not move '%s'. Aim error is precision "
					+ "rather than speed, and nothing measured licenses "
					+ "moving it; a search allowed to sharpen aim buys "
					+ "distance by removing the human, not by playing "
					+ "better.") % key)
			return false
		if not (key in FITTABLE_PROFILE_KEYS):
			printerr("[simulate] --bot knows no knob '%s' (fittable: %s)" % [
				key, ", ".join(FITTABLE_PROFILE_KEYS)])
			return false
		var numeric := float(pair[1])
		if PROFILE_FLOORS.has(key) and numeric < float(PROFILE_FLOORS[key]):
			printerr(
				("[simulate] --bot '%s'=%s is below the human floor of %s "
					+ "ticks. The owner sustains %.0f taps/s at peak; faster "
					+ "than the floor is not a player, and a ceiling reached "
					+ "there says nothing about whether the run is possible.")
					% [key, numeric, PROFILE_FLOORS[key],
						OWNER_TAPS_PER_SECOND_PEAK_1S])
			return false
		_bot_overrides[key] = numeric
	print("[simulate] bot overrides: %s" % JSON.stringify(_bot_overrides))
	return true


func _profile_for(skill: StringName) -> Dictionary:
	var profile: Dictionary = (SKILL_PROFILES[skill] as Dictionary).duplicate()
	for key: String in _bot_overrides:
		var value: float = _bot_overrides[key]
		# Cadence and delay index whole ticks; everything else is continuous.
		profile[key] = (
			maxi(1, int(round(value)))
			if key in ["decision_period_ticks", "reaction_delay_ticks"]
			else value
		)
	return profile


func _parse_ablation(spec: String) -> Array[StringName]:
	var result: Array[StringName] = []
	if spec.strip_edges().is_empty():
		return result
	for raw: String in spec.split(","):
		var name := raw.strip_edges().to_lower()
		if name.is_empty():
			continue
		if name in ["reel", "burst", "dive"]:
			if not StringName(name) in result:
				result.append(StringName(name))
		else:
			printerr("[simulate] unknown --ablate verb '%s'" % name)
	return result


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
		"ablate": "",
		"difficulty": "standard",
		"track": "",
		"reel_style": "adaptive",
		"save_bursts": true,
		"moving_anchor_proof": false,
		"sweep": "",
		"bot": "",
		"trace_top": 0,
		"trace_dir": "",
		"replay": "",
		"json": "",
	}
	for argument: String in arguments:
		if argument == "--moving-anchor-proof":
			options["moving_anchor_proof"] = true
			continue
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
			"ablate":
				options["ablate"] = value
			"track":
				options["track"] = value
			"bot":
				options["bot"] = value
			"trace-top":
				options["trace_top"] = maxi(0, int(value))
			"trace-dir":
				options["trace_dir"] = value
			"replay":
				options["replay"] = value
			"difficulty":
				if DifficultyCatalog.has_mode(StringName(value)):
					options["difficulty"] = value
				else:
					printerr("[simulate] unknown --difficulty '%s'" % value)
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


## Diagnostic proof for ADR 0004. The first case is strict translation
## covariance: a support moving at constant velocity must produce exactly the
## static solution in support-relative coordinates. The second case runs the
## intended slow bounded pivot for twenty complete cycles under baseline
## gravity and requires its relative-speed envelope not to grow over time.
func _run_moving_anchor_proof() -> Dictionary:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	config.automatic_take_up_enabled = false
	var translation := _translation_covariance_probe(config)
	var periodic := _periodic_pivot_probe(config)
	var passed := (
		float(translation["maximum_position_error_px"]) <= 0.001
		and float(translation["maximum_velocity_error_px_s"]) <= 0.001
		and float(periodic["late_to_early_peak_ratio"]) <= 1.05
		and float(periodic["moving_to_static_peak_ratio"]) <= 1.35
		and float(periodic["maximum_rope_overrun_px"])
			<= config.rope_elasticity_allowance
				+ config.attachment_correction_cap * FIXED_DELTA
				+ 0.01
	)
	return {
		"passed": passed,
		"baseline": str(config.preset_name),
		"fixed_hz": 60,
		"translation_covariance": translation,
		"periodic_pivot": periodic,
	}


func _translation_covariance_probe(config: SwingConfig) -> Dictionary:
	var static_web := WebConstraint.new()
	var moving_web := WebConstraint.new()
	static_web.reset(config)
	moving_web.reset(config)
	var static_anchor := Vector2.ZERO
	var support_velocity := Vector2(86.0, -24.0)
	var static_position := Vector2(0.0, 360.0)
	var moving_position := static_position
	var static_velocity := Vector2(285.0, 0.0)
	var moving_velocity := static_velocity + support_velocity
	static_web.try_attach(static_position, static_anchor, config)
	moving_web.try_attach(moving_position, static_anchor, config)
	var maximum_position_error := 0.0
	var maximum_velocity_error := 0.0
	for probe_tick in range(720):
		static_velocity += Vector2.DOWN * config.gravity * FIXED_DELTA
		moving_velocity += Vector2.DOWN * config.gravity * FIXED_DELTA
		var static_result := static_web.solve(
			static_position,
			static_velocity,
			FIXED_DELTA,
			config,
		)
		static_position = static_result["position"]
		static_velocity = static_result["velocity"]
		var next_anchor := support_velocity * FIXED_DELTA * float(probe_tick + 1)
		var moving_result := moving_web.solve_moving_anchor(
			moving_position,
			moving_velocity,
			FIXED_DELTA,
			config,
			next_anchor,
			support_velocity,
		)
		moving_position = moving_result["position"]
		moving_velocity = moving_result["velocity"]
		maximum_position_error = maxf(
			maximum_position_error,
			(static_position - (moving_position - next_anchor)).length(),
		)
		maximum_velocity_error = maxf(
			maximum_velocity_error,
			(static_velocity - (moving_velocity - support_velocity)).length(),
		)
	return {
		"ticks": 720,
		"support_speed_px_s": support_velocity.length(),
		"maximum_position_error_px": maximum_position_error,
		"maximum_velocity_error_px_s": maximum_velocity_error,
	}


func _periodic_pivot_probe(config: SwingConfig) -> Dictionary:
	const PERIOD_TICKS := 300
	const CYCLES := 20
	var moving_web := WebConstraint.new()
	var static_web := WebConstraint.new()
	moving_web.reset(config)
	static_web.reset(config)
	var origin := Vector2(0.0, -38.0)
	var first_sample := CourseMotion.pendulum_anchor(
		origin, 38.0, deg_to_rad(42.0), PERIOD_TICKS,
		157, 1337, 0, FIXED_DELTA, 4)
	var moving_position := Vector2(first_sample["position"]) + \
		Vector2(0.0, 360.0)
	var static_position := Vector2(0.0, 360.0)
	var moving_velocity := Vector2(285.0, 0.0)
	var static_velocity := moving_velocity
	moving_web.try_attach(
		moving_position,
		Vector2(first_sample["position"]),
		config,
	)
	static_web.try_attach(static_position, Vector2.ZERO, config)
	var moving_cycle_peaks: Array[float] = []
	var static_peak := 0.0
	var moving_peak := 0.0
	var maximum_overrun := 0.0
	for cycle in range(CYCLES):
		var cycle_peak := 0.0
		for local_tick in range(PERIOD_TICKS):
			var probe_tick := cycle * PERIOD_TICKS + local_tick
			var sample := CourseMotion.pendulum_anchor(
				origin, 38.0, deg_to_rad(42.0), PERIOD_TICKS,
				157, 1337, probe_tick, FIXED_DELTA, 4)
			moving_velocity += Vector2.DOWN * config.gravity * FIXED_DELTA
			static_velocity += Vector2.DOWN * config.gravity * FIXED_DELTA
			var moving_result := moving_web.solve_moving_anchor(
				moving_position,
				moving_velocity,
				FIXED_DELTA,
				config,
				Vector2(sample["next_position"]),
				Vector2(sample["velocity"]),
			)
			moving_position = moving_result["position"]
			moving_velocity = moving_result["velocity"]
			var static_result := static_web.solve(
				static_position,
				static_velocity,
				FIXED_DELTA,
				config,
			)
			static_position = static_result["position"]
			static_velocity = static_result["velocity"]
			var relative_speed := (
				moving_velocity - Vector2(sample["velocity"])
			).length()
			cycle_peak = maxf(cycle_peak, relative_speed)
			moving_peak = maxf(moving_peak, relative_speed)
			static_peak = maxf(static_peak, static_velocity.length())
			maximum_overrun = maxf(
				maximum_overrun,
				moving_position.distance_to(Vector2(sample["next_position"]))
					- moving_web.rope_length,
			)
		moving_cycle_peaks.append(cycle_peak)
	var early_peak := 0.0
	var late_peak := 0.0
	for index in range(5):
		early_peak = maxf(early_peak, moving_cycle_peaks[index])
		late_peak = maxf(
			late_peak,
			moving_cycle_peaks[moving_cycle_peaks.size() - 1 - index],
		)
	return {
		"cycles": CYCLES,
		"period_ticks": PERIOD_TICKS,
		"pivot_radius_px": 38.0,
		"pivot_amplitude_degrees": 42.0,
		"maximum_relative_speed_px_s": moving_peak,
		"static_maximum_speed_px_s": static_peak,
		"moving_to_static_peak_ratio": moving_peak / maxf(static_peak, 0.001),
		"late_to_early_peak_ratio": late_peak / maxf(early_peak, 0.001),
		"maximum_rope_overrun_px": maximum_overrun,
		"cycle_peaks_px_s": moving_cycle_peaks,
	}


## Write the N furthest-travelling runs of a batch as replayable traces.
##
## The record shape is the game's own (`InputCommand.to_record()` plus the
## `playback_tick` SwingLabSession stamps), so a bot trace and a recording of a
## human are the same kind of object and the same replay path consumes both.
## The header carries everything needed to rebuild the world, and `expected`
## carries what the run did — a trace that cannot be checked against its own
## outcome is a story, not evidence.
func _write_traces(
	directory: String,
	keep: int,
	options: Dictionary,
	traced: Array[Dictionary],
) -> void:
	if keep <= 0 or traced.is_empty():
		return
	var sorted_runs := traced.duplicate()
	sorted_runs.sort_custom(func(a, b):
		return float(a["row"]["travelled_m"]) > float(b["row"]["travelled_m"]))
	if not DirAccess.dir_exists_absolute(directory):
		var error := DirAccess.make_dir_recursive_absolute(directory)
		if error != OK:
			printerr("[simulate] cannot create trace directory %s" % directory)
			return
	var written := 0
	for index in range(mini(keep, sorted_runs.size())):
		var entry: Dictionary = sorted_runs[index]
		var row: Dictionary = entry["row"]
		var payload := {
			"format": TraceCatalog.INPUT_TRACE_FORMAT,
			"bot_model": BOT_MODEL_VERSION,
			# Everything needed to rebuild the identical world.
			"setup": {
				"preset": options["preset"],
				# The ROW's values, never the options': a batch run with
				# --skill=all or --spider=all would stamp the literal "all"
				# into setup, and such a trace can neither be verified nor
				# replayed.
				"spider": row["spider"],
				"skill": row["skill"],
				"upgrades": options["upgrades"],
				"track": options["track"],
				"difficulty": options["difficulty"],
				"reel_style": options["reel_style"],
				"save_bursts": options["save_bursts"],
				"start_m": options["start_m"],
				# The cap the run was captured under. A run that ended at the
				# cap (cause "timeout") only reproduces if the replay stops at
				# the same wall — replayed open-ended it keeps going, inputless,
				# past its own recording and lands somewhere else.
				"max_seconds": options["max_seconds"],
				"course_seed": row["course_seed"],
				"bot_seed": row["seed"],
				"bot": options["bot"],
			},
			# What the run actually did. `--replay` re-runs the commands and
			# fails unless it lands here again.
			"expected": {
				"distance_m": row["distance_m"],
				"travelled_m": row["travelled_m"],
				"seconds": row["seconds"],
				"cause": row["cause"],
				"deaths": row["deaths"],
				"flies": row["flies"],
			},
			"commands": entry["trace"],
		}
		var path := "%s/run-%02d-%dm.json" % [
			directory.rstrip("/"), index + 1, int(row["travelled_m"])]
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file == null:
			printerr("[simulate] cannot write %s" % path)
			continue
		file.store_string(JSON.stringify(payload, "\t"))
		file.close()
		written += 1
		print("[simulate] trace %s — %.1f m, %d command(s)" % [
			path, float(row["travelled_m"]), entry["trace"].size()])
	if written > 0:
		print("[simulate] verify any of them with --replay=<path>")


## Replay a trace and check it lands where it says it does.
##
## This is the load-bearing check for the whole review loop. A trace that is
## watched but never verified could be showing a different run from the one the
## search reported, and nobody would know. Determinism is claimed all over this
## repository; here it is tested.
func _verify_trace(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("[simulate] cannot read trace %s" % path)
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		printerr("[simulate] %s is not a trace document" % path)
		return false
	var trace: Dictionary = parsed
	if str(trace.get("format", "")) != TraceCatalog.INPUT_TRACE_FORMAT:
		printerr("[simulate] %s has format '%s', expected '%s'" % [
			path, trace.get("format", ""), TraceCatalog.INPUT_TRACE_FORMAT])
		return false
	var setup: Dictionary = trace.get("setup", {})
	var expected: Dictionary = trace.get("expected", {})

	_difficulty_mode = StringName(setup.get("difficulty", "standard"))
	_isolated_track = str(setup.get("track", ""))
	if not _parse_bot_overrides(str(setup.get("bot", ""))):
		return false
	var config := _resolve_config(
		StringName(setup.get("preset", str(SwingConfig.PRESET_BALANCED))),
		StringName(setup.get("spider", "classic")),
		int(setup.get("upgrades", 0)),
		{})
	if config == null:
		return false

	var driver := RunDriver.new()
	driver.setup(
		config,
		_profile_for(StringName(setup.get("skill", "intermediate"))),
		int(setup.get("bot_seed", 1)),
		StringName(setup.get("reel_style", "adaptive")),
		bool(setup.get("save_bursts", true)),
		float(int(setup.get("start_m", 0))) * PIXELS_PER_METRE,
		int(setup.get("course_seed", 1337)),
		[],
	)
	driver.replay_records = trace.get("commands", [])
	# Replay under the SAME cap the run was captured under. A death-ended run
	# is indifferent to it; a timeout-ended run only lands on its recorded
	# outcome if the replay stops at the same wall. Traces from before the
	# field existed fall back to a generous 600 s, which those death-ended
	# traces never reach.
	var cap_seconds := float(setup.get("max_seconds", 600))
	var row := driver.run(int(cap_seconds / FIXED_DELTA))

	var checks := [
		["travelled_m", 0.05], ["distance_m", 0.05], ["seconds", 0.02],
	]
	var ok := true
	print("[simulate] replaying %s — %d command(s)" % [
		path, driver.replay_records.size()])
	for check: Array in checks:
		var key: String = check[0]
		var tolerance: float = check[1]
		var want := float(expected.get(key, 0.0))
		var got := float(row[key])
		var matched := absf(want - got) <= tolerance
		ok = ok and matched
		print("  %-12s expected %10.3f  got %10.3f  %s" % [
			key, want, got, "ok" if matched else "MISMATCH"])
	var want_cause := str(expected.get("cause", ""))
	var got_cause := str(row["cause"])
	if want_cause != got_cause:
		ok = false
		print("  %-12s expected %10s  got %10s  MISMATCH" % [
			"cause", want_cause, got_cause])
	print("[simulate] trace %s" % ("REPRODUCES" if ok else "DIVERGES"))
	return ok


func _write_json(
	path: String,
	options: Dictionary,
	rows: Array[Dictionary],
	summaries: Array[Dictionary],
) -> void:
	var payload := {
		"format": "spider-swing-simulation-lab",
		# v3 adds travelled-distance normalization and the deaths-per-km rate.
		"version": 3,
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
	var taps := 0
	var reel_empties := 0
	var reel_ticks := 0
	var empty_ticks := 0
	var reel_energy_spent := 0.0
	## Seconds of continuous reel kept in hand before spending, and the
	## seconds-remaining at which reeling stops. Both are absolute times, not
	## fractions of the meter — see `_derive_adaptations`.
	var reel_reserve_s := 0.5
	var reel_stop_floor_s := 0.12
	var reel_band_scale := 1.0
	var burst_reach := 460.0
	var attached_class: StringName = CourseGeometry.ANCHOR_FIXED
	var attached_expiry_tick := -1
	var timed_anchor_attaches := 0
	var sticky_attaches := 0
	var highway_attaches := 0
	var anchor_failures := 0
	## Swing shape. A web held near-vertical is a player hanging under an
	## anchor and hauling themselves along it; a web that sweeps through a
	## wide arc is a player swinging. The owner identified the first as a
	## loophole on 2026-08-01 after watching a replay — "instead of swinging
	## it basically keeps the web exactly above itself the whole time" — so
	## the distinction is measured here rather than left to the eye.
	var attached_ticks := 0
	var vertical_ticks := 0
	var web_angle_sum := 0.0
	## Vertical band occupied. A style that hugs the ceiling can be pressured
	## by something that threatens the ceiling; a style that uses the whole
	## height cannot. Measured because the design decision rides on it.
	var height_sum := 0.0
	var height_min := 1.0e9
	var height_max := -1.0e9
	var height_ticks := 0
	## How far the run travels ABOVE the speed the drive hands it for free.
	## The owner's 2026-08-01 observation: "I am mostly going faster than the
	## forced speed, so the forced speed is basically useless." A style that
	## lives ON the floor is being carried by it; a style that lives above it
	## is generating its own speed and would survive the floor's removal.
	var overspeed_sum := 0.0
	var above_target_ticks := 0
	var web_length_sum := 0.0
	var swing_arc_sum := 0.0
	var attach_angle_min := 0.0
	var attach_angle_max := 0.0
	var attach_arc_open := false
	var attach_searches := 0
	var class_choices := 0
	var course_seed := 1337
	var start_m := 0.0
	var ablated: Array[StringName] = []
	## Every command actually delivered to the world, in the game's own replay
	## record shape. `playback_tick` is the tick the command was queued on,
	## which is exactly what SwingLabSession stores when it records a human —
	## so a bot trace and a human trace are the same kind of object.
	var trace: Array = []
	## When non-empty the policy is switched off entirely and these records
	## drive the run instead. This is how a trace is proved to reproduce.
	var replay_records: Array = []
	var replay_cursor := 0

	func setup(
		active_config: SwingConfig,
		skill_profile: Dictionary,
		seed_value: int,
		style: StringName,
		defensive_bursts: bool,
		start_offset_px: float = 0.0,
		course_seed_value: int = 1337,
		ablated_verbs: Array[StringName] = [],
	) -> void:
		config = active_config
		profile = skill_profile
		rng.seed = seed_value
		reel_style = style
		save_bursts_enabled = defensive_bursts
		course_seed = course_seed_value
		start_m = start_offset_px / PIXELS_PER_METRE
		ablated = ablated_verbs.duplicate()
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

	## How a player internalizes their build. Reel: a player judges the meter
	## in SECONDS of continuous pull, not in percent — "about two seconds of
	## reel" is the sensation the HUD bar conveys. Writing the policy in
	## seconds is what makes reservoir size legible to the model at all: the
	## v2 policy compared `energy_fraction` against fraction thresholds, so
	## scaling `reel_energy_capacity` scaled both sides and every capacity
	## upgrade was bit-for-bit invisible. It also meant the bot stopped at a
	## fixed 6% and could never empty the meter, which turned "the Reel meter
	## never empties" into a measurement of its own stopping rule.
	## Burst: the further a pull travels, the closer the chosen anchors, so
	## expected travel stays a controllable hop instead of a leap.
	func _derive_adaptations() -> void:
		# Both thresholds are absolute times and MUST NOT be derived from
		# `reel_energy_capacity`. Anything proportional to the reservoir —
		# including a threshold in seconds computed as a share of the seconds
		# the reservoir buys — cancels the reservoir back out and reproduces
		# exactly the v2 blindness this rewrite exists to remove. What a
		# player holds back is a beat of reaction and an expectation of the
		# next correction, neither of which grows because the tank did.
		match reel_style:
			&"hold":
				reel_reserve_s = 0.05
				reel_stop_floor_s = 0.03
			&"tap":
				reel_reserve_s = 0.70
				reel_stop_floor_s = 0.30
			_:
				# The less the meter sustains itself, the longer a player
				# wants banked before committing to a pull.
				var sustain := config.reel_regeneration_rate / \
					maxf(0.001, config.reel_drain_rate)
				reel_reserve_s = clampf(0.9 * (1.0 - sustain), 0.15, 0.80)
				reel_stop_floor_s = 0.10
		reel_reserve_s *= float(profile.get("reel_reserve_scale", 1.0))
		reel_stop_floor_s *= float(profile.get("reel_floor_scale", 1.0))
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
			if replay_records.is_empty():
				_deliver_due_commands()
				if world.tick % int(profile["decision_period_ticks"]) == 0:
					_decide()
			else:
				_feed_replay()
			var next_chunk := maxi(
				0, floori(world.position.x / CourseStream.CHUNK_WIDTH))
			if next_chunk != chunk_index:
				chunk_index = next_chunk
				world.set_course_geometry(stream.update_for_position(
					world.position.x,
					config.middle_hazard_start_distance,
				))
			if world.web.attached:
				var offset := world.position - world.web.anchor
				# Angle from straight down, in degrees. 0 = hanging directly
				# under the anchor; 90 = level with it.
				var angle := absf(rad_to_deg(atan2(offset.x, maxf(0.001, offset.y))))
				attached_ticks += 1
				web_angle_sum += angle
				web_length_sum += offset.length()
				if angle <= VERTICAL_HANG_DEGREES:
					vertical_ticks += 1
				var signed := rad_to_deg(atan2(offset.x, maxf(0.001, offset.y)))
				if not attach_arc_open:
					attach_arc_open = true
					attach_angle_min = signed
					attach_angle_max = signed
				else:
					attach_angle_min = minf(attach_angle_min, signed)
					attach_angle_max = maxf(attach_angle_max, signed)
			elif attach_arc_open:
				swing_arc_sum += attach_angle_max - attach_angle_min
				attach_arc_open = false
			var drive_target := config.target_speed_at(world.distance_pixels)
			overspeed_sum += world.velocity.x - drive_target
			if world.velocity.x > drive_target:
				above_target_ticks += 1
			height_sum += world.position.y
			height_min = minf(height_min, world.position.y)
			height_max = maxf(height_max, world.position.y)
			height_ticks += 1
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
						attached_class = StringName(event.data.get(
							"anchor_class", CourseGeometry.ANCHOR_FIXED))
						attached_expiry_tick = -1
						match attached_class:
							CourseGeometry.ANCHOR_STICKY:
								sticky_attaches += 1
							CourseGeometry.ANCHOR_HIGHWAY:
								highway_attaches += 1
							CourseGeometry.ANCHOR_ROTTEN, \
							CourseGeometry.ANCHOR_COLLAPSING:
								timed_anchor_attaches += 1
					SimulationEvent.Kind.HAZARD_CUE:
						# The same crack cue the HUD is driven by, carrying
						# how long the span has left.
						if event.data.get("cue", &"") == &"rotten_crack" and \
								event.data.has("lifetime_ticks"):
							attached_expiry_tick = world.tick + int(
								event.data["lifetime_ticks"])
					SimulationEvent.Kind.ANCHOR_FAILED:
						anchor_failures += 1
						attached_class = CourseGeometry.ANCHOR_FIXED
						attached_expiry_tick = -1
					SimulationEvent.Kind.RELEASED:
						wants_reel = false
						attached_class = CourseGeometry.ANCHOR_FIXED
						attached_expiry_tick = -1
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
		var distance_m := world.distance_pixels / PIXELS_PER_METRE
		# A rescued death is still a death the player made; counting only the
		# terminal one would halve the rate wherever the rescue life is on.
		var deaths := 0
		if rescue_used:
			deaths += 1
		if cause != &"timeout":
			deaths += 1
		return {
			"seed": int(rng.seed),
			"course_seed": course_seed,
			"distance_m": distance_m,
			"start_m": start_m,
			"travelled_m": maxf(0.0, distance_m - start_m),
			"deaths": deaths,
			"seconds": world.tick * FIXED_DELTA,
			"cause": str(cause),
			"flies": world.run_flies,
			"attaches": attaches,
			"bursts": bursts,
			"save_bursts": save_bursts,
			"dives": dives,
			"taps": taps,
			"taps_per_second": (
				float(taps) / maxf(0.001, world.tick * FIXED_DELTA)),
			"timed_anchor_attaches": timed_anchor_attaches,
			"sticky_attaches": sticky_attaches,
			"highway_attaches": highway_attaches,
			"anchor_failures": anchor_failures,
			"attach_searches": attach_searches,
			"class_choices": class_choices,
			"reel_empties": reel_empties,
			"reel_time_s": reel_ticks * FIXED_DELTA,
			"reel_energy_spent": reel_energy_spent,
			"time_empty_s": empty_ticks * FIXED_DELTA,
			"rescue_used": rescue_used,
			"rescue_distance_m": rescue_distance_m,
			"death_during_pull": died_during_pull,
			"region": str(region["id"]),
			"pattern": str(stream.pattern_id_for_chunk(chunk_index)),
			"commands": trace.size(),
			# Swing shape, the loophole axis. `vertical_share` near 1.0 means
			# the run was spent hanging under its anchor rather than swinging.
			"mean_web_angle_deg": (
				web_angle_sum / attached_ticks if attached_ticks > 0 else 0.0),
			"mean_web_length_px": (
				web_length_sum / attached_ticks if attached_ticks > 0 else 0.0),
			"vertical_share": (
				float(vertical_ticks) / attached_ticks
				if attached_ticks > 0 else 0.0),
			"mean_swing_arc_deg": (
				swing_arc_sum / attaches if attaches > 0 else 0.0),
			"mean_overspeed_ms": (
				(overspeed_sum / height_ticks) / PIXELS_PER_METRE
				if height_ticks > 0 else 0.0),
			"above_target_share": (
				float(above_target_ticks) / height_ticks
				if height_ticks > 0 else 0.0),
			"mean_height_px": (
				height_sum / height_ticks if height_ticks > 0 else 0.0),
			"height_span_px": (
				height_max - height_min if height_ticks > 0 else 0.0),
			"attached_share": (
				float(attached_ticks) / maxi(1, world.tick)),
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
		# A span that expires while you hang on it is the one case where
		# holding a good swing is the mistake. The HUD says so directly
		# ("Weak span holding · release before it breaks"); acting on it is a
		# skill axis, not a cheat.
		if _timed_anchor_overstayed():
			_set_reel(false)
			_schedule(InputCommand.release(_next_sequence(), world.tick))
			return
		if (rising_fast and world.position.y < target_y + band) or \
				high_enough or near_ceiling:
			_set_reel(false)
			# The one Dive each attach re-arms is worth more than an ordinary
			# release: it converts the hang into forward speed instead of
			# merely giving it up. Only taken when the descent is wanted.
			if _try_dive(target_y):
				return
			_schedule(InputCommand.release(_next_sequence(), world.tick))
			return
		var too_low := world.position.y > target_y + \
			float(profile["reel_band_px"]) * reel_band_scale
		var reel_seconds_left := world.web.reel_energy / \
			maxf(0.001, config.reel_drain_rate)
		if wants_reel:
			if world.position.y <= target_y or \
					reel_seconds_left <= reel_stop_floor_s or near_ceiling:
				_set_reel(false)
		elif too_low and reel_seconds_left > reel_reserve_s:
			_set_reel(true)

	## True once a rotten or collapsing span is close enough to failing that a
	## player reading the cue would already have let go. The remaining life
	## comes from the `rotten_crack` hazard cue the HUD itself is driven by —
	## the bot reads the same number the player is shown, and only as reliably
	## as its tier reads cues at all. The margin is its own reaction delay, so
	## it is a decision made in time, not a prediction of the future.
	func _timed_anchor_overstayed() -> bool:
		if not (attached_class in TIMED_ANCHOR_CLASSES):
			return false
		if attached_expiry_tick < 0:
			return false
		if rng.randf() > float(profile["class_read"]):
			return false
		var margin := int(profile["reaction_delay_ticks"]) + 4
		return world.tick >= attached_expiry_tick - margin

	## Spend the Dive if a forward-and-below anchor is in range and the pull
	## preview stays clear. `dive_ready` is re-armed by every web attach, so
	## the natural cadence this produces is at most one Dive per web — which
	## is the loop the owner's recordings show: attach high, swing, dive
	## down-forward for speed, attach high again.
	func _try_dive(target_y: float) -> bool:
		if not world.dive_ready or world.pull_active:
			return false
		if &"dive" in ablated:
			return false
		if rng.randf() > float(profile["dive_chance"]):
			return false
		# Diving from below the route only digs deeper, and near the floor it
		# is simply a way to die faster.
		if world.position.y > target_y or \
				world.position.y > float(profile["dive_floor_y"]):
			return false
		var tap := _find_dive_tap()
		if tap == Vector2.INF:
			return false
		# If the queue already holds a web intent the Dive is not actually
		# sent, and reporting it as taken would silently swallow the release
		# this branch was chosen instead of.
		return _schedule(
			InputCommand.attach(tap, _next_sequence(), world.tick))

	func _decide_detached(target_y: float, band: float) -> void:
		var falling_fast := world.velocity.y > \
			float(profile["panic_fall_speed"])
		var below_route := world.position.y > target_y + band
		var floor_danger := world.position.y > 600.0
		if not (falling_fast or below_route or floor_danger):
			# Coasting above the route with a Dive still armed is the other
			# place the owner spends one: it buys forward speed downward
			# instead of waiting for gravity to give it back.
			if world.position.y < target_y - band and _try_dive(target_y):
				return
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

	## Fan of up-forward taps. v2 took the first usable anchor; v3 reads the
	## whole fan and picks by anchor class, because the classes zones 4–8 are
	## built out of are not interchangeable: a silk highway carries the anchor
	## forward for free, sticky silk bleeds velocity for as long as the web
	## holds, and rotten or collapsing spans expire and are then spent for
	## good. A model blind to that measures those zones as if every anchor
	## were an ordinary fixed one. How much of the class information survives
	## into the choice is `class_read`, so a novice still grabs whatever is
	## nearest.
	func _find_attach_tap() -> Vector2:
		var best_tap := Vector2.INF
		var best_score := -INF
		var index := 0
		var offered: Dictionary = {}
		for angle_degrees: float in _fan_angles(
				float(profile["attach_fan_top_deg"]),
				float(profile["attach_fan_bottom_deg"]), 4):
			var direction := Vector2.RIGHT.rotated(deg_to_rad(angle_degrees))
			var probe := _probe_tap(
				direction,
				float(profile["attach_reach_frac"]) *
					config.web_maximum_length,
				false)
			index += 1
			if not bool(probe["found"]):
				continue
			offered[probe["class"]] = true
			# Earlier angles are the steeper, higher-recovery ones the fan was
			# ordered to prefer; keep that ordering as a small tiebreak so
			# class preference has to be a real difference to override it.
			var score := _anchor_class_score(
				StringName(probe["class"])) - float(index) * 4.0
			if score > best_score:
				best_score = score
				best_tap = probe["tap"]
		# A preference can only change an outcome when there is something to
		# prefer. Counting the searches that actually offered more than one
		# anchor class is what keeps "the bot reads anchor classes" from
		# becoming a claim about behaviour it never gets to make.
		attach_searches += 1
		if offered.size() > 1:
			class_choices += 1
		return best_tap

	## Fan of down-forward taps for the Dive. Mirrors the attach fan below the
	## horizon; the world routes any target `downward_target_threshold` below
	## the spider to the Dive path, whichever button delivered it.
	func _find_dive_tap() -> Vector2:
		var best_tap := Vector2.INF
		var best_score := -INF
		for angle_degrees: float in _fan_angles(
				float(profile["dive_fan_top_deg"]),
				float(profile["dive_fan_bottom_deg"]), 3):
			var direction := Vector2.RIGHT.rotated(deg_to_rad(angle_degrees))
			var probe := _probe_tap(
				direction,
				float(profile["dive_reach_frac"]) * config.web_maximum_length,
				true)
			if not bool(probe["found"]):
				continue
			if not _pull_looks_safe(probe["tap"]):
				continue
			var score := _anchor_class_score(StringName(probe["class"]))
			if score > best_score:
				best_score = score
				best_tap = probe["tap"]
		return best_tap

	## Evenly spaced search angles between two bounds. The fan used to be a
	## literal list; it is generated so a fit can widen, narrow or rotate it
	## without the count changing underneath the rest of the policy.
	func _fan_angles(top: float, bottom: float, count: int) -> Array[float]:
		var angles: Array[float] = []
		if count <= 1:
			angles.append(top)
			return angles
		var step := (bottom - top) / float(count - 1)
		for index in range(count):
			angles.append(top + step * float(index))
		return angles

	## Class preference, faded towards indifference by how well the tier reads
	## the game's own anchor cues.
	func _anchor_class_score(anchor_class: StringName) -> float:
		var base := float(ANCHOR_CLASS_SCORE.get(anchor_class, 0.0))
		return base * float(profile["class_read"])

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
		var probe := _probe_tap(direction, reach, false)
		return probe["tap"] if bool(probe["found"]) else Vector2.INF

	## One aimed tap, snapped through the same forgiving nearest-solid query a
	## real tap gets. `downward` selects which side of the Dive threshold the
	## snapped anchor has to land on: the world routes a target at least
	## `downward_target_threshold` below the spider to the Dive path and
	## everything else to a web, so the two searches are the same search with
	## the test inverted. v2 hard-rejected every downward anchor here, which
	## is the single line that made Dive unreachable for the model.
	func _probe_tap(
		direction: Vector2,
		reach: float,
		downward: bool,
	) -> Dictionary:
		var miss := {"found": false, "tap": Vector2.INF, "class": &""}
		var error := Vector2(
			rng.randfn(0.0, float(profile["aim_error_px"])),
			rng.randfn(0.0, float(profile["aim_error_px"])),
		)
		var tap := world.position + direction.normalized() * reach + error
		var nearest := world.nearest_solid_point(tap)
		if not bool(nearest["found"]):
			return miss
		var anchor := Vector2(nearest["anchor"])
		var is_downward := anchor.y >= \
			world.position.y + config.downward_target_threshold
		if is_downward != downward:
			return miss
		if anchor.x < world.position.x - 60.0:
			return miss
		var distance := world.position.distance_to(anchor)
		if distance < config.web_minimum_length * 1.1 or \
				distance > config.web_maximum_length * 0.98:
			return miss
		return {
			"found": true,
			"tap": tap,
			"class": nearest.get("anchor_class", CourseGeometry.ANCHOR_FIXED),
		}

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
		# Ablation has to bite at the DECISION, not at the command. Dropping
		# only the queued REEL_START leaves `wants_reel` latched true while the
		# meter never drains, so `_decide_attached` waits forever for a reel it
		# never got and the bot hangs on its opening web — 0 webs, 0 bursts,
		# 58 m travelled. Refusing to want it keeps the model coherent.
		if active and &"reel" in ablated:
			return
		if wants_reel == active:
			return
		wants_reel = active
		_schedule(InputCommand.reel(active, _next_sequence(), world.tick))

	func _schedule(command: InputCommand) -> bool:
		if _is_ablated(command):
			return false
		var family := _command_family(command)
		if family != &"other":
			for entry: Dictionary in pending:
				var existing: InputCommand = entry["command"]
				if _command_family(existing) == family:
					# The bot reasons again before delayed input lands. Keeping
					# one pending web/Burst intent prevents a successful attach
					# from being undone by a stale duplicate tap.
					return false
		# Every command the model commits to is one finger contact, so the
		# count is directly comparable to the tap stream recovered from owner
		# recordings: 6.60/s averaged over a run, 18/s sustained for a full
		# second at peak — see
		# docs/measurements/2026-08-01-owner-play-calibration.md.
		taps += 1
		pending.append({
			"deliver_tick": world.tick +
				int(profile["reaction_delay_ticks"]) + rng.randi_range(0, 2),
			"command": command,
		})
		return true

	func _deliver_due_commands() -> void:
		var kept: Array[Dictionary] = []
		for entry: Dictionary in pending:
			if int(entry["deliver_tick"]) <= world.tick:
				var command: InputCommand = entry["command"]
				command.captured_tick = world.tick
				_record(command)
				world.queue_command(command)
			else:
				kept.append(entry)
		pending = kept

	## Feed a recorded trace instead of deciding. Mirrors
	## `SwingLabSession._feed_replay_commands` exactly, including the
	## `playback_tick <= tick` test, so a trace that reproduces here is a trace
	## the game should reproduce too.
	func _feed_replay() -> void:
		while replay_cursor < replay_records.size():
			var record: Dictionary = replay_records[replay_cursor]
			if int(record.get("playback_tick", 0)) > world.tick:
				break
			world.queue_command(InputCommand.from_record(record))
			replay_cursor += 1

	func _record(command: InputCommand) -> void:
		var record := command.to_record()
		record["playback_tick"] = world.tick
		trace.append(record)

	## Verb ablation: refuse to emit one verb's input entirely, so a course
	## segment can be asked "is this passable WITHOUT reeling?" rather than
	## merely "is this hard?". Burst and Dive share one command kind — the
	## world routes a downward target to the Dive path — so the split mirrors
	## `SimulationWorld._is_downward_target`. Ablation is a bot restriction
	## only; nothing in the simulation changes.
	func _is_ablated(command: InputCommand) -> bool:
		if ablated.is_empty():
			return false
		match command.kind:
			# Only the START is dropped; a stray STOP is a harmless no-op and
			# leaving it through keeps the world's reel state consistent.
			InputCommand.Kind.REEL_START:
				return &"reel" in ablated
			InputCommand.Kind.BURST:
				if not (&"burst" in ablated or &"dive" in ablated):
					return false
				var target := (
					command.world_target
					if command.has_world_target
					else world.web.anchor
				)
				var downward := target.y >= \
					world.position.y + config.downward_target_threshold
				return (&"dive" in ablated) if downward \
					else (&"burst" in ablated)
		return false

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

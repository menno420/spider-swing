extends SceneTree
## Phase 0 instrument — walks the deterministic generator and reports the axis
## vector per chunk. **It measures; it does not judge.**
##
## All measurement lives in `tools/course_audit_probe.gd`, which the contracts in
## `tests/unit/course_audit_tests.gd` use too, so the CLI and the gate can never
## measure differently. This file is argument parsing and presentation only.
##
## Usage:
##   godot --headless --path . --script res://tools/course_audit.gd -- \
##     --to-metres=15000 --seeds=5 --json=/tmp/course-audit.json
##
## Options:
##   --to-metres=N     audit 0..N metres (default 15000 — the owner's scope)
##   --from-metres=N   start at N metres (default 0)
##   --seeds=N         audit N course seeds, N>=1 (default 5)
##   --seed-base=N     first course seed (default 1000)
##   --samples=N       vertical probes per chunk (default 40, i.e. every 24 px)
##   --json=PATH       also write the full per-chunk record as JSON
##   --quiet           suppress the per-kilometre table

const Probe := preload("res://tools/course_audit_probe.gd")


func _initialize() -> void:
	var from_metres := 0.0
	var to_metres := 15000.0
	var seed_count := 5
	var seed_base := 1000
	var samples := 40
	var json_path := ""
	var quiet := false

	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--from-metres="):
			from_metres = float(argument.trim_prefix("--from-metres="))
		elif argument.begins_with("--to-metres="):
			to_metres = float(argument.trim_prefix("--to-metres="))
		elif argument.begins_with("--seeds="):
			seed_count = maxi(1, int(argument.trim_prefix("--seeds=")))
		elif argument.begins_with("--seed-base="):
			seed_base = int(argument.trim_prefix("--seed-base="))
		elif argument.begins_with("--samples="):
			samples = maxi(4, int(argument.trim_prefix("--samples=")))
		elif argument.begins_with("--json="):
			json_path = argument.trim_prefix("--json=")
		elif argument == "--quiet":
			quiet = true

	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var first_chunk := maxi(0, floori(
		from_metres * Probe.PIXELS_PER_METRE / Probe.CHUNK_WIDTH))
	var last_chunk := maxi(first_chunk, floori(
		to_metres * Probe.PIXELS_PER_METRE / Probe.CHUNK_WIDTH))

	var runs: Array[Dictionary] = []
	for offset in seed_count:
		runs.append(_audit_seed(
			seed_base + offset, first_chunk, last_chunk, samples, config))

	var report := {
		"first_chunk": first_chunk,
		"last_chunk": last_chunk,
		"from_metres": from_metres,
		"to_metres": to_metres,
		"seeds": range(seed_base, seed_base + seed_count),
		"samples_per_chunk": samples,
		"player_collision_radius": config.player_collision_radius,
		"runs": runs,
	}

	report["course_digest"] = Probe.course_digest(
		range(seed_base, seed_base + seed_count), first_chunk, last_chunk)

	# One number for "the generator built exactly the same course". It changes
	# when — and only when — pattern selection or geometry changes, so a slice
	# that claims to leave behaviour alone can be checked rather than believed.
	# Printed outside the summary because `--quiet` suppresses the table, not the
	# proof.
	print("[course-audit] course digest (patterns + polygons, chunks %d..%d, %d seed(s)): %s" % [
		first_chunk, last_chunk, seed_count, report["course_digest"]])

	if not quiet:
		_print_summary(report)

	if json_path != "":
		var file := FileAccess.open(json_path, FileAccess.WRITE)
		if file == null:
			printerr("[course-audit] could not open %s" % json_path)
			quit(1)
			return
		file.store_string(JSON.stringify(report, "  "))
		file.close()
		print("[course-audit] wrote %s" % json_path)

	quit(0)


## Walks one course seed. Novelty is per-run state, so it is tracked here rather
## than in the probe, which is deliberately stateless.
func _audit_seed(
	course_seed: int,
	first_chunk: int,
	last_chunk: int,
	samples: int,
	config: SwingConfig,
) -> Dictionary:
	var stream := Probe.stream_at(course_seed, first_chunk)
	var chunks: Array[Dictionary] = []
	var seen_patterns := {}
	var seen_lanes := {}

	for chunk_index in range(first_chunk, last_chunk + 1):
		var record := Probe.audit_chunk(
			course_seed, chunk_index, samples, config, stream)
		var pattern: String = record["pattern"]
		var lane: String = record["lane"]
		record["first_exposure_pattern"] = not seen_patterns.has(pattern)
		record["first_exposure_lane"] = not seen_lanes.has(lane)
		seen_patterns[pattern] = true
		seen_lanes[lane] = true
		chunks.append(record)

	return {"course_seed": course_seed, "chunks": chunks}


func _print_summary(report: Dictionary) -> void:
	print("[course-audit] %d seed(s), chunks %d..%d, player radius %.1f px" % [
		report["seeds"].size(),
		report["first_chunk"],
		report["last_chunk"],
		report["player_collision_radius"],
	])
	print("")
	print("  These are GEOMETRIC PROXIES, not difficulty. Use them to detect")
	print("  regressions and to stratify a playtest, never to rank chunks.")
	print("")
	print("  minGap  = tightest INTERIOR corridor, in player diameters.")
	print("  minOpp  = tightest SEQUENTIAL opposite-side pair, seconds at the")
	print("            speed cap for that distance (R13's own metric, and the")
	print("            worst case). Speed-independent px are in the JSON.")
	print("  gates   = simultaneous ceiling+floor pairs sharing an x-range.")
	print("            A width challenge, not a timing one — counted, not timed.")
	print("  new     = chunks introducing a pattern not yet seen in that run.")
	print("  press   = CoursePressure at the kilometre mark. NOTHING READS IT YET —")
	print("            it is printed beside the axes it will eventually schedule so")
	print("            the curve can be judged against what the game builds today.")
	print("")
	print("    km  region               press  label  dens%  minGap(radii)  minOpp(s)  gates  new")
	print("  ---- ------------------- ------ ------ ------ -------------- ---------- ------ ----")

	var buckets := {}
	for run: Dictionary in report["runs"]:
		for chunk: Dictionary in run["chunks"]:
			var km := int(chunk["metres"]) / 1000
			if not buckets.has(km):
				buckets[km] = {
					"region": chunk["region"],
					"label_total": 0.0,
					"count": 0,
					"challenge": 0,
					"min_radii": INF,
					"min_opp": INF,
					"gates": 0,
					"new": 0,
				}
			var bucket: Dictionary = buckets[km]
			bucket["label_total"] += float(chunk["label_difficulty"])
			bucket["count"] += 1
			if not bool(chunk["is_recovery"]):
				bucket["challenge"] += 1
			if float(chunk["min_corridor_radii"]) >= 0.0:
				bucket["min_radii"] = minf(
					bucket["min_radii"], float(chunk["min_corridor_radii"]))
			if float(chunk["min_opposite_gap_s"]) >= 0.0:
				bucket["min_opp"] = minf(
					bucket["min_opp"], float(chunk["min_opposite_gap_s"]))
			bucket["gates"] += int(chunk["simultaneous_gates"])
			if bool(chunk["first_exposure_pattern"]):
				bucket["new"] += 1

	var keys := buckets.keys()
	keys.sort()
	for km: int in keys:
		var bucket: Dictionary = buckets[km]
		var count := maxi(1, int(bucket["count"]))
		print("  %4d  %-19s %6.3f %6.2f %5.0f%% %14s %10s %6d %4d" % [
			km,
			bucket["region"],
			CoursePressure.at(float(km) * CoursePressure.PIXELS_PER_KILOMETRE),
			float(bucket["label_total"]) / float(count),
			100.0 * float(bucket["challenge"]) / float(count),
			("%.2f" % bucket["min_radii"]) if not is_inf(bucket["min_radii"]) else "-",
			("%.2f" % bucket["min_opp"]) if not is_inf(bucket["min_opp"]) else "-",
			bucket["gates"],
			bucket["new"],
		])
	print("")
	_print_curve_profile(report)


## The curve's own numbers, so the slope can be argued with directly rather than
## inferred from the per-kilometre column.
func _print_curve_profile(report: Dictionary) -> void:
	var top := CoursePressure.SCOPE_TOP_PIXELS
	var steepest := CoursePressure.steepest_kilometre(0.0, top, 50.0)
	print("  CoursePressure: 0 through %.0f m, 1.000 at %.0f m, clamped above." % [
		CoursePressure.WARM_UP_END_PIXELS / Probe.PIXELS_PER_METRE,
		top / Probe.PIXELS_PER_METRE,
	])
	print(("    The top of the curve is the top of the OWNER-SCOPED RANGE, not a "
		+ "plateau placement —"))
	print("    O1 is deferred, so the curve clamps at the edge of the evidence.")
	print("    steepest kilometre: %.4f (bound %.4f) · onset shape %.2f" % [
		steepest,
		CoursePressure.MAX_RISE_PER_KILOMETRE,
		CoursePressure.ONSET_SHAPE,
	])
	print("")

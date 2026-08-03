extends RefCounted
class_name CourseAuditTests
## Contracts on the Phase 0 course instrument (`tools/course_audit_probe.gd`).
##
## **These pin the instrument, not the difficulty.** A number that says how hard
## a chunk is would be exactly the `difficulty` label F1 calls dead metadata: no
## consumer, unfalsifiable, free to drift. What is pinned here is that the
## measurement means what it claims to mean — because the instrument has already
## been wrong twice, in ways that looked like plausible data:
##
##   1. An earlier corridor probe measured from `y = 0`, counting the open sky
##      above the ceiling as passable, and returned 9999 at every sample.
##   2. An earlier spacing probe read commitments from a corridor-width
##      threshold. Corridor contours make the ceiling and floor undulate, so it
##      could not separate "the corridor narrows" from "an obstacle is here",
##      and that measurement was discarded rather than published.
##
## Both failures produced numbers, not errors. That is why they get contracts.

const Probe := preload("res://tools/course_audit_probe.gd")

## Enough chunks to cross the warm-up and reach authored patterns, while keeping
## the suite fast — the instrument rebuilds real geometry per chunk.
const SCAN_CHUNKS := 40
const SCAN_SEED := 1000
const SAMPLES := 24

## Where the two pattern fixtures below live after the 0.39.0 region swap.
## `rooted_gate` and `high_low_weave` are Ancient Forest vocabulary, and Ancient
## Forest now occupies 5–10 km rather than 0–5 km. Chunk 52 is its first.
const LADDER_FIRST_CHUNK := 52
const LADDER_CHUNKS := 40

## `CourseStream.WEAVE_SECOND_OFFSET_X - WEAVE_FIRST_OFFSET_X`, restated so this
## contract does not silently follow a change to either constant.
const AUTHORED_WEAVE_SPACING_PX := 420.0

## Placement offsets are authored; the probe measures the *centres of the scaled
## contact polygons*, so the two differ by a few pixels by construction. 5% is
## far tighter than any real change to the weave and far looser than that gap.
const WEAVE_SPACING_TOLERANCE := 0.05

## The authored opening, measured 2026-08-02 and identical across course seeds:
## obstacle counts for chunks 0..5. R12's gate depends on this being authored
## rather than seeded, so a seed-dependent opening must fail loudly.
const AUTHORED_OPENING_COMMITMENTS := [0, 1, 0, 0, 1, 0]
const OPENING_SEEDS := [1000, 1001, 1002]

## The whole owner-scoped range, so the digest below spans all three regions in
## scope rather than only Ancient Forest. Chunk 156 is 14 976 m.
const DIGEST_SEEDS := [1000, 1001]
const DIGEST_FIRST_CHUNK := 0
const DIGEST_LAST_CHUNK := 156

## Measured on the pinned `4.7.1.stable.official.a13da4feb`. Reproduce with:
##
##   godot --headless --path . --script res://tools/course_audit.gd -- \
##     --to-metres=15000 --seeds=2 --seed-base=1000 --quiet
##
## **Re-pinned by the 0.39.0 pressure-curve slice, deliberately.** The previous
## value pinned a course nothing read the curve for; this one pins the course the
## curve produces after selection moved onto it and the first two regions swapped
## slots. The failure that forced this edit is the deliverable — it is the proof
## that behaviour moved, and the reason the constant exists at all is that no
## generator change may land looking like a no-op.
const UNCHANGED_COURSE_DIGEST := \
	"087252417d164e4d2521b917084c63a39fb9f5d100e7826001a5241dcf75704b"

## Chunks the width and envelope contracts below walk. Wide enough to cross all
## three scoped regions, small enough that the suite still runs in seconds — the
## instrument rebuilds real geometry per chunk.
const ENVELOPE_LAST_CHUNK := 156
const ENVELOPE_SEED := 1000

## [D-0056]. `swing` class — `high`, `low`, `weave`, where the route requires a
## direction change — may never cross 7.39 player diameters. That number is
## Ancient Forest's own minimum, measured on content the owner has played and
## endorsed. `hollow_lattice_high` and `hollow_lattice_low` were the only two
## patterns in the first 15 km below it, at 6.69.
const SWING_CLASS_FLOOR_DIAMETERS := 7.39

## R8's constant K, owner-stated as "the absolute minimum of possible passing at
## high skill play" — 3.0 diameters, 108 px. **A backstop, never a target.** If
## anything in the scoped range ever approaches it, the rule above failed first.
const FAIRNESS_BACKSTOP_DIAMETERS := 3.0

## The two width x duration terms nothing was watching before this slice, pinned
## as MEASUREMENTS with regression headroom rather than as difficulty targets —
## the Phase 0 pattern. Measured 2026-08-03 across the scoped range: the longest
## run of chunks near a region minimum is 2 (192 m), and no chunk holds its own
## minimum for the full chunk once it carries an obstacle.
const MAXIMUM_RUN_NEAR_REGION_MINIMUM := 3

## O2's bound, owner-stated: recovery share strictly above Ancient Forest's
## shipped 2% and strictly below Bramble's shipped 50%. Restated as literals so
## this contract cannot follow `CourseAxisEnvelope`'s own constants into a
## vacuous pass.
const RECOVERY_SHARE_FLOOR := 0.02
const RECOVERY_SHARE_CEILING := 0.50

## R7's ceiling on consecutive exposure, restated as a literal. It is
## `CourseAxisEnvelope.RECOVERY_INTERVAL_MAXIMUM`, and it is written out here on
## purpose: a contract that reads the constant it is checking passes whatever
## that constant becomes. The reason the number is 5 rather than 6 is this rule —
## at a widening transition one opening is deliberately spent to stop two open
## chunks sitting side by side, so the worst run is the interval itself.
const MAXIMUM_CONSECUTIVE_CHALLENGE_CHUNKS := 5

## R2, and it is deliberately a statement about the **envelope** rather than the
## instantaneous signal: *"the naive reading — that difficulty never decreases
## anywhere — forbids both the section-entry ramp the owner asked for and the
## recovery chunks he asked for."*
##
## Two clauses together forbid the defect. The **three-kilometre rolling mean**
## of the authored label may dip but never by more than 15% — S7 derives the
## ceiling on that bound rather than picking it: the saw-tooth this exists to
## prevent is a **41% drop**, and any bound at or above ~20% re-permits it. Per
## region, the mean must strictly rise, which stops a run of small legal dips
## adding up to the same thing across a boundary.
##
## **Why a rolling mean and not the raw kilometre.** A kilometre is 10.4 chunks,
## so the recovery cadence aliases against the bucket boundary: one extra open
## chunk in ten moves the mean 10% on its own, and the cadence widening from one
## interval to the next reshuffles which chunks are open. That is quantisation in
## the instrument, not a change in the course. R2 is explicit that monotonicity
## is a property of the envelope rather than of the instantaneous signal, and a
## three-kilometre window is the smallest one that removes the aliasing while
## still catching a real drop — checked against the pre-swap course, where the
## saw-tooth registers as a 17% fall and this bound rejects it.
const MAXIMUM_KILOMETRE_LABEL_DIP := 0.15
const LABEL_ENVELOPE_WINDOW_KM := 3


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_corridor_measures_the_interior_only(failures)
	passed += _test_simultaneous_gate_is_counted_never_timed(failures)
	passed += _test_probe_reproduces_authored_weave_spacing(failures)
	passed += _test_audit_is_deterministic(failures)
	passed += _test_opening_is_authored_not_seeded(failures)
	passed += _test_course_is_unchanged_by_the_pressure_curve(failures)
	passed += _test_constriction_length_is_a_run_not_a_point(failures)
	passed += _test_region_distribution_counts_consecutive_chunks(failures)
	passed += _test_width_envelope_holds_across_the_scoped_range(failures)
	passed += _test_recovery_share_stays_inside_the_owner_bound(failures)
	passed += _test_recovery_cadence_never_exceeds_r7(failures)
	passed += _test_difficulty_envelope_never_saw_tooths(failures)
	return {"passed": passed, "failures": failures}


## The corridor is the space BETWEEN ceiling and floor. Measuring from the top
## of the world instead reports the sky as passable — the exact error that
## returned 9999 everywhere. A measurement above the authored corridor height is
## therefore impossible, and a non-positive one means nothing was found at all.
static func _test_corridor_measures_the_interior_only(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var stream := Probe.stream_at(SCAN_SEED, 0)
	var ceiling := Probe.CORRIDOR_TOTAL_HEIGHT

	for chunk_index in SCAN_CHUNKS:
		var record := Probe.audit_chunk(
			SCAN_SEED, chunk_index, SAMPLES, config, stream)
		var width := float(record["min_corridor_px"])
		if width <= 0.0:
			failures.append(
				"course audit: chunk %d measured no interior corridor (%.1f px)"
				% [chunk_index, width])
			return 0
		if width > ceiling + 0.5:
			failures.append(
				("course audit: chunk %d corridor %.1f px exceeds the authored "
					+ "ceiling-to-floor height %.1f px — the probe is counting "
					+ "space outside the corridor")
				% [chunk_index, width, ceiling])
			return 0
	return 1


## A ceiling and a floor obstacle sharing an x-range is one threading decision,
## not two sequential ones. Timing it yields 0.00 s and would make R13's spacing
## floor look violated wherever a gate appears.
static func _test_simultaneous_gate_is_counted_never_timed(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var stream := Probe.stream_at(SCAN_SEED, LADDER_FIRST_CHUNK)

	for chunk_index in range(
		LADDER_FIRST_CHUNK, LADDER_FIRST_CHUNK + LADDER_CHUNKS
	):
		var record := Probe.audit_chunk(
			SCAN_SEED, chunk_index, SAMPLES, config, stream)
		if String(record["pattern"]) != "rooted_gate":
			continue
		if int(record["simultaneous_gates"]) < 1:
			failures.append(
				("course audit: rooted_gate at chunk %d reported no "
					+ "simultaneous gate — its two obstacles share an x-range")
				% chunk_index)
			return 0
		if float(record["min_opposite_gap_px"]) >= 0.0:
			failures.append(
				("course audit: rooted_gate at chunk %d was timed as a "
					+ "sequential pair (%.1f px). A shared x-range is a width "
					+ "challenge and supplies no reaction time.")
				% [chunk_index, float(record["min_opposite_gap_px"])])
			return 0
		return 1

	failures.append(
		"course audit: no rooted_gate chunk in %d chunks from %d — the fixture "
		% [LADDER_CHUNKS, LADDER_FIRST_CHUNK] + "this contract needs is gone")
	return 0


## Ties the instrument to the generator's own constants. If the probe and the
## authored weave offsets ever disagree by more than a rounding margin, one of
## the two moved and the other did not.
static func _test_probe_reproduces_authored_weave_spacing(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var authored := \
		CourseStream.WEAVE_SECOND_OFFSET_X - CourseStream.WEAVE_FIRST_OFFSET_X
	if not is_equal_approx(authored, AUTHORED_WEAVE_SPACING_PX):
		failures.append(
			("course audit: the authored weave spacing moved to %.1f px from "
				+ "the %.1f px this contract was written against — re-measure "
				+ "and update the baseline deliberately")
			% [authored, AUTHORED_WEAVE_SPACING_PX])
		return 0

	var stream := Probe.stream_at(SCAN_SEED, LADDER_FIRST_CHUNK)
	for chunk_index in range(
		LADDER_FIRST_CHUNK, LADDER_FIRST_CHUNK + LADDER_CHUNKS
	):
		var record := Probe.audit_chunk(
			SCAN_SEED, chunk_index, SAMPLES, config, stream)
		if String(record["pattern"]) != "high_low_weave":
			continue
		var measured := float(record["min_opposite_gap_px"])
		if measured <= 0.0:
			failures.append(
				("course audit: high_low_weave at chunk %d reported no "
					+ "sequential opposite pair — the weave is the one pattern "
					+ "that must have one") % chunk_index)
			return 0
		if absf(measured - authored) / authored > WEAVE_SPACING_TOLERANCE:
			failures.append(
				("course audit: high_low_weave measured %.1f px against an "
					+ "authored %.1f px, outside the %.0f%% tolerance")
				% [measured, authored, WEAVE_SPACING_TOLERANCE * 100.0])
			return 0
		return 1

	failures.append(
		"course audit: no high_low_weave chunk in %d chunks from %d — the "
		% [LADDER_CHUNKS, LADDER_FIRST_CHUNK] + "fixture this contract needs is gone")
	return 0


## Course generation is a pure function of `(chunk_index, distance, seed)`, so
## the instrument reading it must be one too. A probe that drifts between calls
## cannot be used for regression detection, which is its whole purpose.
static func _test_audit_is_deterministic(failures: PackedStringArray) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	for chunk_index in [7, 12, 29]:
		var first := Probe.audit_chunk(SCAN_SEED, chunk_index, SAMPLES, config)
		var second := Probe.audit_chunk(SCAN_SEED, chunk_index, SAMPLES, config)
		for key: String in first.keys():
			if first[key] != second[key]:
				failures.append(
					("course audit: chunk %d field '%s' changed between two "
						+ "identical audits (%s then %s)")
					% [chunk_index, key, str(first[key]), str(second[key])])
				return 0
	return 1


## R12's section gate rests on the opening being the same for everyone. If the
## first 500 m became seed-dependent, "the first 500 m stays as it is" would
## silently mean something different per run.
static func _test_opening_is_authored_not_seeded(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	for course_seed: int in OPENING_SEEDS:
		var stream := Probe.stream_at(course_seed, 0)
		for chunk_index in AUTHORED_OPENING_COMMITMENTS.size():
			var record := Probe.audit_chunk(
				course_seed, chunk_index, SAMPLES, config, stream)
			var expected: int = AUTHORED_OPENING_COMMITMENTS[chunk_index]
			var actual := int(record["commitment_count"])
			if actual != expected:
				failures.append(
					("course audit: opening chunk %d on seed %d carries %d "
						+ "obstacle(s), not the authored %d — the warm-up is "
						+ "either seeded or has been retuned")
					% [chunk_index, course_seed, actual, expected])
				return 0
	return 1


## `CoursePressure` computes the difficulty-amount curve and **nothing consumes
## it yet**, so the generator must still build exactly the course it built
## before. This is the contract that makes that a fact rather than an assurance,
## and it is what makes every later phase comparable: the before-picture cannot
## drift out from under the after-picture unnoticed.
##
## It is *expected* to fail the moment a later phase wires selection onto the
## curve. That failure is the deliverable — it forces a deliberate re-pin, so no
## generator change can land looking like a no-op.
static func _test_course_is_unchanged_by_the_pressure_curve(
	failures: PackedStringArray,
) -> int:
	var digest := Probe.course_digest(
		DIGEST_SEEDS, DIGEST_FIRST_CHUNK, DIGEST_LAST_CHUNK)
	if digest != UNCHANGED_COURSE_DIGEST:
		failures.append(
			("course audit: the generated course changed. Chunks %d..%d on "
				+ "seeds %s now hash to %s, not the pinned %s. If you moved "
				+ "selection or geometry deliberately, re-pin this constant in "
				+ "the same commit and say so; if you did not, something reads "
				+ "the pressure curve that should not.")
			% [
				DIGEST_FIRST_CHUNK,
				DIGEST_LAST_CHUNK,
				str(DIGEST_SEEDS),
				digest,
				UNCHANGED_COURSE_DIGEST,
			])
		return 0
	return 1


## Constriction length is width x DURATION, and the duration half is the part
## that was invisible: an obstacle could be reshaped into a 400 px tube at an
## unchanged minimum and every previous contract would have stayed green.
##
## Two properties, and the second is the one that makes the measurement mean
## anything. A chunk with no obstacle has a corridor set only by the rail
## contour, so it sits near its own minimum for most of its length; a chunk that
## carries a commitment must pinch *somewhere in particular* and therefore report
## a shorter run. If the two ever measured the same, the probe would be reporting
## chunk width rather than constriction length.
static func _test_constriction_length_is_a_run_not_a_point(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var stream := Probe.stream_at(ENVELOPE_SEED, 0)
	var open_longest := 0.0
	var obstacle_shortest := INF
	var obstacle_chunks := 0

	for chunk_index in range(ENVELOPE_LAST_CHUNK + 1):
		var record := Probe.audit_chunk(
			ENVELOPE_SEED, chunk_index, SAMPLES, config, stream)
		var constriction := float(record["constriction_px"])
		if constriction < 0.0 or constriction > Probe.CHUNK_WIDTH + 0.01:
			failures.append(
				("course audit: chunk %d reports a %.1f px constriction, which "
					+ "is outside [0, %.0f] — a run of samples cannot be longer "
					+ "than the chunk it was sampled across")
				% [chunk_index, constriction, Probe.CHUNK_WIDTH])
			return 0
		if int(record["commitment_count"]) == 0:
			open_longest = maxf(open_longest, constriction)
		else:
			obstacle_chunks += 1
			obstacle_shortest = minf(obstacle_shortest, constriction)

	if obstacle_chunks == 0 or is_inf(obstacle_shortest):
		failures.append(
			"course audit: no chunk in 0..%d carries an obstacle — the fixture "
			% ENVELOPE_LAST_CHUNK + "this contract needs is gone")
		return 0
	if open_longest <= obstacle_shortest:
		failures.append(
			("course audit: the longest constriction in an empty chunk is "
				+ "%.1f px and the shortest in a chunk with an obstacle is "
				+ "%.1f px. An empty chunk should hold its own minimum for "
				+ "longer than a pinched one — the probe is measuring chunk "
				+ "width, not constriction length.")
			% [open_longest, obstacle_shortest])
		return 0
	return 1


## The other new term: how long a region holds near its own tightest corridor.
##
## Checked against literal inputs rather than a generator run, because a
## measurement contract that derives its inputs from the generator can only prove
## the number is stable, never that it is the number claimed. The run below is
## deliberately not the longest block of small values — sorting the widths, or
## counting them out of course order, would return 4 instead of 3.
static func _test_region_distribution_counts_consecutive_chunks(
	failures: PackedStringArray,
) -> int:
	var records: Array = []
	for radii: float in [10.0, 10.0, 10.5, 20.0, 10.2, 10.1, 30.0, 10.4]:
		records.append({"region": "fixture", "min_corridor_radii": radii})
	# Two records the aggregate must ignore: a different region, and a chunk
	# where no interior corridor could be measured at all.
	records.append({"region": "other", "min_corridor_radii": 4.0})
	records.append({"region": "fixture", "min_corridor_radii": -1.0})

	var distribution := Probe.region_width_distribution(records)
	if not distribution.has("fixture") or not distribution.has("other"):
		failures.append("course audit: region distribution lost a region")
		return 0
	var entry: Dictionary = distribution["fixture"]
	# min 10.0, so the near-minimum band is <= 11.0: indices 0,1,2 then 4,5 then
	# 7 — six of eight, longest consecutive run three.
	if int(entry["chunks"]) != 8 or \
			not is_equal_approx(float(entry["min_radii"]), 10.0) or \
			absf(float(entry["share_near_min"]) - 0.75) > 0.001 or \
			int(entry["longest_run_near_min"]) != 3:
		failures.append(
			("course audit: region distribution measured chunks=%d min=%.2f "
				+ "share=%.3f run=%d against the authored 8 / 10.00 / 0.750 / 3")
			% [
				int(entry["chunks"]),
				float(entry["min_radii"]),
				float(entry["share_near_min"]),
				int(entry["longest_run_near_min"]),
			])
		return 0
	if float(entry["median_radii"]) < float(entry["min_radii"]):
		failures.append("course audit: a region median fell below its own minimum")
		return 0
	return 1


## [D-0056], and it is a distribution rather than a floor on purpose: written as
## "the minimum is X", a scheduler may drive every chunk to X and pass.
static func _test_width_envelope_holds_across_the_scoped_range(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var stream := Probe.stream_at(ENVELOPE_SEED, 0)
	var records: Array = []

	for chunk_index in range(ENVELOPE_LAST_CHUNK + 1):
		var record := Probe.audit_chunk(
			ENVELOPE_SEED, chunk_index, SAMPLES, config, stream)
		records.append(record)
		var radii := float(record["min_corridor_radii"])
		if radii < 0.0:
			continue
		if radii < FAIRNESS_BACKSTOP_DIAMETERS:
			failures.append(
				("course audit: chunk %d (%s) measures %.2f player diameters, "
					+ "below R8's absolute backstop of %.2f. That constant is "
					+ "the limit of possible passing, not a target — reaching "
					+ "it means the class rule above failed first.")
				% [chunk_index, record["pattern"], radii,
					FAIRNESS_BACKSTOP_DIAMETERS])
			return 0
		if str(record["width_class"]) == "swing" and \
				radii + 0.005 < SWING_CLASS_FLOOR_DIAMETERS:
			failures.append(
				("course audit: swing-class chunk %d (%s, lane %s) measures "
					+ "%.2f diameters, below the %.2f floor its class may never "
					+ "cross. A threading gate may go lower as its constriction "
					+ "shortens; a swing may not.")
				% [chunk_index, record["pattern"], record["lane"], radii,
					SWING_CLASS_FLOOR_DIAMETERS])
			return 0

	var distribution := Probe.region_width_distribution(records)
	for region: String in distribution:
		var entry: Dictionary = distribution[region]
		if int(entry["chunks"]) < 5:
			continue
		if int(entry["longest_run_near_min"]) > MAXIMUM_RUN_NEAR_REGION_MINIMUM:
			failures.append(
				("course audit: %s holds within 10%% of its own minimum for %d "
					+ "consecutive chunks (%.0f m), past the %d this was "
					+ "measured at. Width x duration: a narrow stretch is a "
					+ "different demand from a narrow chunk.")
				% [
					region,
					int(entry["longest_run_near_min"]),
					float(entry["longest_run_near_min"]) * Probe.CHUNK_WIDTH
						/ Probe.PIXELS_PER_METRE,
					MAXIMUM_RUN_NEAR_REGION_MINIMUM,
				])
			return 0
		if float(entry["median_radii"]) < float(entry["min_radii"]):
			failures.append(
				"course audit: %s reports a median below its own minimum" % region)
			return 0
	return 1


## O2, owner-stated: recovery strictly above Ancient Forest's shipped 2% and
## strictly below Bramble's shipped 50%. Warm-up chunks are excluded because they
## draw no pattern at all — they are neither a challenge nor a scheduled pocket,
## and counting them either way misreports the axis.
static func _test_recovery_share_stays_inside_the_owner_bound(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var stream := Probe.stream_at(ENVELOPE_SEED, 0)
	var scheduled := {}
	var recovered := {}

	for chunk_index in range(ENVELOPE_LAST_CHUNK + 1):
		var record := Probe.audit_chunk(
			ENVELOPE_SEED, chunk_index, SAMPLES, config, stream)
		if bool(record["is_warm_up"]):
			continue
		var region := str(record["region"])
		scheduled[region] = int(scheduled.get(region, 0)) + 1
		if bool(record["is_recovery"]):
			recovered[region] = int(recovered.get(region, 0)) + 1

	for region: String in scheduled:
		var count := int(scheduled[region])
		if count < 10:
			continue
		var share := float(int(recovered.get(region, 0))) / float(count)
		if share <= RECOVERY_SHARE_FLOOR or share >= RECOVERY_SHARE_CEILING:
			failures.append(
				("course audit: %s schedules %.1f%% recovery chunks, outside the "
					+ "owner's (%.0f%%, %.0f%%) bound — above it the region is "
					+ "half empty like Bramble was, at or below it the region "
					+ "has no recovery rhythm at all like Ancient Forest did.")
				% [
					region,
					100.0 * share,
					100.0 * RECOVERY_SHARE_FLOOR,
					100.0 * RECOVERY_SHARE_CEILING,
				])
			return 0
	return 1


## R2's monotone envelope, and the contract that would have caught the 41%
## saw-tooth the doctrine exists to remove.
##
## The instantaneous signal is allowed to dip — recovery chunks are deliberate
## dips and 10.4 chunks per kilometre alias against the bucket boundary — so this
## bounds the dip rather than forbidding it, and separately requires the region
## means to rise. Before this slice the measured region means, in play order,
## were 2.81 -> 2.00 -> 3.15: the middle term is the defect.
static func _test_difficulty_envelope_never_saw_tooths(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var stream := Probe.stream_at(ENVELOPE_SEED, 0)
	var kilometre_total := {}
	var kilometre_count := {}
	var region_total := {}
	var region_count := {}
	var region_order: Array[String] = []

	for chunk_index in range(ENVELOPE_LAST_CHUNK + 1):
		var record := Probe.audit_chunk(
			ENVELOPE_SEED, chunk_index, SAMPLES, config, stream)
		if bool(record["is_warm_up"]):
			continue
		var kilometre := int(float(record["metres"]) / 1000.0)
		kilometre_total[kilometre] = \
			float(kilometre_total.get(kilometre, 0.0)) \
				+ float(record["label_difficulty"])
		kilometre_count[kilometre] = int(kilometre_count.get(kilometre, 0)) + 1
		var region := str(record["region"])
		if not region_total.has(region):
			region_order.append(region)
		region_total[region] = \
			float(region_total.get(region, 0.0)) \
				+ float(record["label_difficulty"])
		region_count[region] = int(region_count.get(region, 0)) + 1

	var kilometres := kilometre_total.keys()
	kilometres.sort()
	var means := PackedFloat32Array()
	for kilometre: int in kilometres:
		means.append(float(kilometre_total[kilometre])
			/ float(maxi(1, int(kilometre_count[kilometre]))))
	if means.size() < LABEL_ENVELOPE_WINDOW_KM:
		failures.append(
			"course audit: only %d kilometre(s) audited — too few to read an "
			% means.size() + "envelope from")
		return 0

	var previous := -1.0
	for start in range(means.size() - LABEL_ENVELOPE_WINDOW_KM + 1):
		var total := 0.0
		for offset in LABEL_ENVELOPE_WINDOW_KM:
			total += means[start + offset]
		var window := total / float(LABEL_ENVELOPE_WINDOW_KM)
		if previous > 0.0 and window < previous * (1.0 - MAXIMUM_KILOMETRE_LABEL_DIP):
			failures.append(
				("course audit: the %d km window at km %d delivers a mean "
					+ "authored label of %.2f against %.2f one kilometre "
					+ "earlier — a %.0f%% drop, past the %.0f%% an envelope may "
					+ "dip. The saw-tooth this forbids was 41%%.")
				% [
					LABEL_ENVELOPE_WINDOW_KM,
					int(kilometres[start]),
					window,
					previous,
					100.0 * (1.0 - window / previous),
					100.0 * MAXIMUM_KILOMETRE_LABEL_DIP,
				])
			return 0
		previous = window

	var previous_region_mean := -1.0
	var previous_region := ""
	for region: String in region_order:
		var count := int(region_count[region])
		if count < 10:
			continue
		var mean := float(region_total[region]) / float(count)
		if previous_region_mean > 0.0 and mean <= previous_region_mean:
			failures.append(
				("course audit: %s delivers a mean authored label of %.2f, no "
					+ "higher than %s's %.2f before it. Section ceilings never "
					+ "decrease (R2) — a region that reads easier than the one "
					+ "in front of it is the saw-tooth.")
				% [region, mean, previous_region, previous_region_mean])
			return 0
		previous_region_mean = mean
		previous_region = region
	return 1


## R7 on its own, deliberately separated from the share above. The two describe
## the same cadence from different sides — how *often* it opens and how *long* it
## stays shut — and a single contract holding both would let either failure mask
## the other, which is exactly what happened when they were falsified together.
static func _test_recovery_cadence_never_exceeds_r7(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var stream := Probe.stream_at(ENVELOPE_SEED, 0)
	var run := 0
	var longest := 0
	var longest_end := -1

	for chunk_index in range(ENVELOPE_LAST_CHUNK + 1):
		var record := Probe.audit_chunk(
			ENVELOPE_SEED, chunk_index, SAMPLES, config, stream)
		if bool(record["is_warm_up"]):
			continue
		# A chunk that carries no obstacle is an opening whatever it is called.
		# The tight-rail corridor is the case that matters: it is narrow and it
		# is empty, so counting it as a commitment would overstate the density
		# axis and understate the width one.
		if bool(record["is_recovery"]) or int(record["commitment_count"]) == 0:
			run = 0
			continue
		run += 1
		if run > longest:
			longest = run
			longest_end = chunk_index

	if longest > MAXIMUM_CONSECUTIVE_CHALLENGE_CHUNKS:
		failures.append(
			("course audit: %d consecutive challenge chunks (%.0f m) ending at "
				+ "chunk %d, past the %d R7 allows. Recovery cadence widens with "
				+ "pressure; it does not stop.")
			% [
				longest,
				float(longest) * Probe.CHUNK_WIDTH / Probe.PIXELS_PER_METRE,
				longest_end,
				MAXIMUM_CONSECUTIVE_CHALLENGE_CHUNKS,
			])
		return 0
	return 1

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

## Measured against the generator as it stood when `CoursePressure` was written,
## on the pinned `4.7.1.stable.official.a13da4feb`. Reproduce with:
##
##   godot --headless --path . --script res://tools/course_audit.gd -- \
##     --to-metres=15000 --seeds=2 --seed-base=1000 --quiet
const UNCHANGED_COURSE_DIGEST := \
	"4d7bbdf27f856fa7d16e68b5a21419a121103d911954694aa0aabd1b249f076f"


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_corridor_measures_the_interior_only(failures)
	passed += _test_simultaneous_gate_is_counted_never_timed(failures)
	passed += _test_probe_reproduces_authored_weave_spacing(failures)
	passed += _test_audit_is_deterministic(failures)
	passed += _test_opening_is_authored_not_seeded(failures)
	passed += _test_course_is_unchanged_by_the_pressure_curve(failures)
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
	var stream := Probe.stream_at(SCAN_SEED, 0)

	for chunk_index in SCAN_CHUNKS:
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
		"course audit: no rooted_gate chunk in the first %d — the fixture this "
		% SCAN_CHUNKS + "contract needs is gone")
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

	var stream := Probe.stream_at(SCAN_SEED, 0)
	for chunk_index in SCAN_CHUNKS:
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
		"course audit: no high_low_weave chunk in the first %d — the fixture "
		% SCAN_CHUNKS + "this contract needs is gone")
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

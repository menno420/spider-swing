extends RefCounted
class_name CourseAuditProbe
## The Phase 0 measurement functions, shared by the CLI and the contracts.
##
## **It measures; it does not judge.** Nothing here is called "difficulty".
## Every value is a geometric or structural proxy whose only jobs are regression
## detection and stratifying a playtest, exactly as
## `docs/game-design/difficulty-research-2026-08-02.md` § 3 requires.
##
## Lives in `tools/` rather than `game/` because it is instrumentation, not
## gameplay — no shipped code path reads it, and the layer checker governs
## `game/` only.
##
## TWO MEASUREMENT ERRORS ARE DESIGNED OUT HERE, both made and caught earlier
## and both recorded in the doctrine's appendix:
##
##   1. Corridor width is the largest **interior** gap between merged blocked
##      spans. Measuring from `y = 0` reports the open sky *above the ceiling* as
##      passable and returns nonsense at every sample.
##   2. Commitments are read from obstacle contact polygons, never from a
##      corridor-width threshold. Corridor contours make the ceiling and floor
##      undulate, so a width threshold cannot separate "the corridor narrows"
##      from "an obstacle is here" — an earlier spacing measurement was
##      discarded for exactly this reason.

const CHUNK_WIDTH := 960.0
const PIXELS_PER_METRE := 10.0
const RECOVERY_PATTERN_ID := &"open_recovery"

## One spider width. Constriction *length* is reported in these because that is
## the unit D-0056 states the two width classes in — a threading gate may go
## below the swing floor "as its constriction shortens toward roughly one spider
## width".
const SPIDER_WIDTH_PX := 36.0

## A sample counts as "at the constriction" when it is within this fraction of
## the chunk's own minimum. Taken from the ad-hoc method behind the 2026-08-03
## corridor measurement so the numbers here are comparable to the ones that
## produced the envelope, rather than a second definition of the same word.
const NEAR_MINIMUM_TOLERANCE := 0.10

## `lane` is the width classifier and **not** the timing one — the split D-0056
## makes and N3 warns about in the other direction. `swing` means the route
## requires a direction change around the obstacle, so the corridor is the whole
## budget; `centre` patterns are threaded straight through and pay in width ×
## length instead.
const SWING_LANES := [&"high", &"low", &"weave"]

## Vertical line used to say which side of the corridor an obstacle grew from.
## Obstacles whose span crosses it are `centre` and never form an opposite pair.
const CORRIDOR_MIDLINE_Y := (CourseStream.CEILING_Y + CourseStream.FLOOR_Y) * 0.5

## Total ceiling-to-floor extent. No interior gap may ever reach it — that is
## the invariant which catches the `y = 0` error if it is ever reintroduced.
const CORRIDOR_TOTAL_HEIGHT := CourseStream.FLOOR_Y - CourseStream.CEILING_Y


## Builds a stream positioned so `chunk_index` is never an edge chunk of the
## generated window. Edge chunks can be missing neighbour context.
##
## **Content fields come from the balanced preset, never from literals here.**
## They used to be hard-coded, which meant the instrument measured a course the
## game does not build the moment any of those defaults moved — a silent
## divergence between the audit and the thing being audited, and exactly the
## class of error the two contracts at the top of `course_audit_tests.gd` exist
## to catch.
static func stream_at(course_seed: int, chunk_index: int) -> CourseStream:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var stream := CourseStream.new()
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
		SimulationWorld.START_POSITION.x,
		config.opening_obstacle_scale_floor,
	)
	stream.update_for_position(float(chunk_index) * CHUNK_WIDTH + CHUNK_WIDTH * 0.5)
	return stream


## The distance the generator itself passes to the pattern catalog for a chunk.
##
## `CourseStream` measures a chunk's distance from `START_X`, so a probe that
## used `chunk × CHUNK_WIDTH` was reading the catalog 220 px ahead of the stream
## it was measuring beside. That was harmless while selection was keyed to coarse
## distance bands; it stops being harmless the moment selection reads a
## continuous curve, because the two can then disagree about a chunk.
static func pattern_distance_for(chunk_index: int) -> float:
	return maxf(0.0, float(chunk_index) * CHUNK_WIDTH - CourseStream.START_X)


## One chunk's full axis vector.
static func audit_chunk(
	course_seed: int,
	chunk_index: int,
	samples: int,
	config: SwingConfig,
	stream: CourseStream = null,
) -> Dictionary:
	var distance_px := float(chunk_index) * CHUNK_WIDTH
	var pattern_distance := pattern_distance_for(chunk_index)
	var live := stream
	if live == null:
		live = stream_at(course_seed, chunk_index)
	else:
		live.update_for_position(distance_px + CHUNK_WIDTH * 0.5)
	var geometry := live.geometry()

	var pattern := CoursePatternCatalog.pattern_for_chunk(
		chunk_index, pattern_distance, course_seed
	)
	var pattern_id: StringName = pattern.get("id", &"")
	var width := corridor_width_across(
		geometry, distance_px, samples, config.player_collision_radius
	)
	var commitments := commitments_in(geometry, distance_px)
	var speed_cap := config.spider_speed_cap_at(distance_px)
	var pairs := classify_pairs(commitments, speed_cap)
	var lane := StringName(pattern.get("lane", &""))

	return {
		"chunk": chunk_index,
		"metres": distance_px / PIXELS_PER_METRE,
		"region": str(CourseRegionCatalog.region_for_distance(
			pattern_distance + CHUNK_WIDTH * 0.5).get("id", &"")),
		"pattern": str(pattern_id),
		"lane": str(lane),
		"width_class": "swing" if lane in SWING_LANES else "thread",
		"label_difficulty": int(pattern.get("difficulty", 0)),
		"is_recovery": pattern_id == RECOVERY_PATTERN_ID,
		# A warm-up chunk draws no pattern at all — pressure is zero there, so
		# there is nothing for the curve to select. It is neither a challenge nor
		# a scheduled recovery pocket, and counting it as either misreports the
		# density axis: the previous audit read km 0 as "100% challenge" on the
		# strength of chunks that carry no authored pattern.
		"is_warm_up": pattern_id == &"",
		# The curve, and the four axis terms it now drives. These are read by the
		# generator, so a change to any of them moves the course — which is what
		# `UNCHANGED_COURSE_DIGEST` is there to make visible.
		"pressure": CoursePressure.at(pattern_distance),
		"recovery_share": CourseAxisEnvelope.recovery_share(
			CoursePressure.at(pattern_distance)),
		"admission_floor": CourseAxisEnvelope.admission_floor(
			CoursePressure.at(pattern_distance)),
		"obstacle_scale": CourseAxisEnvelope.opening_scale(
			CoursePressure.at(pattern_distance),
			config.opening_obstacle_scale_floor,
		) * CourseAxisEnvelope.growth_scale(
			CoursePressure.at(pattern_distance)),
		"min_corridor_px": width["min_px"],
		"min_corridor_radii": width["min_radii"],
		"mean_corridor_px": width["mean_px"],
		# The first of the two width × duration terms nothing was watching. An
		# obstacle could be reshaped into a 400 px tube at an unchanged minimum
		# and every previous contract would have stayed green.
		"constriction_px": width["constriction_px"],
		"constriction_spider_widths": width["constriction_px"] / SPIDER_WIDTH_PX,
		"commitment_count": commitments.size(),
		# Seconds are AT THE SPEED CAP for this distance, which is what R13
		# specifies and is the worst case. The px figures are speed-independent
		# — divide by whatever speed you want to reason at.
		"min_opposite_gap_s": pairs["centre_s"],
		"min_opposite_edge_gap_s": pairs["edge_s"],
		"min_opposite_gap_px": pairs["centre_px"],
		"min_opposite_edge_gap_px": pairs["edge_px"],
		"simultaneous_gates": pairs["gates"],
		"speed_cap_px_s": speed_cap,
	}


## One hash over everything the generator builds across a fixed window.
##
## **This is the before/after instrument for the pressure curve.** Phase 2
## computes `CoursePressure` and deliberately gives it no consumer, so the course
## must come out unchanged — and a claim of "byte-identical" is worth exactly as
## much as the check standing behind it. Pinning the digest turns that claim into
## something a merge, a refactor or an accidental early wiring cannot quietly
## break.
##
## It reads the generator's own output — pattern identity plus the real polygons
## — and **never a derived pressure value**. Hashing pressure here would make the
## digest move the moment the curve landed, which is the one thing it exists to
## rule out.
##
## When Phase 3 deliberately moves selection onto the curve, this digest is
## *supposed* to change. Updating the pinned constant is then the visible record
## that behaviour moved, which is the point: no generator change can land looking
## like a no-op.
static func course_digest(
	seeds: Array,
	first_chunk: int,
	last_chunk: int,
) -> String:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	for course_seed: int in seeds:
		var stream := stream_at(int(course_seed), first_chunk)
		for chunk_index in range(first_chunk, last_chunk + 1):
			var distance_px := float(chunk_index) * CHUNK_WIDTH
			stream.update_for_position(distance_px + CHUNK_WIDTH * 0.5)
			var pattern := CoursePatternCatalog.pattern_for_chunk(
				chunk_index, pattern_distance_for(chunk_index), int(course_seed)
			)
			hashing.update(("seed %d chunk %d %s %s %d\n" % [
				int(course_seed),
				chunk_index,
				str(pattern.get("id", &"")),
				str(pattern.get("lane", &"")),
				int(pattern.get("difficulty", 0)),
			]).to_utf8_buffer())
			var geometry := stream.geometry()
			hashing.update(_polygon_digest_text(
				"boundary", geometry.boundary_surfaces).to_utf8_buffer())
			hashing.update(_polygon_digest_text(
				"obstacle", geometry.obstacles).to_utf8_buffer())
			hashing.update(_polygon_digest_text(
				"contact", geometry.obstacle_contact_polygons).to_utf8_buffer())
			hashing.update(_polygon_digest_text(
				"surface", geometry.surfaces).to_utf8_buffer())
	return hashing.finish().hex_encode()


## Stable text for one polygon list.
##
## Four decimals is far finer than any real change to authored geometry and
## coarse enough that last-bit float noise cannot flip the digest on its own.
##
## The leading `label count` line is always present, so an *empty* list still
## contributes — "no obstacles here" is a fact about the course and a digest that
## dropped it could not tell an emptied chunk from an absent one. It also keeps
## the buffer non-empty, which `HashingContext.update` requires.
static func _polygon_digest_text(
	label: String,
	polygons: Array[PackedVector2Array],
) -> String:
	var text := "%s %d\n" % [label, polygons.size()]
	for polygon: PackedVector2Array in polygons:
		text += label
		for point: Vector2 in polygon:
			text += " %.4f,%.4f" % [point.x, point.y]
		text += "\n"
	return text


## Largest INTERIOR free vertical span, sampled across one chunk — plus how far
## that chunk holds its own minimum.
##
## **Constriction length is the term nothing was watching.** A narrow gap costs
## width × length: a pinch crossed in 8 ms demands far less positional accuracy
## than a tube of the same width that must be threaded, which is the whole
## mechanism behind D-0056's two width classes. Measured as the longest run of
## consecutive samples within `NEAR_MINIMUM_TOLERANCE` of this chunk's minimum,
## reported in pixels so it is independent of the sample count.
##
## Resolution caveat, and it points the wrong way for a fairness floor: at the
## audit's default 24 px step this **overestimates** the minimum slightly (the
## 2 px reference run reads `hollow_lattice_*` at 240.8 px against 244.5). The
## length term inherits the same coarseness — it is quantised to the step, so a
## constriction shorter than one sample reads as one sample wide.
static func corridor_width_across(
	geometry: CourseGeometry,
	chunk_x: float,
	samples: int,
	player_radius: float,
) -> Dictionary:
	var count := maxi(samples, 1)
	var step := CHUNK_WIDTH / float(count)
	var gaps := PackedFloat32Array()
	var min_px := INF
	var total := 0.0
	var counted := 0

	for index in count:
		var x := chunk_x + step * (float(index) + 0.5)
		var gap := largest_interior_gap(geometry, x)
		gaps.append(gap)
		if gap < 0.0:
			continue
		min_px = minf(min_px, gap)
		total += gap
		counted += 1

	if counted == 0:
		return {
			"min_px": -1.0, "min_radii": -1.0, "mean_px": -1.0,
			"constriction_px": -1.0,
		}

	var threshold := min_px * (1.0 + NEAR_MINIMUM_TOLERANCE)
	var longest_run := 0
	var run := 0
	for gap: float in gaps:
		if gap >= 0.0 and gap <= threshold:
			run += 1
			longest_run = maxi(longest_run, run)
		else:
			run = 0

	var diameter := maxf(player_radius, 0.001) * 2.0
	return {
		"min_px": min_px,
		"min_radii": min_px / diameter,
		"mean_px": total / float(counted),
		"constriction_px": float(longest_run) * step,
	}


## The second width × duration term: how long a region holds near its own
## tightest corridor.
##
## D-0056 is written as a **distribution** precisely because a floor cannot see
## this. Ancient Forest and Silk Hollow differ by 8% at their minima and by 3×
## in how often they sit there and 2× in how long they sustain it — the
## frequency and duration diverge far more than the width does, and that is the
## difference between content the owner enjoys and content he calls a wall.
##
## Pure over a list of records so it can be contracted with literal inputs
## instead of a generator run, which is the only way to prove it computes what it
## claims rather than merely producing a plausible number.
static func region_width_distribution(records: Array) -> Dictionary:
	var by_region := {}
	for record: Dictionary in records:
		var radii := float(record.get("min_corridor_radii", -1.0))
		if radii < 0.0:
			continue
		var region := str(record.get("region", ""))
		if not by_region.has(region):
			by_region[region] = []
		(by_region[region] as Array).append(radii)

	var result := {}
	for region: String in by_region:
		var widths: Array = by_region[region]
		var sorted := widths.duplicate()
		sorted.sort()
		var minimum := float(sorted[0])
		var threshold := minimum * (1.0 + NEAR_MINIMUM_TOLERANCE)
		var near := 0
		var longest_run := 0
		var run := 0
		# Deliberately walks `widths` in course order, not `sorted` — the run
		# length is a fact about consecutive chunks and sorting destroys it.
		for value: float in widths:
			if value <= threshold:
				near += 1
				run += 1
				longest_run = maxi(longest_run, run)
			else:
				run = 0
		result[region] = {
			"chunks": widths.size(),
			"min_radii": minimum,
			"median_radii": float(sorted[sorted.size() / 2]),
			"share_near_min": float(near) / float(widths.size()),
			"longest_run_near_min": longest_run,
		}
	return result


## Merges every blocked y-span at `x` and returns the largest gap BETWEEN them.
##
## Returns -1.0 when fewer than two blockers exist, because then there is no
## interior at all and any number would be fiction. Gaps before the first
## blocker and after the last are the sky and the void — never returned.
static func largest_interior_gap(geometry: CourseGeometry, x: float) -> float:
	var blocked: Array[Vector2] = []

	for polygon: PackedVector2Array in geometry.boundary_surfaces:
		var span := span_at(polygon, x)
		if span.y > span.x:
			blocked.append(span)
	for polygon: PackedVector2Array in geometry.obstacle_contact_polygons:
		var span := span_at(polygon, x)
		if span.y > span.x:
			blocked.append(span)

	if blocked.size() < 2:
		return -1.0

	blocked.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)

	var merged: Array[Vector2] = [blocked[0]]
	for index in range(1, blocked.size()):
		var span := blocked[index]
		var last: Vector2 = merged[merged.size() - 1]
		if span.x <= last.y:
			merged[merged.size() - 1] = Vector2(last.x, maxf(last.y, span.y))
		else:
			merged.append(span)

	if merged.size() < 2:
		return -1.0

	var largest := 0.0
	for index in range(1, merged.size()):
		largest = maxf(largest, merged[index].x - merged[index - 1].y)
	return largest


## Vertical extent of `polygon` on the line X = x, as (min_y, max_y).
## Returns a zero-width span when the polygon does not cross that line.
static func span_at(polygon: PackedVector2Array, x: float) -> Vector2:
	var count := polygon.size()
	if count < 2:
		return Vector2.ZERO

	var min_y := INF
	var max_y := -INF
	for index in count:
		var a := polygon[index]
		var b := polygon[(index + 1) % count]
		if is_equal_approx(a.x, b.x):
			if is_equal_approx(a.x, x):
				min_y = minf(min_y, minf(a.y, b.y))
				max_y = maxf(max_y, maxf(a.y, b.y))
			continue
		var low := minf(a.x, b.x)
		var high := maxf(a.x, b.x)
		if x < low or x > high:
			continue
		var t := (x - a.x) / (b.x - a.x)
		var y := a.y + (b.y - a.y) * t
		min_y = minf(min_y, y)
		max_y = maxf(max_y, y)

	if min_y > max_y:
		return Vector2.ZERO
	return Vector2(min_y, max_y)


## Obstacle commitments whose centre falls inside this chunk, sorted by x.
## Side is read from the polygon's own span against the corridor midline —
## never from corridor width.
static func commitments_in(
	geometry: CourseGeometry,
	chunk_x: float,
) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var chunk_end := chunk_x + CHUNK_WIDTH

	for polygon: PackedVector2Array in geometry.obstacle_contact_polygons:
		if polygon.is_empty():
			continue
		var min_x := INF
		var max_x := -INF
		var min_y := INF
		var max_y := -INF
		for point: Vector2 in polygon:
			min_x = minf(min_x, point.x)
			max_x = maxf(max_x, point.x)
			min_y = minf(min_y, point.y)
			max_y = maxf(max_y, point.y)
		var centre_x := (min_x + max_x) * 0.5
		if centre_x < chunk_x or centre_x >= chunk_end:
			continue

		var side := &"centre"
		if max_y < CORRIDOR_MIDLINE_Y:
			side = &"high"
		elif min_y > CORRIDOR_MIDLINE_Y:
			side = &"low"

		found.append({
			"min_x": min_x, "max_x": max_x, "centre_x": centre_x, "side": side,
		})

	found.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return a["centre_x"] < b["centre_x"]
	)
	return found


## Separates the two things that look alike in the polygon list and are not.
##
##   * **Sequential opposite pair** — one obstacle cleared, then an opposite-side
##     obstacle *after* it in x. This is R13's timing quantity.
##   * **Simultaneous gate** — a ceiling and a floor obstacle sharing an x-range,
##     e.g. `rooted_gate`. The player threads one opening; it is a *width*
##     challenge and supplies no reaction time at all.
##
## Reading a gate as a sequential pair yields a 0.00 s spacing and would make
## R13 look violated everywhere. Overlap in x is the discriminator.
static func classify_pairs(
	commitments: Array[Dictionary],
	speed_cap: float,
) -> Dictionary:
	var empty := {
		"centre_s": -1.0, "edge_s": -1.0,
		"centre_px": -1.0, "edge_px": -1.0, "gates": 0,
	}
	if commitments.size() < 2 or speed_cap <= 0.0:
		return empty

	var min_centre := INF
	var min_edge := INF
	var gates := 0

	for index in range(1, commitments.size()):
		var previous: Dictionary = commitments[index - 1]
		var current: Dictionary = commitments[index]
		if previous["side"] == &"centre" or current["side"] == &"centre":
			continue
		if previous["side"] == current["side"]:
			continue
		if float(current["min_x"]) < float(previous["max_x"]):
			gates += 1
			continue
		min_centre = minf(
			min_centre,
			float(current["centre_x"]) - float(previous["centre_x"]),
		)
		min_edge = minf(
			min_edge,
			float(current["min_x"]) - float(previous["max_x"]),
		)

	return {
		"centre_s": -1.0 if is_inf(min_centre) else min_centre / speed_cap,
		"edge_s": -1.0 if is_inf(min_edge) else min_edge / speed_cap,
		"centre_px": -1.0 if is_inf(min_centre) else min_centre,
		"edge_px": -1.0 if is_inf(min_edge) else min_edge,
		"gates": gates,
	}

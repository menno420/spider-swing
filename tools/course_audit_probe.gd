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

## Vertical line used to say which side of the corridor an obstacle grew from.
## Obstacles whose span crosses it are `centre` and never form an opposite pair.
const CORRIDOR_MIDLINE_Y := (CourseStream.CEILING_Y + CourseStream.FLOOR_Y) * 0.5

## Total ceiling-to-floor extent. No interior gap may ever reach it — that is
## the invariant which catches the `y = 0` error if it is ever reintroduced.
const CORRIDOR_TOTAL_HEIGHT := CourseStream.FLOOR_Y - CourseStream.CEILING_Y


## Builds a stream positioned so `chunk_index` is never an edge chunk of the
## generated window. Edge chunks can be missing neighbour context.
static func stream_at(course_seed: int, chunk_index: int) -> CourseStream:
	var stream := CourseStream.new()
	stream.reset(10000.0, 0.94, 0.90, 1.12, [], true, 1.0, 1.0, 20000.0, course_seed)
	stream.update_for_position(float(chunk_index) * CHUNK_WIDTH + CHUNK_WIDTH * 0.5)
	return stream


## One chunk's full axis vector.
static func audit_chunk(
	course_seed: int,
	chunk_index: int,
	samples: int,
	config: SwingConfig,
	stream: CourseStream = null,
) -> Dictionary:
	var distance_px := float(chunk_index) * CHUNK_WIDTH
	var live := stream
	if live == null:
		live = stream_at(course_seed, chunk_index)
	else:
		live.update_for_position(distance_px + CHUNK_WIDTH * 0.5)
	var geometry := live.geometry()

	var pattern := CoursePatternCatalog.pattern_for_chunk(
		chunk_index, distance_px, course_seed
	)
	var pattern_id: StringName = pattern.get("id", &"")
	var width := corridor_width_across(
		geometry, distance_px, samples, config.player_collision_radius
	)
	var commitments := commitments_in(geometry, distance_px)
	var speed_cap := config.spider_speed_cap_at(distance_px)
	var pairs := classify_pairs(commitments, speed_cap)

	return {
		"chunk": chunk_index,
		"metres": distance_px / PIXELS_PER_METRE,
		"region": str(CourseRegionCatalog.region_for_distance(distance_px).get(
			"id", &"")),
		"pattern": str(pattern_id),
		"lane": str(pattern.get("lane", &"")),
		"label_difficulty": int(pattern.get("difficulty", 0)),
		"is_recovery": pattern_id == RECOVERY_PATTERN_ID,
		"min_corridor_px": width["min_px"],
		"min_corridor_radii": width["min_radii"],
		"mean_corridor_px": width["mean_px"],
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
				chunk_index, distance_px, int(course_seed)
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


## Largest INTERIOR free vertical span, sampled across one chunk.
static func corridor_width_across(
	geometry: CourseGeometry,
	chunk_x: float,
	samples: int,
	player_radius: float,
) -> Dictionary:
	var step := CHUNK_WIDTH / float(maxi(samples, 1))
	var min_px := INF
	var total := 0.0
	var counted := 0

	for index in maxi(samples, 1):
		var x := chunk_x + step * (float(index) + 0.5)
		var gap := largest_interior_gap(geometry, x)
		if gap < 0.0:
			continue
		min_px = minf(min_px, gap)
		total += gap
		counted += 1

	if counted == 0:
		return {"min_px": -1.0, "min_radii": -1.0, "mean_px": -1.0}

	var diameter := maxf(player_radius, 0.001) * 2.0
	return {
		"min_px": min_px,
		"min_radii": min_px / diameter,
		"mean_px": total / float(counted),
	}


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

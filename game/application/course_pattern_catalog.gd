extends RefCounted
class_name CoursePatternCatalog
## Curated, seeded challenge vocabulary.
##
## Selection varies only the order of prevalidated patterns. CourseStream
## remains the geometry owner and every selected pattern still resolves through
## the shared route plan; no individual lethal object is placed randomly.

const CONTROL_START_DISTANCE := 10000.0
const MASTERY_START_DISTANCE := 20000.0
const DEEP_FOREST_START_DISTANCE := 35000.0
const CHUNK_WIDTH := 960.0
const REPETITION_COOLDOWN_CHUNKS := 2
const RECOVERY_PATTERN := {
	"id": &"open_recovery",
	"lane": &"centre",
	"difficulty": 0,
}

const CONTROL_PATTERNS := [
	{"id": &"floor_vine", "lane": &"high", "difficulty": 1},
	{"id": &"canopy_pod", "lane": &"low", "difficulty": 1},
	{"id": &"thorn_ridge", "lane": &"high", "difficulty": 1},
	{"id": &"hanging_vine", "lane": &"low", "difficulty": 1},
	{"id": &"rooted_gate", "lane": &"centre", "difficulty": 2},
	{"id": &"fallen_stump", "lane": &"high", "difficulty": 2},
	{"id": &"ceiling_stump", "lane": &"low", "difficulty": 2},
	{"id": &"bramble_curve", "lane": &"high", "difficulty": 2},
]

const MASTERY_PATTERNS := [
	{"id": &"floor_vine", "lane": &"high", "difficulty": 2},
	{"id": &"canopy_pod", "lane": &"low", "difficulty": 2},
	{"id": &"high_low_weave", "lane": &"weave", "difficulty": 3},
	{"id": &"low_high_weave", "lane": &"weave", "difficulty": 3},
	{"id": &"silk_burr_high", "lane": &"high", "difficulty": 3},
	{"id": &"silk_burr_low", "lane": &"low", "difficulty": 3},
	{"id": &"staggered_s", "lane": &"centre", "difficulty": 3},
	{"id": &"rooted_gate", "lane": &"centre", "difficulty": 3},
	{"id": &"tall_vine", "lane": &"high", "difficulty": 3},
	{"id": &"long_pod", "lane": &"low", "difficulty": 3},
	{"id": &"alternating_thorns", "lane": &"centre", "difficulty": 3},
	{"id": &"fallen_stump", "lane": &"high", "difficulty": 2},
	{"id": &"ceiling_stump", "lane": &"low", "difficulty": 2},
	{"id": &"vine_curtain", "lane": &"low", "difficulty": 3},
	{"id": &"bramble_steps", "lane": &"high", "difficulty": 3},
]

const DEEP_FOREST_PATTERNS := [
	{"id": &"floor_vine", "lane": &"high", "difficulty": 3},
	{"id": &"canopy_pod", "lane": &"low", "difficulty": 3},
	{"id": &"high_low_weave", "lane": &"weave", "difficulty": 4},
	{"id": &"low_high_weave", "lane": &"weave", "difficulty": 4},
	{"id": &"silk_burr_high", "lane": &"high", "difficulty": 4},
	{"id": &"silk_burr_low", "lane": &"low", "difficulty": 4},
	{"id": &"staggered_s", "lane": &"centre", "difficulty": 4},
	{"id": &"rooted_gate", "lane": &"centre", "difficulty": 4},
	{"id": &"tall_vine", "lane": &"high", "difficulty": 4},
	{"id": &"long_pod", "lane": &"low", "difficulty": 4},
	{"id": &"alternating_thorns", "lane": &"centre", "difficulty": 4},
	{"id": &"fallen_stump", "lane": &"high", "difficulty": 3},
	{"id": &"ceiling_stump", "lane": &"low", "difficulty": 3},
	{"id": &"vine_curtain", "lane": &"low", "difficulty": 4},
	{"id": &"bramble_steps", "lane": &"high", "difficulty": 4},
	{"id": &"stump_and_vine", "lane": &"centre", "difficulty": 4},
	{"id": &"recovery_pair", "lane": &"high", "difficulty": 4},
]

## Region two emphasizes fast vertical reading through a vocabulary it owns.
## None of these ids are inherited from Ancient Forest: the device-reviewed
## material swap was not enough while the underlying obstacle roles remained
## stumps, pods, curtains, and ordinary alternating rail growth.
const BRAMBLE_CANOPY_PATTERNS := [
	{"id": &"canopy_hook_high", "lane": &"high", "difficulty": 4},
	{"id": &"canopy_hook_low", "lane": &"low", "difficulty": 4},
	{"id": &"canopy_leaf_high", "lane": &"high", "difficulty": 4},
	{"id": &"canopy_leaf_low", "lane": &"low", "difficulty": 4},
	{"id": &"canopy_hook_high_low", "lane": &"weave", "difficulty": 4},
	{"id": &"canopy_hook_low_high", "lane": &"weave", "difficulty": 4},
	{"id": &"canopy_shutter_high_low", "lane": &"weave", "difficulty": 4},
	{"id": &"canopy_shutter_low_high", "lane": &"weave", "difficulty": 4},
]

## Region three emphasizes exact lines around suspended hazards and rail-grown
## openings. A fixed recovery pocket follows every short precision set.
const SILK_HOLLOW_PATTERNS := [
	{"id": &"silk_burr_high", "lane": &"high", "difficulty": 4},
	{"id": &"silk_burr_low", "lane": &"low", "difficulty": 4},
	{"id": &"rooted_gate", "lane": &"centre", "difficulty": 4},
	{"id": &"staggered_s", "lane": &"centre", "difficulty": 4},
	{"id": &"stump_and_vine", "lane": &"centre", "difficulty": 4},
	{"id": &"recovery_pair", "lane": &"high", "difficulty": 4},
	{"id": &"alternating_thorns", "lane": &"centre", "difficulty": 4},
	{"id": &"high_low_weave", "lane": &"weave", "difficulty": 4},
	{"id": &"low_high_weave", "lane": &"weave", "difficulty": 4},
]


static func pattern_for_chunk(
	chunk_index: int,
	distance_at_chunk: float,
	course_seed: int = 0,
) -> Dictionary:
	if _patterns_for_distance(distance_at_chunk).is_empty():
		return {}

	# Resolve from the latest authored recovery pocket. This keeps selection
	# stateless across CourseStream rebuilds while comparing against the actual
	# final previous choices, including authored weave/tight-gap overrides.
	# Ancient Forest has no recovery cadence, but contains fewer than 53 chunks.
	var history_start := chunk_index
	while history_start > 0:
		var history_distance := maxf(
			0.0,
			distance_at_chunk
				- float(chunk_index - history_start) * CHUNK_WIDTH,
		)
		var history_pattern := _base_pattern_for_chunk(
			history_start,
			history_distance,
			course_seed,
		)
		if history_pattern.is_empty():
			history_start += 1
			break
		if StringName(history_pattern["id"]) == \
				StringName(RECOVERY_PATTERN["id"]):
			break
		history_start -= 1

	var recent: Array[StringName] = []
	var resolved: Dictionary = {}
	for current_chunk in range(history_start, chunk_index + 1):
		var current_distance := maxf(
			0.0,
			distance_at_chunk
				- float(chunk_index - current_chunk) * CHUNK_WIDTH,
		)
		var selected := _base_pattern_for_chunk(
			current_chunk,
			current_distance,
			course_seed,
		)
		if selected.is_empty():
			continue
		var selected_id := StringName(selected["id"])
		if selected_id != StringName(RECOVERY_PATTERN["id"]) and \
				selected_id != &"tight_rail" and recent.has(selected_id):
			var pool := _patterns_for_distance(current_distance)
			var start_index := _index_for_id(pool, selected_id)
			for offset in range(1, pool.size()):
				var candidate: Dictionary = pool[
					posmod(start_index + offset, pool.size())]
				if not recent.has(StringName(candidate["id"])):
					selected = candidate.duplicate(true)
					selected_id = StringName(selected["id"])
					break
		recent.append(selected_id)
		while recent.size() > REPETITION_COOLDOWN_CHUNKS:
			recent.pop_front()
		resolved = selected
	return resolved


static func _base_pattern_for_chunk(
	chunk_index: int,
	distance_at_chunk: float,
	course_seed: int,
) -> Dictionary:
	var pool := _patterns_for_distance(distance_at_chunk)
	if pool.is_empty():
		return {}
	var region := CourseRegionCatalog.region_for_distance(
		distance_at_chunk + CHUNK_WIDTH * 0.5)
	var region_id := StringName(region["id"])
	var local_chunk := maxi(
		0,
		floori((
			distance_at_chunk + CHUNK_WIDTH * 0.5
				- float(region["start_distance"])
		) / CHUNK_WIDTH),
	)
	if bool(region["checkpoint"]) and local_chunk == 0:
		return RECOVERY_PATTERN.duplicate(true)
	var recovery_interval := 6 \
		if region_id == CourseRegionCatalog.BRAMBLE_CANOPY else 5
	if region_id != CourseRegionCatalog.ANCIENT_FOREST and \
			posmod(local_chunk, recovery_interval) == recovery_interval - 1:
		return RECOVERY_PATTERN.duplicate(true)
	if (
		region_id == CourseRegionCatalog.ANCIENT_FOREST
		and distance_at_chunk >= MASTERY_START_DISTANCE
		and posmod(chunk_index, 8) == 7
	) or (
		region_id == CourseRegionCatalog.SILK_HOLLOW
		and posmod(local_chunk, 7) == 4
	):
		return {
			"id": &"tight_rail",
			"lane": &"tight",
			"difficulty": 4,
		}
	if region_id == CourseRegionCatalog.BRAMBLE_CANOPY and \
			posmod(local_chunk, 4) == 2:
		return {
			"id": (
				&"canopy_shutter_high_low"
					if posmod(local_chunk + course_seed, 2) == 0
					else &"canopy_shutter_low_high"
			),
			"lane": &"weave",
			"difficulty": 4,
		}
	return _seeded_pattern(
		pool,
		local_chunk,
		course_seed,
		CourseRegionCatalog.region_index_for_id(region_id),
	)


static func pattern_id_for_chunk(
	chunk_index: int,
	distance_at_chunk: float,
	course_seed: int = 0,
) -> StringName:
	return StringName(pattern_for_chunk(
		chunk_index,
		distance_at_chunk,
		course_seed,
	).get("id", &""))


static func _patterns_for_distance(distance_at_chunk: float) -> Array:
	var region_id := StringName(CourseRegionCatalog.region_for_distance(
		distance_at_chunk + CHUNK_WIDTH * 0.5,
	)["id"])
	if region_id == CourseRegionCatalog.BRAMBLE_CANOPY:
		return BRAMBLE_CANOPY_PATTERNS
	if region_id == CourseRegionCatalog.SILK_HOLLOW:
		return SILK_HOLLOW_PATTERNS
	if distance_at_chunk < CONTROL_START_DISTANCE:
		return []
	if distance_at_chunk < MASTERY_START_DISTANCE:
		return CONTROL_PATTERNS
	if distance_at_chunk < DEEP_FOREST_START_DISTANCE:
		return MASTERY_PATTERNS
	return DEEP_FOREST_PATTERNS


static func _seeded_pattern(
	pool: Array,
	local_chunk: int,
	course_seed: int,
	region_index: int,
) -> Dictionary:
	var size := pool.size()
	var offset := posmod(course_seed * 31 + region_index * 17, size)
	var stride := _coprime_stride(size, course_seed + region_index * 11)
	var index := posmod(offset + local_chunk * stride, size)
	return (pool[index] as Dictionary).duplicate(true)


static func _coprime_stride(size: int, seed_value: int) -> int:
	if size <= 2:
		return 1
	var candidate := 2 + posmod(seed_value, size - 1)
	for _attempt in range(size):
		if _greatest_common_divisor(candidate, size) == 1:
			return candidate
		candidate = 2 + posmod(candidate - 1, size - 1)
	return 1


static func _greatest_common_divisor(first: int, second: int) -> int:
	var a := absi(first)
	var b := absi(second)
	while b != 0:
		var remainder := a % b
		a = b
		b = remainder
	return maxi(1, a)


static func _index_for_id(pool: Array, pattern_id: StringName) -> int:
	for index in range(pool.size()):
		if StringName(pool[index]["id"]) == pattern_id:
			return index
	return 0

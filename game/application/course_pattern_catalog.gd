extends RefCounted
class_name CoursePatternCatalog
## Curated deterministic challenge vocabulary.
##
## Pattern selection is distance-banded and never places individual hazards
## randomly. CourseStream remains the geometry owner and validates every
## pattern through the shared route plan.

const CONTROL_START_DISTANCE := 10000.0
const MASTERY_START_DISTANCE := 20000.0
const DEEP_FOREST_START_DISTANCE := 35000.0
const REPETITION_COOLDOWN_CHUNKS := 2

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


static func pattern_for_chunk(
	chunk_index: int,
	distance_at_chunk: float,
) -> Dictionary:
	# Preserve one predictable late-course squeeze every eight chunks. Keeping
	# it on a fixed cadence makes the challenge learnable and prevents the
	# selector from clustering narrow corridors next to other hard patterns.
	if (
		distance_at_chunk >= MASTERY_START_DISTANCE
		and posmod(chunk_index, 8) == 7
	):
		return {
			"id": &"tight_rail",
			"lane": &"tight",
			"difficulty": 3 if distance_at_chunk < DEEP_FOREST_START_DISTANCE else 4,
		}
	var patterns := _patterns_for_distance(distance_at_chunk)
	if patterns.is_empty():
		return {}
	var band_seed := _band_index(distance_at_chunk) * 3
	var preferred := posmod(chunk_index * 7 + band_seed, patterns.size())
	var recent := _recent_raw_ids(chunk_index, distance_at_chunk)
	for offset in range(patterns.size()):
		var candidate: Dictionary = patterns[posmod(
			preferred + offset,
			patterns.size(),
		)]
		if not recent.has(StringName(candidate["id"])):
			return candidate.duplicate(true)
	return (patterns[preferred] as Dictionary).duplicate(true)


static func pattern_id_for_chunk(
	chunk_index: int,
	distance_at_chunk: float,
) -> StringName:
	return StringName(pattern_for_chunk(
		chunk_index,
		distance_at_chunk,
	).get("id", &""))


static func _patterns_for_distance(distance_at_chunk: float) -> Array:
	if distance_at_chunk < CONTROL_START_DISTANCE:
		return []
	if distance_at_chunk < MASTERY_START_DISTANCE:
		return CONTROL_PATTERNS
	if distance_at_chunk < DEEP_FOREST_START_DISTANCE:
		return MASTERY_PATTERNS
	return DEEP_FOREST_PATTERNS


static func _band_index(distance_at_chunk: float) -> int:
	if distance_at_chunk < MASTERY_START_DISTANCE:
		return 0
	if distance_at_chunk < DEEP_FOREST_START_DISTANCE:
		return 1
	return 2


static func _recent_raw_ids(
	chunk_index: int,
	distance_at_chunk: float,
) -> Array[StringName]:
	var recent: Array[StringName] = []
	for offset in range(1, REPETITION_COOLDOWN_CHUNKS + 1):
		var previous_chunk := chunk_index - offset
		if previous_chunk < 0:
			continue
		var previous_distance := maxf(
			0.0,
			distance_at_chunk - float(offset) * 960.0,
		)
		var patterns := _patterns_for_distance(previous_distance)
		if patterns.is_empty():
			continue
		var band_seed := _band_index(previous_distance) * 3
		var preferred := posmod(
			previous_chunk * 7 + band_seed,
			patterns.size(),
		)
		recent.append(StringName(
			(patterns[preferred] as Dictionary)["id"],
		))
	return recent

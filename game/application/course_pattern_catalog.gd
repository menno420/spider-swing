extends RefCounted
class_name CoursePatternCatalog
## Curated, seeded challenge vocabulary.
##
## Selection varies only the order of prevalidated patterns. CourseStream
## remains the geometry owner and every selected pattern still resolves through
## the shared route plan; no individual lethal object is placed randomly.
##
## **[D-0054] R1 lives here.** How *hard* a chunk is comes from
## `CoursePressure.at(distance)` by way of `CourseAxisEnvelope`, composed with
## the pure mode transforms in `CourseDifficultyProfile`, and from nothing else.
## Distance still decides which *region* you are in — that is R4's "regions
## choose character, never amount" — and the region still owns its vocabulary,
## its cadence quirks and its authored overrides. What it no longer owns is the
## amount.
##
## Three distance laws were removed to get there, all of them measured as F2's
## "the game's entire distance-driven progression belongs to Ancient Forest":
##
##   * the control → mastery → deep-forest pool ladder at 1 km / 2 km / 3.5 km,
##     now one pool filtered by `CourseAxisEnvelope.admission_floor`;
##   * `MASTERY_START_DISTANCE` gating the tight-rail corridor, now
##     `tight_lane_admitted`;
##   * `CONTROL_START_DISTANCE` gating whether any pattern exists at all, now
##     "pressure is zero", which is the warm-up and nothing else.
##
## The pools below are unchanged authored content. Only who reads them moved.
## Difficulty mode is a declared deterministic input beside seed, chunk and
## pressure; Standard is the exact pre-profile identity path.

## Retained as the authored provenance of the three Ancient Forest rungs — the
## distances at which the pool ladder used to step. **Nothing reads them for
## selection any more**; `ANCIENT_FOREST_PATTERNS` is the ladder now and
## `CourseAxisEnvelope` decides which rungs are legal.
const CONTROL_START_DISTANCE := 10000.0
const MASTERY_START_DISTANCE := 20000.0
const DEEP_FOREST_START_DISTANCE := 35000.0
const CHUNK_WIDTH := 960.0
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
##
## **These carry `difficulty` 3 against the pairs' 4, which is a correction, not
## a nerf.** F5 measured Bramble as binary — 50% empty chunks and 50% identical
## difficulty-4 chunks — and named the missing rung as the reason it cannot ramp.
## §6.1's third lever says where the rung is: *"the pool is already split 4
## singles / 4 pairs, and the pairs are the commitment"*. Now that the label has
## a consumer (R10, via `CourseAxisEnvelope.admission_floor`) that distinction is
## load-bearing rather than decorative, so it has to be honest about the two
## rungs it actually contains.
const BRAMBLE_CANOPY_SINGLE_PATTERNS := [
	{"id": &"canopy_hook_high", "lane": &"high", "difficulty": 3},
	{"id": &"canopy_hook_low", "lane": &"low", "difficulty": 3},
	{"id": &"canopy_leaf_high", "lane": &"high", "difficulty": 3},
	{"id": &"canopy_leaf_low", "lane": &"low", "difficulty": 3},
]

const BRAMBLE_CANOPY_PAIR_PATTERNS := [
	{"id": &"canopy_hook_high_low", "lane": &"weave", "difficulty": 4},
	{"id": &"canopy_hook_low_high", "lane": &"weave", "difficulty": 4},
	{"id": &"canopy_shutter_high_low", "lane": &"weave", "difficulty": 4},
	{"id": &"canopy_shutter_low_high", "lane": &"weave", "difficulty": 4},
]

const BRAMBLE_CANOPY_PATTERNS := \
	BRAMBLE_CANOPY_SINGLE_PATTERNS + BRAMBLE_CANOPY_PAIR_PATTERNS

## Ancient Forest's three authored rungs as the one ladder the curve draws from.
##
## Built once rather than declared, so the rungs keep exactly one source. Order
## is control → mastery → deep so the array reads as the ramp it encodes, and
## duplicate `(id, difficulty)` pairs are dropped — `fallen_stump@2` and
## `ceiling_stump@2` appear in both the control and mastery arrays, and two
## identical rungs would bias selection toward those ids for no authored reason.
##
## This is F5's "Ancient Forest is the only early region that can ramp **because
## it is the only early region whose pools contain more than one difficulty**",
## turned from an accident of three distance-keyed arrays into a property the
## selector can read at any pressure.
static var _ancient_forest_ladder: Array = []


static func ancient_forest_patterns() -> Array:
	if _ancient_forest_ladder.is_empty():
		var ladder: Array = []
		var seen := {}
		for pool: Array in [
			CONTROL_PATTERNS, MASTERY_PATTERNS, DEEP_FOREST_PATTERNS,
		]:
			for pattern: Dictionary in pool:
				var key := "%s@%d" % [
					str(pattern["id"]), int(pattern["difficulty"])]
				if seen.has(key):
					continue
				seen[key] = true
				ladder.append(pattern)
		_ancient_forest_ladder = ladder
	return _ancient_forest_ladder

## Region three emphasizes exact lines around suspended hazards and rail-grown
## openings. A fixed recovery pocket follows every short precision set.
const SILK_HOLLOW_PATTERNS := [
	{"id": &"hollow_cocoon_chute", "lane": &"low", "difficulty": 4},
	{"id": &"hollow_spindle_gate", "lane": &"centre", "difficulty": 4},
	{"id": &"hollow_thread_eye", "lane": &"centre", "difficulty": 4},
	{"id": &"hollow_lattice_high", "lane": &"high", "difficulty": 4},
	{"id": &"hollow_lattice_low", "lane": &"low", "difficulty": 4},
	{"id": &"hollow_droplet_needles", "lane": &"high", "difficulty": 4},
	{"id": &"hollow_orb_cluster", "lane": &"low", "difficulty": 4},
	{"id": &"hollow_twin_sacs", "lane": &"centre", "difficulty": 4},
	{"id": &"hollow_suspended_bridge", "lane": &"high", "difficulty": 4},
]

## Ruined Arboretum opens with seven static/drip silhouettes before any lethal
## part moves. Its full pool adds phase gates without shrinking the visible
## cycle below the CI-enforced diversity floor.
const ARBORETUM_OPENING_PATTERNS := [
	{"id": &"arboretum_beam_high", "lane": &"high", "difficulty": 4},
	{"id": &"arboretum_beam_low", "lane": &"low", "difficulty": 4},
	{"id": &"arboretum_drip_arch_high", "lane": &"high", "difficulty": 4},
	{"id": &"arboretum_drip_arch_low", "lane": &"low", "difficulty": 4},
	{"id": &"arboretum_frame_rest_high", "lane": &"high", "difficulty": 4},
	{"id": &"arboretum_frame_rest_low", "lane": &"low", "difficulty": 4},
	{"id": &"arboretum_beam_corridor", "lane": &"centre", "difficulty": 4},
]

const RUINED_ARBORETUM_PATTERNS := [
	{"id": &"arboretum_pane_high", "lane": &"high", "difficulty": 5},
	{"id": &"arboretum_pane_low", "lane": &"low", "difficulty": 5},
	{"id": &"arboretum_rotor_high", "lane": &"high", "difficulty": 5},
	{"id": &"arboretum_rotor_low", "lane": &"low", "difficulty": 5},
	{"id": &"arboretum_collapsed_high", "lane": &"high", "difficulty": 4},
	{"id": &"arboretum_collapsed_low", "lane": &"low", "difficulty": 4},
	{"id": &"arboretum_pane_pair", "lane": &"centre", "difficulty": 5},
	{"id": &"arboretum_rotor_pane", "lane": &"centre", "difficulty": 5},
	{"id": &"arboretum_timed_gate", "lane": &"centre", "difficulty": 5},
	{"id": &"arboretum_broken_span", "lane": &"high", "difficulty": 4},
	{"id": &"arboretum_drip_rotor", "lane": &"low", "difficulty": 5},
]

const STORM_RIDGE_PATTERNS := [
	{"id": &"ridge_spire_high", "lane": &"high", "difficulty": 5},
	{"id": &"ridge_spire_low", "lane": &"low", "difficulty": 5},
	{"id": &"ridge_scree_high", "lane": &"high", "difficulty": 5},
	{"id": &"ridge_wind_tree_high", "lane": &"high", "difficulty": 5},
	{"id": &"ridge_wind_tree_low", "lane": &"low", "difficulty": 5},
	{"id": &"ridge_gust_arch", "lane": &"centre", "difficulty": 5},
	{"id": &"ridge_split_spires", "lane": &"centre", "difficulty": 5},
	{"id": &"ridge_lightning_high", "lane": &"high", "difficulty": 6},
	{"id": &"ridge_lightning_low", "lane": &"low", "difficulty": 6},
	{"id": &"ridge_scree_chute", "lane": &"high", "difficulty": 5},
	{"id": &"ridge_open_gust", "lane": &"centre", "difficulty": 4},
]

const WEB_CITY_PATTERNS := [
	{"id": &"city_highway_high", "lane": &"high", "difficulty": 4},
	{"id": &"city_highway_low", "lane": &"low", "difficulty": 4},
	{"id": &"city_highway_diagonal", "lane": &"centre", "difficulty": 4},
	{"id": &"city_sticky_high", "lane": &"high", "difficulty": 5},
	{"id": &"city_sticky_low", "lane": &"low", "difficulty": 5},
	{"id": &"city_egg_arch", "lane": &"centre", "difficulty": 5},
	{"id": &"city_resident_high", "lane": &"high", "difficulty": 6},
	{"id": &"city_resident_low", "lane": &"low", "difficulty": 6},
	{"id": &"city_torn_high", "lane": &"high", "difficulty": 5},
	{"id": &"city_torn_low", "lane": &"low", "difficulty": 5},
	{"id": &"city_crossroads", "lane": &"centre", "difficulty": 5},
]

const ASHEN_HOLLOW_PATTERNS := [
	{"id": &"ashen_sound_char_high", "lane": &"high", "difficulty": 5},
	{"id": &"ashen_sound_char_low", "lane": &"low", "difficulty": 5},
	{"id": &"ashen_rotten_high", "lane": &"high", "difficulty": 6},
	{"id": &"ashen_rotten_low", "lane": &"low", "difficulty": 6},
	{"id": &"ashen_ember_high", "lane": &"high", "difficulty": 6},
	{"id": &"ashen_ember_low", "lane": &"low", "difficulty": 6},
	{"id": &"ashen_collapsing_high", "lane": &"high", "difficulty": 6},
	{"id": &"ashen_collapsing_low", "lane": &"low", "difficulty": 6},
	{"id": &"ashen_bone_gate", "lane": &"centre", "difficulty": 5},
	{"id": &"ashen_char_pair", "lane": &"centre", "difficulty": 5},
	{"id": &"ashen_ember_corridor", "lane": &"centre", "difficulty": 6},
]

const DEEP_MIST_PATTERNS := [
	{"id": &"mist_echo_spire_high", "lane": &"high", "difficulty": 6},
	{"id": &"mist_echo_spire_low", "lane": &"low", "difficulty": 6},
	{"id": &"mist_lone_beam", "lane": &"high", "difficulty": 6},
	{"id": &"mist_scree_shelf", "lane": &"high", "difficulty": 6},
	{"id": &"mist_cocoon", "lane": &"low", "difficulty": 6},
	{"id": &"mist_standing_char", "lane": &"low", "difficulty": 6},
	{"id": &"mist_root_gap", "lane": &"centre", "difficulty": 6},
	{"id": &"mist_high_gap", "lane": &"high", "difficulty": 6},
	{"id": &"mist_low_gap", "lane": &"low", "difficulty": 6},
]


static func pattern_for_chunk(
	chunk_index: int,
	distance_at_chunk: float,
	course_seed: int = 0,
	difficulty_mode: StringName = DifficultyCatalog.MODE_STANDARD,
) -> Dictionary:
	if _region_pool_for(distance_at_chunk).is_empty():
		return {}

	# Resolve from the latest authored recovery pocket. This keeps selection
	# stateless across CourseStream rebuilds while comparing against the actual
	# final previous choices, including authored weave/tight-gap overrides.
	# Every region now carries a recovery cadence (R7), so the walk back is
	# bounded by `CourseAxisEnvelope.max_consecutive_challenge` rather than by a
	# region's chunk count.
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
			difficulty_mode,
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
			difficulty_mode,
		)
		if selected.is_empty():
			continue
		var selected_id := StringName(selected["id"])
		if selected_id != StringName(RECOVERY_PATTERN["id"]) and \
				selected_id != &"tight_rail" and recent.has(selected_id):
			var pool := _drawable_pool_for(
				current_chunk, current_distance, difficulty_mode)
			var start_index := _index_for_id(pool, selected_id)
			for offset in range(1, pool.size()):
				var candidate: Dictionary = pool[
					posmod(start_index + offset, pool.size())]
				if not recent.has(StringName(candidate["id"])):
					selected = candidate.duplicate(true)
					selected_id = StringName(selected["id"])
					break
		recent.append(selected_id)
		while recent.size() > CourseDifficultyProfile.repetition_cooldown_chunks(
			difficulty_mode):
			recent.pop_front()
		resolved = selected
	return resolved


static func _base_pattern_for_chunk(
	chunk_index: int,
	distance_at_chunk: float,
	course_seed: int,
	difficulty_mode: StringName,
) -> Dictionary:
	if _region_pool_for(distance_at_chunk).is_empty():
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
	if bool(region.get("checkpoint", false) or region.get("safe_entry", false)) \
			and local_chunk == 0:
		return RECOVERY_PATTERN.duplicate(true)
	# The paired rotor/pane lesson, and the static recovery that must follow it.
	# Both are authored overrides and both outrank the cadence: the combination
	# used to sit one slot before the region's own every-fifth-chunk rhythm, and
	# a curve-driven cadence has no reason to land there. Stating the intent
	# beats leaving it to coincide — under the new cadence the combination slot
	# would otherwise be swallowed by a recovery chunk and never appear.
	if _is_arboretum_combination(chunk_index, distance_at_chunk):
		return RUINED_ARBORETUM_PATTERNS[7].duplicate(true)
	if _is_arboretum_combination(chunk_index - 1, distance_at_chunk - CHUNK_WIDTH):
		return RECOVERY_PATTERN.duplicate(true)
	var pressure := CoursePressure.at(distance_at_chunk)
	# R7, and it now applies to every region including Ancient Forest — which
	# F3 measured as the one region with no recovery cadence at all, while its
	# own catalogue entry declares a "wide recovery rhythm". One curve, one rule,
	# and the per-region constants that produced 2% / 50% / 21% are gone.
	if CourseDifficultyProfile.is_recovery_chunk(
		difficulty_mode,
		chunk_index,
		pressure,
		CoursePressure.at(distance_at_chunk - CHUNK_WIDTH),
	):
		# A region entry is itself an opening (R12's gate). Firing the cadence
		# one chunk earlier would put two open chunks side by side, which is a
		# gap rather than a pocket — and the shipped no-adjacent-repeat contract
		# reads it, correctly, as `open_recovery` repeating.
		if _is_region_entry(distance_at_chunk + CHUNK_WIDTH):
			return _seeded_pattern(
				_drawable_pool_for(
					chunk_index, distance_at_chunk, difficulty_mode),
				local_chunk,
				course_seed,
				CourseRegionCatalog.region_index_for_id(region_id),
				difficulty_mode,
				chunk_index,
			)
		return RECOVERY_PATTERN.duplicate(true)
	# The authored tight-rail corridor. **Slot 5 of 8, not 7 of 8, and the
	# difference is load-bearing:** `chunk % 8 == 7` implies `chunk % 4 == 3`,
	# which is exactly where the cadence puts its opening at the interval Ancient
	# Forest runs. Every tight rail therefore landed on a scheduled recovery
	# chunk — either the corridor vanished from the first 15 km, or it ate the
	# region's only opening for ten chunks. `chunk % 8 == 5` is coprime with both
	# intervals Ancient Forest ever uses, so the cadence keeps priority and the
	# corridor still appears.
	if region_id == CourseRegionCatalog.ANCIENT_FOREST and \
			CourseAxisEnvelope.tight_lane_admitted(pressure) and \
			posmod(chunk_index, 8) == 5:
		return {
			"id": &"tight_rail",
			"lane": &"tight",
			"difficulty": 4,
		}
	if region_id == CourseRegionCatalog.SILK_HOLLOW and \
			posmod(local_chunk, 7) == 4:
		return SILK_HOLLOW_PATTERNS[2].duplicate(true)
	var pool := _drawable_pool_for(
		chunk_index, distance_at_chunk, difficulty_mode)
	if pool.is_empty():
		return {}
	return _seeded_pattern(
		pool,
		local_chunk,
		course_seed,
		CourseRegionCatalog.region_index_for_id(region_id),
		difficulty_mode,
		chunk_index,
	)


static func pattern_id_for_chunk(
	chunk_index: int,
	distance_at_chunk: float,
	course_seed: int = 0,
	difficulty_mode: StringName = DifficultyCatalog.MODE_STANDARD,
) -> StringName:
	return StringName(pattern_for_chunk(
		chunk_index,
		distance_at_chunk,
		course_seed,
		difficulty_mode,
	).get("id", &""))


## The region's whole authored vocabulary, before the curve filters it.
##
## Empty means one thing only: **pressure is zero, so this is the warm-up.** The
## old `CONTROL_START_DISTANCE` test said the same thing in distance terms and
## said it for Ancient Forest alone; saying it in pressure terms makes it true
## for whichever region holds the front slot, which is exactly what the owner
## asked for when he said the warm-up *"moves with the front slot"*.
static func _region_pool_for(distance_at_chunk: float) -> Array:
	if CoursePressure.at(distance_at_chunk) <= 0.0:
		return []
	var region_id := StringName(CourseRegionCatalog.region_for_distance(
		distance_at_chunk + CHUNK_WIDTH * 0.5,
	)["id"])
	if region_id == CourseRegionCatalog.BRAMBLE_CANOPY:
		return BRAMBLE_CANOPY_PATTERNS
	if region_id == CourseRegionCatalog.SILK_HOLLOW:
		return SILK_HOLLOW_PATTERNS
	if region_id == CourseRegionCatalog.RUINED_ARBORETUM:
		var region_start := float(CourseRegionCatalog.region_for_id(
			CourseRegionCatalog.RUINED_ARBORETUM)["start_distance"])
		return ARBORETUM_OPENING_PATTERNS \
			if distance_at_chunk < region_start + 15000.0 \
			else RUINED_ARBORETUM_PATTERNS
	if region_id == CourseRegionCatalog.STORM_RIDGE:
		return STORM_RIDGE_PATTERNS
	if region_id == CourseRegionCatalog.WEB_CITY:
		return WEB_CITY_PATTERNS
	if region_id == CourseRegionCatalog.ASHEN_HOLLOW:
		return ASHEN_HOLLOW_PATTERNS
	if region_id == CourseRegionCatalog.DEEP_MIST:
		return DEEP_MIST_PATTERNS
	return ancient_forest_patterns()


## Instrument-facing count of the authored vocabulary at this distance. The
## audit uses it to report the profile's bounded legal-continuation count; it
## does not expose or mutate selection state.
static func authored_pool_size_for_distance(distance_at_chunk: float) -> int:
	return _region_pool_for(distance_at_chunk).size()


## What may actually be drawn into this chunk: the region's vocabulary, filtered
## by the curve. **This is R1's whole surface.**
##
## Two filters, both from `CourseAxisEnvelope` and neither reading distance:
##
##   1. **R13's bounded spread** — the easiest rungs drop out as pressure rises.
##      Ancient Forest is the only pool in the scoped range with rungs to drop,
##      which is F5 restated; every other pool passes through untouched and is
##      shaped by cadence and size instead.
##   2. **Commitment isolation.** A Bramble pair is admitted only once pressure
##      has passed `MULTI_OBSTACLE_PRESSURE` *and* the preceding chunk is open.
##      The first half is §6.1's "singles before pairs"; the second preserves the
##      real fix D-0040 shipped — *"a pair owns one readable high↔low commitment"*
##      — while letting the open chunks either side of it be filled, which C3
##      established they may be, since the geometry fix carries Bramble on its
##      own and the 50% cadence was guarding a failure two other things prevent.
static func _drawable_pool_for(
	chunk_index: int,
	distance_at_chunk: float,
	difficulty_mode: StringName,
) -> Array:
	var pool := _region_pool_for(distance_at_chunk)
	if pool.is_empty():
		return []
	var pressure := CoursePressure.at(distance_at_chunk)
	var region_id := StringName(CourseRegionCatalog.region_for_distance(
		distance_at_chunk + CHUNK_WIDTH * 0.5,
	)["id"])
	if region_id == CourseRegionCatalog.BRAMBLE_CANOPY and not (
		CourseDifficultyProfile.multi_obstacle_admitted(
			difficulty_mode, pressure)
			and _chunk_is_open(
				chunk_index - 1,
				distance_at_chunk - CHUNK_WIDTH,
				difficulty_mode,
			)
	):
		pool = BRAMBLE_CANOPY_SINGLE_PATTERNS
	return CourseAxisEnvelope.admitted_patterns(
		pool,
		CourseDifficultyProfile.admission_pressure(
			difficulty_mode, pressure),
	)


## Whether the chunk containing `distance_at_chunk` is a region's first, i.e. the
## slot R12's section gate owns.
static func _is_region_entry(distance_at_chunk: float) -> bool:
	if distance_at_chunk < 0.0:
		return false
	var region := CourseRegionCatalog.region_for_distance(
		distance_at_chunk + CHUNK_WIDTH * 0.5)
	if not bool(region.get("checkpoint", false) or region.get("safe_entry", false)):
		return false
	return floori((
		distance_at_chunk + CHUNK_WIDTH * 0.5 - float(region["start_distance"])
	) / CHUNK_WIDTH) == 0


## Ruined Arboretum's authored rotor-plus-pane combination slot. Outside the
## owner-scoped range and unchanged in placement; only its guaranteed recovery
## had to become explicit.
static func _is_arboretum_combination(
	chunk_index: int,
	distance_at_chunk: float,
) -> bool:
	if chunk_index < 0 or distance_at_chunk < 185000.0:
		return false
	var region := CourseRegionCatalog.region_for_distance(
		distance_at_chunk + CHUNK_WIDTH * 0.5)
	if StringName(region["id"]) != CourseRegionCatalog.RUINED_ARBORETUM:
		return false
	var local_chunk := maxi(
		0,
		floori((
			distance_at_chunk + CHUNK_WIDTH * 0.5
				- float(region["start_distance"])
		) / CHUNK_WIDTH),
	)
	return posmod(local_chunk, 10) == 3


## Whether a chunk carries no commitment at all — warm-up, region entry, or a
## scheduled recovery pocket. Pure in `(chunk_index, distance)`, so it can be
## asked about a neighbour without replaying that neighbour's selection.
static func _chunk_is_open(
	chunk_index: int,
	distance_at_chunk: float,
	difficulty_mode: StringName,
) -> bool:
	if chunk_index < 0:
		return true
	if _region_pool_for(distance_at_chunk).is_empty():
		return true
	var region := CourseRegionCatalog.region_for_distance(
		distance_at_chunk + CHUNK_WIDTH * 0.5)
	var local_chunk := maxi(
		0,
		floori((
			distance_at_chunk + CHUNK_WIDTH * 0.5
				- float(region["start_distance"])
		) / CHUNK_WIDTH),
	)
	if bool(region.get("checkpoint", false) or region.get("safe_entry", false)) \
			and local_chunk == 0:
		return true
	return CourseDifficultyProfile.is_recovery_chunk(
		difficulty_mode,
		chunk_index,
		CoursePressure.at(distance_at_chunk),
		CoursePressure.at(distance_at_chunk - CHUNK_WIDTH),
	)


static func _seeded_pattern(
	pool: Array,
	local_chunk: int,
	course_seed: int,
	region_index: int,
	difficulty_mode: StringName,
	chunk_index: int,
) -> Dictionary:
	var size := pool.size()
	var offset := posmod(course_seed * 31 + region_index * 17, size)
	var stride := _coprime_stride(size, course_seed + region_index * 11)
	var standard_index := posmod(offset + local_chunk * stride, size)
	var index := CourseDifficultyProfile.select_index(
		difficulty_mode,
		pool,
		standard_index,
		chunk_index,
		course_seed,
		region_index,
	)
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

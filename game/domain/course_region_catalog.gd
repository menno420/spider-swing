extends RefCounted
class_name CourseRegionCatalog
## Stable endless-course regions shared by generation, saves, UI, and tools.
##
## Distances use the simulation's authoritative pixel unit. Presentation alone
## converts them to metres (10 px = 1 m). Regions describe content identity and
## player-facing intent; they never mutate physics or collision.

const PIXELS_PER_METRE := 10.0
const REGION_LENGTH_METRES := 5000.0
const REGION_LENGTH_PIXELS := REGION_LENGTH_METRES * PIXELS_PER_METRE

const ANCIENT_FOREST := &"ancient_forest"
const BRAMBLE_CANOPY := &"bramble_canopy"
const SILK_HOLLOW := &"silk_hollow"

const VISUAL_OLD_GROWTH := &"old_growth"
const VISUAL_CANOPY := &"canopy"
const VISUAL_HOLLOW := &"hollow"

const REGIONS := [
	{
		"id": ANCIENT_FOREST,
		"name": "ANCIENT FOREST",
		"start_distance": 0.0,
		"focus": "Mixed fundamentals · learn every route",
		"quirk": "Wide recovery rhythm",
		"visual_profile": VISUAL_OLD_GROWTH,
		"checkpoint": false,
	},
	{
		"id": BRAMBLE_CANOPY,
		"name": "BRAMBLE CANOPY",
		"start_distance": REGION_LENGTH_PIXELS,
		"focus": "Height control · rapid high↔low choices",
		"quirk": "Alternating weave cues",
		"visual_profile": VISUAL_CANOPY,
		"checkpoint": true,
	},
	{
		"id": SILK_HOLLOW,
		"name": "SILK HOLLOW",
		"start_distance": REGION_LENGTH_PIXELS * 2.0,
		"focus": "Precision · suspended hazards and narrow lines",
		"quirk": "Silk-marked recovery pockets",
		"visual_profile": VISUAL_HOLLOW,
		"checkpoint": true,
	},
]


static func region_for_distance(distance_pixels: float) -> Dictionary:
	return REGIONS[region_index_for_distance(distance_pixels)].duplicate(true)


static func region_for_id(region_id: StringName) -> Dictionary:
	for region: Dictionary in REGIONS:
		if StringName(region["id"]) == region_id:
			return region.duplicate(true)
	return {}


static func region_index_for_distance(distance_pixels: float) -> int:
	var result := 0
	for index in range(REGIONS.size()):
		if distance_pixels + 0.001 < float(REGIONS[index]["start_distance"]):
			break
		result = index
	return result


static func region_index_for_id(region_id: StringName) -> int:
	for index in range(REGIONS.size()):
		if StringName(REGIONS[index]["id"]) == region_id:
			return index
	return -1


static func practice_regions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for region: Dictionary in REGIONS:
		if bool(region["checkpoint"]):
			result.append(region.duplicate(true))
	return result


static func checkpoint_ids_reached(distance_pixels: float) -> Array[StringName]:
	var result: Array[StringName] = []
	for region: Dictionary in REGIONS:
		if bool(region["checkpoint"]) and \
				distance_pixels + 0.001 >= float(region["start_distance"]):
			result.append(StringName(region["id"]))
	return result


static func checkpoint_start(region_id: StringName) -> float:
	var region := region_for_id(region_id)
	if region.is_empty() or not bool(region["checkpoint"]):
		return 0.0
	return float(region["start_distance"])


static func is_checkpoint(region_id: StringName) -> bool:
	var region := region_for_id(region_id)
	return not region.is_empty() and bool(region["checkpoint"])

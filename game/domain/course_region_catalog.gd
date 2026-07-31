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
const RUINED_ARBORETUM := &"ruined_arboretum"
const STORM_RIDGE := &"storm_ridge"
const WEB_CITY := &"web_city"
const ASHEN_HOLLOW := &"ashen_hollow"
const DEEP_MIST := &"deep_mist"

const VISUAL_OLD_GROWTH := &"old_growth"
const VISUAL_CANOPY := &"canopy"
const VISUAL_HOLLOW := &"hollow"
const VISUAL_ARBORETUM := &"arboretum"
const VISUAL_STORM := &"storm"
const VISUAL_WEB_CITY := &"web_city"
const VISUAL_ASHEN := &"ashen"
const VISUAL_MIST := &"mist"

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
	{
		"id": RUINED_ARBORETUM,
		"name": "RUINED ARBORETUM",
		"start_distance": REGION_LENGTH_PIXELS * 3.0,
		"focus": "Timing · read the phase before committing",
		"quirk": "Moving gaps and pivots",
		"visual_profile": VISUAL_ARBORETUM,
		"checkpoint": false,
		"safe_entry": true,
	},
	{
		"id": STORM_RIDGE,
		"name": "STORM RIDGE",
		"start_distance": REGION_LENGTH_PIXELS * 4.0,
		"focus": "External force · stay on silk through the gust",
		"quirk": "Deterministic lateral wind",
		"visual_profile": VISUAL_STORM,
		"checkpoint": false,
		"safe_entry": true,
	},
	{
		"id": WEB_CITY,
		"name": "WEB CITY",
		"start_distance": REGION_LENGTH_PIXELS * 5.0,
		"focus": "Route choice · safe silk or a faster free line",
		"quirk": "Ridable and sticky strands",
		"visual_profile": VISUAL_WEB_CITY,
		"checkpoint": false,
		"safe_entry": true,
	},
	{
		"id": ASHEN_HOLLOW,
		"name": "ASHEN HOLLOW",
		"start_distance": REGION_LENGTH_PIXELS * 6.0,
		"focus": "Trust · release before a weak anchor fails",
		"quirk": "Timed rotten anchors",
		"visual_profile": VISUAL_ASHEN,
		"checkpoint": false,
		"safe_entry": true,
	},
	{
		"id": DEEP_MIST,
		"name": "DEEP MIST",
		"start_distance": REGION_LENGTH_PIXELS * 7.0,
		"focus": "Information · lit anchors and audio-first hazards",
		"quirk": "Short sightline, endless spacing",
		"visual_profile": VISUAL_MIST,
		"checkpoint": false,
		"safe_entry": true,
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

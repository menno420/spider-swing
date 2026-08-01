extends RefCounted
class_name CampaignCatalog
## The campaign teaching tier: short levels that each REQUIRE one verb.
##
## D-0033 approved a staged campaign whose early levels teach one mechanic
## each. The gap it names is specific: the tutorial explains Reel, Burst and
## Dive across six static text steps and then never asks the player to perform
## any of them.
##
## A level is therefore completed by BOTH conditions, not either:
##
##   1. reach `goal_distance_pixels` without dying, and
##   2. perform the taught verb at least once on the way.
##
## The verb requirement is an explicit objective rather than an emergent
## property of geometry. That is a deliberate choice and the honest one: the
## simulation lab cannot certify "this terrain is impassable without reeling"
## — its bot model deadlocks with Reel removed and never Dives at all (see
## `docs/technical/simulation-lab.md`), so a geometry-derived guarantee would
## be a claim nobody could check. An explicit objective is verifiable by the
## suite, unambiguous to the player, and cannot rot when course tuning moves.
##
## Levels reuse existing Ancient Forest geometry at fixed course seeds. They
## add no obstacle kinds and no art. Rewards are stars only — never flies —
## so a fixed-seed repeatable level can never become the optimal farm.

const PIXELS_PER_METRE := 10.0

const VERB_REEL := &"reel"
const VERB_BURST := &"burst"
const VERB_DIVE := &"dive"

const TEACH_REEL := &"teach_reel"
const TEACH_BURST := &"teach_burst"
const TEACH_DIVE := &"teach_dive"

## Ordered: each level assumes the previous verb is known. Course seeds are
## fixed so a level is the same course for every player on every attempt,
## which is what makes a taught beat teachable and a star comparable.
const LEVELS := [
	{
		"id": TEACH_REEL,
		"name": "PULL YOURSELF IN",
		"verb": VERB_REEL,
		"order": 0,
		"goal_distance_pixels": 3000.0,
		"course_seed": 4101,
		"objective": "Reach 300 m and hold REEL at least once.",
		"coaching": "Hold REEL while attached to shorten the line and rise "
			+ "into a tighter arc.",
	},
	{
		"id": TEACH_BURST,
		"name": "SNAP TO THE ANCHOR",
		"verb": VERB_BURST,
		"order": 1,
		"goal_distance_pixels": 3000.0,
		"course_seed": 4102,
		"objective": "Reach 300 m and fire one Anchor Burst.",
		"coaching": "Double-tap a solid target above you to snap toward it.",
	},
	{
		"id": TEACH_DIVE,
		"name": "DROP THROUGH",
		"verb": VERB_DIVE,
		"order": 2,
		"goal_distance_pixels": 3000.0,
		"course_seed": 4103,
		"objective": "Reach 300 m and perform one Dive Pull.",
		"coaching": "Double-tap a solid target below you to pull down fast.",
	},
]


static func all_levels() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for level: Dictionary in LEVELS:
		result.append(level.duplicate(true))
	return result


static func level_for_id(level_id: StringName) -> Dictionary:
	for level: Dictionary in LEVELS:
		if StringName(level["id"]) == level_id:
			return level.duplicate(true)
	return {}


static func has_level(level_id: StringName) -> bool:
	return not level_for_id(level_id).is_empty()


static func level_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for level: Dictionary in LEVELS:
		result.append(StringName(level["id"]))
	return result


## The verb a level teaches, or &"" when the id is unknown.
static func verb_for_level(level_id: StringName) -> StringName:
	var level := level_for_id(level_id)
	return &"" if level.is_empty() else StringName(level["verb"])


static func goal_distance_pixels(level_id: StringName) -> float:
	var level := level_for_id(level_id)
	return 0.0 if level.is_empty() else float(level["goal_distance_pixels"])


static func course_seed(level_id: StringName) -> int:
	var level := level_for_id(level_id)
	return 0 if level.is_empty() else int(level["course_seed"])


## Both conditions, never either. This is the whole teaching guarantee, in one
## place, so a contract can hold it and a later change cannot weaken it by
## accident.
static func is_complete(
	level_id: StringName,
	distance_pixels: float,
	verbs_performed: Array[StringName],
) -> bool:
	var level := level_for_id(level_id)
	if level.is_empty():
		return false
	if distance_pixels + 0.001 < float(level["goal_distance_pixels"]):
		return false
	return StringName(level["verb"]) in verbs_performed


## Settlement id for one campaign completion. Stable per level so repeat
## clears of an already-starred level are idempotent through
## `PlayerProgress.applied_settlement_ids`, exactly like any other settlement.
static func settlement_id(level_id: StringName) -> String:
	return "campaign-%s" % level_id

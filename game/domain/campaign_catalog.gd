extends RefCounted
class_name CampaignCatalog
## The campaign: short levels that each REQUIRE the verbs they name.
##
## D-0033 approved a staged campaign whose early levels teach one mechanic
## each. The gap it names is specific: the tutorial explains Reel, Burst and
## Dive across six static text steps and then never asks the player to perform
## any of them.
##
## **Two tiers.** The teaching tier asks for one verb each. The combination tier
## asks for two or three in a single run, because knowing three verbs separately
## is not the same skill as choosing between them under pressure — which is what
## the measured recovery gap says actually fails: 88–100% of the model's deaths
## happen with an unspent Burst or Dive in hand
## (`docs/measurements/2026-08-01-recovery-gap.md`).
##
## A level is completed by BOTH conditions, not either:
##
##   1. reach `goal_distance_pixels` without dying, and
##   2. perform **every** verb it names at least once on the way.
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

const COMBINE_ARC := &"combine_arc"
const COMBINE_RECOVER := &"combine_recover"
const COMBINE_FULL := &"combine_full"

const TIER_TEACH := &"teach"
const TIER_COMBINE := &"combine"

## Display order for the tier headings. A tier is presentation grouping only —
## nothing gates on it, exactly as nothing gates the three teaching levels on
## each other. Introducing a gate would need unlock state and a save question,
## and it is a product decision rather than a technical one.
const TIERS := [
	{
		"id": TIER_TEACH,
		"name": "TEACHING TIER",
		"blurb": "One verb each. Reach the goal and perform it.",
	},
	{
		"id": TIER_COMBINE,
		"name": "COMBINATION TIER",
		"blurb": "Two or three verbs in one run, and a longer goal.",
	},
]

## Ordered: each level assumes the previous verbs are known. Course seeds are
## fixed so a level is the same course for every player on every attempt,
## which is what makes a taught beat teachable and a star comparable.
const LEVELS := [
	{
		"id": TEACH_REEL,
		"name": "PULL YOURSELF IN",
		"tier": TIER_TEACH,
		"verbs": [VERB_REEL],
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
		"tier": TIER_TEACH,
		"verbs": [VERB_BURST],
		"order": 1,
		"goal_distance_pixels": 3000.0,
		"course_seed": 4102,
		"objective": "Reach 300 m and fire one Anchor Burst.",
		"coaching": "Double-tap a solid target above you to snap toward it.",
	},
	{
		"id": TEACH_DIVE,
		"name": "DROP THROUGH",
		"tier": TIER_TEACH,
		"verbs": [VERB_DIVE],
		"order": 2,
		"goal_distance_pixels": 3000.0,
		"course_seed": 4103,
		"objective": "Reach 300 m and perform one Dive Pull.",
		"coaching": "Double-tap a solid target below you to pull down fast.",
	},
	# The combination tier. Each pairing is a distinction the repository has
	# already measured or been told about, not an arbitrary permutation.
	{
		"id": COMBINE_ARC,
		"name": "SHAPE, THEN CORRECT",
		"tier": TIER_COMBINE,
		"verbs": [VERB_REEL, VERB_BURST],
		"order": 3,
		"goal_distance_pixels": 5000.0,
		"course_seed": 4201,
		"objective": "Reach 500 m using both REEL and one Anchor Burst.",
		# The owner's own device finding: at speed these two do different jobs.
		"coaching": "Reel early to shape the arc you want. Save the Burst for "
			+ "the late height correction it is better at.",
	},
	{
		"id": COMBINE_RECOVER,
		"name": "DROP, THEN RECOVER",
		"tier": TIER_COMBINE,
		"verbs": [VERB_DIVE, VERB_BURST],
		"order": 4,
		"goal_distance_pixels": 5000.0,
		"course_seed": 4202,
		"objective": "Reach 500 m using one Dive Pull and one Anchor Burst.",
		# The escape pair. Most measured deaths happen holding one of these.
		"coaching": "Dive through the gap, then Burst back up to the next "
			+ "anchor. Both are escapes; this asks you to use them as a pair.",
	},
	{
		"id": COMBINE_FULL,
		"name": "THE WHOLE REPERTOIRE",
		"tier": TIER_COMBINE,
		"verbs": [VERB_REEL, VERB_BURST, VERB_DIVE],
		"order": 5,
		"goal_distance_pixels": 8000.0,
		"course_seed": 4203,
		"objective": "Reach 800 m using REEL, an Anchor Burst and a Dive Pull.",
		"coaching": "Reel to shape, Burst to climb, Dive to drop. The run is "
			+ "long enough that you will want all three.",
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


## Every verb a level requires, or an empty array when the id is unknown.
static func verbs_for_level(level_id: StringName) -> Array[StringName]:
	var result: Array[StringName] = []
	var level := level_for_id(level_id)
	if level.is_empty():
		return result
	for verb: Variant in (level["verbs"] as Array):
		result.append(StringName(verb))
	return result


static func tiers() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for tier: Dictionary in TIERS:
		result.append(tier.duplicate(true))
	return result


static func levels_for_tier(tier_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for level: Dictionary in LEVELS:
		if StringName(level["tier"]) == tier_id:
			result.append(level.duplicate(true))
	return result


static func goal_distance_pixels(level_id: StringName) -> float:
	var level := level_for_id(level_id)
	return 0.0 if level.is_empty() else float(level["goal_distance_pixels"])


static func course_seed(level_id: StringName) -> int:
	var level := level_for_id(level_id)
	return 0 if level.is_empty() else int(level["course_seed"])


## Both conditions, never either — and **every** named verb, never any of them.
## This is the whole teaching guarantee, in one place, so a contract can hold it
## and a later change cannot weaken it by accident. A combination level that
## cleared on one of its two verbs would silently become a second teaching
## level, which is exactly the thing the tier exists to stop being.
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
	var required := level["verbs"] as Array
	if required.is_empty():
		return false
	for verb: Variant in required:
		if not StringName(verb) in verbs_performed:
			return false
	return true


## Settlement id for one campaign completion. Stable per level so repeat
## clears of an already-starred level are idempotent through
## `PlayerProgress.applied_settlement_ids`, exactly like any other settlement.
static func settlement_id(level_id: StringName) -> String:
	return "campaign-%s" % level_id

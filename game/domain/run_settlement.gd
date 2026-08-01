extends RefCounted
class_name RunSettlement
## Immutable-by-convention request to apply one completed run exactly once.

var settlement_id: String = ""
var distance_pixels: float = 0.0
var flies_collected: int = 0
var death_cause: StringName = &"unknown"
var run_mode: StringName = &"standard"
var start_distance_pixels: float = 0.0
var rewards_eligible: bool = true
var records_eligible: bool = true
var leaderboards_eligible: bool = true
var course_seed: int = 0
## Set only for a campaign clear. Names which teaching level was
## completed so settlement can award its star; empty for every other run.
var campaign_level_id: StringName = &""


static func create(
	id: String,
	distance: float,
	flies: int,
	cause: StringName,
	mode: StringName = &"standard",
	start_distance: float = 0.0,
	eligible: bool = true,
	seed: int = 0,
) -> RunSettlement:
	var settlement := RunSettlement.new()
	settlement.settlement_id = id
	settlement.distance_pixels = maxf(0.0, distance)
	settlement.flies_collected = maxi(0, flies)
	settlement.death_cause = cause
	settlement.run_mode = mode
	settlement.start_distance_pixels = maxf(0.0, start_distance)
	settlement.rewards_eligible = eligible
	settlement.records_eligible = eligible
	settlement.leaderboards_eligible = eligible
	settlement.course_seed = seed
	return settlement


## A campaign clear settles like Region Practice — no flies, no records, no
## leaderboard — and additionally names the level whose star it earns.
static func campaign(
	id: String,
	distance: float,
	cause: StringName,
	level_id: StringName,
	seed: int = 0,
) -> RunSettlement:
	var settlement := RunSettlement.new()
	settlement.settlement_id = id
	settlement.distance_pixels = maxf(0.0, distance)
	settlement.flies_collected = 0
	settlement.death_cause = cause
	settlement.run_mode = &"campaign"
	settlement.start_distance_pixels = 0.0
	settlement.rewards_eligible = false
	settlement.records_eligible = false
	settlement.leaderboards_eligible = false
	settlement.course_seed = seed
	settlement.campaign_level_id = level_id
	return settlement

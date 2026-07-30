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

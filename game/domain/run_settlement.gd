extends RefCounted
class_name RunSettlement
## Immutable-by-convention request to apply one completed run exactly once.

var settlement_id: String = ""
var distance_pixels: float = 0.0
var flies_collected: int = 0
var death_cause: StringName = &"unknown"


static func create(
	id: String,
	distance: float,
	flies: int,
	cause: StringName,
) -> RunSettlement:
	var settlement := RunSettlement.new()
	settlement.settlement_id = id
	settlement.distance_pixels = maxf(0.0, distance)
	settlement.flies_collected = maxi(0, flies)
	settlement.death_cause = cause
	return settlement

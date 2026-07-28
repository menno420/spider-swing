extends RefCounted
class_name SimulationEvent
## A fact emitted by authoritative gameplay and consumed by presentation.

enum Kind {
	ATTACHED,
	RELEASED,
	INVALID_TARGET,
	OUT_OF_RANGE,
	REEL_STARTED,
	REEL_UNAVAILABLE,
	REEL_EMPTY,
	BURST_STARTED,
	BURST_UNAVAILABLE,
	DEATH_REQUESTED,
	RUN_RESTARTED,
	PRESET_CHANGED,
	DIAGNOSTIC_EXPORTED,
	RECORDING_CHANGED,
	REPLAY_STARTED,
	DIVE_STARTED,
	FLY_COLLECTED,
	BOOST_COLLECTED,
	BOOST_EXPIRED,
}

var kind: int = Kind.ATTACHED
var position: Vector2 = Vector2.ZERO
var message: String = ""
var data: Dictionary = {}


static func make(
	event_kind: int,
	event_position: Vector2 = Vector2.ZERO,
	event_message: String = "",
	event_data: Dictionary = {},
) -> SimulationEvent:
	var event := SimulationEvent.new()
	event.kind = event_kind
	event.position = event_position
	event.message = event_message
	event.data = event_data.duplicate(true)
	return event

extends RefCounted
class_name RunMetricsAccumulator
## Pure fixed-step run evidence gathered from authoritative state and events.

const FIXED_DELTA := 1.0 / 60.0

var _sampled_ticks: int = 0
var _forward_speed_sum: float = 0.0
var _maximum_forward_speed: float = 0.0
var _above_reference_ticks: int = 0
var _reel_held_ticks: int = 0
var _successful_web_attachments: int = 0
var _reel_activations: int = 0
var _reel_empty_events: int = 0
var _burst_activations: int = 0
var _dive_activations: int = 0
var _rescue_consumed: bool = false


func reset() -> void:
	_sampled_ticks = 0
	_forward_speed_sum = 0.0
	_maximum_forward_speed = 0.0
	_above_reference_ticks = 0
	_reel_held_ticks = 0
	_successful_web_attachments = 0
	_reel_activations = 0
	_reel_empty_events = 0
	_burst_activations = 0
	_dive_activations = 0
	_rescue_consumed = false


## Called exactly once immediately before an authoritative world step.
func observe_tick(
	horizontal_velocity: float,
	reference_speed: float,
	reel_active: bool,
) -> void:
	var forward_speed := maxf(
		0.0, horizontal_velocity if is_finite(horizontal_velocity) else 0.0)
	var floor_speed := maxf(
		0.0, reference_speed if is_finite(reference_speed) else 0.0)
	_sampled_ticks += 1
	_forward_speed_sum += forward_speed
	_maximum_forward_speed = maxf(_maximum_forward_speed, forward_speed)
	if forward_speed > floor_speed:
		_above_reference_ticks += 1
	if reel_active:
		_reel_held_ticks += 1


## Unavailable input events deliberately do not appear in this match.
func observe_event(event: SimulationEvent) -> void:
	match event.kind:
		SimulationEvent.Kind.ATTACHED:
			_successful_web_attachments += 1
		SimulationEvent.Kind.REEL_STARTED:
			_reel_activations += 1
		SimulationEvent.Kind.REEL_EMPTY:
			_reel_empty_events += 1
		SimulationEvent.Kind.BURST_STARTED:
			_burst_activations += 1
		SimulationEvent.Kind.DIVE_STARTED:
			_dive_activations += 1
		SimulationEvent.Kind.RESCUE_USED:
			_rescue_consumed = true


func sampled_ticks() -> int:
	return _sampled_ticks


func result() -> Dictionary:
	return {
		"sampled_ticks": _sampled_ticks,
		"active_duration_seconds": _sampled_ticks * FIXED_DELTA,
		"mean_forward_speed_pixels_per_second": (
			_forward_speed_sum / _sampled_ticks
			if _sampled_ticks > 0 else 0.0
		),
		"maximum_forward_speed_pixels_per_second": _maximum_forward_speed,
		"above_reference_speed_share": (
			float(_above_reference_ticks) / _sampled_ticks
			if _sampled_ticks > 0 else 0.0
		),
		"successful_web_attachments": _successful_web_attachments,
		"reel_activations": _reel_activations,
		"reel_held_seconds": _reel_held_ticks * FIXED_DELTA,
		"reel_empty_events": _reel_empty_events,
		"burst_activations": _burst_activations,
		"dive_activations": _dive_activations,
		"rescue_consumed": _rescue_consumed,
	}

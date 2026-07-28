extends RefCounted
class_name RunStateMachine
## Sole owner of Phase 0 run lifecycle transitions.

enum State {
	ACTIVE,
	DYING,
	DEAD,
}

var state: int = State.ACTIVE
var death_cause: StringName = &""
var _dying_remaining: float = 0.0


func reset() -> void:
	state = State.ACTIVE
	death_cause = &""
	_dying_remaining = 0.0


func request_death(cause: StringName, confirmation_seconds: float) -> bool:
	if state != State.ACTIVE:
		return false
	state = State.DYING
	death_cause = cause
	_dying_remaining = confirmation_seconds
	return true


func advance(delta: float) -> void:
	if state != State.DYING:
		return
	_dying_remaining = maxf(0.0, _dying_remaining - delta)
	if _dying_remaining <= 0.0:
		state = State.DEAD


func state_name() -> StringName:
	match state:
		State.DYING:
			return &"dying"
		State.DEAD:
			return &"dead"
		_:
			return &"active"

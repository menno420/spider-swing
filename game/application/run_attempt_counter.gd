extends RefCounted
class_name RunAttemptCounter
## In-memory attempt ordinal shared by every SwingLabSession in one app launch.

var _ordinal: int = 0


func next_attempt() -> int:
	_ordinal += 1
	return _ordinal


func current() -> int:
	return _ordinal

extends RefCounted
class_name EffectState
## Application-owned activation and expiry for temporary run effects.

const BURST_FRENZY := &"burst_frenzy"

var _remaining: Dictionary = {}


func reset() -> void:
	_remaining.clear()


func activate(effect: StringName, duration: float) -> void:
	_remaining[effect] = maxf(float(_remaining.get(effect, 0.0)), duration)


func advance(delta: float) -> PackedStringArray:
	var expired := PackedStringArray()
	for effect: Variant in _remaining.keys():
		var name := StringName(effect)
		var next := maxf(0.0, float(_remaining[effect]) - delta)
		if next <= 0.0:
			_remaining.erase(effect)
			expired.append(name)
		else:
			_remaining[effect] = next
	return expired


func is_active(effect: StringName) -> bool:
	return remaining(effect) > 0.0


func remaining(effect: StringName) -> float:
	return float(_remaining.get(effect, 0.0))

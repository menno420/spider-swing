extends RefCounted
class_name InputCommand
## Immutable-at-consumption command crossing the input -> simulation seam.

enum Kind {
	ATTACH,
	RELEASE,
	REEL_START,
	REEL_STOP,
	BURST,
}

var kind: int = Kind.RELEASE
var world_target: Vector2 = Vector2.ZERO
var has_world_target: bool = false
var sequence: int = 0
var captured_tick: int = 0


static func attach(target: Vector2, command_sequence: int, tick: int) -> InputCommand:
	var command := InputCommand.new()
	command.kind = Kind.ATTACH
	command.world_target = target
	command.has_world_target = true
	command.sequence = command_sequence
	command.captured_tick = tick
	return command


static func release(command_sequence: int, tick: int) -> InputCommand:
	var command := InputCommand.new()
	command.kind = Kind.RELEASE
	command.sequence = command_sequence
	command.captured_tick = tick
	return command


static func reel(active: bool, command_sequence: int, tick: int) -> InputCommand:
	var command := InputCommand.new()
	command.kind = Kind.REEL_START if active else Kind.REEL_STOP
	command.sequence = command_sequence
	command.captured_tick = tick
	return command


static func burst(command_sequence: int, tick: int) -> InputCommand:
	var command := InputCommand.new()
	command.kind = Kind.BURST
	command.sequence = command_sequence
	command.captured_tick = tick
	return command


static func burst_at(
	target: Vector2,
	command_sequence: int,
	tick: int,
) -> InputCommand:
	var command := burst(command_sequence, tick)
	command.world_target = target
	command.has_world_target = true
	return command


func to_record() -> Dictionary:
	return {
		"kind": int(kind),
		"target_x": world_target.x,
		"target_y": world_target.y,
		"has_world_target": has_world_target,
		"sequence": sequence,
		"captured_tick": captured_tick,
	}


static func from_record(record: Dictionary) -> InputCommand:
	var command := InputCommand.new()
	command.kind = int(record.get("kind", Kind.RELEASE))
	command.world_target = Vector2(
		float(record.get("target_x", 0.0)),
		float(record.get("target_y", 0.0)),
	)
	command.has_world_target = bool(record.get(
		"has_world_target",
		command.kind == Kind.ATTACH,
	))
	command.sequence = int(record.get("sequence", 0))
	command.captured_tick = int(record.get("captured_tick", 0))
	return command

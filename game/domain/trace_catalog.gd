extends RefCounted
class_name TraceCatalog
## The input traces bundled with the build, for watching in the real game.
##
## `tools/simulate.gd --trace-top` writes the simulation lab's best runs as
## input traces in exactly the shape `SwingLabSession` records a human in. This
## catalog is how they become watchable: the debug Test Run screen lists them,
## and `SwingLabSession.load_input_trace` replays one.
##
## The reason the loop exists at all: **no statistic decides whether a search
## result was played fairly.** A bot rewarded for distance will use whatever
## the physics allows, and the only reliable way to tell "played well" from
## "found a loophole" is for a person to watch it. Everything here serves that
## one sentence.
##
## Traces are data, never authority. They award nothing, set no record, and
## replay through `RUN_PRACTICE` like any other debug run.

## Identity of a trace document. Lives here, in domain, because both the
## producer (`tools/simulate.gd`) and the consumer (`SwingLabSession`) must
## agree on it and neither may own it. Bump it when the record shape or
## authoritative physics semantics changes so an old trace is refused rather
## than replayed into a world it was never recorded in.
## Bumped to @6 by the 0.42.0 mode-profile slice. **A course generation change
## is exactly what this constant is for.** Difficulty mode is now a declared
## structural selection input. Standard's course stays exact,
## but an older Relaxed/Harsh trace would otherwise replay into a different
## sequence while looking plausible. The setup already records difficulty; the
## format bump makes the semantic change fail loudly.
const INPUT_TRACE_FORMAT := "spider-swing-input-trace@6"
const TRACE_DIRECTORY := "res://assets/runtime/traces"
const TRACE_EXTENSION := ".json"
const PIXELS_PER_METRE := 10.0


## Every bundled trace, sorted by furthest travelled first — the interesting
## ones are the long ones. Each entry is
## `{path, id, label, travelled_m, seconds, upgrades, start_m, commands}`.
##
## Returns an empty array when nothing is bundled, which is a normal state:
## traces are optional content and the screen simply offers nothing to watch.
static func entries() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var directory := DirAccess.open(TRACE_DIRECTORY)
	if directory == null:
		return found
	for file_name: String in directory.get_files():
		# Godot hands exported builds an `.import`/`.remap` suffix on files it
		# processed; strip it so the same name works in both.
		var name := file_name.trim_suffix(".remap")
		if not name.ends_with(TRACE_EXTENSION):
			continue
		var path := "%s/%s" % [TRACE_DIRECTORY, name]
		var summary := describe(path)
		if summary.is_empty():
			continue
		found.append(summary)
	found.sort_custom(func(a, b):
		return float(a["travelled_m"]) > float(b["travelled_m"]))
	return found


## Read one trace's header without keeping its commands in memory. Returns an
## empty dictionary for anything that is not a trace this build understands —
## an unreadable or future-format file is skipped rather than listed and then
## refused at the last moment.
static func describe(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var trace: Dictionary = parsed
	if str(trace.get("format", "")) != INPUT_TRACE_FORMAT:
		return {}
	var setup: Dictionary = trace.get("setup", {})
	var expected: Dictionary = trace.get("expected", {})
	var commands: Array = trace.get("commands", [])
	if commands.is_empty():
		return {}
	var travelled := float(expected.get("travelled_m", 0.0))
	var start_m := int(setup.get("start_m", 0))
	var upgrades := int(setup.get("upgrades", 0))
	return {
		"path": path,
		"id": path.get_file().trim_suffix(TRACE_EXTENSION),
		"label": "%s m  ·  from %s m  ·  L%d  ·  %s" % [
			String.num(travelled, 0),
			String.num(float(start_m), 0),
			upgrades,
			str(setup.get("skill", "?")),
		],
		"travelled_m": travelled,
		"seconds": float(expected.get("seconds", 0.0)),
		"upgrades": upgrades,
		"start_m": start_m,
		"commands": commands.size(),
	}

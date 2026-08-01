extends RefCounted
class_name SimulationLabTests
## Contracts on the information the simulation lab's player model reads.
##
## `tools/simulate.gd` is diagnostic instrumentation and asserts nothing, so
## nothing else in the suite notices when the world stops telling it something.
## Bot v3 was built after owner device recordings showed v2 measuring a
## different game from the one being played
## (`docs/measurements/2026-08-01-owner-play-calibration.md`), and two of its
## three fixes rest entirely on facts the simulation reports to a caller:
##
## 1. `nearest_solid_point` names the **anchor class** of what a tap snapped
##    to. Without it every anchor in zones 4–8 reads as an ordinary fixed one,
##    which is exactly how v2 measured those zones.
## 2. Attaching a rotten or collapsing span emits the `rotten_crack` cue
##    carrying **`lifetime_ticks`** — how long the span has left. It is the
##    only number that separates "release before it breaks" from clairvoyance,
##    because it is the same number the HUD is driven by.
##
## These assert **that the information exists and is correct**, never what the
## bot does with it. What a player model concludes is a measurement, and
## pinning one here would freeze a bot that still fails its own acceptance
## targets.

const FIXED_DELTA := 1.0 / 60.0

## A run the simulation lab produced and wrote as an input trace. Committed so
## the replay path has something to prove itself against without anyone having
## to re-run a search first.
const COMMITTED_TRACE := \
	"res://assets/runtime/traces/earned-speed-bird-technical.json"

## `SwingLabSession.TRACE_PIXELS_PER_METRE`, restated so this contract does not
## silently follow a change to it.
const TRACE_PIXELS_PER_METRE := 10.0

## A committed trace from a superseded format. It exists so the "skip what we
## cannot replay" rule has something real to be tested against.
const SUPERSEDED_FIXTURE := \
	"res://assets/runtime/traces/lab-best-warp5000-l20.json"


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_nearest_solid_point_names_the_anchor_class(failures)
	passed += _test_fixed_geometry_reads_as_fixed(failures)
	passed += _test_timed_anchor_publishes_its_remaining_life(failures)
	passed += _test_dive_is_reachable_through_a_web_tap(failures)
	passed += _test_committed_trace_replays_in_the_session(failures)
	passed += _test_trace_replays_its_bird_isolation_settings(failures)
	passed += _test_trace_format_mismatch_is_refused(failures)
	passed += _test_catalog_lists_the_committed_trace(failures)
	passed += _test_catalog_skips_documents_it_cannot_replay(failures)
	passed += _test_bundled_traces_ship_in_the_android_export(failures)
	return {"passed": passed, "failures": failures}


static func _rectangle_polygon(rect: Rect2) -> PackedVector2Array:
	return PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	])


## A ceiling to hang from, plus one extra surface carrying `anchor_class`.
static func _geometry_with_ceiling_class(
	anchor_class: StringName,
	motion_spec: Dictionary,
) -> CourseGeometry:
	var geometry := CourseGeometry.new()
	geometry.surfaces.append(
		_rectangle_polygon(Rect2(0.0, 112.0, 1400.0, 38.0)))
	geometry.surface_ids.append(&"plain_ceiling")
	geometry.surface_anchor_classes.append(CourseGeometry.ANCHOR_FIXED)
	geometry.surface_visual_ids.append(&"")
	geometry.surface_motion_specs.append({})
	geometry.surfaces.append(
		_rectangle_polygon(Rect2(600.0, 150.0, 220.0, 30.0)))
	geometry.surface_ids.append(&"classed_span")
	geometry.surface_anchor_classes.append(anchor_class)
	geometry.surface_visual_ids.append(&"")
	geometry.surface_motion_specs.append(motion_spec)
	return geometry


## The load-bearing one. A tap that snaps to a silk highway, sticky silk or a
## collapsing span must say so. If this key ever stops being reported the lab
## keeps running and quietly measures every late zone as if its defining
## mechanic were not there — a silent wrong answer, which is the worst kind.
static func _test_nearest_solid_point_names_the_anchor_class(
	failures: PackedStringArray,
) -> int:
	for anchor_class: StringName in [
		CourseGeometry.ANCHOR_HIGHWAY,
		CourseGeometry.ANCHOR_STICKY,
		CourseGeometry.ANCHOR_ROTTEN,
		CourseGeometry.ANCHOR_COLLAPSING,
		CourseGeometry.ANCHOR_MOVING_PIVOT,
	]:
		var world := SimulationWorld.new()
		world.reset(
			SwingConfig.from_preset(SwingConfig.PRESET_BALANCED),
			_geometry_with_ceiling_class(anchor_class, {}))
		var nearest := world.nearest_solid_point(Vector2(700.0, 168.0))
		if not bool(nearest["found"]):
			failures.append(
				"no anchor found on the %s span the query was aimed at" %
					anchor_class)
			return 0
		if StringName(nearest.get("anchor_class", &"")) != anchor_class:
			failures.append(
				"nearest_solid_point reported anchor class '%s', expected '%s'" % [
					nearest.get("anchor_class", &"<missing>"), anchor_class])
			return 0
	return 1


## The other half of the same contract: ordinary geometry must not be dressed
## up as something special, or a preference for good anchors becomes noise.
static func _test_fixed_geometry_reads_as_fixed(
	failures: PackedStringArray,
) -> int:
	var world := SimulationWorld.new()
	world.reset(
		SwingConfig.from_preset(SwingConfig.PRESET_BALANCED),
		_geometry_with_ceiling_class(CourseGeometry.ANCHOR_FIXED, {}))
	var nearest := world.nearest_solid_point(Vector2(700.0, 168.0))
	if not bool(nearest["found"]):
		failures.append("no anchor found on the plain span")
		return 0
	if StringName(nearest.get("anchor_class", &"")) != \
			CourseGeometry.ANCHOR_FIXED:
		failures.append("plain geometry reported anchor class '%s'" %
			nearest.get("anchor_class", &"<missing>"))
		return 0
	return 1


## Attaching to a span that expires must publish how long it has left. A cue
## that says only "this is weak" cannot be acted on in time; the number is the
## contract.
static func _test_timed_anchor_publishes_its_remaining_life(
	failures: PackedStringArray,
) -> int:
	for anchor_class: StringName in [
		CourseGeometry.ANCHOR_ROTTEN,
		CourseGeometry.ANCHOR_COLLAPSING,
	]:
		var lifetime := 42
		var world := SimulationWorld.new()
		world.reset(
			SwingConfig.from_preset(SwingConfig.PRESET_BALANCED),
			_geometry_with_ceiling_class(
				anchor_class, {"lifetime_ticks": lifetime}))
		world.queue_command(InputCommand.attach(Vector2(700.0, 168.0), 1, 0))
		var events := world.step(FIXED_DELTA)
		var reported := -1
		var attached := false
		for event: SimulationEvent in events:
			if event.kind == SimulationEvent.Kind.ATTACHED:
				attached = true
				if StringName(event.data.get("anchor_class", &"")) != \
						anchor_class:
					failures.append(
						"ATTACHED on a %s span reported class '%s'" % [
							anchor_class,
							event.data.get("anchor_class", &"<missing>")])
					return 0
			if event.kind == SimulationEvent.Kind.HAZARD_CUE and \
					event.data.get("cue", &"") == &"rotten_crack":
				reported = int(event.data.get("lifetime_ticks", -1))
		if not attached:
			failures.append("could not attach to the %s span" % anchor_class)
			return 0
		if reported <= 0:
			failures.append(
				("attaching to a %s span published no usable lifetime "
					+ "(got %d) — a weak-anchor cue without a deadline "
					+ "cannot be released in time") % [anchor_class, reported])
			return 0
		if reported > lifetime:
			failures.append(
				"%s span reported %d ticks of life, authored for %d" % [
					anchor_class, reported, lifetime])
			return 0
	return 1


## Bot v3 reaches Dive by aiming an ordinary web tap below itself, which is
## what the HUD instructs ("tap solid below to Dive Pull"). If that routing
## ever moved to a separate command the model would stop diving and, as v2
## showed, nothing would report it — the runs would simply get shorter.
static func _test_dive_is_reachable_through_a_web_tap(
	failures: PackedStringArray,
) -> int:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var geometry := CourseGeometry.new()
	geometry.surfaces.append(
		_rectangle_polygon(Rect2(0.0, 112.0, 1400.0, 38.0)))
	geometry.surfaces.append(
		_rectangle_polygon(Rect2(260.0, 570.0, 520.0, 42.0)))
	var world := SimulationWorld.new()
	world.reset(config, geometry)
	var below := Vector2(560.0, 570.0)
	if below.y < world.position.y + config.downward_target_threshold:
		failures.append("test target is not below the Dive threshold")
		return 0
	world.queue_command(InputCommand.attach(below, 1, 0))
	var events := world.step(FIXED_DELTA)
	for event: SimulationEvent in events:
		if event.kind == SimulationEvent.Kind.DIVE_STARTED:
			return 1
	failures.append(
		"a downward web tap no longer starts a Dive — the lab's only route "
			+ "to the verb")
	return 0


## The load-bearing contract for the whole review loop.
##
## A search result is only worth watching if what you watch is the run the
## search reported. The lab writes traces in the game's own record shape and
## `--replay` proves they reproduce *there*; this proves they also reproduce
## **here**, through `SwingLabSession` — the same code path a human recording
## replays through, with the session's own rescue handling, effect timers and
## course streaming in the loop rather than the lab's minimal mirror of them.
##
## If these two ever drift apart, the replay would quietly show a different run
## from the one in the report and nothing else in the suite would notice.
static func _test_committed_trace_replays_in_the_session(
	failures: PackedStringArray,
) -> int:
	var trace := SwingLabSession.read_input_trace(COMMITTED_TRACE)
	if trace.is_empty():
		failures.append("committed trace %s is missing or unreadable" %
			COMMITTED_TRACE)
		return 0
	var expected: Dictionary = trace.get("expected", {})
	var want := float(expected.get("distance_m", 0.0))
	if want <= 0.0:
		failures.append("committed trace records no expected distance")
		return 0

	var session := SwingLabSession.new()
	var loaded := session.load_input_trace(trace)
	if not bool(loaded["ok"]):
		failures.append("session refused the committed trace: %s" %
			loaded["reason"])
		session.free()
		return 0

	# Step past the trace's own duration so the run reaches its recorded end
	# rather than being cut short by the loop bound.
	var budget := int(float(expected.get("seconds", 60.0)) / FIXED_DELTA) + 240
	for _tick in range(budget):
		session._step_once()
	var got := session.current_snapshot().distance_pixels / \
		TRACE_PIXELS_PER_METRE
	session.free()

	# Metres, not pixels. The two paths run identical fixed-step physics from
	# identical state, so this is deliberately tight -- a loose tolerance here
	# would hide exactly the drift the contract exists to catch.
	if absf(got - want) > 1.0:
		failures.append(
			("replaying the committed trace through SwingLabSession reached "
				+ "%.2f m, the lab recorded %.2f m (%.2f m apart) -- the "
				+ "replay shows a different run from the one reported")
				% [got, want, absf(got - want)])
		return 0
	return 1


static func _test_trace_replays_its_bird_isolation_settings(
	failures: PackedStringArray,
) -> int:
	var trace := SwingLabSession.read_input_trace(COMMITTED_TRACE)
	var setup: Dictionary = trace.get("setup", {})
	if not is_zero_approx(float(setup.get("bird_speed", -1.0))) or \
			not is_equal_approx(float(setup.get("bird_acceleration", -1.0)), 12.0) or \
			not is_equal_approx(float(setup.get("bird_start_offset", -1.0)), 760.0):
		failures.append("technical trace does not declare all bird isolation axes")
		return 0
	var session := SwingLabSession.new()
	var loaded := session.load_input_trace(trace)
	var snapshot := session.current_snapshot()
	if not bool(loaded.get("ok", false)) or snapshot.bird_enabled or \
			not is_zero_approx(float(snapshot.tuning_values[&"bird_speed"])) or \
			not is_equal_approx(
				float(snapshot.tuning_values[&"bird_acceleration"]), 12.0) or \
			not is_equal_approx(
				float(snapshot.tuning_values[&"bird_start_offset"]), 760.0):
		failures.append("trace replay did not restore its bird-off world exactly")
		session.free()
		return 0
	session.free()
	return 1


## A trace from a future format must be refused, not replayed into a world it
## was never recorded in. Silent acceptance is the failure that would put a
## plausible-looking wrong run in front of a reviewer.
static func _test_trace_format_mismatch_is_refused(
	failures: PackedStringArray,
) -> int:
	var session := SwingLabSession.new()
	var result := session.load_input_trace({
		"format": "spider-swing-input-trace@999",
		"setup": {},
		"commands": [{"kind": 0, "playback_tick": 0}],
	})
	var refused_format := not bool(result["ok"])
	var empty_result := session.load_input_trace({
		"format": SwingLabSession.INPUT_TRACE_FORMAT,
		"setup": {},
		"commands": [],
	})
	var refused_empty := not bool(empty_result["ok"])
	session.free()
	if not refused_format:
		failures.append("a trace with an unknown format was accepted")
		return 0
	if not refused_empty:
		failures.append("a trace carrying no input was accepted")
		return 0
	return 1


## The screen can only offer what the catalog finds. If the directory, the
## extension or the format identity drifts, the list silently empties and the
## review loop quietly stops existing rather than failing.
static func _test_catalog_lists_the_committed_trace(
	failures: PackedStringArray,
) -> int:
	var entries := TraceCatalog.entries()
	if entries.is_empty():
		failures.append(
			"TraceCatalog found no bundled traces in %s — the Test Run screen "
				% TraceCatalog.TRACE_DIRECTORY
				+ "would offer nothing to watch")
		return 0
	var found := false
	for entry: Dictionary in entries:
		if str(entry["path"]) == COMMITTED_TRACE:
			found = true
			if float(entry["travelled_m"]) <= 0.0:
				failures.append("catalog entry reports no distance travelled")
				return 0
			if int(entry["commands"]) <= 0:
				failures.append("catalog entry reports no commands")
				return 0
	if not found:
		failures.append("catalog did not list %s" % COMMITTED_TRACE)
		return 0
	# Longest first: the interesting runs are the long ones, and a reviewer
	# opening the screen should land on one rather than hunt for it.
	for index in range(1, entries.size()):
		if float(entries[index]["travelled_m"]) > \
				float(entries[index - 1]["travelled_m"]):
			failures.append("catalog is not sorted by distance travelled")
			return 0
	return 1


## A document the session would refuse must not be listed in the first place.
## Listing it and refusing at the last moment puts a dead entry in front of a
## reviewer and reads as a broken feature rather than an incompatible file.
static func _test_catalog_skips_documents_it_cannot_replay(
	failures: PackedStringArray,
) -> int:
	if not TraceCatalog.describe("res://does-not-exist.json").is_empty():
		failures.append("catalog described a file that does not exist")
		return 0
	if not TraceCatalog.describe(
			"res://project.godot").is_empty():
		failures.append("catalog described a file that is not JSON at all")
		return 0
	# The one that matters: a complete, plausible trace from a format this
	# build cannot replay. After a format bump every old trace looks like
	# this, so it is the real scenario rather than a hypothetical.
	if not TraceCatalog.describe(SUPERSEDED_FIXTURE).is_empty():
		failures.append(
			"catalog described a superseded-format trace as watchable")
		return 0
	for entry: Dictionary in TraceCatalog.entries():
		if str(entry["path"]) == SUPERSEDED_FIXTURE:
			failures.append(
				"catalog listed the superseded-format fixture — a reviewer "
					+ "would pick it and be refused at the last moment")
			return 0
	# A well-formed JSON document that is not a trace at all.
	# `assets/runtime/` already holds one, so this is the exact hazard rather
	# than a hypothetical — a document that parses cleanly, carries no format
	# identity, and would be listed as a watchable run by any check that only
	# asked "is this valid JSON?".
	if not TraceCatalog.describe(
			"res://assets/runtime/audio/audio-sample-manifest.json").is_empty():
		failures.append(
			"catalog described the audio manifest as a watchable run — any "
				+ "JSON in the build would be listed")
		return 0
	return 1


## Traces are plain JSON, not Godot resources, so `export_filter=all_resources`
## does not carry them into an APK on its own. Without the include filter the
## feature works on a desktop checkout and silently offers nothing on the
## device it was built for — the only place the owner actually watches runs.
static func _test_bundled_traces_ship_in_the_android_export(
	failures: PackedStringArray,
) -> int:
	var file := FileAccess.open("res://export_presets.cfg", FileAccess.READ)
	if file == null:
		failures.append("export_presets.cfg is unreadable")
		return 0
	var text := file.get_as_text()
	file.close()
	var expected := "%s/*%s" % [
		TraceCatalog.TRACE_DIRECTORY.trim_prefix("res://"),
		TraceCatalog.TRACE_EXTENSION,
	]
	if not text.contains(expected):
		failures.append(
			("export_presets.cfg has no include_filter covering '%s' — "
				+ "bundled traces would not reach a device") % expected)
		return 0
	return 1

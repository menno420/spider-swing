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


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_nearest_solid_point_names_the_anchor_class(failures)
	passed += _test_fixed_geometry_reads_as_fixed(failures)
	passed += _test_timed_anchor_publishes_its_remaining_life(failures)
	passed += _test_dive_is_reachable_through_a_web_tap(failures)
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

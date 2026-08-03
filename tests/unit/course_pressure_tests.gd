extends RefCounted
class_name CoursePressureTests
## Contracts on the difficulty-amount curve (`game/domain/course_pressure.gd`).
##
## **These pin the curve's shape, never its feel.** Whether 2 km is the right
## place for the second rung is device-only and permanently so; a contract
## asserting it would be asserting taste and would fight every legitimate retune.
## What is pinned here is that the curve keeps the promises other rules are
## written on top of — because each of these failures produces a plausible curve
## rather than an error, and would be found on a device rather than in CI.

const WARM_UP_SAMPLES := 40

## The owner's warm-up, restated as a literal so this contract does NOT follow a
## change to `CoursePressure.WARM_UP_END_PIXELS`.
##
## Deriving the sample distances from that constant made this contract vacuous:
## setting it to 0 shrank every sample to 0 m, where pressure is legitimately
## zero, and the deleted warm-up passed. "The first 500 m" is a fact about the
## game the owner asked for, not about whatever the constant currently says.
const AUTHORED_WARM_UP_PIXELS := 5000.0
const MONOTONE_SAMPLE_STEP_PIXELS := 250.0

## Well past the top of scope. The clamp has to hold at distances no run has
## ever reached, which is exactly where nobody would look.
const BEYOND_SCOPE_PIXELS := 400000.0

## The 1750 -> 2000 m cliff, normalised onto the curve's 0..1 scale: the authored
## label ran 1.30 -> 3.27 on a 0..4 scale inside 250 m, so (3.27 - 1.30) / 4 /
## 0.25 per km. `measured` (five seeds, doctrine section 2.1). This is the defect
## R3 exists to forbid, restated here so the bound cannot be raised toward it
## without the number being in the room.
const MEASURED_CLIFF_RISE_PER_KM := 1.97

## The rise must not be compressible into a short stretch. At 0.15 per km the
## full 0 -> 1 range needs about 6.7 km, i.e. it cannot be crammed into less than
## roughly half the owner-scoped range.
const MINIMUM_KILOMETRES_FOR_FULL_RISE := 6.0


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_warm_up_carries_no_pressure(failures)
	passed += _test_curve_never_decreases(failures)
	passed += _test_curve_clamps_at_the_top_of_scope(failures)
	passed += _test_no_kilometre_exceeds_the_slope_bound(failures)
	passed += _test_slope_bound_forbids_what_it_exists_to_forbid(failures)
	return {"passed": passed, "failures": failures}


## Owner requirement 1: the first 500 m stays as it is. Pressure must contribute
## exactly nothing there -- not "nearly nothing", because every difficulty term
## derives from this number and a small non-zero value is a small amount of
## content in a warm-up the owner asked to leave alone.
##
## It must also actually leave: a curve that is zero at 500 m and still zero at
## 600 m has moved the warm-up rather than ended it.
static func _test_warm_up_carries_no_pressure(
	failures: PackedStringArray,
) -> int:
	if not is_equal_approx(
			CoursePressure.WARM_UP_END_PIXELS, AUTHORED_WARM_UP_PIXELS):
		failures.append(
			("course pressure: the warm-up moved to %.0f m from the %.0f m this "
				+ "contract was written against. Owner requirement 1 is that the "
				+ "first 500 m stays as it is -- move it deliberately, and say so.")
			% [
				CoursePressure.WARM_UP_END_PIXELS / 10.0,
				AUTHORED_WARM_UP_PIXELS / 10.0,
			])
		return 0
	var warm_up := AUTHORED_WARM_UP_PIXELS
	for index in WARM_UP_SAMPLES + 1:
		var distance := warm_up * float(index) / float(WARM_UP_SAMPLES)
		var pressure := CoursePressure.at(distance)
		if pressure != 0.0:
			failures.append(
				("course pressure: %.0f px (%.0f m) is inside the warm-up but "
					+ "carries pressure %.6f -- every difficulty term derives from "
					+ "this, so a non-zero value here puts content in the 500 m the "
					+ "owner asked to leave alone")
				% [distance, distance / 10.0, pressure])
			return 0
	var just_after := CoursePressure.at(warm_up + 1000.0)
	if just_after <= 0.0:
		failures.append(
			("course pressure: still %.6f at %.0f m, 100 m past the warm-up -- "
				+ "the curve has moved the warm-up rather than ended it")
			% [just_after, (warm_up + 1000.0) / 10.0])
		return 0
	return 1


## R2: monotonicity is a property of the envelope. The instantaneous course may
## dip -- recovery chunks are deliberate dips -- but the curve those dips are
## measured against may not, or "pressure at this distance" stops being one
## number and every rule built on it inherits the ambiguity.
static func _test_curve_never_decreases(failures: PackedStringArray) -> int:
	var previous := CoursePressure.at(0.0)
	var distance := MONOTONE_SAMPLE_STEP_PIXELS
	while distance <= BEYOND_SCOPE_PIXELS:
		var pressure := CoursePressure.at(distance)
		if pressure < previous:
			failures.append(
				("course pressure: dips from %.6f to %.6f at %.0f m -- R2 makes "
					+ "monotonicity a property of this curve, not of the course "
					+ "built from it")
				% [previous, pressure, distance / 10.0])
			return 0
		if pressure < 0.0 or pressure > 1.0:
			failures.append(
				"course pressure: %.6f at %.0f m is outside [0, 1]"
				% [pressure, distance / 10.0])
			return 0
		previous = pressure
		distance += MONOTONE_SAMPLE_STEP_PIXELS
	return 1


## O1 is DEFERRED, so the top of this curve is the edge of the owner's scope and
## not a plateau placement. Clamping and plateauing produce identical numbers
## today and mean opposite things -- and a curve that kept rising past 15 km
## would be extrapolating onto ground nobody has stood on, which is the specific
## error the deferral exists to prevent.
static func _test_curve_clamps_at_the_top_of_scope(
	failures: PackedStringArray,
) -> int:
	var top := CoursePressure.SCOPE_TOP_PIXELS
	var at_top := CoursePressure.at(top)
	if not is_equal_approx(at_top, 1.0):
		failures.append(
			("course pressure: reaches %.6f at the top of scope (%.0f m), not "
				+ "1.0 -- the curve must arrive at full pressure exactly where the "
				+ "owner's evidence ends")
			% [at_top, top / 10.0])
		return 0
	for beyond: float in [top + 1.0, top * 1.5, BEYOND_SCOPE_PIXELS]:
		var pressure := CoursePressure.at(beyond)
		if not is_equal_approx(pressure, 1.0):
			failures.append(
				("course pressure: %.6f at %.0f m, past the top of scope -- the "
					+ "curve must CLAMP there, not extrapolate. Where the plateau "
					+ "belongs is O1 and it is deferred; the longest verified run is "
					+ "10 605 m.")
				% [pressure, beyond / 10.0])
			return 0
	return 1


## R3, the rule that exists to kill the 1750 -> 2000 m cliff.
##
## The window slides a full kilometre so a step of any width is caught: a jump
## 10 m across still raises its enclosing kilometre by the whole step. Sampling
## adjacent points instead would shrink with the spacing and report a cliff as a
## small number.
static func _test_no_kilometre_exceeds_the_slope_bound(
	failures: PackedStringArray,
) -> int:
	var steepest := CoursePressure.steepest_kilometre(
		0.0, CoursePressure.SCOPE_TOP_PIXELS, 50.0)
	if steepest > CoursePressure.MAX_RISE_PER_KILOMETRE:
		failures.append(
			("course pressure: steepest kilometre raises pressure by %.4f, over "
				+ "the %.4f bound -- R3 exists because the shipped game already "
				+ "has one of these at 1750-2000 m")
			% [steepest, CoursePressure.MAX_RISE_PER_KILOMETRE])
		return 0
	return 1


## The bound is derived, not chosen, and a derivation nothing checks is a number
## free to drift. This is what stops it being raised until it permits the defect
## it was written against.
static func _test_slope_bound_forbids_what_it_exists_to_forbid(
	failures: PackedStringArray,
) -> int:
	var bound := CoursePressure.MAX_RISE_PER_KILOMETRE
	if bound <= 0.0:
		failures.append(
			"course pressure: slope bound %.4f is not positive" % bound)
		return 0
	if bound * 10.0 > MEASURED_CLIFF_RISE_PER_KM:
		failures.append(
			("course pressure: slope bound %.4f per km is within 10x of the "
				+ "measured 1750-2000 m cliff (%.2f per km normalised). A bound "
				+ "that close re-permits the defect R3 was written to forbid.")
			% [bound, MEASURED_CLIFF_RISE_PER_KM])
		return 0
	var kilometres_for_full_rise := 1.0 / bound
	if kilometres_for_full_rise < MINIMUM_KILOMETRES_FOR_FULL_RISE:
		failures.append(
			("course pressure: slope bound %.4f per km lets the whole 0->1 rise "
				+ "be compressed into %.1f km, under the %.1f km floor. Owner "
				+ "requirement 2 is that difficulty rises gradually; a rise that "
				+ "fits in a fraction of the scoped range is a step with smooth "
				+ "edges.")
			% [
				bound,
				kilometres_for_full_rise,
				MINIMUM_KILOMETRES_FOR_FULL_RISE,
			])
		return 0
	return 1

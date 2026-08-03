extends RefCounted
class_name CoursePressure
## The one difficulty-amount curve: `pressure(d) ∈ [0, 1]`.
##
## [D-0054] R1. **Pressure is how much, never what kind.** Which axes a region
## spends it on — density, width, displacement, phase, verb, predictability — is
## the region's profile, and the scalar deliberately knows nothing about them.
## The doctrine's §4 explains why they are not interchangeable currency: a point
## of narrowing is not a point of density, and no validated conserved difficulty
## budget exists. This file is the orchestration instrument, not the exchange
## rate.
##
## `CourseAxisEnvelope` maps this scalar onto the shared Standard axes, and
## `CourseDifficultyProfile` composes mode-specific selection/cadence transforms
## without adding another distance law. Standard's exact output remains pinned
## by `UNCHANGED_COURSE_DIGEST` in `tests/unit/course_audit_tests.gd`.
##
## Distances are the simulation's authoritative pixel unit (10 px = 1 m), the
## same convention `CourseRegionCatalog` and `SwingConfig.spider_speed_cap_at`
## use. Metre figures appear only in comments and in tooling output.

## Owner requirement 1, 2026-08-02: *"the first 500m should remain as it is"*.
## Pressure is exactly zero here, so no term derived from it can put anything in
## the warm-up. R6 governs what the warm-up may contain; this constant governs
## only that the curve contributes nothing to it.
const WARM_UP_END_PIXELS := 5000.0

## The top of the OWNER-SCOPED RANGE, and deliberately not "the plateau".
##
## O1 — where the plateau belongs — is **deferred**, not answered: *"let's focus
## on the first 15K because that's actually something that's proven to be
## reachable."* The longest verified run is 10 605 m and five of the eight
## regions have never been reached, so any pressure target beyond here would be
## fitted to nothing.
##
## The curve therefore **clamps** at the edge of the evidence rather than
## extrapolating past it. Clamping and plateauing produce the same numbers today
## and mean opposite things: one says "this is where our authority ends", the
## other says "this is where the game stops getting harder". When the scope
## extends, this constant moves and the curve extends with it — which is exactly
## the edit a real plateau decision must NOT be able to hide inside.
const SCOPE_TOP_PIXELS := 150000.0

## How the rise is distributed between the warm-up and the top of scope.
##
## `assumed`, and it is **the one number the owner is meant to judge on device** —
## the doctrine's §7 asks for exactly this: put every knob on one curve so device
## time is spent judging one slope rather than re-authoring content chunk by
## chunk.
##
## Below 1.0 the rise is front-loaded. That answers the loudest complaint in his
## account — *"the start is too easy, the whole time I'm speeding through it with
## reel just to get it over with"* — and it leaves the curve **decelerating into
## the clamp**, which is the shape that survives O1 being deferred: if the
## plateau later turns out to sit at 40 km rather than 15, a decelerating tail
## stretches, while a curve still climbing hard at its top would have to be
## redesigned.
##
## It moves *where* pressure sits, not how steep the curve ever gets: measured
## across 0.7…1.0 the peak rise stays ≈ 0.10 per km. Steepness is bounded by
## `MAX_RISE_PER_KILOMETRE` independently.
const ONSET_SHAPE := 0.7

## R3, the bounded-slope rule — the one that exists to kill the 1750 → 2000 m
## cliff, where the authored label went 1.30 → 3.27 with 0% → 93% hard patterns
## inside 250 m.
##
## Derived as a ceiling rather than picked. Normalised onto this curve's 0…1
## scale, that cliff is a rise of **≈ 1.97 per km**; a bound anywhere near it
## re-permits the defect the doctrine exists to prevent. This bound is **13×
## below it**, and the shipped curve's own peak is ≈ 0.103, so a retune has
## roughly 45% headroom before it has to argue with the rule.
const MAX_RISE_PER_KILOMETRE := 0.15

const PIXELS_PER_KILOMETRE := 10000.0


## The curve. Monotone non-decreasing everywhere, zero through the warm-up,
## exactly 1.0 from the top of scope onward.
##
## Smoothstep over a front-loaded input: the smoothstep supplies zero slope at
## both ends, so the warm-up ends without a kink and the top is approached
## without one, and `ONSET_SHAPE` decides how much of the rise happens early.
static func at(distance_pixels: float) -> float:
	if distance_pixels <= WARM_UP_END_PIXELS:
		return 0.0
	var span := SCOPE_TOP_PIXELS - WARM_UP_END_PIXELS
	if span <= 0.0:
		return 1.0
	var progress := clampf(
		(distance_pixels - WARM_UP_END_PIXELS) / span, 0.0, 1.0)
	var shaped := pow(progress, ONSET_SHAPE)
	return shaped * shaped * (3.0 - 2.0 * shaped)


## Pressure gained between two distances. Never negative, because `at` is
## monotone; a negative result here would mean the curve had developed a dip.
static func rise_between(from_pixels: float, to_pixels: float) -> float:
	return at(to_pixels) - at(from_pixels)


## The steepest one-kilometre rise anywhere in `[from_pixels, to_pixels]`, which
## is the quantity R3 bounds.
##
## Sliding a full kilometre-wide window means a step of any width is caught: a
## cliff 10 m across still raises its enclosing window by the whole step. A
## per-sample difference would not — it would shrink with the sample spacing and
## report a cliff as a small number.
static func steepest_kilometre(
	from_pixels: float,
	to_pixels: float,
	step_pixels: float = 100.0,
) -> float:
	var step := maxf(step_pixels, 1.0)
	var steepest := 0.0
	var cursor := from_pixels
	while cursor <= to_pixels:
		steepest = maxf(
			steepest, rise_between(cursor, cursor + PIXELS_PER_KILOMETRE))
		cursor += step
	return steepest

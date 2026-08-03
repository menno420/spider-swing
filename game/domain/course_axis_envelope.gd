extends RefCounted
class_name CourseAxisEnvelope
## The pressure → axis mapping. **This is the file that gives `CoursePressure` a
## consumer**, and with it the thing the curve was written for: [D-0054] R1, one
## curve as the single source of difficulty *amount*.
##
## Phase 2 shipped the scalar with nothing reading it, deliberately, so the
## numbers could be judged before they were load-bearing. Phase 3 is this file.
## Every term below is a pure function of pressure alone — **nothing here reads
## distance, a region id, or a chunk's position in its region to decide how hard
## that chunk is.** Region identity still chooses *what kind* of content appears
## (R4: regions choose character, never amount); it no longer chooses how much.
##
## [D-0054] deliberately left the per-axis numbers unfixed, on the grounds that
## "a cap with no consumer is exactly the shape of the `difficulty` label F1
## calls dead metadata", and said each axis gets its numbers in the phase that
## gives it a consumer. This is that phase for four of them:
##
##   * **Density** — `recovery_share`, and R7's max-consecutive-challenge rule
##     falls out of it rather than being asserted separately.
##   * **Size** — `opening_scale` (the owner's Bramble opening ramp) and
##     `growth_scale` (which replaces `CourseStream._obstacle_growth_scale`'s
##     four distance steps with one continuous curve).
##   * **Vocabulary** — `admission_floor`, the R13 bounded-spread rule. This is
##     also what finally gives the `difficulty` label a consumer (R10).
##   * **Commitment** — `multi_obstacle_admitted`, which is "singles before
##     pairs" from the doctrine's §6.1 lever 3.
##
## Distances never appear here. Pressure does, and `CoursePressure` owns the
## distance → pressure step.

## Recovery share at the bottom and the top of the curve, and the shape between.
##
## Both endpoints are **shipped, measured, owner-seen values** rather than
## inventions — which is the whole reason this single curve can replace three
## per-region constants:
##
##   * **0.50** is Bramble Canopy's cadence exactly as the owner played it. It is
##     also the upper bound O2 names — *"it should not become 50/50 as in
##     Brambles right now"* — so the curve starts at the bound and only ever
##     moves away from it.
##   * **0.17** sits just under Silk Hollow's shipped 21%, measured as **N6** in
##     the course-audit baseline, and stays above the 2% Ancient Forest ships
##     today, which O2's other bound rules out.
##
## `ONSET` front-loads the fall so most of the fill happens where the owner asked
## for it — *"add some loose obstacles in between certain wide spaces instead of
## just repeating the same pattern"* — and so Ancient Forest's band lands near
## the 20% its own catalogue already claims as a "wide recovery rhythm" (F3).
##
## `assumed`: the endpoints are shipped values, the interpolation between them is
## a design hypothesis awaiting a device verdict.
const RECOVERY_SHARE_AT_ZERO := 0.50
const RECOVERY_SHARE_AT_TOP := 0.20
const RECOVERY_ONSET_SHAPE := 0.25

## The cadence is served as an integer interval — every `n`-th chunk is open —
## rather than as the raw fractional share, and the bounds are the two ends of
## that ladder. 2 is Bramble's shipped every-other-chunk rhythm and 6 is the
## sparsest the curve ever asks for.
##
## **Why an integer and not the exact share.** A fractional cadence has to place
## its openings by accumulator, and the phase then drifts against the 10.4 chunks
## that make up a kilometre — which shows up as ±10% swings in measured density
## that correspond to nothing anyone chose. An integer interval is also the thing
## R14 asks for and the fractional one is not: *"a demonstration is only a
## demonstration if the player can see the pattern as a pattern"*. The interval
## widening from 2 to 6 is legible from inside the run; a drifting accumulator is
## not. It is also exactly the mechanism that shipped (`recovery_interval := 5`),
## so this generalises an existing rule rather than replacing it.
const RECOVERY_INTERVAL_MINIMUM := 2
const RECOVERY_INTERVAL_MAXIMUM := 5

## Below this pressure a chunk may carry only a single obstacle commitment.
##
## Two rules meet here. **R6** protects 0–500 m, where pressure is exactly zero
## and no pattern is drawn at all, so the warm-up is covered by construction.
## **§6.1 lever 3** — *"singles before pairs"* — asks for one further stretch
## where Bramble shows its four single hooks and leaves before its four
## opposite-side pairs join them. `CoursePressure.at(10_000)` is 0.0252, so this
## admits pairs at almost exactly 1 km, which is the owner's own figure.
const MULTI_OBSTACLE_PRESSURE := 0.025

## The obstacle-size floor at the end of the warm-up, as a multiplier on whatever
## scale the difficulty mode already asked for.
##
## **`assumed`, and it is the number the owner is meant to judge on device.** The
## doctrine is explicit that this is the one lever that can look wrong rather
## than play wrong: *"how small an obstacle can be drawn before it looks wrong is
## a device call, not a measurable one."*
##
## Why 0.60 and not the doctrine's worked 0.45: today's entire shipped range
## across all three difficulty modes is 0.76–1.06, so 0.45 is a larger stretch
## than the art has ever been asked for. A **multiplier** rather than an absolute
## keeps each mode's own size intent — Standard's 0.90 floors at 0.54, Relaxed's
## 0.76 at 0.46, Harsh's 1.02 at 0.61 — so the ramp composes with modes instead
## of overriding them. At Standard that is a 300 px Bramble hook drawn at 162 px,
## 28% of the 572 px corridor, against 270 px and 47% at full size.
##
## It is exposed as `opening_obstacle_scale_floor` in the Test Lab; this constant
## is the default, not the only value the game can run.
const OPENING_SCALE_FLOOR := 0.60

## Pressure at which obstacles reach full authored size. `CoursePressure.at` puts
## 0.0637 at 1 500 m, which is the endpoint the owner named for the size ramp —
## and independently the endpoint R12's family-introduction arithmetic lands on
## (~1 440 m) for a section's vocabulary to be fully shown.
const FULL_SIZE_PRESSURE := 0.0637

## The late size term, replacing `_obstacle_growth_scale`'s four distance steps.
## 1.16 is that ladder's own top value, so the deepest content is the size it
## already was; everything below it is now reached continuously instead of in
## four jumps, which is what R3 asks of every term derived from the curve.
const GROWTH_AT_TOP := 1.16

## R13's bounded spread, expressed on the authored `difficulty` label.
##
## **This is what finally gives that label a consumer** — R10 says it becomes
## load-bearing or it is deleted, and F1 measured that nothing read it at all.
## The floor rises with pressure, so the easiest rungs of a graded pool drop out
## as the run goes on; the ceiling is the pool's own top, because R13 constrains
## the *distribution* ("a chunk may be easier than the current level, never much
## harder") rather than the chunk-to-chunk sequence.
##
## The endpoints span the labels actually authored inside the owner-scoped range:
## 1 is the easiest Ancient Forest control pattern, 4 the hardest thing in the
## first 15 km. Past 15 km pressure clamps at 1.0 and the floor clamps at 4.0,
## which admits every later pool in full rather than gating content nobody has
## measured.
const EASIEST_LABEL := 1.0
const HARDEST_LABEL := 4.0

## Where the authored tight-rail corridor becomes admissible. Previously keyed to
## `MASTERY_START_DISTANCE`, i.e. raw distance, which is exactly what R1 forbids.
## At 0.50 it lands around 6 km — inside Ancient Forest's new band rather than at
## its boundary, so the region ramps internally instead of stepping on entry.
const TIGHT_LANE_PRESSURE := 0.50

## Guards a float comparison against a label that is authored as an integer.
const LABEL_EPSILON := 0.001


## Share of chunks that are open recovery, at this pressure.
##
## Monotone **decreasing**, which is R7 seen from the other side: the maximum run
## of consecutive challenge chunks is `ceil(1 / share) - 1`, so a falling share
## is a rising ceiling on consecutive exposure.
static func recovery_share(pressure: float) -> float:
	var shaped := pow(clampf(pressure, 0.0, 1.0), RECOVERY_ONSET_SHAPE)
	return lerpf(RECOVERY_SHARE_AT_ZERO, RECOVERY_SHARE_AT_TOP, shaped)


## The recovery cadence: every `n`-th chunk is open. Monotone **non-decreasing**
## in pressure, which is R7 — the maximum run of consecutive challenge chunks is
## `n - 1`, so a widening interval is a rising ceiling on consecutive exposure.
static func recovery_interval(pressure: float) -> int:
	var share := recovery_share(pressure)
	if share <= 0.0:
		return 0
	return clampi(
		roundi(1.0 / share),
		RECOVERY_INTERVAL_MINIMUM,
		RECOVERY_INTERVAL_MAXIMUM,
	)


## Whether this chunk is an open recovery chunk. Pure in
## `(chunk_index, pressure)`, so a neighbour can be asked about without replaying
## that neighbour's selection.
##
## `previous_pressure` exists for one reason and it is a real defect it fixes:
## **at the chunk where the interval widens, the old phase and the new phase can
## both fire, putting two open chunks side by side.** A recovery pocket is a
## pocket; two in a row is a gap, and the shipped contract that forbids repeating
## a pattern in adjacent chunks catches it as `open_recovery` repeating. The
## later of the two is dropped rather than the earlier, which keeps the worst
## consecutive-challenge run at exactly `recovery_interval` — the absolute phase
## means the next opening is still only one interval away, not two.
static func is_recovery_chunk(
	chunk_index: int,
	pressure: float,
	previous_pressure: float = -1.0,
) -> bool:
	if not _cadence_fires(chunk_index, pressure):
		return false
	if chunk_index <= 0:
		return true
	var prior := pressure if previous_pressure < 0.0 else previous_pressure
	return not _cadence_fires(chunk_index - 1, prior)


static func _cadence_fires(chunk_index: int, pressure: float) -> bool:
	var interval := recovery_interval(pressure)
	if interval <= 0:
		return false
	return posmod(chunk_index, interval) == interval - 1


## R7 stated directly, for the audit and for contracts. Derived from the cadence
## rather than declared beside it, so the two cannot drift apart.
##
## Reports `recovery_interval`, not `interval - 1`: in steady state a run of
## challenge chunks is one shorter than the interval, but the widening transition
## above spends exactly one opening and produces a run of `interval`. A bound
## that only described the steady state would be wrong precisely where it matters.
static func max_consecutive_challenge(pressure: float) -> int:
	return maxi(0, recovery_interval(pressure))


## True once opposite-side pairs and other multi-obstacle patterns may appear.
static func multi_obstacle_admitted(pressure: float) -> bool:
	return pressure >= MULTI_OBSTACLE_PRESSURE


## The owner's Bramble opening ramp: obstacle size from the floor to full over
## 500 m → ~1 500 m. Exactly 1.0 everywhere above `FULL_SIZE_PRESSURE`, so this
## term is inert for every region after the first.
static func opening_scale(
	pressure: float,
	floor_scale: float = OPENING_SCALE_FLOOR,
) -> float:
	var safe_floor := clampf(floor_scale, 0.05, 1.0)
	if FULL_SIZE_PRESSURE <= 0.0:
		return 1.0
	var progress := clampf(pressure / FULL_SIZE_PRESSURE, 0.0, 1.0)
	return lerpf(safe_floor, 1.0, progress)


## The late size term. One continuous curve where four distance-keyed steps used
## to be; the top value is unchanged, so the deepest content did not move.
static func growth_scale(pressure: float) -> float:
	return lerpf(1.0, GROWTH_AT_TOP, clampf(pressure, 0.0, 1.0))


## The easiest authored `difficulty` label the curve still allows.
static func admission_floor(pressure: float) -> float:
	return lerpf(EASIEST_LABEL, HARDEST_LABEL, clampf(pressure, 0.0, 1.0))


## Whether a pattern carrying `label` may be drawn at this pressure.
static func admits_label(label: int, pressure: float) -> bool:
	return float(label) + LABEL_EPSILON >= admission_floor(pressure)


## R13 applied to a pool. **Never returns an empty array for a non-empty pool** —
## if the floor would exclude everything, the pool's own hardest rung is served
## instead. A silently empty pool would produce a chunk with no content at all,
## which is the failure mode S1 refuses: fail loudly or serve something real,
## never substitute in silence.
static func admitted_patterns(pool: Array, pressure: float) -> Array:
	if pool.is_empty():
		return []
	var admitted: Array = []
	var best_label := -1
	for pattern: Dictionary in pool:
		var label := int(pattern.get("difficulty", 0))
		best_label = maxi(best_label, label)
		if admits_label(label, pressure):
			admitted.append(pattern)
	if not admitted.is_empty():
		return admitted
	for pattern: Dictionary in pool:
		if int(pattern.get("difficulty", 0)) == best_label:
			admitted.append(pattern)
	return admitted


## Whether the authored tight-rail corridor is admissible at this pressure.
static func tight_lane_admitted(pressure: float) -> bool:
	return pressure >= TIGHT_LANE_PRESSURE

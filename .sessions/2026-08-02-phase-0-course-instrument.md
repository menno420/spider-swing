# Build the Phase 0 instrument, and let it disagree with the plan

> **Status:** `complete`

## Close-out

**Evidence:**

- source: `tools/course_audit_probe.gd` (the measurement),
  `tools/course_audit.gd` (CLI over it, so the gate and the command can never
  measure differently). **No gameplay value changed** — no file under `game/` was
  touched.
- contracts: five, in `tests/unit/course_audit_tests.gd`, registered in the
  runner. **Each was falsified independently before being trusted**, and one of
  those falsifications failed first in an instructive way (below).
- verify: **`python3 tools/verify.py --require-godot` — PASS, 216/216** against
  the pinned `4.7.1.stable.official.a13da4feb`. `bootstrap.py check --strict`
  passes; 0 broken links.
- docs: `docs/measurements/2026-08-02-course-audit-baseline.md` (the first
  output, six new findings), plus doctrine §8/R6/O3/appendix, `README.md`,
  `testing.md`, `current-state.md`.

**The instrument reproduces all four of the owner's felt difficulty boundaries
from geometry alone, with no play data.** He described them from device play —
too easy at the start, a sharp jump near 2 500 m, most deaths 2 500–5 000, easier
5 000–10 000, then a step at 10 km with no ramp. Every one of them appears in the
generator's own geometry, and the 2 500 m jump now has a mechanism: **the first
*sequential* opposite-side commitment in the entire run appears in km 2.**
Before it there are only simultaneous gates, which are threaded rather than
reacted to in sequence. Density and the authored label were already high by km 1;
the thing that actually changes where he says it changes is sequencing.

**The instrument disagreed with the plan twice, and that is why it exists.**

- **N1 — the whole of O3 was framed against the wrong number.** The doctrine
  built its spacing question on `high_low_weave` at 420 px / 0.60 s. Three
  `centre`-lane patterns are tighter: `hollow_spindle_gate` at **180 px**,
  `staggered_s` at 233 px, `stump_and_vine` at 252 px. **The real floor is 2.3×
  tighter than the figure the open question rested on**, and every `weave`-lane
  pattern is *looser* than all three — so the lane label does not predict timing
  pressure, which is precisely what an axis-vector approach exists to prevent.
- **N5 — R6 contradicts R12, and the generator sides with R12.** R6 says the
  first 500 m carries no lethal obstacle. Measured: chunks 1 and 4 each carry
  one, identically across every seed. That is exactly what R12's own first-gate
  row describes. The owner's requirement was *"the first 500m should remain as it
  is"*, so the rule needs rewording, not the generator.

**A trap the instrument was built to avoid, and hit anyway.** `rooted_gate`
places its ceiling and floor obstacles at an **identical x-range**. Timed as a
sequential pair it reads **0.00 s**, and the first run of the tool printed
exactly that — which would have made R13's spacing floor look violated
everywhere. Overlap in x separates a *width* challenge from a *timing* one, and a
contract now pins the distinction.

**Decisions made:** none. The instrument measures; it decides nothing, and
nothing here is a difficulty judgement.

**Next session should know:** the hazard telemetry § 3 of the research document
specifies — deaths over runs that *reached* a point, first exposure separated
from later — **still does not exist**, because it needs instrumented runs and
this tool only reads geometry. That is the other half of Phase 0. The remaining
queued work is expanded campaign levels and per-region endless modes (doctrine
§9), in that order.

## 💡 Session idea

**Falsify with the real failure, not a convenient one.** The corridor contract
was "falsified" first by injecting a bug that made the measurement *smaller* than
the truth — and the suite stayed green, because the real interior gap was larger
than the wrong value and `max()` swallowed it. For about a minute the honest
reading was "this contract is worthless".

It was not: the *actual* historical error measured from above the ceiling and
returned 10 066 px, which tripped the contract instantly. **The lesson is that a
falsification is itself a test, and injecting a plausible-looking bug is not the
same as injecting the one that happened.** Where a real prior failure is on
record — and here it was, in the doctrine's appendix — the falsification should
reproduce *that*, verbatim. This is now written into `docs/technical/testing.md`
beside the falsify rule, because the generic instruction did not prevent it.

## ⟲ Previous-session review

The previous session folded the deep research report into the doctrine and wrote
that § 3 of it was *"a specification for Phase 0, not background"*. That framing
was right and it paid immediately: the report's insistence on separating
first-exposure from later, and on never calling a geometric proxy "difficulty",
shaped every column this instrument emits and the disclaimer printed above its
own table.

**Workflow improvement:** it also over-promised by one step. The card said § 3
specified Phase 0, but § 3 is a *play-telemetry* spec — hazard rates, quits,
death causes — and none of that is reachable from a generator walk. Only about
half of it was buildable here, and the rest needs instrumented runs. **When a
document is called a specification for the next step, say which parts of it that
step can actually reach**, or the next session inherits a scope it cannot close
and either overreaches or quietly drops the remainder.

- **📊 Model:** opus-5 · high · feature build — Phase 0 course instrument

# Bot model v4 — teach the simulator to pump

> **Status:** `complete`

## Close-out

**Evidence:**

- source: `tools/simulate.gd` — `pump_window_deg` knob plus
  `RunDriver._in_pump_window`; `BOT_MODEL_VERSION` 3 → 4.
- docs added (1): `docs/measurements/2026-08-02-bot-model-v4-pumping.md`.
- docs updated (2): `docs/technical/simulation-lab.md` (publication rule now
  names v4 and its score), `docs/CAPABILITIES.md` (engine runs in this seat).
- verify: **`python3 tools/verify.py --require-godot` — PASS, 204/204**, run
  against the exactly-pinned `4.7.1.stable.official.a13da4feb`, both before and
  after the change. `python3 bootstrap.py check --strict` passes.

**What this session did.** Closed the blind spot cited in more places in this
repository than any other — *the bot cannot pump a pendulum* — and measured it
honestly on two disjoint seed sets.

**The mechanism.** Reeling makes you faster — `measured`, 79.2 → 74.5 m/s under
ablation — and the design's "speed-neutral" is narrower than it reads. What is
narrow is only the retraction step: `advance_resource` writes no velocity, and
the constraint afterwards removes outward radial velocity while preserving
tangential. Speed arrives one step later through the pendulum, by two routes —
the rope going taut redirects a radial fall into tangential travel, and
shortening below the anchor lifts the spider for free, injecting `m·g·dr` that
returns as speed on the next descent. Both peak at the bottom of the arc: the
lift from shortening `dr` is `dr·cos θ` off straight down, and the tangential
component the constraint preserves peaks there too. The old policy reeled on
being *below the route*, which correlates with the bottom of a swing but does
not imply it: low and far out to the side is the worst place to spend the meter,
and it was being spent there routinely.

**Correction, owner-caught.** The first draft of this work stated the mechanism
as "a reel adds no speed". That is the exact misreading
`2026-08-01-upgrade-playstyle-sweep.md` § "Reeling buys speed" warns against —
in a document this session had already read. The physics and the implementation
were unaffected (both mechanisms peak at the same phase, so the pump window is
unchanged), but the framing was wrong and was corrected in source, in the
measurement, and in the PR before merge.

**The finding worth carrying.** Pumping is worth **+46.0% at L40 against +14.8%
at L0**. That is not a coincidence — L40 reels at 454 px/s into a 2.67 s meter
against L0's 320 px/s into 2.00 s. **Pumping is how a bigger reel gets spent**,
and its absence mechanically explains a contradiction this repo has carried
unexplained: the lab reading reel upgrades as worthless while the owner reports
max upgrades playing far better than none. The L40 upgrade penalty shrank from
−37.7% to −20.7% — a large move toward his reality, still the wrong sign.

**What did not replicate, stated because it is the more useful half.** The
distance gain is seed-dependent: +14.8% on Set A became **+1.3%** on Set B.
What replicated across all four cells is **speed** (≈ +3.3 m/s) and
`reel_empties` rising 0.29 → 1.17 toward the owner's measured "empties in every
recorded L0 run". Pumping converts reliably into speed; whether that becomes
distance depends on what else binds.

**A fix that measured worse and was deleted.** A release-arc gate — postponing a
discretionary release until the `_release_web` award would actually be paid —
cost 9% at two different thresholds and raised deaths/km 1.11 → 1.22. Deleted
rather than parked behind a default-off knob, following the practice set by v3's
three deleted fixes. It is bot evidence, not a tuning verdict, but it belongs in
front of OQ-16.

**A hypothesis that failed.** If the speed-for-deaths trade were purely
reading-bound, more reading time should flip the upgrade sign. It does not
behave monotonically (−20.7% at 7/6 ticks, −24.0% at 4/3, −8.1% at 2/2), and L0
itself is not monotone in cadence. Recorded as a negative result so it is not
re-run expecting a clean answer.

**Decisions made:** none that touch the game. No physics, progression, course,
bird or economy value changed; the diff outside `tools/` is documentation.
**The publication rule is unchanged and this session did not weaken it** — v4
scores about two and a half of eight acceptance targets and still fails the
upgrade sign, the whole warp band, and sustained pace.

**Next session should know:** every pre-v4 batch in `docs/measurements/`
reproduces only with `--bot=pump_window_deg:0`; `BOT_MODEL_VERSION` prints in
each batch header. The warp band is where the model still collapses — 361 m
median net progress at 3.76 deaths/km against the owner's 3 113 m at 0.32 on the
same warp — and its sustained speed there is 26 m/s below the reference curve.
That, not pumping, is the next fidelity target.

## 💡 Session idea

**The speed-for-deaths trade is now visible in the model, and that makes it
testable rather than merely argued.** Every cell measured this session where the
bot got faster, it also died more per kilometre — four independent ways, across
two seed sets. The upgrade-and-difficulty research reached the same conclusion
from source arithmetic (fixed 700–820 px hazard cues and a fixed 853 px camera
preview, so warning *time* falls as `1/v`). Two instruments that share no
assumptions now agree.

That suggests a cheap, decisive experiment nobody has run: make the bot's cue
lead **time-based instead of distance-based** in a throwaway branch, and see
whether the upgrade sign flips positive. If it does, the repository has a
model-side prediction that the fixed-distance cue is what caps the payoff of
every propulsion upgrade — the strongest possible argument for the change
before spending device time on it. If it does not, the recommendation loses its
best supporting evidence and should be weakened accordingly. Either outcome is
worth more than another round of window tuning.

## ⟲ Previous-session review

The previous session (the research synthesis, PR #110) recorded that its
findings had to be verified against source because an external review had
independently caught a 10×-off reading in an earlier analysis. That habit paid
off immediately here: this session's first instinct was that the pump window
should be *narrower* for weaker players, which is backwards — a sloppier player
has a **wider**, less efficient window, and the sweep measured wide windows as
strictly worse. Catching that before committing kept the tier table monotone in
the right direction.

**Workflow improvement:** the seat began with no engine and `verify.py` honestly
reported the engine steps as SKIPPED — which reads like a wall and is not one.
One download makes the full 204-contract suite and the whole simulation lab
available. That is now an explicit `docs/CAPABILITIES.md` entry with the recipe,
because two sessions in a row shipped source-adjacent work without ever running
the engine that would have checked it.

- **📊 Model:** opus-5 · high · research — bot-model fidelity and pumping

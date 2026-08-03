# The curve gets a consumer, and Bramble opens the game

> **Status:** `complete`
>
> **One deviation from the card discipline, recorded rather than hidden:**
> this log was written at close-out and committed already `complete`,
> not born `in-progress` as the session's first commit. The rule exists so
> parallel sessions can see in-flight work; nothing else was running here,
> so the cost was zero — but back-dating a born-red commit now would be
> theatre, and the honest record is that the discipline was skipped.

## Goal

Deliver a playable, buildable first 15 km: selection driven by
`CoursePressure` instead of by distance thresholds, the first two regions
swapped, the width envelope enforced, the two measurements nothing was watching
built, and an Android debug APK the owner can install and judge on device.

## Scope guard

Standard only. **Difficulty modes untouched** — D-0055 makes them profiles
derived from Standard and Standard is what this builds. No per-difficulty
leaderboards, no per-region endless, no Field Guide dead-space item (withdrawn),
and **Silk Hollow is not narrowed** — its 10 km wall is a timing wall and the two
`hollow_lattice_*` patterns are widened rather than anything else being tightened.

## Previous-session review

The width-envelope session ended with three width claims retired and two
measurements named as belonging in the probe. Both of those calls paid off
immediately and in the direction they predicted: the swing-class floor caught
`hollow_lattice_*` the moment it became a contract, and constriction length
produced a finding on its first run — **Silk Hollow's pinches are 3.4× shorter
than Bramble's or Ancient Forest's** (120 px against 408), which generalises C1's
`hollow_spindle_gate` result to the whole region and supports its own
instruction that Silk's difficulty should come from spacing.

Its one weakness was that it wrote D-0056's distribution terms as though they
were already achievable — *"no more than ~6% of chunks near the minimum"* — when
two of the three regions shipped at 26% and 18%. Contracting that would have
failed on the first run against content the owner has never complained about.
**What is contracted here is the part that is true and must stay true** (the
class floor, the backstop, the consecutive-run bound); the share is reported and
left uncontracted, with the reason recorded.

## What was decided

**[D-0057] — pressure spends four named axes, and the swap lands with it.**
`CourseAxisEnvelope` (`game/domain/`) maps the scalar to the recovery cadence,
obstacle size, the admissible authored rungs, and multi-obstacle admission.
Three distance laws deleted: the control/mastery/deep ladder at 1/2/3.5 km,
`MASTERY_START_DISTANCE` gating the tight corridor, and `CONTROL_START_DISTANCE`
deciding whether any pattern exists. Bramble opens the game; Ancient Forest
follows; Silk Hollow unchanged. **D-0054 said the per-axis numbers get set in the
phase that gives each axis a consumer — this is that phase, so they are set here
and nowhere earlier.**

**[D-0058] — width is watched as a duration, not only as a minimum.**
Constriction length within a chunk and the longest run of consecutive chunks near
a region's minimum enter the probe, the audit and the suite, pinned as
measurements rather than as difficulty. The two patterns D-0056 named are fixed:
lattice height 292 → 258 px, swing-class minimum 6.69 → **7.75** diameters.

## The digest contract failed, and that was the point

`UNCHANGED_COURSE_DIGEST` pinned a course nothing read the curve for. It is
re-pinned in the same commit that moved the behaviour, because the whole reason
it exists is that **no generator change may land looking like a no-op**. Nothing
was worked around.

## Measured, 0–15 km, three seeds

| | recovery | mean label | tightest sequential pair |
| --- | ---: | ---: | ---: |
| Bramble Canopy | 50.0% → **28.3%** | 2.00 → **2.28** | 0.77 → **0.87 s** |
| Ancient Forest | 2.4% → **23.1%** | 2.81 → **2.88** | 0.29 → **0.26 s** |
| Silk Hollow | 21.2% → 21.2% | 3.15 → 3.15 | 0.20 → 0.20 s |

- **The 2 km cliff is gone** — there is no distance threshold left to step at.
  Steepest kilometre of pressure 0.1032 against the 0.15 bound.
- **The saw-tooth is inverted.** Region means run 2.28 → 2.88 → 3.15 in play
  order where they ran 2.81 → **2.00** → 3.15. Worst three-kilometre rolling dip
  **17.4% → 4.1%**.
- **Recovery share is inside O2's (2%, 50%) in every region**, from one curve
  replacing three per-region constants. Ancient Forest's 23.1% is the "wide
  recovery rhythm" its catalogue has claimed since before F3 measured it at 2%.
- **The width envelope holds.** Swing-class minimum 7.75 d, absolute minimum
  7.39 d against R8's 3.0 backstop — 2.5× margin, so the backstop stays a
  backstop.

Full numbers, both columns and the method:
[`curve-driven course`](../docs/measurements/2026-08-03-curve-driven-course.md).

## What I guessed, and why

Three values the brief said to pick rather than agonise over. All `assumed`, all
recorded where a device verdict can overrule them.

1. **Obstacle size floor: 0.60, as a multiplier on the mode's own scale.** Not an
   absolute — a multiplier composes with difficulty modes instead of overriding
   them, so Standard floors at 0.54 effective, Relaxed at 0.46, Harsh at 0.61. At
   Standard that draws a 300 px Bramble hook at 162 px, 28% of the corridor. The
   doctrine's worked example was 0.45; today's entire shipped range is 0.76–1.06,
   so 0.45 is a bigger stretch than the art has ever been asked for and 0.60 is a
   defensible first ask. **Exposed as `opening_obstacle_scale_floor` in the Test
   Lab**, which is where the doctrine says this one belongs.
2. **Recovery share interpolates 50% → 20%, front-loaded.** Both endpoints are
   *shipped, owner-seen* values rather than inventions: 50% is Bramble's own
   cadence and O2's stated ceiling, 20% is just under Silk Hollow's measured 21%.
   Only the shape between them is a guess.
3. **The fill starts at ~740 m, not the ~1500 m the doctrine names.** The
   cadence widens 2 → 3 there, which is what fills Bramble's open chunks. 1500 m
   is where the *size* ramp finishes; running the two together would have left
   0.5–1.5 km unchanged, which is exactly the stretch the attrition data blames
   for the 41% spike at 2 km.

## What got worse, said plainly

**Ancient Forest's tightest sequential pair reads 0.288 s → 0.261 s on unchanged
geometry.** Spacing is measured at the speed cap and 5–10 km is a faster band of
the pace curve than 2–5 km was. The owner clears 0.29–0.31 s on this exact
content today and now meets it 3 km later — but 9% tighter is 9% tighter, and
**this is the sharpest device question in the slice.**

**The thinnest pool in the game is now the opening region.** Bramble has eight
patterns against Ancient Forest's ladder of 38; §9 measures that as 13×
repetition over a 5 km slot. The doctrine's Phase 4 is explicit that this lands
with no new patterns authored, so it is a known cost rather than a discovery.
Partly offset: F7's memorisable four-beat loop is gone, so sequence variety rose
as vocabulary variety fell, and the contract that used to ask for ten distinct
ids in that window now asks for **all nine Bramble can produce**.

**One Harsh override became a no-op.** Standard's warm-up moved to the 500 m
Harsh already overrode to. Kept rather than deleted — it still records intent,
and D-0055 gives Harsh its real separation in the mode-profile phase.

## Defects the suite caught that I would not have

Three, all real, none cosmetic. Recorded because each was invisible in review.

1. **The tight-rail corridor would have vanished from the first 15 km.** Its slot
   was `chunk % 8 == 7`, which implies `chunk % 4 == 3` — exactly where the new
   cadence puts its opening at the interval Ancient Forest runs. Every tight rail
   landed on a recovery chunk. Moving it to slot 5 of 8 makes it coprime with
   both intervals the region uses. My first fix — letting it *replace* the
   opening — was worse: it produced a run of **ten** commitment chunks with one
   empty chunk in it.
2. **Two open chunks side by side at every cadence transition.** The old and new
   phases both fire on the chunk where the interval widens. The later one is
   dropped, which keeps the worst run at exactly the interval.
3. **The committed input trace replayed into a course that no longer exists** and
   landed 1 586 m short *without erroring*. §11 claimed traces "fail loudly
   rather than silently" across a generation change; they did not, because
   nothing had told the format the world had moved. `INPUT_TRACE_FORMAT` is @5
   now and the fixture is re-recorded from the lab.

## Falsification

Every new contract was broken in the way it exists to catch, **each in
isolation**, with a byte-for-byte backup restore and a green baseline proven
before and after the whole run — `git checkout --` is a no-op on an untracked
file and has already contaminated a falsification run in this repository. Eight
mutations, eight caught, table in the measurement doc. The one that took three
attempts is worth keeping: reverting the region order *did not* reproduce the
saw-tooth, because with the curve in place the amount no longer depends on which
region sits where. That is the strongest single piece of evidence that R1 landed.

## Close-out

**Evidence:**

- source: `game/domain/course_axis_envelope.gd` (new), plus
  `course_pattern_catalog.gd`, `course_stream.gd`, `course_region_catalog.gd`,
  `player_progress.gd`, `swing_config.gd`, `zone_course_builder.gd`,
  `trace_catalog.gd`, `tuning_catalog.gd`, the probe and the audit.
- verify: `python3 tools/verify.py --require-godot` — **232/232**, all seven
  stages pass. `python3 bootstrap.py check --strict` — all checks passed.
- build: `0.39.0-pressure-curve-region-swap`, Android version code 59, bumped
  across all four pinned files.

**Decisions made:** [D-0057], [D-0058].

**Next session should know:** the owner has an APK to judge and **three specific
questions to answer on device**, in order of how much rides on them — (1) does
Ancient Forest at 0.261 s still read as "the right kind of difficult" now that it
sits at 5–10 km; (2) does a 162 px Bramble hook look wrong, which is the only
question the size floor cannot answer without him; (3) does the first 2 km still
invite reeling through it. The reel-usage-per-kilometre proxy the attrition doc
names has a **predicted direction** for (3) and still costs nothing to log.

## 💡 Session idea

**A contract that pins a per-kilometre statistic is fighting the chunk grid, and
the grid wins.** A kilometre is 10.4 chunks, so any per-kilometre share aliases
against the bucket boundary by ±10% no matter what the generator does — which
means a monotonicity bound tight enough to catch a real regression is also tight
enough to fail on quantisation. Three attempts here died on that before the
contract became a three-kilometre rolling window.

The general form is worth a line somewhere: **when a measurement's natural unit
is not a whole number of the thing being measured, pin a window rather than a
point, and pick the window by falsifying against the defect** — three kilometres
was chosen because it is the smallest window that still rejects the pre-swap
course, at 17.4%, not because it looked smooth. Cheaper alternative when it
applies: bucket by chunk count instead of by distance, which removes the aliasing
entirely at the cost of a less readable table.

## ⟲ Previous-session review

Covered above under its own heading — the two probe measurements that session
named both paid off on their first run, and its one overreach (writing D-0056's
share target as though it were achievable) is corrected here by contracting the
parts that hold and reporting the part that does not.

**Workflow improvement:** that session's scope guard said "no code, no contract"
and was right to. But it left the *implementation* of its own decision entirely
to a later session with no note of what would break — and eighteen contracts
broke here, most of them encoding the region layout in a scan range. **A decision
that moves content should list the contracts whose fixtures live in that
content**, even when it deliberately does not touch them. Ten minutes of grep at
decision time would have replaced an hour of discovery.

- **📊 Model:** opus-5 · high · feature build — Phase 3 + Phase 4 in one slice

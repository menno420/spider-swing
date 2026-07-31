# Death confirmation survives an in-flight tap; the tutorial leads with the aimed Burst

> **Status:** `complete`

## Goal

Fix two things the owner's 5000 m depth-run recording exposed: a death
confirmation window that a tap already in flight can consume entirely, and a
tutorial that teaches the weaker of two Burst controls first.

## Scope guard

One guard clause in the session's tap entry point, one tutorial string, one new
contract. No physics values, no new UI, no control removed.

## Previous-session review

**previous-session review:** PR #61 landed the `balanced_baseline` promotion with
the "never a comparison" caveat intact, which was the right call. Two process
misses. It ran the substrate gate against an uncommitted tree, so the
session-card grammar rule — which only fires on cards **added in the diff** —
never applied, and CI caught a taxonomy violation that a post-commit run
reproduces instantly. And it left a watcher polling for an auto-merge that a
mid-flight conflict had silently disarmed; the PR sat green and unmerged until
checked by hand. Verify diff-aware checks after committing, and confirm
`auto_merge` is actually armed rather than trusting that its workflow succeeded.

## What the recording showed

48 s at 1040×480/60, a debug run from 5000 m with L20 upgrades. Frame extraction
(1 fps contact sheets, then 20 and 60 fps around the interesting moment) gives:

- `DEBUG START 5000 m · UPGRADES L20 · AWARDS NOTHING` held for the whole run —
  debug start, the session-only upgrade overlay, and the noncompetitive label all
  behave on device.
- `BRAMBLE CANOPY` correct for the 5000–10000 m band; one rescue consumed near
  8100 m (`RESCUE READY` → `RESCUE SPENT`); 63 flies collected; run ended at
  **8652.2 m**.
- Pace flat at **76.4 then 77.2 m/s** across the two halves. With
  `PIXELS_PER_METRE = 10` that is `maximum_target_speed` (760 px/s) exactly, and
  `speed_curve_distance` completes at 5000 m — so a debug start at 5000 m hands
  the player the end of the speed curve on frame one, with no ramp at all. Worth
  recording because it explains the difficulty without anything being wrong.
- Attachment rhythm sampled from the contextual action button at 2 fps across
  94 samples: **21 detached / 73 attached**, roughly 22% airborne. An earlier
  read of the contact sheets suggested near-continuous attachment; counting
  refuted it.

## Fix 1 — a tap in flight ate the death confirmation

`death_confirmation_seconds` is 0.45 s. The recording shows the `FALLING…`
overlay for roughly **80 ms** before a fresh run begins at 5002 m.

`request_web_tap` restarted the run on any non-`ACTIVE` state, which includes
`DYING`. At 77 m/s the player taps continuously, so the next queued tap lands
inside the dying window and restarts before the cause can be read. The overlay
only offers "Tap anywhere to restart" once the run is `DEAD`, so the behaviour
and the advertised affordance disagreed.

Now `DYING` swallows the tap; `DEAD` still restarts on one. This is the GDD §23
exit criterion "most test deaths can be correctly attributed by the player" —
at speed it was close to unattainable.

## Fix 2 — the tutorial taught the weaker Burst first

The owner reports never using the BURST button in normal play: at speed, reaching
for it is not feasible, and double-tapping where you want to go is the natural
action. The code says his instinct is not merely preference — the two paths are
not equivalent:

| | BURST button | Double-tap |
|---|---|---|
| command | `InputCommand.burst` — unaimed | `InputCommand.burst_at(target)` — aimed |
| while a pull owns motion | fires anyway | reinterpreted as an attach |
| detached with no charges | nothing useful | reinterpreted as a recovery web |

The gesture takes a direction *and* degrades into the useful action rather than
wasting the input. Tutorial step 05 led with the button and mentioned the gesture
second; it now leads with the gesture and frames the button as the unaimed
fallback. Copy only — both controls still work exactly as before.

## Shipped

- `game/application/swing_lab_session.gd` — `request_web_tap` ignores taps during
  `DYING`.
- `game/application/front_end_state.gd` — tutorial step 05 copy and tip.
- `tests/unit/phase0_physics_tests.gd` —
  `_test_dying_window_is_not_eaten_by_an_in_flight_tap`.
  `EXPECTED_CHECK_COUNT` 119 → 120.

## Verification

Real exit codes, no pipes:

- `python3 tools/verify.py --require-godot` against Godot 4.7.1 stable →
  **exit 0**, **120 contracts**.
- **The new contract was falsified before it was trusted.** Reverting only the
  guard clause and re-running the suite → `FAIL — 1 failed`; restoring it →
  `PASS — 120`. A contract that has never failed is a claim, not a test.
- `python3 bootstrap.py check --strict` → green, run after committing so the
  diff-aware card rules actually apply.

## Open owner questions

**What should the BURST button become?** It is now documented as the unaimed
fallback, but if it stays unused in practice it is occupying a large, prominent
touch target for nothing. Options, none urgent: leave it (costs only space);
shrink it and give the room to the play area; or make it aim at the current
heading so it is no longer strictly worse than the gesture. This is a control-
layout change on the surface the owner actually plays, so it is his call rather
than a contained one — flagged, not taken.

## A frame-sampling read that was wrong, recorded so it is not repeated

Reviewing the contact sheets, this session told the owner the challenge "lives
on the edges" with an empty middle, and that difficulty past 5 km was close to
flat. He corrected both from play, and the source disagrees with the session,
not with him.

`BRAMBLE_CANOPY_PATTERNS` — the region this recording is in — leads with
`high_low_weave` and `low_high_weave` at difficulty 4, and its own comment says
region two "emphasizes fast vertical reading… difficulty comes from changing
height, not precision." Most of its remaining patterns (`tall_vine`, `long_pod`,
`vine_curtain`, `bramble_steps`) are vertical-displacement patterns too. Beyond
that, `pattern_for_chunk` escalates again at 10 km, 20 km and 35 km, and each
region carries its own set. The difficulty curve is composed, not flat; only the
*speed* component finishes at 5 km.

The methodological lesson is the reusable part. **A still frame shows geometry
but not trajectory constraint.** A weave renders as an empty centre with hazards
at the rails, because the empty centre *is* the route you are being forced
across — the obstacle is the displacement requirement, which exists between
frames and not in any one of them. Frame extraction answers "what is on screen";
it cannot answer "what did the player have to do to still be alive." Ask the
owner, or read the pattern catalog, before characterising difficulty from
sampled frames.

## 💡 Idea

`tools/simulate.gd` already runs headless bot runs with fixed seeds. Pointing it
at deaths-per-kilometre across the band boundaries (5 km, 10 km, 20 km, 35 km)
would turn the difficulty curve from an argument into a measurement, and would
have prevented this session's wrong claim outright. It is also the natural
baseline to hold the queued difficulty modes against.

- **📊 Model:** opus-5 · high · runtime bugfix — death confirmation window and
  Burst discoverability, from device evidence

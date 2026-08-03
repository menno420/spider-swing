# Let players practise each tutorial lesson directly

> **Status:** `complete`

## Goal

Turn the focused tutorial into a short teaching loop: start the real simulation
from a practice-enabled lesson, prove the requested authoritative action,
receive clear completion feedback, and return to that same lesson.

## Scope guard

This PR adds centralized application-owned tutorial objectives, deterministic
noncompetitive runs, in-run coaching/progress, and same-lesson return. It does
not grant Campaign stars, flies, records, checkpoints, leaderboard eligibility,
or persistent tutorial completion, and it does not change physics or course
truth.

## Previous-session review

**previous-session review:** PR #156 replaced the generic tutorial renderer with
eight stable, production-asset lessons and merged before this branch started.
That work deliberately kept its launch honest as `START RUN`; this PR consumes
the stable lesson ids and current `origin/main` without reopening presentation
ownership or changing any source-backed mechanic explanation.

## Delivered

- `TutorialPracticeCatalog` gives all eight lessons stable centralized practice
  metadata; Attach, momentum Release, Reel, Anchor Burst, and Dive Recovery own
  direct fixed-seed objectives.
- Reel, Burst, and Dive reuse Campaign's shared `*_STARTED` verb meanings.
  Attach requires `ATTACHED`; release requires a positive simulation-awarded
  `forward_bonus`; Dive Recovery requires Dive followed by `dive_rearmed`.
- `RUN_TUTORIAL_PRACTICE` uses the real simulation, input, HUD, selected spider,
  cosmetics, and upgrades on deterministic Standard geometry. Its objective HUD
  remains enclosed through strict 1040×480.
- Completion, confirmed death, and Menu return to the originating lesson.
  Completion feedback is session-only, and tutorial practice creates no
  settlement or persistence path.
- Android identity is `0.41.0-tutorial-practice`, version code 61, app name
  `Spider Swing Tutorial Practice (dev)`.

## Verification

- `python3 tools/verify.py --require-godot` — PASS with Godot
  `4.7.1.stable.official.a13da4feb`; 244/244 contracts.
- Focused test runner — PASS, 244/244 after restoration.
- Reward-boundary falsification: disabling the tutorial settlement guard failed
  with `tutorial practice emitted a settlement or checkpoint`.
- Wrong-verb falsification: accepting any Campaign verb failed with
  `distance or the wrong verb advanced reel`.
- Both mutations were restored byte-for-byte from commit `2373436`, then the
  full contract runner returned green.

## Pull request

- PR [#159](https://github.com/menno420/spider-swing/pull/159) — Let players
  practise each tutorial lesson directly.
- Owner action needed before merge: **None**. Device teaching-loop review follows
  from the installable Android artifact; issue #2 remains open.

## 💡 Session idea

With the tutorial now explaining and rehearsing the live verbs, the next planned
slice is D-0055: make Relaxed and Harsh explicit pressure-envelope course profiles
while preserving Standard's exact digest and leaving physics unchanged.

- **📊 Model:** gpt-5.6-sol · high · feature build

# Phase 0 — Swing Laboratory implementation session

> **Status:** `complete`

## Goal

Implement GitHub issue #2 end-to-end: deterministic world-space movement,
validated web attachment, manual momentum-preserving detach, continuous Reel-In
energy, camera/world boundaries, touch-safe buffered input, graybox presentation,
runtime tuning, diagnostics, replay, and trajectory tests.

## Scope guard

This session implemented GDD Phase 0 only. It did not add procedural chunks,
obstacles, collectibles, economy, progression, multiple spiders, monetization, or
production art. The owner-facing exit gate remains real-device feel approval.

## Previous-session review

**previous-session review:** the founding bootstrap was reviewed against
`main`, merged PRs #1/#5, live engine CI evidence, the pinned GDD checksum, and the verified project shell. Its architecture and build substrate remained intact.

## Outcome

- Added engine-independent commands, events, snapshots, tunable configuration,
  and three deliberately unapproved candidate presets.
- Added one authoritative 60 Hz point-mass simulation with gravity, forward
  drive, velocity caps, left/lower bounds, a nonlethal open top, and a capped
  maximum-length rope constraint.
- Added attach validation, velocity-preserving detach, tension feedback, and
  finite Reel energy with drain, regeneration delay, and lockout.
- Added `RunStateMachine` and `SwingLabSession` as lifecycle/fixed-step owners.
- Added a multi-touch `InputRouter`; Reel and lab controls never double-fire a
  web command, held input is cleared on focus loss, and simulation never polls UI.
- Replaced the placeholder with a code-drawn graybox lab: anchors, spider, web,
  follow camera, distance/speed HUD, Reel ring, event feedback, candidate
  selection, live tuning, pause, frame-step, quarter-speed, record/replay, and
  diagnostic JSON export.
- Added one recorded command fixture and eight deterministic physics contracts.
- Updated the README, testing guide, current-state ledger, architecture index,
  heartbeat, and the dedicated owner playtest guide.
- Removed the work claim after closing the implementation scope.

## Verification evidence

- **game-quality:** PASS on
  https://github.com/menno420/spider-swing/actions/runs/30350393128 using Godot
  `4.7.1.stable.official.a13da4feb`.
- **Host verification:** all six stages passed: 14/14 architecture fixtures,
  inward scan, exact engine pin, headless import, boot smoke, and headless runner.
- **Runtime runner:** PASS — 16 checks. The Phase 0 group passed 8/8, including
  detach velocity, Reel no-teleport, invalid-target inertness, repeat attach/detach
  energy, top/lower boundary outcomes, and identical recorded-trace results under
  simulated 30/60/90/120 Hz render loops.
- **GDD:** untouched; the frozen
  `docs/game-design/Spider-Swing-GDD-v2.0.md` remains the source of truth.
- **PR:** https://github.com/menno420/spider-swing/pull/6
- **Final gate expectation:** this complete card removes the designed born-red
  hold; both `game-quality` and `substrate-gate` must be green before merge.

## Documentation audit

**docs audit:** PASS. Durable docs describe the playable candidate, the exact
controls, tuning candidates, deterministic checks, debug/reproduction workflow,
later-phase boundary, and the real-device approval gate. The architecture index
points each area to the implemented owner and forbids parallel motors, constraints,
input paths, lifecycle owners, and mutable presentation state.

## Flagged reversible decisions

- The spider is a deterministic point mass, not a Godot rigid body.
- The web is a capped maximum-length constraint rather than a spring joint.
- The first three values are named `balanced_candidate`, `weighty_candidate`,
  and `agile_candidate`; none is a baseline until the owner approves it.
- Phase 0 visuals are code-drawn graybox art to keep movement legible and avoid
  committing to a production style before feel is proven.
- The top is open and nonlethal; the lower and trailing bounds request one death.
- Invalid taps produce visible feedback and no partial constraint.
- Quarter-speed advances one simulation tick every four physics callbacks, while
  frame-step advances exactly one tick.
- Recorded commands and automated trajectory tests share the same JSON shape.

## Owner gates

1. Play all three candidates on a real phone and approve one or request
   concrete changes.
2. The existing GitHub plan decision for protecting `main` remains open; this
   session did not change repository visibility or spend money.

## 💡 Idea

The same recorded command trace now drives regression tests and runtime replay.
A subjective “that swing felt wrong” report can therefore arrive with a small,
deterministically replayable diagnostic instead of a video-only guess.

- **📊 Model:** gpt-5 · high · feature build

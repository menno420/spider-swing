# `game/adapters/` — the edges

**Rank 3. Depends on `domain`, `simulation`, `application`. Peer of `presentation`
— must not depend on it.**

Everything that talks to the outside: Godot input, scene wiring, persistence,
telemetry, platform integration.

## What belongs here

- **Input Router** — converts touch and UI input into buffered `InputCommand`
  values. Input is sampled during rendering and consumed on the next physics tick;
  a valid tap is never lost between ticks (GDD § 5.3). UI touches must never fire a
  web through the UI.
- **Save Repository** — the *exclusive* owner of persistent writes. Atomic,
  versioned, with a recovery path for interrupted writes and forward migrations
  (GDD § 20).
- **Platform integration** — haptics, lifecycle/suspension handling.

## Rules

- Nothing else may write persistent state. Collision callbacks, UI nodes,
  presentation code, and telemetry may never write currency, records, unlocks, or
  save files.
- App suspension during death or results must not duplicate rewards (GDD § 20).
- Never references `presentation` — they are peers. Shared needs go inward into
  `domain`, or invert through an event.

## Current contents

- `input_router.gd` owns GUI-consumed Reel, Burst, DEBUG, and Menu input before
  world taps reach `_unhandled_input`. It derives the rope-action hit rectangles
  from `LabLayout` and converts accepted Reel/Burst events into distinct handheld
  haptics when the independent persisted setting is enabled. Its OVERLAYS controls emit presentation-diagnostic intent; they do not
  mutate simulation or course geometry.
- `save_repository.gd` is the exclusive persistent writer. It stores versioned
  PlayerSettings, PlayerProgress, DebugTestProfile, diagnostics, and the
  independently versioned bounded RunRecordLedger through the shared
  temp/primary/backup seam; every future persistent system must extend this seam
  rather than duplicate it.
- `clipboard_adapter.gd` owns the explicit platform clipboard call for the
  owner-selected local JSON export. It makes no network call and does not claim
  paste success from an API that supplies no acknowledgement.

See ADR 0002, [`front-end-flow.md`](../../docs/technical/front-end-flow.md), and
[`run-evidence.md`](../../docs/technical/run-evidence.md).

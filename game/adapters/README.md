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
- **Telemetry Adapter** — privacy-conscious balance and technical events, optional
  and resilient offline (GDD § 22.3).
- **Platform integration** — haptics, lifecycle/suspension handling.

## Rules

- Nothing else may write persistent state. Collision callbacks, UI nodes,
  presentation code, and telemetry may never write currency, records, unlocks, or
  save files.
- App suspension during death or results must not duplicate rewards (GDD § 20).
- Never references `presentation` — they are peers. Shared needs go inward into
  `domain`, or invert through an event.

## Current contents

- `input_router.gd` owns GUI-consumed Reel, DEBUG, and Menu input before world
  taps reach `_unhandled_input`.
- `save_repository.gd` is the exclusive persistent writer. It currently stores
  versioned PlayerSettings through a recoverable temp/backup rotation and is the
  seam future progression persistence must extend rather than duplicate.

See ADR 0002 and `docs/technical/front-end-flow.md`.

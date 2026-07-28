# `game/application/` — orchestration

**Rank 2. Depends on `domain` and `simulation`.**

Coordinates the run. Owns lifecycle and sequencing; does not own physics truth.

## What belongs here

- **Front-end State** — owns Home/Tutorial/Settings navigation, tutorial
  progression, validated player settings, and the request to begin a run.
- **Run State Machine** — countdown, active run, dying, settlement, results,
  restart. Requests exactly one `RunSettlement` after death (GDD § 19.1).
- **Difficulty Director** — selects curated chunks from speed, entry-state
  envelope, history, and seed. Never improvises an unvalidated lethal layout; falls
  back to a safe recovery chunk (GDD § 9.2).
- **World Stream** — spawns, pools, positions, and retires selected chunks.
- **Effect State** — applies, refreshes, expires, and reports power-ups. Refresh
  does not stack strength unless explicitly specified (GDD § 11.3).
- **Score and Settlement** — tracks distance and run stats, creates one idempotent
  settlement.
- **Progression Service** — applies validated settlements, purchases, unlocks, and
  mission progress.

## Rules

- The Difficulty Director selects; World Stream owns the spawned instances. Those
  are separate responsibilities and must not merge.
- Settlement is created once and is idempotent: applying the same settlement twice
  has no effect (GDD § 20).
- Never references `adapters` or `presentation`.

## Current contents

`FrontEndState` owns pre-run navigation and settings intent.
`SwingLabSession` owns the active laboratory command buffer, fixed-step order,
candidate presets, snapshots, recording, replay, and diagnostics. Neither imports
adapters or presentation. See ADR 0002.

# `game/application/` — orchestration

**Rank 2. Depends on `domain` and `simulation`.**

Coordinates the run. Owns lifecycle and sequencing; does not own physics truth.

## What belongs here

- **Front-end State** — owns Home/Garage/Shop/Tutorial/Course Lab/Settings
  navigation, tutorial progression, validated player settings, and the request
  to begin a run.
- **Run State Machine** — countdown, active run, dying, settlement, results,
  restart. Requests exactly one `RunSettlement` after death (GDD § 19.1).
- **Difficulty Director** — selects curated chunks from speed, entry-state
  envelope, history, and seed. Never improvises an unvalidated lethal layout; falls
  back to a safe recovery chunk (GDD § 9.2).
- **Course Stream** — derives a bounded deterministic ceiling, floor, obstacle,
  and fly window and can substitute a bounded local creator pattern. One
  explicit route plan coordinates boundary shaping, obstacle placement, and fly
  guidance; the first 2000 m forbid inward rails by default, and later inward
  passages remain rail-only. `CoursePatternCatalog` supplies curated,
  distance-banded natural compositions with a repetition cooldown. Small
  hazards grow by at most 16% after the learning runway, paired/staggered
  patterns begin only after 2000 m, and a predictable late squeeze occurs every
  eight chunks instead of appearing in clusters. Two authored weave patterns
  alternate floor/ceiling growth around a fully validated Classic-sized
  high↔low fly route; two compact silk-burr patterns add only a small central
  decision. Fly-advertised root passages
  grow from both rails and expose a verified steering envelope rather than a
  centre-line-only hole. Phase 1 extends this seam with selected authored chunks
  and pooling.
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

`FrontEndState` owns pre-run navigation, Garage/Shop/Course Lab intent, and
settings intent. `ProgressionService` is the only mutator for fly-funded
upgrades, selections, and creator slots. Upgrade purchases report whether the
new level is a 5/10/15/20 breakthrough so presentation can acknowledge a real
milestone without owning progression truth.
`SwingLabSession` owns the active laboratory command buffer, fixed-step order,
candidate presets, snapshots, recording, replay, independent diagnostic-overlay
state, and chunk-boundary refreshes. `CourseStream` owns the seven-chunk
deterministic geometry window; `CoursePatternCatalog` owns its curated pattern
vocabulary and distance bands. Neither imports
adapters or presentation. See ADR 0002.

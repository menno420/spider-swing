# `game/simulation/` — the deterministic fixed-step core

**Rank 1. Depends on `domain` only.**

The authoritative simulation. Advances at a fixed 60 Hz independent of render rate
(ADR 0001) and is the only place authoritative state changes.

## What belongs here

- **Spider Motor** — gravity, forward drive, velocity limits, body configuration.
  The forward drive moves horizontal velocity *toward* a target pace; it must not
  overwrite velocity every step (GDD § 4.2).
- **Web Constraint** — the maximum-length rope with a small tunable elastic
  allowance, plus Reel-In and Burst decomposition. Reel guarantees a minimum
  inward speed on its first tick, then applies sustained radial acceleration while
  its authoritative energy/shortening rules continue. Burst removes opposing
  radial motion, guarantees an anchor-directed launch, retains a configured share
  of tangential movement, and never caps away faster natural inward motion. The
  constraint removes only velocity that would extend the rope past its allowed
  length, preserves tangential velocity except for configured drag, and never
  teleports the spider (GDD § 6.3).
- **Simulation World collision seam** — currently resolves the graybox obstacle rectangles and boundaries; the Phase 1 Collision Policy expands this into exactly one
  outcome per contact, so repeated callbacks in the same tick cannot consume two
  shields or settle a run twice (GDD § 13.2).
- **Run model** — the deterministic per-tick state the application layer reads.

## The tick order is fixed

GDD § 8, enforced: consume buffered commands → update target pace and forward drive
→ gravity and movement forces → web constraint and Reel-In → advance physics →
collectible contacts → hazard contacts through the collision policy → emit domain
events → update presentation.

## Rules

- Never reads input directly — it consumes buffered `InputCommand` values.
- Never writes saves, currency, records, or unlocks.
- Never references `application`, `adapters`, or `presentation`.
- Must not add unbounded energy through repeated attach/release (GDD § 6.3).

`SimulationWorld`, `SpiderMotor`, and `WebConstraint` implement the Phase 0.7
responsive rope-actions candidate. Accepted actions emit events containing their
authoritative before/after motion for presentation and diagnostics. See ADR 0002.

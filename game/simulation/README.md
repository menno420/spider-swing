# `game/simulation/` — the deterministic fixed-step core

**Rank 1. Depends on `domain` only.**

The authoritative simulation. Advances at a fixed 60 Hz independent of render rate
(ADR 0001) and is the only place authoritative state changes.

## What belongs here

- **Spider Motor** — gravity, forward drive, velocity limits, body configuration.
  The forward drive moves horizontal velocity *toward* a target pace; it must not
  overwrite velocity every step (GDD § 4.2).
- **Web Constraint** — the maximum-length rope with a small tunable elastic
  allowance, plus Reel-In. Removes only the velocity component that would extend
  the rope past its allowed length; preserves tangential velocity except for
  configured drag; never teleports the spider (GDD § 6.3).
- **Collision Policy** — the single authority on contact outcomes. Exactly one
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

Empty at bootstrap: Phase 0 populates it. See ADR 0002.

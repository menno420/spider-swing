# Phase 0.6 anchor-pull feel session

> **Status:** `in-progress`

## Goal

Convert Menno's four Android playtest recordings into a more natural rope-control model: one guide interval more targeting reach, Reel that responds on its first authoritative tick, and Burst that propels toward the active anchor.

## Scope guard

This session may tune and extend the versioned Phase 0 rope configuration, deterministic simulation, tests, tutorial, diagnostics, documentation, and development build identity. It will not add progression, collectibles, production content, or a second movement implementation.

## Previous-session review

**previous-session review:** PR #10 successfully proved continuous surface targeting, bounded endless traversal, mobile controls, and static graybox obstacles. Menno's four 1040×480 recordings show the concept is fun and replayable while exposing three connected feel gaps: natural forward targets fall just outside range, Reel shortens too gradually to arrest a fall, and Burst ignores the active rope direction.

## Decisions flagged

- Increase the shared maximum web length by roughly one guide interval rather than loosening target validity everywhere.
- Add an immediate bounded inward Reel response plus sustained radial pull, while keeping rope-length retraction and energy authoritative.
- Require an attached web for Burst; capture its anchor direction, release, then add one bounded impulse along that direction.

## 💡 Idea

Treat Reel and Burst as two intensities of the same radial rope action: Reel is continuous energy-limited inward control, while Burst is a cooldown-limited release impulse derived from the exact same anchor vector.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

Born red until the implementation, exact checks, Android artifact, documentation audit, and final PR evidence are complete.

# Phase 0.12 opening swing and spider garage

> **Status:** `in-progress`

## Goal

Turn the latest owner playtest into a contained comparison build: slightly
roomier and explicitly tunable obstacle geometry, a deterministic opening web
that teaches the first swing before input is required, one recoverable mistake
per run, and a data-defined Garage/Shop prototype for comparing spider
archetypes and fly-funded upgrades.

## Scope

- Reduce floating obstacle geometry slightly while keeping collision and
  visuals on the same authoritative polygons.
- Expose plain-language obstacle-size controls in DEBUG, including independent
  controls for edge obstacles, floating hazards, and gate openings.
- Begin each run on a deterministic web and safe swing trajectory without
  locking or discarding early player input.
- Add one clearly communicated rescue charge per run with a safe,
  authoritative recovery path.
- Add data-defined Classic, small/agile, heavy, and gliding spider candidates
  with explicit trade-offs rather than strict paid superiority.
- Add Home entry points for Garage, Shop, cosmetics/web variants, and a
  contained creator-course foundation.
- Keep purchases local and fly-funded in this laboratory build. Do not add
  store billing, paid upgrades, or a timer that prevents play.
- Preserve the checksum-pinned GDD and keep all experimental feel values
  reversible through DEBUG or centralized catalog data.

## Previous-session review

**previous-session review:** PR #17 made Dive rearm depend on a successful
upper/obstacle attachment and rebuilt DEBUG as a touch-first grouped lab. Menno
reports that solid/lethal rails and most obstacle patterns work well, while the
first floating obstacle remains too tight, the free-fall opening demands input
too quickly, and the prototype now needs clearer long-term identity and
progression experiments.

## Product boundary

The owner also proposed hourly lives and real-money purchases. The binding GDD
currently forbids play-blocking energy systems and paid gameplay upgrades, and
the repository has no store SDK, product catalogue, purchase verification, or
backend entitlement service. This session therefore implements the reversible
gameplay experiments—one in-run rescue, flies, archetypes, upgrades, cosmetics,
and creator foundations—without pretending that production billing exists.

## 💡 Idea

Make every spider a named profile of modifiers over the one authoritative
`SwingConfig`, and let the Garage preview the same resolved values the
simulation consumes. That keeps character identity, DEBUG comparison, future
upgrade balancing, and deterministic tests on one mechanical source of truth.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

`[[fill: implementation, local gates, CI, Android artifact, docs audit, and
flagged reversible decisions at close-out]]`

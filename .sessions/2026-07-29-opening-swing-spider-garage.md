# Phase 0.12 opening swing and spider garage

> **Status:** `complete`

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

- **Implementation:** authoritative 94% edge / 90% floating obstacle scales and
  112% gate openings; six-section DEBUG controls; immediately interruptible
  opening web; one-run rescue; four centralized spider profiles; profile-specific
  fly upgrades; Garage palettes/web treatments; saved six-slot Course Lab.
- **Local game gate:** `python3 tools/verify.py --require-godot` passed with
  Godot 4.7.1: 14 architecture fixtures, import, boot, 34 deterministic physics
  checks, 15 mobile GUI checks, and 11 front-end/progression checks—70/70 total.
  `git diff --check` passed.
- **Published-tree proof:** local and published trees both equal
  `6c4dc1c09d92cf377d4b2cb13fede9144dbc9889`.
- **PR:** [#18](https://github.com/menno420/spider-swing/pull/18).
- **CI:** `game-quality`
  [30422862144](https://github.com/menno420/spider-swing/actions/runs/30422862144)
  passed 70 contracts at source
  `e43500546b896972c96ee833e0967094d4edd982`. The first
  `substrate-gate` failure is the designed born-red in-progress hold.
- **Android:** `android-debug`
  [30422862138](https://github.com/menno420/spider-swing/actions/runs/30422862138)
  passed and produced
  [`spider-swing-android-debug`](https://github.com/menno420/spider-swing/actions/runs/30422862138/artifacts/8712535636).
  The downloaded 56,839,504-byte ZIP matched GitHub digest
  `7b0200d952148090efcd271f7ed1240650657d43de3ca7e26e5abae848cdf89a`.
  Its 57,223,786-byte APK passed archive verification, had SHA-256
  `d9f1f109f58d5c49509a8d89aa5b89b6ff28e7435c17f21a202c040c702df382`,
  contained the Android manifest, `classes.dex`, and project binary, and its
  manifest proved version `0.5.0-opening-garage-test`, exact source, dev package,
  and display name.
- **Docs audit:** checksum-pinned GDD remains byte-exact at
  `a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53`;
  README, current state, capabilities, front-end flow, test guide, playtest
  guide, layer READMEs, and decisions [D-0008]/[D-0009] match verified source.
- **Flagged reversible decisions:** all profiles remain open for Phase 0
  comparison; fly costs/upgrade caps, one rescue, opening assistance, geometry
  scales, and creator piece vocabulary are candidates. Real IAP/hourly lives and
  shared UGC are deliberately deferred until product approval and honest billing,
  entitlement, validation, and moderation infrastructure exist.

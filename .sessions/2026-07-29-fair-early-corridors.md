# Phase 0.14 fair early corridors

> **Status:** `complete`

## Goal

Correct the deterministic corridor pattern exposed by Menno's
`0.6.0-gradual-progression-test` recordings: keep the first 2000 m spacious,
prevent floating gates from being paired with inward-moving lethal rails that
erase their bypass, and make the suggested fly route describe a genuinely
usable lane.

## Scope

- Preserve the continuous lethal ceiling and floor, gradual 5000 m speed ramp,
  existing obstacle scale, and all current spider mechanics.
- Keep inward-moving tight corridors out of the first 2000 m by default, with
  the threshold editable in the touch-first DEBUG course controls.
- Give each generated challenge one explicit route intent shared by boundary
  shaping, fly guidance, and deterministic validation.
- Never combine the broken-pot gate with the old inward pattern; retain
  deliberate later tight corridors only where their challenge geometry leaves
  a validated route.
- Add regression coverage for the exact repeated gate failure seen around
  21–24 s and 32–34 s in the owner recordings.

## Previous-session review

**previous-session review:** PR #19 successfully slowed the pace curve, made
the continuous rails meaningful, and improved overall play feel. Its
pattern-seven combination independently pinched both rails around a centered
pot gate, however, leaving effectively no upper bypass and an impractical lower
route. The deterministic repeat made an authored geometry mistake look like a
player failure.

## 💡 Idea

Make route intent a first-class chunk contract: the same value should shape
the rails, place route flies, and drive a clearance assertion. This prevents
three independently reasonable systems from composing into an impossible
course.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

- **Implementation:** `CourseStream` now resolves one high, low, centre, or
  tight route before generating a chunk. The route shapes its rails, places its
  fly trail, and decides whether a detached obstacle may exist. Before the
  configurable 2000 m default threshold, rail profiles can only remain level
  or move outward. Later tight routes are rail-only.
- **DEBUG:** `Routes` exposes `Inward rails begin` from 1000–8000 m in 250 m
  steps. Existing rail shape, bypass room, and tight-gap controls remain
  independent.
- **Local game gate:** `git diff --check` and
  `python3 tools/verify.py --require-godot` pass with Godot 4.7.1: 14
  architecture fixtures, import, boot, 39 deterministic physics checks, 15
  mobile GUI checks, and 11 front-end checks—75 total.
- **Godot proof:** PR #20
  [`game-quality` run 30447006504](https://github.com/menno420/spider-swing/actions/runs/30447006504)
  passed all 75 contracts at source
  `b700c61eaa1c427005b1e957cb708dc58e56390f`.
- **Android proof:** PR #20
  [`android-debug` run 30447006513](https://github.com/menno420/spider-swing/actions/runs/30447006513)
  produced
  [`spider-swing-android-debug` ID 8721864851](https://github.com/menno420/spider-swing/actions/runs/30447006513/artifacts/8721864851),
  56,858,997 bytes with digest
  `sha256:53f7da38c36856e6f559731eb9a8c099d90247f5141c51c8cec7d44edd237c85`.
  Its downloaded 57,240,170-byte APK passed archive verification with SHA-256
  `ab4727e70deee2bd041e1c6038968e67d998587ee76002a9c4d7e061b4774098`;
  `build-info.txt` proves version `0.6.1-fair-corridor-test`, exact source,
  package `com.menno420.spiderswing.dev`, and display name
  `Spider Swing Fair Corridors (dev)`.
- **Docs audit:** README, current state, capability ledger, decision ledger,
  technical playtest guide, application boundary, and heartbeat match verified
  source. The checksum-pinned GDD is unchanged.
- **Reversible decisions flagged:** 2000 m is a default comparison threshold,
  not a final balance promise; later tight routes remain available as
  standalone rail challenges; both values stay centralized and DEBUG-editable.
- **PR:** [#20](https://github.com/menno420/spider-swing/pull/20) was opened
  ready while the session card's designed hold was active.

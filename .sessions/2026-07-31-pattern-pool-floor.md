# A floor under region pattern pools

> **Status:** `complete`

## Goal

Make the repository catch a regression that is invisible in review and easy to
misdiagnose on device: a region pattern pool shrunk far enough that the zone's
sequence visibly loops.

## Scope guard

One contract. No gameplay change, no pool edited, no pattern added or removed.

## Previous-session review

**previous-session review:** PR #70 split the agent lanes by domain and added
missions and currencies to the backlog. Correct, and it caught its own card
grammar failure from CI rather than shipping it. No fault to record.

## Why this exists

A parallel ChatGPT session is fixing a real problem: Bramble Canopy's art reads
as Ancient Forest recoloured, because its mound and hanging pod share Ancient
Forest's geometry builders with greener material. Its stated first step was to
stop Bramble selecting `tall_vine`, `long_pod`, `vine_curtain`, `bramble_steps`,
`alternating_thorns` and the stump patterns.

That would leave four patterns, and the arithmetic matters. `_seeded_pattern`
walks a pool with a coprime stride, which is a **full-cycle permutation** — the
visible cycle length *is* the pool size. At `CHUNK_WIDTH` 960 px (96 m), four
patterns repeat the zone's whole sequence every ~384 m, about **five seconds**
at full pace. Eleven give ~1 056 m, about fourteen seconds.

There is a second, quieter loss. `_coprime_stride` admits exactly one legal
stride at sizes 3, 4 and 6 — measured, not assumed. At those sizes the course
seed can only rotate the order, never reorder it, which silently drops the
"curated pattern order varies by seed" property `docs/current-state.md` records
as live.

The session appears to be taking the better route anyway — it is building
Bramble-specific silhouettes and making collision geometry follow them rather
than deleting shared patterns. This contract is not aimed at that session. It
exists because the property is worth holding regardless of who edits a pool
next, and because the failure mode reads on device as "this zone feels
repetitive", which is very easy to misattribute to level design.

## Shipped

- `tests/unit/phase0_physics_tests.gd` — `_test_region_pattern_pools_stay_varied`
  asserts every non-empty pool holds at least seven patterns, and that
  `_coprime_stride` admits more than one stride for each pool size so the seed
  keeps reordering it. `EXPECTED_CHECK_COUNT` 122 → 123.

Current pools all pass with room: control 8, mastery 15, deep forest 17, bramble
canopy 11, silk hollow 9.

## Verification

Real exit codes, no pipes:

- `python3 tools/verify.py --require-godot` → **exit 0**, **123 contracts**.
- **Falsified before trusted.** Shrinking `BRAMBLE_CANOPY_PATTERNS` to the four
  survivors of the proposed removal fails the suite with "pattern pool
  bramble_canopy has 0 patterns; below 7 the zone's sequence visibly loops".
  Restoring it passes 123.

## Open owner questions

**A hook-shaped hazard advertises grabbability it may not have.** The first new
Bramble asset is a large sideways hook-vine with a concave pocket. If it is
floor-grown it is lethal but untappable, so a shape that visually invites a web
would answer taps with a release instead. That is the exact confusion PR #65
removed, reintroduced through art rather than code. Worth deciding per asset:
either make the hook ceiling-grown so the affordance is honest, or shape
floor-grown hazards so they do not read as anchors.

## 💡 Idea

This contract guards a numeric property of a data table. The same shape would
catch other silent table regressions — a region losing its checkpoint flag, a
spider losing an upgrade track, a zone whose density curve inverts. A small
family of table-invariant contracts is cheap and catches the class of bug that
survives review precisely because the diff looks reasonable.

## Next slice

None queued here. The overnight session starts at slice 1, difficulty curve
measurement.

- **📊 Model:** opus-5 · high · test writing — a floor under region pattern pools

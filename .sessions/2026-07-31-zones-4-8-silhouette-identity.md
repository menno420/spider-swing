# Silk Hollow identity and Zones 4–8 session

> **Status:** `in-progress`

## Goal

Strengthen Silk Hollow's obstacle and art silhouette, then build the five
owner-designed 15,000 m+ zones as deterministic, readable, mechanically distinct
endless-course regions rather than palette variants.

## Scope guard

This session owns the deterministic moving-parts ADR and phase model, the
moving-anchor simulator proof, additive region definitions and pattern pools for
Ruined Arboretum through Deep Mist, Silk Hollow plus Zones 4–8 presentation art,
zone mechanics, focused contracts, build identity, and living documentation.

It does **not** edit `BRAMBLE_CANOPY_PATTERNS` or Bramble art; Ancient Forest and
Bramble geometry remain untouched. It also does not change the approved physics
baseline, speed curve, input, upgrades, campaign, missions, currencies, saves,
settlement, monetization, production signing, or publishing.

## What is about to happen

Write the moving-parts ADR before any moving hazard, use `tools/simulate.gd` to
measure whether a phase-derived moving anchor can remain energy-safe, then build
and visually verify one complete data-defined region stack from 10,000 m through
the endless 35,000 m+ tail.

## Previous-session review

**previous-session review:** PR #67 correctly froze one mechanical axis and one
success sentence per zone, while PRs #71–#72 raised every region pool to a
CI-enforced minimum and made the declared 123-contract baseline self-checking.
PR #69 remains the sole Bramble obstacle owner; this slice deliberately excludes
its constants and assets even where shared catalog files require separate hunks.

## Planned verification

- Prove phase evaluation is a pure function of `(chunk_index, course_seed, tick)`
  and remains identical at simulated 30/60/90/120 Hz and off-grid starts.
- Measure moving-anchor energy against a static-anchor control in the production
  simulator before accepting the signature Ruined Arboretum mechanic.
- Require at least seven owned patterns and multiple coprime strides per new
  region, with Garden level-zero route-clearance and recovery contracts.
- Record every asset's dimensions, anchor eligibility, 25% silhouette verdict,
  nearest possible zone confusion, alpha/fringe inspection, and provenance.
- Run `python3 tools/verify.py --require-godot`, strict Substrate checks, exact
  Android export verification, and required GitHub checks before the final
  `complete` flip and merge.

## 💡 Idea

Make zone silhouette identity machine-checkable as a maintained contact sheet:
geometry masks at gameplay scale can catch accidental re-skins before a device
build, while owner playtests still decide whether the resulting place feels good.

- **📊 Model:** gpt-5.6-sol · ultra · feature build

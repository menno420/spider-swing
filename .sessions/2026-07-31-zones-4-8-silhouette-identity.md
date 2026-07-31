# Silk Hollow identity and Zones 4–8 session

> **Status:** `complete`

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

## Delivered

- Wrote ADR 0004 before the moving-hazard implementation and kept all motion as
  a pure sample of `(chunk_index, course_seed, tick)`, including hazards,
  harmless phase teachers, wind, weather, residents, expiring anchors, and
  presentation particles.
- Proved the production moving-pivot constraint energy-safe, then added Ruined
  Arboretum, Storm Ridge, Web City, Ashen Hollow, and Deep Mist at their frozen
  15,000/20,000/25,000/30,000/35,000 m entries without new checkpoints or
  changes to campaign, difficulty, upgrades, economy, saves, or settlement.
- Replaced Silk Hollow's inherited forest vocabulary with membranes, cocoons,
  spindles, lattices, and a supported thread eye. Every new region has a
  full-cycle pool of at least seven patterns and explicit per-obstacle anchor
  eligibility, semantic identity, visual identity, and deterministic motion.
- Added thirteen original generated RGBA assets plus exact-dimension, alpha,
  fringe, provenance, anchor-state, and 25% silhouette records. The maintained
  evidence contains eight 1280×720 captures, eight 320×180 pure-black masks,
  and full-colour/silhouette contact sheets.
- Reconciled PR #69 after it merged without editing `BRAMBLE_CANOPY_PATTERNS` or
  either Bramble asset directory. The fixed 6000 m Bramble evidence window
  contains its hook-vine and leaf-shutter signatures; the maximum pair IoU is
  0.497 and every owned zone remains below 0.488.
- Assigned the stable-key Android build identity `0.21.0-zones-4-8`, version
  code 39, and app label `Spider Swing Zones 4-8 (dev)`.

## Previous-session review

**previous-session review:** PR #67 correctly froze one mechanical axis and one
success sentence per zone, while PRs #71–#72 raised every region pool to a
CI-enforced minimum and made the declared 123-contract baseline self-checking.
PR #69 remained the sole Bramble obstacle owner; after its merge this slice
combined only shared plumbing and tests, leaving its constants and assets
unchanged.

## Verification

- `tools/simulate.gd --moving-anchor-proof`: **PASS**. Translation covariance
  stayed within 0.000271 px / 0.000285 px/s; the moving/static peak ratio was
  1.06272, the late/early peak ratio 0.117737, and maximum rope overrun
  17.0388 px across twenty 300-tick cycles at a 42° pivot amplitude.
- Exact local `python3 tools/verify.py --require-godot`: **PASS**, using
  `4.7.1.stable.official.a13da4feb`; architecture, import, boot, 56 deterministic
  physics contracts, 10 zone contracts, and all other suites pass **134/134**.
- GitHub `game-quality` run 325: **PASS** on source
  `f26045ecf7fd3a9f01ec9b93abb21a71a0ca6f4f`.
- GitHub `android-debug` run 224: **PASS**. The APK is a valid arm64 development
  package with manifest version `0.21.0-zones-4-8` / code 39 and the pinned
  stable debug signer. Artifact
  [8809628376](https://github.com/menno420/spider-swing/actions/runs/30673502921/artifacts/8809628376)
  is 68,989,480 bytes, retained for 14 days, with archive digest
  `sha256:4ce8008eec437a3d77f0b0740d9e2b85ad9fc57a4df8449802a8a50194d10e10`.
- `docs/visual/zones/zone-art-audit.json`: **PASS** for all thirteen assets,
  including source/runtime/25%-size alpha-edge inspection with zero magenta
  fringe pixels. The full-size and 25% contact sheets were visually inspected.
- No Balanced physics value changed. Off-grid debug starts compare exact
  polygons, anchor flags, semantic/visual ids, motion descriptors, decorations,
  and seeded phases across Silk Hollow and all five appended regions.

## Handoff

PR [#73](https://github.com/menno420/spider-swing/pull/73) is ready. The remaining
acceptance step is the owner's real-device one-sentence playtest for each zone;
the headless and image evidence verifies construction and readability, not feel.

## 💡 Idea

Make zone silhouette identity machine-checkable as a maintained contact sheet:
geometry masks at gameplay scale can catch accidental re-skins before a device
build, while owner playtests still decide whether the resulting place feels good.

- **📊 Model:** gpt-5.6-sol · high · feature build

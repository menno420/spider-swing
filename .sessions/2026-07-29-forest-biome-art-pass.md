# Phase 0.16 forest biome art pass

> **Status:** `in-progress`

## Goal

Turn Ancient Forest from a repeated material comparison into one cohesive,
production-quality visual slice with natural boundary edges, environment-native
hazards, and readable Classic spider and fly art.

## Scope

- Add a seamless tree-branch treatment for the lethal ceiling and floor without
  changing authoritative collision geometry.
- Add a small, deliberate set of thorned bramble and hanging-vine obstacle
  sprites whose visible silhouettes remain honest about their hit regions.
- Replace the prototype Classic spider and fly drawing with polished,
  small-screen-readable sprites.
- Keep collision outlines available only in DEBUG and preserve Graybox plus the
  existing comparison themes.
- Record asset provenance, validate runtime imports, and ship a testable Android
  artifact.

## Previous-session review

**previous-session review:** PR #21 proved four lightweight texture packs and a
safe presentation-only theme seam, but its single repeated tile made walls and
obstacles monotonous. This pass builds on that seam and separates boundary,
hazard, character, and collectible art while preserving the playable geometry.

## 💡 Idea

Treat the biome as a small visual grammar rather than one texture: bark is the
mass behind the corridor, branches define its collision edge, and distinct
rooted or hanging plants communicate each hazard's origin and lethality.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

- **Implementation:** `ArtAssetCatalog` owns six finished candidate runtime
  textures. Ancient Forest adds overlapped/mirrored branch edges, rooted
  brambles, top-anchored thorn vines, a grouped hollow root gate, the Classic
  Garden Spider, and golden flies. Normal play omits graphic collision outlines;
  DEBUG restores the exact snapshot polygons and spider radius.
- **Geometry truth:** course generation, boundary/obstacle polygons, anchor
  resolution, lethality, pickup radius, difficulty, speed progression, and
  persistence are unchanged. Transparent obstacle regions retain a dark
  collision shadow, and the root gate visual groups the existing four collision
  pieces without replacing them.
- **Asset proof:** all six source generations were inspected at full resolution
  and gameplay scale. Chroma removal, alpha trim, padding, runtime downscaling,
  source/runtime SHA-256 values, and regeneration specifications are recorded
  under `assets/source/forest-biome/`. The six lossless runtime PNGs total about
  1.3 MiB.
- **Local game gate:** `git diff --check` and
  `python3 tools/verify.py --require-godot` pass with Godot 4.7.1: 14
  architecture fixtures, import, boot, 39 deterministic physics checks, 16
  mobile GUI checks, and 11 front-end checks—76 total.
- **Godot proof:** PR #22
  [`game-quality` run 30458975297](https://github.com/menno420/spider-swing/actions/runs/30458975297)
  passed all 76 contracts at source
  `8aaa517823239a3d80db94d14c72eab12ad0219d`.
- **Android proof:** PR #22
  [`android-debug` run 30458979638](https://github.com/menno420/spider-swing/actions/runs/30458979638)
  produced
  [`spider-swing-android-debug` ID 8726773191](https://github.com/menno420/spider-swing/actions/runs/30458979638/artifacts/8726773191),
  58,679,746 bytes with digest
  `sha256:c3e0c2c94cacec5f0315c87ba7320decf55a39a61fdb166a5eba2288aebf1870`.
  The downloaded artifact passed archive verification; its 59,065,710-byte APK
  passed archive verification with SHA-256
  `f045f1ab5b3af460c77b256502c73338fcfbcf8d3d5b0b713acee98228e709e7`.
  `build-info.txt` proves version `0.8.0-forest-art-test`, exact source, dev
  package, and display name `Spider Swing Forest Art (dev)`.
- **Docs audit:** README, current state, capability ledger, decision ledger,
  technical playtest guide, source provenance, and heartbeat match verified
  source. The checksum-pinned GDD is unchanged.
- **Reversible decisions flagged:** Ancient Forest is a finished candidate, not
  an approved production-art direction; the other three packs remain prototype
  comparisons; non-Classic spider profiles intentionally retain procedural art
  until each receives an equally deliberate pass.
- **PR:** [#22](https://github.com/menno420/spider-swing/pull/22) was opened
  ready while the session card's designed hold remained active.

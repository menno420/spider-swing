# Phase 0.15 environment theme packs

> **Status:** `complete`

## Goal

Replace the temporary flat rail rendering with four coherent, touch-selectable
environment texture packs while preserving the existing authoritative collision
geometry and a one-tap graybox comparison mode.

## Scope

- Add four original texture packs for the ceiling, floor, and rail-grown
  obstacles.
- Centralize visual theme data in one presentation-owned catalog.
- Add an obvious DEBUG selector and keep graybox available as a baseline.
- Preserve gameplay geometry, lethality, pacing, and deterministic simulation.
- Add runtime contracts and ship a uniquely identified Android comparison APK.

## Previous-session review

**previous-session review:** PR #20 fixed the early impossible corridors without
changing the gradual pace curve. This session deliberately builds only on the
presentation surface so the newly playable geometry remains the comparison
baseline.

## 💡 Idea

Treat the environment as a swappable visual skin over one collision silhouette:
the same world can compare art direction without silently changing route width
or difficulty.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

- **Implementation:** `EnvironmentThemeCatalog` owns Graybox plus Ancient
  Forest, Mossy Ravine, Overgrown Greenhouse, and Reclaimed Attic. The view maps
  each generated material over the exact snapshot polygons with repeated
  world-space UVs, while theme palette and edge treatment stay entirely in
  presentation.
- **DEBUG:** `LOOK` adds five direct, large preview cards. Ancient Forest is
  the default and Graybox remains a one-tap collision-silhouette comparison.
- **Asset proof:** the four visually inspected 384×384 WebP runtime tiles total
  about 136 KiB. Their exact prompts, processing, and SHA-256 values are recorded
  under `assets/source/environment-themes/`; no third-party image was used.
- **Local game gate:** `git diff --check` and
  `python3 tools/verify.py --require-godot` pass with Godot 4.7.1: 14
  architecture fixtures, import, boot, 39 deterministic physics checks, 16
  mobile GUI checks, and 11 front-end checks—76 total.
- **Godot proof:** PR #21
  [`game-quality` run 30451065223](https://github.com/menno420/spider-swing/actions/runs/30451065223)
  passed all 76 contracts at source
  `402997b6362e46c9002aa6001c7b3f9f28cbb16a`.
- **Android proof:** PR #21
  [`android-debug` run 30451065009](https://github.com/menno420/spider-swing/actions/runs/30451065009)
  produced
  [`spider-swing-android-debug` ID 8723522456](https://github.com/menno420/spider-swing/actions/runs/30451065009/artifacts/8723522456),
  57,651,810 bytes with digest
  `sha256:d74b40e6a2ff92cbb7457bbf982c6212e087506e78c13ba8b19ac13990744926`.
  Its downloaded 58,035,981-byte APK passed archive verification with SHA-256
  `0e8689f112068f2ae4b0d763472d40c0bc284613b424f6113e43421f652131bf`;
  `build-info.txt` proves version `0.7.0-environment-themes-test`, exact source,
  package `com.menno420.spiderswing.dev`, and display name
  `Spider Swing Environment Themes (dev)`.
- **Docs audit:** README, current state, capability ledger, decision ledger,
  technical playtest guide, presentation ownership, source provenance, and
  heartbeat match verified source. The checksum-pinned GDD is unchanged.
- **Reversible decisions flagged:** Ancient Forest is a comparison default, not
  a final art-direction decision; theme choice is per run rather than persisted;
  the generated tiles are prototype art; obstacles share the selected material
  for this comparison rather than introducing a separate object-art system.
- **PR:** [#21](https://github.com/menno420/spider-swing/pull/21) was opened
  ready while the session card's designed hold was active.

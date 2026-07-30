# Anchorite production sprite session

> **Status:** `complete`

## Goal

Create and integrate one production-quality Anchorite character sprite that is
as deliberate and mobile-readable as the finished Garden Spider while clearly
expressing Anchorite's heavy, powerful movement identity.

## Scope guard

This session may add one transparent character asset, register it in the
presentation-owned art catalog, render it for the Anchorite profile, add
presentation regression coverage, refresh development build identity, and
update living art documentation. It must not change collision radius, physics,
balance, upgrades, targeting, web reach, course generation, saves, the frozen
GDD, monetization, or any other spider's visual.

## About to happen

Generate a broad, low, burrowing/tarantula-like Anchorite from the finished
Garden Spider's source pose and quality bar, remove the flat chroma key to clean
alpha, inspect both source-size and downscaled readability, integrate it through
the centralized art catalog, render it in Godot, validate the exact Android
artifact, then complete this card and remove the claim only after every required
check is green.

## Previous-session review

**previous-session review:** PR #40 corrected the owner-tested Reel response
without changing the bounded meter. That isolated balance work remains open for
device judgment; this art-only session does not reinterpret or modify it.

## Shipped

- `assets/runtime/characters/anchorite-burrowing-spider.png` and its import
  metadata add one transparent, mipmapped 384×181 finished sprite. The broad
  charcoal-and-bronze burrowing-spider silhouette has thick legs, a compact
  eye cluster, and heavy chelicerae, and remains readable at the 96×46
  gameplay footprint.
- `game/presentation/scripts/art_asset_catalog.gd` registers the asset through
  the presentation-owned catalog. `game/presentation/scripts/swing_lab.gd`
  routes Garden and Anchorite through one finished-sprite renderer while
  retaining procedural fallback for Skitter, Ballooner, and Springtail.
  Anchorite's authoritative profile radius still owns its rendered scale and
  collision remains untouched.
- `tests/unit/mobile_hud_layout_tests.gd` proves the renderer route, mipmaps,
  exact source dimensions, transparent corners, and eleven-asset catalog.
  Build identity advances to `0.13.0-anchorite-art-test` / Android code 29.
- `README.md`, both presentation/character READMEs, the phase-0 checklist,
  test documentation, `docs/current-state.md`, and decision D-0021 record the
  species mapping, art contract, and unchanged gameplay boundary.
- Remote implementation source
  `9f82310e52d5925a92d2b4e6d8d78c1ddfa2ed09` has tree
  `0d545d6377e1ab0039b9ba7ac185d8a799c719f1`, byte-identical to locally
  verified implementation commit `79cf617c5d8b1eee14bd9c1f1708a787921089b1`.
  Merged `main` from PR #41 was then reconciled without changing the art slice.

## Decisions flagged

- Anchorite represents a heavy burrowing/tarantula-like spider rather than a
  recolored Garden Spider: compact eyes, broad low body, strong chelicerae,
  thick legs, and muted mineral/earth colors.
- Use Garden's pose, orientation, source dimensions, and finish quality as the
  production contract, not its jumping-spider facial anatomy.
- Keep character art presentation-only. It may rotate, interpolate, and scale
  from the simulation snapshot, but it cannot define collision or profile
  balance.
- Complete one new spider at a time. Skitter, Ballooner, and Springtail keep
  their existing procedural silhouettes until each receives an equally
  deliberate species-readable asset.

## 💡 Idea

Add a calm Garage showcase pose that displays each finished spider slightly
larger than gameplay size against the active environment. This would let
future art reviews catch silhouette, face, palette contrast, and alpha-fringe
problems before spending an Android playtest.

- **📊 Model:** gpt-5.6-sol · high · feature build

## Capability delta

Appended to `docs/CAPABILITIES.md`: the built-in image generator plus one
targeted facial edit produced a stable chroma-keyed source, and local key
removal/downscaling converted it into a transparent 384×181 Godot asset whose
import survived the exact CI and Android export path. Connector-backed Git
objects again provided an exact-tree publishing fallback where local
authenticated push was unavailable.

## Verification evidence

- Source and visual inspection: the final PNG is RGBA 384×181, 96,326 bytes,
  SHA-256
  `9f1de7799ca0a3e78aebe5317418106aba61c4d9c02a2e6cd88c832166763175`.
  Its alpha bounds are `373x167+9+5`, both tested corners are transparent,
  and a side-by-side 96×46 comparison remains visibly heavier and more
  burrowing-spider-like than Garden.
- `git diff --check` passed on the implementation tree. Local
  `python3 tools/verify.py` passed architecture and host checks; the container
  lacked its own Godot binary, so exact-engine proof came from CI rather than
  weakening or skipping the engine requirement in the repository.
- Ready PR [#44](https://github.com/menno420/spider-swing/pull/44)
  implementation head
  `9f82310e52d5925a92d2b4e6d8d78c1ddfa2ed09` passed `game-quality`
  [run 30566614922](https://github.com/menno420/spider-swing/actions/runs/30566614922):
  clean import, clean front-end boot, and 91/91 contracts on pinned
  `4.7.1.stable.official.a13da4feb`.
- Android
  [run 30566616021](https://github.com/menno420/spider-swing/actions/runs/30566616021)
  produced verified
  [artifact 8769099561](https://github.com/menno420/spider-swing/actions/runs/30566616021/artifacts/8769099561).
  Its 61,495,520-byte ZIP matched GitHub digest
  `sha256:d43ab6eafa793f74d6b11cee1dac55536af4c2d1be776a6a9007c33d9ffc4260`
  and passed archive validation. The 61,898,115-byte APK passed archive
  validation with SHA-256
  `2e5d771c383e38b42d3a70f857ba9087b3c084667ca615b5ea15edba831f1f83`;
  embedded `build-info.txt` proves version `0.13.0-anchorite-art-test`, exact
  source, dev package, and display name. Its imported Godot payload contains
  the Anchorite texture and import metadata.
- The pre-flip Substrate gate reported only this card's designed
  `HOLD (by design)`. The checksum-pinned GDD remains byte-identical at
  `a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53`.
- Final `python3 bootstrap.py check --strict --require-session-log
  --session-log .sessions/2026-07-30-anchorite-production-sprite.md` reports
  `check: session log .sessions/2026-07-30-anchorite-production-sprite.md
  complete.` and `check: all checks passed.`
- PR: #44 is ready and remains open only for final closeout-head checks and
  its rebuilt exact-head Android artifact; merge is permitted only after both
  are green.

## Documentation audit

The art catalog, renderer, import contract, tests, build identity, asset
READMEs, presentation boundary, phase-0 checklist, current-state ledger, and
decision D-0021 agree. No collision, physics, balance, upgrade, target, route,
save, other-spider art, monetization, or frozen-GDD source changed.

## Remaining owner review

On device, compare Garden and Anchorite in Garage and ordinary play. Confirm
Anchorite reads as a heavy burrowing/tarantula-like spider at gameplay size,
stays distinct against Ancient Forest, has no magenta fringe, rotates smoothly,
and visually agrees with the unchanged collision outline. This is visual
approval only; no gameplay feel value changed.

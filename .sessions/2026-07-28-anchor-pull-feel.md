# Phase 0.6 anchor-pull feel session

> **Status:** `complete`

## Goal

Convert Menno's four Android playtest recordings into a more natural rope-control model: one guide interval more targeting reach, Reel that responds on its first authoritative tick, and Burst that propels toward the active anchor.

## Scope guard

This session tuned and extended the versioned Phase 0 rope configuration, deterministic simulation, tests, tutorial, diagnostics, documentation, and development build identity. It did not add progression, collectibles, production content, or a second movement implementation.

## Previous-session review

**previous-session review:** PR #10 successfully proved continuous surface targeting, bounded endless traversal, mobile controls, and static graybox obstacles. Menno's four 1040×480 recordings show the concept is fun and replayable while exposing three connected feel gaps: natural forward targets fall just outside range, Reel shortens too gradually to arrest a fall, and Burst ignores the active rope direction.

## Decisions flagged

- Increased the shared maximum web length from 620 to 820 pixels—roughly one guide interval—rather than loosening surface or cone validity.
- Added a bounded 170 px/s first-tick Reel response, 1200 px/s² sustained radial pull, and a 720 px/s inward cap while preserving rope shortening, energy, lockout, and no-teleport rules.
- Burst now requires an attached web, captures its anchor direction, releases, and adds one 440 px/s impulse along that vector. Detached Burst is inert and starts no cooldown.
- Preset-specific Reel values remain runtime-tunable; the new shared range and Burst pull remain reversible candidate values pending owner device approval.

## 💡 Idea

Treat Reel and Burst as two intensities of the same radial rope action: Reel is continuous energy-limited inward control, while Burst is a cooldown-limited release impulse derived from the exact same anchor vector.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

- `game-quality` implementation run [30372449569](https://github.com/menno420/spider-swing/actions/runs/30372449569) passed on Godot 4.7.1.
- The documented branch state passed `game-quality` again in run [30373042671](https://github.com/menno420/spider-swing/actions/runs/30373042671): **41/41** runtime contracts, comprising 15 deterministic physics, 9 mobile HUD, 8 front-end, and 9 bootstrap/build checks; the architecture checker passed all 14 fixtures and the live inward-dependency scan.
- New regression contracts prove attachment beyond the old 620-pixel limit, first-authoritative-tick Reel fall arrest without repeated engagement impulse, sustained pull under the resource rules, Burst velocity aligned to the active web vector, and detached Burst rejection without cooldown.
- `android-debug` run [30372450524](https://github.com/menno420/spider-swing/actions/runs/30372450524) succeeded for source `ce9e5f74bebad32bf5425b5b2368da9ae02f5ee1`. Artifact `spider-swing-android-debug` ID `8693506101` is 56,715,449 bytes, expires 2026-08-11, and has archive digest `sha256:129b61404fd4e4a7f7c4f2559b45805f82032776efb5cc5fe5b97a0cb653f94f`.
- The artifact was downloaded and inspected: its APK is an Android package with `classes.dex`, compiled main/swing-lab/tutorial-preview scripts, build `0.2.1-anchor-pull-test`, package `com.menno420.spiderswing.dev`, and app label `Spider Swing Anchor Pull (dev)`. APK SHA-256: `4f7e5197a65705dc2088a4fc4789e4de1b216651538030687c8cb6dbfeab3e1d`.
- Pre-close Substrate run [30373042779](https://github.com/menno420/spider-swing/actions/runs/30373042779) reported exactly one exit-affecting finding: this card's designed in-progress hold. No product or documentation defect remained. PR [#11](https://github.com/menno420/spider-swing/pull/11) must show the completed-card `substrate-gate` and `game-quality` green before merge.

## Documentation audit

README, Phase 0 playtest guide, testing contract, current-state ledger, project context index, and domain/simulation folios now describe the same 820-pixel reach and radial Reel/Burst model as verified source. The byte-frozen GDD was not modified. No `[[fill:]]` marker or speculative Phase 1 claim was introduced.

## Remaining owner review

Install the private Phase 0.6 artifact and judge whether the extended reach, first-tick Reel response, sustained fall arrest, and anchor-directed Burst feel natural across Balanced, Weighty, and Agile. This is a product-feel gate, not an unverified tooling capability. The previously verified GitHub-plan limitation on private-repository branch protection remains recorded in `control/status.md`.

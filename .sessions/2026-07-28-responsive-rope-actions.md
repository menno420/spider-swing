# Phase 0.7 responsive rope-actions session

> **Status:** `complete`

## Goal

Turn Menno's five Android anchor-pull recordings into a more immediately
controllable rope-action candidate: forgiving thumb targets, a decisive
first-tick Reel correction, an unmistakable anchor-directed Burst, and feedback
that makes accepted actions readable without watching the HUD text.

## Scope guard

This session changes only the Phase 0 rope-action candidate, mobile hit geometry,
authoritative success feedback, tests, development build identity, and the
host-owned Android workflow. It does not approve a movement baseline, alter the
endless test course, or add Phase 1 content/progression.

## Previous-session review

**previous-session review:** PR #11 correctly made Burst follow the active web and
gave Reel a first-tick response, but Menno's five follow-up recordings showed both
actions still read as subtle under downward/lateral momentum. His taps also
clustered on the outer edges of the controls. The prior radial-action direction
was right; its response floor, hit tolerance, and success feedback needed another
measured pass.

## Shipped

- `game/domain/{swing_config.gd,lab_layout.gd,simulation_event.gd}`,
  `game/simulation/{web_constraint.gd,simulation_world.gd}`,
  `game/adapters/input_router.gd`, `game/presentation/scripts/swing_lab.gd`,
  tutorial copy, tests, and product/technical folios — implementation commit
  `00650eb143ed4a114e1dc8d9fea58f898b2b7d8d`.
- `.github/workflows/android-debug.yml` and `tests/test_runner.gd` — Android
  identity-drift repair and permanent regression guard in commit
  `cc0bac54e74f49ed4147978bc7a6e702c4c50804`.
- `.sessions/2026-07-28-responsive-rope-actions.md`,
  `docs/{current-state.md,CAPABILITIES.md}`, and the retained Substrate telemetry
  delta — close-out evidence commit
  `cee2299203583c8bdb4e4208931e8a1965d217c4`.

## Decisions flagged

- Reel now guarantees a candidate-specific minimum inward speed on its first
  authoritative tick, then continues radial acceleration and rope shortening.
  It preserves tangential motion and never reduces faster natural inward speed.
- Burst decomposes velocity along/across the rope, removes motion away from the
  anchor, guarantees a 660 px/s candidate pull, retains 74% of tangential motion,
  and adds at most the configured assistance without capping faster earned
  inward travel.
- Reel and Burst each use a symmetric 228×228 reference-pixel hit region with a
  smaller drawn circle. This is a reversible layout value, not final production UI.
- Accepted actions drive short authoritative-event flashes and distinct
  lightweight haptics. Reduced motion holds the feedback ring steady rather than
  removing the success cue.
- Godot 4.7.1 generated script `.gd.uid` sidecars during the clean import. They
  are committed because the repository already versions Godot UID sidecars and
  they stabilize script resource identity across clones.

## 💡 Idea

Add a temporary debug-only radial/tangential velocity readout beside the existing
rope diagnostics during the next feel pass. It would let a recording show whether
a questionable Burst came from aim direction, incoming momentum, or tuning without
putting simulation authority into presentation.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

- Local
  `GODOT_BIN=/tmp/spider-swing-godot-4.7.1/Godot_v4.7.1-stable_linux.x86_64 python3 tools/verify.py --require-godot`
  passed all six stages: 14 architecture fixtures, live inward scan, Godot
  4.7.1 discovery, clean import, boot smoke, and **42/42** runtime contracts
  (15 physics, 10 mobile HUD, 8 front-end, 9 bootstrap/build).
- PR #12 `game-quality` run
  [30377680346](https://github.com/menno420/spider-swing/actions/runs/30377680346)
  passed the same 42 contracts from
  `cc0bac54e74f49ed4147978bc7a6e702c4c50804`.
- The first Android attempt, run
  [30377392951](https://github.com/menno420/spider-swing/actions/runs/30377392951),
  stopped at its identity assertion because the workflow still named build
  `0.2.1`. The narrow workflow correction landed with a test that now fails if
  project, export preset, and workflow identities drift again.
- Corrected `android-debug` run
  [30377680073](https://github.com/menno420/spider-swing/actions/runs/30377680073)
  passed every step. Artifact `spider-swing-android-debug` ID `8695654625` is
  56,723,433 bytes, expires 2026-08-11, and has archive digest
  `sha256:9a6a22f0cc5a7d6165740101c29691f75aa02a10b38d626a2c81dd716271776a`.
- The artifact was downloaded and inspected. It is an Android APK with
  `classes.dex`, `AndroidManifest.xml`, and `assets/project.binary`; bundled
  `build-info.txt` proves version `0.2.2-responsive-pull-test`, source
  `cc0bac54e74f49ed4147978bc7a6e702c4c50804`, package
  `com.menno420.spiderswing.dev`, and app label
  `Spider Swing Responsive Pull (dev)`.
- Pre-close `python3 bootstrap.py check --strict` reported exactly this card's
  intentional `in-progress` hold as the sole exit-affecting finding. Its seven
  guard-fire records were retained in `.substrate/guard-fires.jsonl`.

## Documentation audit

README, testing guide, Phase 0 playtest guide, front-end guide, architecture
folios, current-state ledger, decision ledger, capability ledger, build manifest,
and tutorial now describe the same response math, 228-pixel controls, feedback,
and `0.2.2-responsive-pull-test` identity as source and CI. The checksum-pinned
GDD was not modified. No `[[fill:]]` marker or speculative Phase 1 claim was added.

## Remaining owner review

Install the Phase 0.7 artifact and judge the edge taps, first-tick fall arrest,
anchor dominance, retained swing, and action feedback across Balanced, Weighty,
and Agile. Automated evidence proves the contract and APK, but only the owner's
phone playtest can approve or reject a movement baseline.

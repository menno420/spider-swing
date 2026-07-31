# Debug depth control repair session

> **Status:** `complete`

## Goal

Repair the owner-reported depth workflow by making exact distance and temporary
upgrade level configurable before play, while retaining useful in-run controls
and changing no physics, balance, economy, ownership, or settlement architecture.

## Scope guard

Debug-only pre-run UI and application wiring for the two depth controls, focused
regression contracts, required build identity, and close-out documentation. The
stable signer, real progression, tuning values, and normal competitive flow
remain unchanged.

## Previous-session review

**previous-session review:** PR #54 added the two controls with strong service
and persistence contracts, but the first owner device test reports that both
controls do not work properly. This session treats device behavior as the
finding to reproduce; passing lower-level contracts are not proof that the
actual touch-first interaction is usable.

## Planned verification

Exercise the real 1280×720 view and native input path under Godot 4.7.1, add a
contract that fails for the reproduced interaction, run the complete engine
suite and strict Substrate gate, then verify the exact Android artifact before
merge.

## Finding

The underlying practice start and progression overlay are sound: an actual
1280×720 `SubViewport` GUI probe delivered the distance preset and `MAX` through
the native buttons into one live session, producing the requested distance,
practice mode, level 20, and the expected 416 px/s maxed Garden Reel. The gap is
the mobile interaction seam and, more importantly, timing. Both controls were
mounted only after a run had already started, so correct setup required starting,
opening DEBUG, changing a value, and accepting a restart. Typed distance could
also depend on an Android keyboard submission event with no visible apply action.
The overlay did not plainly say that `MAX` temporarily resolves all seven tracks
and buys nothing. Existing contracts separately emitted adapter signals and
called services, so they did not cover the owner workflow end to end.

## Shipped

- Commit `34b8d5d1a9a98d8f1a8bef434bb4535d0a9ebc6b` on PR #60 carries the
  exact locally verified implementation tree.
- `InputRouter` now gives typed distance a visible 48-pixel `GO`, Enter/Done,
  and focus-loss commit paths; presets and `−`/`+` synchronize the field.
- Home now exposes a gated `DEBUG TEST RUN` route. It stages exact distance with
  large 100 m `−`/`+` and shortcuts, stages a temporary all-seven-track level
  with large one-level `−`/`+` plus `OWNED`/L0/L10/`MAX`, and starts once through
  the existing noncompetitive practice path.
- DEBUG → RUN still calls the second control `Temporary upgrade level` and says that
  `MAX` applies all seven tracks without buying or saving them. Inline copy says
  that depth changes restart and DEBUG must be closed to play.
- Normal Play, Course Lab, and Region Practice clear any active overlay before
  mounting, so a temporary debug choice cannot leak into an ordinary run.
- A 117th contract connects the in-run native controls to one real
  `SwingLabSession`: typed `GO` starts exact noncompetitive practice, `MAX`
  resolves the live config, and `OWNED` restores the saved config. An 118th
  contract joins the pre-run view, application state, overlay service, and live
  session, including debug-off gating and normal-Play restoration.
- Build candidate `0.19.1-depth-control-repair`, Android version code 36 and
  app label `Spider Swing Depth Controls (dev)`, retains the stable signer.

## Verification

- Official Godot `4.7.1.stable.official.a13da4feb` Standard: architecture
  fixtures/scan, import, boot, and **118/118** contracts pass.
- The 1280×720 and wide-phone layout contracts enclose the field and `GO` target
  and retain the debug-only gate.
- Pixel capture was attempted twice, but this seat uses Godot's dummy headless
  renderer and returns a null `SubViewport` texture; the exact wall and device
  workaround are recorded in `docs/CAPABILITIES.md`.
- A three-frame headless 1280×720 Front End measurement encloses the 1088×533
  pre-run card, two 534-pixel columns, 64-pixel `−`/`+`, and 68-pixel start
  action without overflow.
- `game-quality` run
  [30656982928](https://github.com/menno420/spider-swing/actions/runs/30656982928)
  passed the official-engine gate on exact source `34b8d5d1…`.
- `android-debug` run
  [30656983045](https://github.com/menno420/spider-swing/actions/runs/30656983045)
  passed every identity, stable-key, export, APK-validity, version, and signer
  assertion and produced
  [artifact 8803635374](https://github.com/menno420/spider-swing/actions/runs/30656983045/artifacts/8803635374).
  Its 61,797,497-byte ZIP independently matched GitHub's SHA-256
  `cb9cb31d…`; the intact 62,202,652-byte APK has SHA-256 `7a9aa69d…`, embeds
  source `34b8d5d1…`, and reports certificate SHA-256 `83ff0bc2…`, exactly the
  pinned stable debug signer.
- Final `python3 bootstrap.py check --strict` passes with this card complete and
  the session claim removed.

## Decide-and-flag

The pre-run overlay remains one shared selected-spider level rather than free
purchases or seven separately persisted cheats. That preserves the requested
fast owned-versus-upgraded A/B test while keeping ownership, costs, save codecs,
and settlement untouched. No owner decision remains open for implementation;
the remaining ask is the real-device feel and interaction gate below.

## Owner device gate

Install artifact 8803635374 over any `0.19.0-depth-testing` or later stable-key
build without uninstalling. Enable Debug Tools, return Home, open `DEBUG TEST
RUN`, set an off-grid distance, switch upgrades through `−`/`+`, `OWNED`, and
`MAX`, then start. Confirm the HUD says the run awards nothing, the requested
geometry appears, and a later ordinary Play uses exact owned levels. Issue #2's
device traversal/feel judgment remains the product gate.

## PR

[PR #60](https://github.com/menno420/spider-swing/pull/60) is ready for its
final-head checks and squash merge. The handoff probes its terminal state
against the checked head rather than relying on this pre-merge card snapshot.

## 💡 Idea

The exact-distance value now has both pre-run and in-run presentation adapters.
If either grows another numeric field, extract a shared locale-aware parsing and
formatting policy so comma decimals, focus loss, `GO`, and field synchronization
cannot drift while each adapter keeps ownership of its native Godot controls.

- **📊 Model:** gpt-5 · high · runtime bugfix

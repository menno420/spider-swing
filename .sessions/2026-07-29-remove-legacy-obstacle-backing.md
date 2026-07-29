# Remove legacy obstacle backing session

> **Status:** `in-progress`

## Goal

Make the Ancient Forest artwork the only normal-game obstacle silhouette while
preserving the authoritative polygons for collision, targeting, and opt-in
diagnostics.

## Scope guard

This session may change presentation composition, related rendering contracts,
documentation, and development build identity. It does not change authoritative
course geometry, obstacle frequency, route planning, physics, rewards, or
progression.

## Previous-session review

**previous-session review:** PR #24 made the rail-grown root gate physically
traversable and hid collision outlines and unattached web guides by default.
Menno's `0.8.2-wide-passage-test` recording proves the route fix works, but also
reveals the legacy geometric backing layer behind the finished branches,
brambles, vines, and root passages.

## Decisions flagged

- Remove the duplicated normal-game silhouette at the centralized presentation
  seam instead of special-casing individual obstacle types.
- Preserve authoritative geometry unchanged and render it only when the
  collision-outline diagnostic is explicitly enabled.
- Add a runtime contract that fails if finished Ancient Forest obstacles fall
  back to legacy filled polygons.

## 💡 Idea

Treat each environment theme as a complete presentation policy: a finished theme
must declare how authoritative geometry is surfaced, preventing a prototype
fallback from silently leaking beneath production-candidate art.

- **📊 Model:** gpt-5 · high · runtime bugfix

## Verification evidence

- `python3 tools/verify.py --require-godot` passes with Godot
  `4.7.1.stable.official.a13da4feb`: 14 architecture fixtures, repository
  architecture scan, clean import, front-end boot, and 79/79 headless contracts
  (40 physics, 18 mobile HUD, 11 front-end, and 10 bootstrap).
- The new mobile contract proves the Ancient Forest theme declares no normal-game
  geometry backing and that `SwingLabView` contains no legacy
  `FOREST_OBSTACLE_SHADOW` draw path.
- PR [#25](https://github.com/menno420/spider-swing/pull/25) is ready.
  `game-quality` run
  [30474513238](https://github.com/menno420/spider-swing/actions/runs/30474513238)
  passes at source `e01113d1a8d8f919125fd1630a42dad421589007`.
- `android-debug` run
  [30474512943](https://github.com/menno420/spider-swing/actions/runs/30474512943)
  passes and produced
  [`spider-swing-android-debug`](https://github.com/menno420/spider-swing/actions/runs/30474512943/artifacts/8733049254),
  artifact ID `8733049254`, 58,597,102 bytes, digest
  `sha256:26c3a7b81986bdd2cff2c293c6cf8a4a48d21f318b7ddc79b044c430ea2c2885`.
  The downloaded ZIP and its APK both pass archive validation. The APK has
  SHA-256
  `991c8e8d33be956ee4908c981f356d8a0653c47c875b17229a1680e92943d311`
  and contains `classes.dex`, `AndroidManifest.xml`, and
  `assets/project.binary`. `build-info.txt` proves version
  `0.8.3-clean-forest-test`, exact source, dev package, and display name
  `Spider Swing Clean Forest (dev)`.
- The initial `substrate-gate` failure is the designed in-progress-card hold.
  It will be rerun after this close-out and final status flip.

## Documentation audit

Updated the README, current-state ledger, phase-lab contract, testing guide,
presentation boundary, and test index. The frozen GDD is unchanged. No binding
document still claims that finished obstacle alpha is backed by the old dark
collision shadow.

## Remaining owner review

Install the verified PR artifact and confirm that brambles, hanging vines, and
both halves of the broad root passage show only their natural transparent art in
normal play. Then enable Collision Outlines under DEBUG → OVERLAYS and confirm
the exact authoritative polygons still appear only as the requested diagnostic.

# Bramble Canopy environment and height-control session

> **Status:** `complete`

## Goal

Turn the 5000 m boundary into a clearly different Bramble Canopy environment
and make its validated obstacle vocabulary demand readable high-to-low choices
instead of relying on the region name and a subtle tint.

## Scope guard

Presentation-owned region art and transition treatment, Bramble-specific
validated course patterns, focused contracts, build identity, and living
records. Preserve swing physics, targeting, upgrade values, economy, save
compatibility, settlement, the Garden level-zero baseline, and authoritative
collision ownership.

## Previous-session review

**previous-session review:** PR #60 made exact distance and temporary upgrade
level configurable before play. Menno's first 5000 m recordings prove those
controls now reach a live level-20 noncompetitive run, while exposing that PR
#48's Bramble Canopy identity is largely a label over the same Ancient Forest
art and that its purported height weave often leaves a neutral centre line.

## What is about to happen

Build one complete 5000 m vertical slice: inspected painterly region art,
distance-owned presentation selection, a visible boundary transition, and
deterministic route envelopes proven passable by the unupgraded Garden Spider.

## Device evidence and interpretation

Four 1040×480 Android recordings begin at 5000 m with the level-20 session
overlay and advance through roughly 6400–6500 m. They prove the setup reaches
the intended live run and expose two separate findings:

- `BRAMBLE CANOPY` previously reused Ancient Forest's backdrop, rails, and
  hazard art; the green tint, silk threads, and particles were not enough to
  read as a new environment at gameplay speed.
- At full pace, Reel is most useful before the correction is urgent: it shapes
  the next arc after an early route read. Burst becomes the reliable late large
  height correction. This is a useful late-game role split, not evidence to
  slow the course or turn Reel into a second Burst. The content must provide
  enough advance visual information for both choices to remain intentional.

## Implemented

- Six inspected Bramble runtime assets: open high-canopy far/mid depth,
  braided-thorn rail, growth socket, leafy bramble, and hanging seed-pod vine.
- Foreground selection derives from each authoritative polygon's world x, so
  the region arrives from the right without a global art pop. The backdrop
  crossfades for 2.2 seconds; Reduced Motion and direct 5000 m starts switch
  immediately.
- Bramble owns distinct compact thorn and high↔low pattern ids. Its signature
  pairs extend through the neutral middle line while the authored fly route,
  Classic-sized steering envelope, recovery entry, and recovery cadence remain
  clear. No physics or upgrade value changed.
- Build identity is `0.20.0-bramble-canopy`, Android version code 37. D-0038
  records both the material-region standard and the owner-observed late-game
  control roles. Silk Hollow remains explicitly incomplete rather than being
  overstated by this slice.

## Visual review

Every generated source and alpha result was inspected individually. A
1280×720 phone-scale composition of the exact runtime textures was compared
with Ancient Forest: the lime-lit open canopy, braided green rails, large
leaves, pale thorns, and seed-pod silhouette remain visibly different after
minification. The bright centre was darkened with runtime modulation so the
white web and dark spider retain contrast.

The exact headless Godot display driver on this seat uses dummy texture storage,
so framebuffer capture returns null even though the structural SubViewport
contracts execute. This is recorded as a capability limit, not called a pixel
render. The source-identified Android artifact remains the final exact-renderer
visual proof.

## Local verification

- PR #61 (`balanced_baseline`) was integrated first. Its migration and naming
  contract remains intact; no preset value changed.
- `python3 tools/verify.py --require-godot` with exact
  `4.7.1.stable.official.a13da4feb`: architecture self-tests/live scan, import,
  front-end boot, and **121/121 contracts** all pass after integrating PR #63's
  death-window protection and aimed-Burst ordering.
- New proofs require deterministic Bramble variety across seeds, a blocked
  neutral centre, a clear Classic-sized high↔low guide, six loadable distinct
  assets, world-position foreground selection, ordinary-entry crossfade,
  Reduced Motion bypass, and direct-start bypass.
- `python3 bootstrap.py check --strict --require-session-log` reaches only this
  card's deliberate `in-progress` lifecycle hold. Remote Android signer/source
  evidence was the remaining prerequisite before the final `complete` flip.

## Remote and Android proof

- Exact remote head `b4eb76e18b56c30bb503c04d761b78e62936c4da` has tree
  `c9db21eb25745b24ec828f0b2ae290a0e1ca4d47`, byte-identical to the locally
  verified tree and cleanly ahead of current main `162b9c0…` by three commits.
- `game-quality` runs 30662003736 and 30662011415 passed the exact head. The
  deliberate born-red `substrate-gate` failure is only this card's status.
- Android run 30662003775 passed stable-key, export, APK identity/version, signer
  certificate, and upload checks. Artifact 8805521840 is 64,564,251 bytes and
  its downloaded ZIP matches GitHub's SHA-256
  `c3d8eb300b8552ee2be722c160f1019fa7a6bce9bf281a8320943313bdd5acca`.
- The intact 64,968,926-byte APK has SHA-256
  `e7d783bb3a680f4f057585efd7a7ccf7305974e4c32dd72e6e4f75b54ba60da5`.
  Its embedded provenance names build `0.20.0-bramble-canopy`, exact source
  `b4eb76e…`, package `com.menno420.spiderswing.dev`, and display name
  `Spider Swing Bramble Canopy (dev)`. The APK contains all six imported
  Bramble textures plus `classes.dex`, `AndroidManifest.xml`, and
  `assets/project.binary`.
- `keytool -printcert -jarfile` independently reports certificate SHA-256
  `83ff0bc27903351779ffd1439f115e8c7e4c228fddd683e2a801c9700b30a741`,
  exactly the pinned stable debug signer. The carrier PR used only to emit
  Actions is closed; PR #62 remains the sole implementation PR.

## Planned verification

Inspect the generated assets at source and phone scale; measure the exact
1280×720 view structure and use the Android artifact as the real-renderer proof;
run the pinned Godot 4.7.1 Standard suite and strict Substrate gate; then verify
the source-identified Android artifact before close-out.

## 💡 Idea

Use one data-defined presentation pack per region so future 5000 m environments
can replace backgrounds, rail materials, obstacle families, ambience, and
transition cues without branching simulation or duplicating the renderer.

- **📊 Model:** gpt-5.6-sol · high · feature build

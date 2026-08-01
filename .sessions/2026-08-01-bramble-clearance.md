# Bramble Canopy clearance correction

> **Status:** `complete`

## Goal

Correct the owner-reported device failure in which Bramble Canopy's new hook
and leaf-shutter obstacles are too large and too closely sequenced to make the
opening course physically playable.

## Scope guard

Bramble-only obstacle geometry, pair spacing/recovery cadence, a player-path
passability regression, development build identity, and living verification
records. Preserve the approved physics, speed curve, Reel/Burst/Dive values,
upgrades, input, economy, settlement, saves, and every other zone.

## Previous-session review

**previous-session review:** PR #69 correctly replaced Ancient Forest obstacle
roles with a distinct Bramble vocabulary, but its static guide-and-radius sweep
was weaker evidence than the owner's five device recordings. Those recordings
show the new silhouettes occupying too much of the corridor and recurring too
quickly for the actual swinging trajectory, so the prior passability claim is
superseded rather than defended.

## Owner evidence

Five 1040×480 Android recordings from build `0.22.0-audio-playtest` show
immediate or near-immediate deaths around Bramble's large hooks and diagonal
leaf shutters. The correction must retain their distinct silhouettes while
making both individual openings and the time between commitments achievable at
the unchanged full-speed traversal values.

## What is about to happen

Measure the recorded failure against current seeded geometry, reduce Bramble's
collision occupancy, lengthen its commitment/recovery spacing, and replace the
point-guide-only proof with a timed traversal-envelope contract that can
fail on the shipped configuration.

## Falsification and root cause

The new device-envelope contract was added before generation changed. Against
the shipped `0.22.0` values it failed with **136 adjacent hard-chunk
transitions**, an effective **450 px** minimum pair gap against the 646 px
full-speed floor, and collision bounds up to **479×345 px** against limits of
340×275. The source causes were independent and cumulative:

- Bramble's eight-item pool let ordinary seeded slots select pair patterns, on
  top of the separately forced pair cadence.
- Pair centres were authored only 420 px apart before asymmetric bounds moved
  the effective centre gap to roughly 450 px—about 0.59 s at 760 px/s.
- Bramble's already-authored dimensions were multiplied by Ancient Forest's
  generic late-distance growth, reaching 1.044× at the default 0.90 obstacle
  scale.
- The neutral-line assertion sampled only the bounds centre of a concave hook,
  rewarding an oversized shape that filled its intentional pocket.

## Implemented

- The eight exclusive Bramble ids remain intact, split into named single and
  pair pools. Deterministic generation alternates every hard chunk with a fully
  open recovery chunk, and alternates single versus pair commitments.
- Pair authoring now spans offsets 230→900 px, matching the complete seven-fly
  route and providing at least 0.85 s between effective commitments at unchanged
  maximum speed.
- Hook/shutter base widths and heights are smaller, and Bramble no longer
  receives the unrelated Ancient Forest distance-growth multiplier. The normal
  floating-obstacle debug/difficulty scale remains authoritative.
- The neutral-path proof sweeps the real Garden collision circle across a
  concave obstacle's whole x-span instead of requiring collision at one
  arbitrary bounds-centre point.
- Build identity is `0.22.1-bramble-clearance`, Android version code 41.
  D-0040 records that vertical displacement, not density, owns Bramble's
  difficulty axis.

## Visual and diagnostic review

The same seed and 5288 m capture changed from four overlapping 406 px-wide,
345 px-tall hooks in one viewport to one 323×275 px mirrored pair with a clear
central transition. The runtime art remains the same C-hook and diagonal leaf
fan, scaled from the authoritative bounds rather than replaced or distorted.

The deliberately non-gating v3 bot smoke moved from its documented 217 m
median per life on the overcrowded course to 652 m and 2.66 deaths/km. It still
fails the owner acceptance targets by a wide margin, so this is only a shared
failure-mode sanity check—not difficulty, balance, or device-passability
evidence.

## Local verification

- The new deterministic envelope failed before the production correction with
  the exact recorded values above, then passed after the cadence, dimensions
  and pair spacing changed.
- `GODOT_BIN=/tmp/godot-4.7.1/Godot_v4.7.1-stable_linux.x86_64 python3
  tools/verify.py --require-godot` passed architecture self-tests and live
  scan, import, front-end boot, and all **170/170** contracts under exact
  `4.7.1.stable.official.a13da4feb`.
- Seeded 1280×720 runtime exports at 5000–5480 m retain the safe regional entry,
  show a fully open chunk around each hard commitment, and show the 5288 m pair
  at 323×275 px with a readable central transition.
- The non-gating 40-run expert bot smoke completed as recorded above; it is not
  being substituted for owner-device acceptance.
- `python3 bootstrap.py check --strict --require-session-log` reports only this
  card's deliberate `in-progress` lifecycle hold. `git diff --check` is clean.

## Remote implementation proof

- PR #86 head `965df9c6e388cf3a17b83dcecf2eb2de42365ac8` has Git tree
  `15149aa7cf3d8a5c01debb49823c208323ffe7a1`, exactly matching the locally
  verified tree. `game-quality` run `30694253404` passed; the only substantive
  red check is the designed open-session hold.
- Android run `30694253389` passed stable-key verification, export, package and
  build checks, signer validation, and artifact upload. Artifact `8816709938`
  has ZIP SHA-256 `59d3f7be58673c6a2b310e63bf9995b6923aa910762d70bddc45ddb9a62cf91c`;
  its archive test is clean.
- The intact APK has SHA-256
  `7926363e76f3edf0523dfa5f4e10cda3a9ad813b22912862e880c00512439ac7`.
  Embedded provenance reports source `965df9c6`, build
  `0.22.1-bramble-clearance`, package `com.menno420.spiderswing.dev`, and the
  Bramble clearance display name. The APK contains both region obstacle
  textures and the compiled corrected catalog/stream.
- The embedded certificate SHA-256 is
  `83ff0bc27903351779ffd1439f115e8c7e4c228fddd683e2a801c9700b30a741`,
  exactly the pinned stable public debug signer.

## Moving-main reconciliation

Before the lifecycle flip, `main` advanced to `633e7db1` with another agent's
non-overlapping Zones 3–4 art claim. True merge commit `583fecc2` preserves that
claim and this evidence history as two parents. The combined tree passed exact
Godot 4.7.1 and all 170 contracts before this card closed.

## Final verification gate

This `complete` badge and deletion of only
`control/claims/claude-bramble-clearance.md` are the deliberate final lifecycle
change. The exact engine suite and strict repository gate must pass again on
this final tree, which may merge only after fresh final-head checks are green.

## Capability delta

No new capability or blocker was discovered. Publication reused the already
documented authenticated GitHub-app exact-tree route; the local `gh`/Git push
wall and stable Android signing/export route are unchanged, so
`docs/CAPABILITIES.md` needs no update.

## Owner questions

None. The next owner decision is the explicit device verdict recorded in
`control/status.md`: whether the corrected first Bramble sequence is now
physically traversable without losing the region's vertical identity.

## 💡 Idea

Treat each authored obstacle sequence as a timed traversal envelope: validate
clearance, minimum reaction time, and a recoverable exit state together rather
than certifying isolated polygons against an ideal centreline.

- **📊 Model:** gpt-5.6-sol · high · feature build

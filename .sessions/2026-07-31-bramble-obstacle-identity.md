# Bramble Canopy obstacle-identity follow-up

> **Status:** `in-progress`

## Goal

Respond to Menno's device verdict that Bramble Canopy's new art still wraps
obstacles which are effectively the Ancient Forest set. Make the 5000–10000 m
area own a genuinely different static obstacle vocabulary, not merely different
textures and renamed variants.

## Scope guard

Bramble-only curated patterns, authoritative static geometry, matching
presentation assets, focused deterministic/passability/readability contracts,
development build identity, and living records. Preserve the approved physics,
speed curve, Reel/Burst roles and tuning, input, economy, progression, saves,
settlement, the 0–5000 m Ancient Forest course, and the frozen GDD.

## Previous-session review

**previous-session review:** PR #62 successfully made the 5000 m background,
rails, palette, transition, and obstacle material visibly Bramble-specific, and
proved a stronger high↔low pair. Menno's device test found the decisive remaining
gap: the obstacle silhouettes and roles still read as the same stumps, pods,
brambles, and alternating rail growth under a new skin. Its completion wording
therefore overstated the region's content identity.

## Owner verdict

The environment transition is directionally correct, but the obstacles must be
genuinely different from what already exists so Bramble feels like a new area.
This is an implementation correction, not a request to change traversal physics
or make the late game faster.

## What is about to happen

Replace Bramble's inherited Ancient-Forest pattern pool with a small Bramble-only
vocabulary whose silhouettes and route grammar are unique: deep concave hook
vines and broad diagonal leaf shutters, each available as a single rail-grown
hazard or an authored mirrored high↔low pair. Each remains seeded, static,
world-anchored, and prevalidated for the level-zero Garden steering envelope.
New painterly alpha assets match those authoritative bounds at phone scale.

## Implemented

- Normal 5000–10000 m generation now owns eight Bramble-only pattern ids and
  selects no Ancient Forest stump, pod, curtain, gate, mound, or ordinary thorn
  pattern. The forced signature cadence also uses the new leaf-shutter pair.
- Deep hook vines form concave wall pockets; giant leaf shutters form broad
  diagonal barricades. Singles demand one clear side, while mirrored pairs
  alternate the required height. Both families cross the neutral centre line,
  so their gameplay role differs as well as their pixels.
- A domain-owned obstacle kind travels beside each collision polygon and
  anchorability flag through geometry, simulation, snapshots, and session
  copies. Presentation therefore chooses the matching inspected asset and
  horizontal orientation explicitly instead of guessing from the same bounds.
- Build identity is `0.20.1-bramble-obstacles`, Android version code 38. D-0039
  records that a region owns obstacle silhouette and route grammar, while the
  saved region ids/ranges and the approved traversal values remain unchanged.

## Visual review

The two image-generation sources, their chroma-keyed alpha results, and a
1040×480 phone-scale composite using the exact runtime textures were inspected.
The large C-shaped hook and fan-like diagonal shutter remain distinguishable
from each other and from Ancient Forest's compact stumps, seed pods, rooted
gates, and burrs after minification. Their open centres keep the spider, web,
flies, and route readable; neither is a recolour of PR #62's leafy mound or pod.

The exact source specifications, sampled chroma colours, generated-source
hashes, final texture hashes, and processing steps are recorded beside the art.
The built-in image generator created the raster sources; the repository's
chroma-removal pipeline produced the runtime alpha assets.

## Local verification

- `python3 tools/verify.py --require-godot` with exact
  `4.7.1.stable.official.a13da4feb`: architecture self-tests/live scan, import,
  front-end boot, and **124/124 contracts** all pass after integrating main's
  independent region-pool variety floor and clearer count-mismatch diagnostic.
- The new contract rejects every Ancient Forest id from Bramble, exposes all
  eight new variants across representative seeds, proves explicit left/right
  kinds survive copies, requires each hazard to remove the neutral-centre
  coast, and sweeps a conservative Garden-sized circle along every authored
  route segment.
- Direct debug starts still reproduce sequentially streamed geometry, now
  including semantic obstacle kinds. All 22 production textures load.
- A non-gating diagnostic compared 128 maxed expert runs from 5000 m: the
  simple future-fly-following bot reached a 5210 m mean with the new course
  versus 5348 m on PR #62. The bot cannot anticipate high↔low sequences, so
  this is evidence of stronger vertical commitment, not a balance verdict; the
  exact Garden route-envelope contract remains the passability authority.
- `python3 bootstrap.py check --strict --require-session-log` reaches only this
  card's deliberate `in-progress` lifecycle hold. Source-identified Android
  and signer proof remain required before the final `complete` flip.

## Remote and Android proof

- Exact remote head `4fb5cce4ff7b1abdf39f27593a317bca5b756101` has tree
  `d3e7d606c22004ccf5e7b7840edbbadb19e85978`, byte-identical to the merged,
  locally verified tree. It is a true merge over current main
  `6e2f63686b9f21c6058c615517c278a1b3a264b8`, so PR #69 is mergeable rather
  than silently skipping Actions as a conflicted head.
- `game-quality` run
  [30667529686](https://github.com/menno420/spider-swing/actions/runs/30667529686)
  passed the exact head. `substrate-gate` run 30667529692 fails only on this
  card's deliberate `in-progress` badge; the merge helper passed.
- Android run
  [30667529691](https://github.com/menno420/spider-swing/actions/runs/30667529691)
  passed stable-key, export, APK identity/version, signer-certificate, and
  upload checks. [Artifact
  8807542392](https://github.com/menno420/spider-swing/actions/runs/30667529691/artifacts/8807542392)
  is 64,949,162 bytes; the downloaded ZIP exactly matches GitHub's SHA-256
  `f4b166b08dfe1ea0a8e70a78d65ca2e8424ceff01cd240bb36337590d483791a`.
- The intact 65,358,715-byte APK has SHA-256
  `aaad94c103349e6812ca2074571c3ce90d9dfcd6dbb1322d2247c40141c4d9a5`.
  Its embedded provenance names build `0.20.1-bramble-obstacles`, exact source
  `4fb5cce4…`, package `com.menno420.spiderswing.dev`, and display name
  `Spider Swing Bramble Obstacles (dev)`. Both new imported textures, their
  manifests, `classes.dex`, `AndroidManifest.xml`, and `assets/project.binary`
  are present in the APK.
- `keytool -printcert -jarfile` independently reports certificate SHA-256
  `83ff0bc27903351779ffd1439f115e8c7e4c228fddd683e2a801c9700b30a741`,
  exactly the pinned stable public debug signer.

## Planned verification

Prove that Bramble selects no Ancient-Forest obstacle ids, that every new family
appears across representative seeds, that direct debug starts equal sequential
streaming, and that conservative Garden-sized route sweeps remain clear. Inspect
all generated sources and alpha results at source and phone scale, run exact
Godot 4.7.1 verification plus strict Substrate, then require green GitHub and
source-identified Android proofs before merging.

## 💡 Idea

Give each shipped region an enforceable pattern-ownership contract: shared
renderer and validation primitives are reusable, but the player-facing obstacle
family ids and signature route grammar may not leak across region boundaries.

- **📊 Model:** gpt-5.6-sol · high · owner-device follow-up build

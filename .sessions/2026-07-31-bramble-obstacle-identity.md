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
  front-end boot, and **123/123 contracts** all pass.
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

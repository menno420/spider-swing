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
vocabulary whose silhouettes and route grammar are unique: hooked wall growth,
staggered leaf shutters, and forked thorn arches. Each remains seeded, static,
world-anchored, and prevalidated for the level-zero Garden steering envelope.
New painterly alpha assets will match those authoritative bounds at phone scale.

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

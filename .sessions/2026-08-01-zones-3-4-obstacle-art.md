# Silk Hollow and Ruined Arboretum obstacle art correction

> **Status:** `in-progress`

## Goal

Replace the visibly unfinished collision-polygon obstacle presentation in Silk
Hollow and Ruined Arboretum with painterly foreground objects that belong to
their approved backgrounds, while preserving the authoritative gameplay.

## Scope guard

Own only Zones 3–4 foreground obstacle assets, their presentation routing,
asset provenance/QA, visual contracts, build identity, and living handoff
records. Preserve every collision polygon, route, motion phase, moving-anchor
rule, anchor eligibility flag, physics value, difficulty value, background,
progression, save, economy, settlement, and input behavior. Bramble Canopy and
PR #86 are explicitly excluded.

## Previous-session review

**previous-session review:** PR #73 successfully established distinct
backgrounds, deterministic later-zone mechanics, and zone-level silhouette
identity, but the owner recordings expose a weaker foreground-art claim: most
Silk lattice/spindle and Arboretum beam/rotor hazards still fall back to flat
filled polygons with bright outlines. The backgrounds look finished while the
hazards read as debug geometry.

## Owner evidence

Two 1040×480 Android recordings from build `0.22.0-audio-playtest` cover
10,000–11,700 m and 15,000–16,200 m. Silk Hollow shows repeated pink angular
bars over a convincing web chamber; Ruined Arboretum shows pale rectangular
crosses over a convincing reclaimed glasshouse. The correction target is the
foreground vocabulary, not course difficulty or the backgrounds.

## What is about to happen

Create single-object chroma-keyed art for Silk cocoons, spindles, and woven
lattice struts plus Arboretum beams and rotor components; route each stable
visual/content id explicitly; align long assets to their authoritative oriented
polygons; remove opaque prototype backing only when inspected art exists; and
prove fallback/debug behavior remains available when it does not.

## Planned verification

Inspect every generated source, runtime matte, and 25% gameplay-scale edge;
render seeded 10 km and 15 km review frames; contract-test explicit asset
routing, orientation, no-geometry-change invariance, and complete runtime paths;
then run exact Godot 4.7.1, strict Substrate, and Android export checks before
the final lifecycle flip and merge.

## 💡 Idea

Make the renderer expose a development-only “art/fallback” comparison toggle so
future playtests can distinguish a collision-authoring problem from an asset or
routing problem in one recording.

- **📊 Model:** gpt-5.6-sol · high · feature build

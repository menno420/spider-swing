# Obstacle contacts sit inside the visible silhouette

> **Status:** `in-progress`

## Goal

Correct the owner-reported Android failure where a run ends while the rendered
spider is still visibly separated from a Bramble Canopy obstacle, then give all
lethal obstacle contacts a small conservative visual safety margin.

## Scope guard

Obstacle contact geometry, the shared contact margin, truthful collision-debug
presentation, focused deterministic contracts, build identity, and living
records. Preserve obstacle artwork and placement, web attachment geometry,
boundary lethality, route order and passability, physics values, upgrades,
input, progression, saves, settlement, audio, and menu presentation.

## Owner evidence and root-cause probe

The supplied 1040×480 build `0.34.0-speed-cap-playtest` screenshot ends at
5346.6 m on a floor-grown Bramble leaf shutter while visible air remains between
the spider and the painted leaves. A local alpha-versus-polygon audit reproduces
the mismatch: only about 73% of that lethal polygon is visibly occupied, with
an invisible extension of roughly 77 px; the hook-vine family reaches roughly
42 px. The simulation also applies the full player radius to every obstacle
with no visual contact margin.

## What is about to happen

Separate lethal-contact polygons from the visual and attachment envelope,
author contact silhouettes for the two Bramble families that demonstrably need
them, apply one small shared inset to every obstacle contact, expose the actual
contact shape in the opt-in collision overlay, and falsify the fix against the
reported visible-gap class before landing on green.

## 💡 Session idea

Promote collision-to-alpha coverage into an asset acceptance metric: generated
obstacle art should prove that its visible silhouette contains the lethal
contact shape plus the configured safety margin at runtime placement, rather
than treating polygon bounds and raster review as unrelated checks.

## ⟲ Previous-session review

The Bramble clearance correction correctly reduced obstacle occupancy and
cadence, but its own source record said collision outlines rather than raster
silhouettes remained the geometry proof. The owner screenshot now falsifies
that separation: a passable polygon can still be unfair when its player-facing
art does not cover the lethal shape. This slice keeps the successful cadence
work and closes only that contact-visibility gap.

- **📊 Model:** gpt-5.6-sol · high · runtime fairness correction

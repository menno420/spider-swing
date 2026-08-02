# Obstacle contacts sit inside the visible silhouette

> **Status:** `complete`

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

The supplied 2048×945 build `0.34.0-speed-cap-playtest` screenshot ends at
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

## Implemented design

- `CourseGeometry.obstacles` remains the visible, route-validation, and web
  attachment envelope; a parallel contact polygon is lethal.
- Every obstacle contact uses a default 4 px inset from the 18 px player circle.
  Ceiling/floor boundaries retain the complete player radius.
- Bramble hook and shutter variants mirror alpha-traced contact profiles four
  runtime pixels inside their finished art at the shipped scale.
- Moving hazards sample and sweep visual and contact polygons through the same
  deterministic motion descriptor.
- Advanced Test Lab exposes 0/2/4/6 px presets. The opt-in overlay draws contact
  polygons plus the full boundary radius and smaller obstacle-contact radius.

## Verification so far

Exact Godot 4.7.1 passes 208/208 contracts. The new owner-device regression
rejects the former 17 px gap death, requires collision at 13 px, keeps full-size
rails and visual-envelope attachment, preserves distinct Bramble profiles
through geometry copies, and sweeps a smaller moving contact silhouette. Final
strict/CI/Android evidence is deliberately pending while this card is
`in-progress`.

## Adversarial falsification

Three one-at-a-time production mutations turned the permanent contract red for
the intended reason: changing the shared default from 4 px to 0 resurrected the
gap death; replacing the hook's alpha profile with its broad visual polygon was
identified by family name; and applying the obstacle inset to course boundaries
was rejected. The implemented source was restored after each mutation.

## Remote implementation evidence

PR #119 implementation head `75f95ad4` is a true merge over current `main`
`1d6778c8`; its GitHub tree `ec622ee72d5ea4ec1ee8d8020d300262d4466895`
matches the locally verified tree byte-for-byte. Exact Godot 4.7.1 passes
210/210 after the reconciliation, including both menu-session contracts and
this obstacle-contact regression. The claim is removed only in the closeout
batch that follows this recorded evidence.

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

- **📊 Model:** gpt-5.6-sol · high · runtime bugfix

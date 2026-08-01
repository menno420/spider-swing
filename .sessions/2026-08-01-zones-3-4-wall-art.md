# Recorded Zones 3–6 environment finish

> **Status:** `in-progress`

## Goal

Bring Silk Hollow, Ruined Arboretum, Storm Ridge, and Web City to the complete
environment standard established by Ancient Forest and Bramble Canopy. Add
real parallax depth, finished zone-specific corridor and safe-surface
materials, remove non-debug polygon ghosts from finished obstacles, and make
every declared ceiling-grown hazard meet the actual local ceiling profile.
Attachment supports may extend only through the measured gap to that profile;
primary hazard silhouettes, corridor profiles, route guides, physics values,
floor clearances, and anchor rules remain unchanged.

## Scope guard

Own only recorded Zones 3–6 environment presentation assets, semantic renderer
routing, presentation contracts, reproducible recording/device-scale evidence,
build identity, and the living handoff record. Exclude PR #89 replay tooling,
Ancient Forest and Bramble art, authoritative obstacle/boundary/surface
geometry except narrow ceiling attachment supports, route guides and corridor
profiles, zone mechanics, simulation, physics values, difficulty, progression,
economy, settlement, saves, and input. Every support change requires a seeded
passability proof and an exact before/after geometry assertion limiting the
delta to the intended support.

## Previous-session review

**previous-session review:** PR #87 correctly replaced the most visible flat
obstacle polygons with finished Silk and Arboretum objects, but its seeded
preview exposes the remaining generic wall path: thin cyan double outlines at
the ceiling and floor still frame otherwise finished zone art.

## Owner evidence

The owner's six 2026-08-01 recordings establish Ancient Forest (0–5 km) and
Bramble Canopy (5–10 km) as the finished benchmark. Silk Hollow, Ruined
Arboretum, Storm Ridge, and Web City retain attractive single-layer backplates
but expose pale corridor polygons, always-on moving-rest outlines, unresolved
surface/egg/scree fallbacks, and visible joins where wall-grown art stops short
of the rendered boundary. The correction must address those shared
presentation paths without using painted thickness to misrepresent collision
or reduce the opening.

## 💡 Idea

Give each zone reusable backdrop-layer, boundary-material, surface-material,
and obstacle-art specifications so environment finish is selected from semantic
zone data rather than accumulating renderer branches.

- **📊 Model:** gpt-5.6-sol · high · visual correction

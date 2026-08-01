# Silk Hollow and Ruined Arboretum corridor wall art

> **Status:** `in-progress`

## Goal

Replace the visibly unfinished ceiling and floor corridor outlines in Silk
Hollow and Ruined Arboretum with finished, zone-specific wall surfaces while
preserving every authoritative wall polygon, playable clearance, obstacle,
background, physics value, and anchor rule.

## Scope guard

Own only Zones 3–4 corridor-wall presentation assets, renderer routing,
presentation contracts, reproducible visual evidence, build identity, and the
living handoff record. Exclude PR #89 replay tooling, Bramble, obstacle
geometry/art, zone mechanics, simulation, difficulty, progression, economy,
settlement, saves, and input.

## Previous-session review

**previous-session review:** PR #87 correctly replaced the most visible flat
obstacle polygons with finished Silk and Arboretum objects, but its seeded
preview exposes the remaining generic wall path: thin cyan double outlines at
the ceiling and floor still frame otherwise finished zone art.

## Owner evidence

The owner's 2026-08-01 screenshot of the PR #87 comparison identifies the top
and bottom corridor walls—not the new foreground objects—as unfinished. The
correction must therefore change the wall surface treatment itself without
using painted thickness to misrepresent collision or reduce the opening.

## 💡 Idea

Give each zone a reusable boundary-material specification so later wall art is
selected from semantic zone data rather than accumulating renderer branches.

- **📊 Model:** gpt-5.6-sol · high · visual correction

# Living forest depth session

> **Status:** `in-progress`

## Goal

Turn the current Ancient Forest slice into one continuous, convincing
environment: remove the remaining branch-rail texture gaps, give wall-grown
hazards natural attachment sockets, introduce a restrained and fair progression
of larger/more varied obstacle compositions, and replace the abstract circle
background with layered forest depth.

## Scope guard

This session may change presentation rendering, Ancient Forest runtime art,
deterministic course pattern selection, late-course obstacle composition,
regression contracts, documentation, and development build identity. It must
not move either rail inward before 2000 m, alter swing physics, make a required
route depend on upgrades or power-ups, shrink the broad passage, expose
outlines/web guides by default, or add random lethal placement.

## Previous-session review

**previous-session review:** PR #26 made finished obstacle art overlap behind
the rail and retired the distorted circular gate crop. Menno's
`0.8.4-cohesive-forest-test` recording confirms the broad passage and overall
environment are much better, while exposing a short missing-wood patch at
profile changes, a few weak wall attachments, undersized low-impact hazards,
repeated obstacle rhythms, and a flat abstract background.

## Decisions flagged

- Render each visible ceiling/floor profile as one cumulative textured path so
  texture continuity is independent of individual segment length.
- Treat hazard-to-wall contact as a reusable growth socket with roots, moss, and
  a contact shadow that stays inside the authoritative polygon/rail overlap.
- Preserve the 0–1000 m learning runway; introduce modest size and composition
  changes by distance band, with paired/staggered challenges only after 2000 m.
- Keep pattern selection deterministic and curated, with repetition cooldowns
  and explicit route lanes rather than per-obstacle random placement.
- Add three restrained, mobile-safe background depths that never compete with
  lethal silhouettes.

## 💡 Idea

Make the course read like a single old tree system: the rail is the continuous
load-bearing branch, every obstacle has a visible root collar where it grows
from that branch, and background layers reuse the same bark/moss/light language
at progressively lower contrast.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

[[fill: local Godot, strict gate, pull-request CI, and APK evidence]]

## Documentation audit

[[fill: exact records updated and binding documents left unchanged]]

## Remaining owner review

[[fill: real-device visual and feel checks]]

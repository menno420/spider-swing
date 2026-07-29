# Living forest depth session

> **Status:** `complete`

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

- `python3 tools/verify.py --require-godot`: PASS on Godot
  `4.7.1.stable.official.a13da4feb`; architecture self-test/scan, clean import,
  front-end boot, and all 82 declared contracts passed.
- PR #27 `game-quality` run
  [30485134026](https://github.com/menno420/spider-swing/actions/runs/30485134026):
  PASS at source `06a4c65aeb87b4d47a54423f9cd56ce87dcaaba5`.
- PR #27 `android-debug` run
  [30485133800](https://github.com/menno420/spider-swing/actions/runs/30485133800):
  PASS. Artifact
  [`spider-swing-android-debug`](https://github.com/menno420/spider-swing/actions/runs/30485133800/artifacts/8737309320)
  is 61,305,243 bytes with digest
  `sha256:298f4733a665863f348af041c67b4c2ba6d4258e9705864fc0ebecba4d4cf33f`.
  The downloaded ZIP and 61,704,954-byte APK both passed archive validation;
  APK SHA-256 is
  `90294c3b51a1aebe7b2227ea720573d2b2888443d6bdcf4686b60ab495e45eb8`.
  `build-info.txt` proves version `0.9.0-living-forest-test`, exact source, dev
  package, and display name `Spider Swing Living Forest (dev)`.
- Final `python3 bootstrap.py check --strict`: PASS after the deliberate
  completed-status flip; the earlier red run was the designed born-red hold.

## Documentation audit

Updated the root README; runtime/source asset records; application and
presentation ownership READMEs; testing reference; current-state ledger;
capability ledger; control heartbeat; development build identity; and this
session card. The checksum-pinned GDD and all binding ADRs were read as
constraints and left byte-for-byte unchanged.

## Remaining owner review

Install the verified PR #27 APK and confirm that bark is continuous at profile
changes, every hazard reads as growth from the rail, the realistic depth remains
subordinate to the spider/web/flies, and the slightly larger/more varied later
patterns remain fair with the near-max Classic spider. This is a reversible
development-art and deterministic-pattern decision, not final production-art or
balance approval.

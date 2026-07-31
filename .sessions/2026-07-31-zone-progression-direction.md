# Zone progression direction, and the overnight brief

> **Status:** `complete`

## Goal

Turn an owner + Grok brainstorm into a zone design document the repo can build
from, and write the standing brief for the unattended overnight session.

## Scope guard

Documents only. No gameplay code, no physics values, no region added yet.

## Previous-session review

**previous-session review:** PR #66 recorded the required-checks ruleset and the
settings capability, and correctly refused to write a classifier refusal down as
a wall — the retry an hour later proved that right. Nothing to fault; the
session closed with main clean and no open PRs.

## What the brainstorm got right, and what it could not know

Grok's list gave a strong spine: one new mechanical feeling per zone, silhouette
and palette as the identity test, and a sensible escalation from canopy through
storm to fog. All of that is kept.

Three things it could not know, each of which would have caused real damage:

- **Its zones 1–3 sit on top of shipped regions.** `ancient_forest`,
  `bramble_canopy` and `silk_hollow` already own 0–15 000 m, their ids key
  persisted checkpoints, and Bramble Canopy's environment landed in PR #62
  today. Owner decision: keep the three, append new zones from 15 000 m.
- **Moving parts are an architecture change, not a content change.** The
  simulation is fixed-step and seeded with contracts asserting identical
  trajectories across frame rates. Swinging shards, wind and machinery must be
  pure functions of `(chunk_index, course_seed, tick)`. That needs an ADR before
  the first one lands.
- **Reduced visibility costs a measured budget.** At 76 m/s there is about one
  second of warning. Fog, spore clouds and ash spend that directly and have to
  repay it with silhouette lighting or audio.

## Improvements made on top

- **Every zone declares one axis it owns**, because speed stops escalating at
  5000 m — so composition is the only remaining difficulty lever, and repeating
  an axis is how a zone becomes a re-skin.
- **Every zone declares the one sentence a playtester would say**, which turns
  "does it work" into an acceptance test rather than a matter of taste.
- **New feelings, not new buttons** — the owner never uses the BURST button at
  speed, so mechanics must express themselves through existing verbs.
- **Hazards must declare anchor eligibility**, now that it is per-obstacle data.
- **Fungal Grove is recommended for the campaign rather than the endless run.**
  Its range is occupied by Silk Hollow, and a gentle spectacular zone sits badly
  at 20 000 m+ where everything else escalates. The campaign teaching tier wants
  exactly that, and its bounce surfaces are the natural place to teach Buckler.

## Shipped

- `docs/product/zone-progression.md` — zone source of truth: the axis table,
  six standing constraints, zones 4–8 in full, the Fungal Grove recommendation,
  and a build order that puts the ADR and the moving-anchor proof first.
- `docs/planning/overnight-brief-2026-08-01.md` — the unattended session's
  standing brief: non-negotiables, wake-chain discipline per `docs/ROUTINES.md`,
  and an ordered slice backlog.
- `docs/README.md` — both indexed.

## Verification

`python3 bootstrap.py check --strict` → **exit 0**. The gate rejected `direction`
as a status badge on first attempt; corrected to `owner-guidance`.

## Open owner questions

**Fungal Grove placement** — recommended as a campaign environment rather than
an endless zone. Recorded as a recommendation, not a decision.

## 💡 Idea

The riskiest item in the whole plan is one question: can the web constraint hold
a *moving* anchor without injecting energy? Everything in Zone 4 leans on it,
and it is answerable headlessly in an hour with `tools/simulate.gd`. The brief
puts it at slice 2, before any zone content depends on it, so a negative answer
costs a morning instead of a zone.

- **📊 Model:** opus-5 · high · idea/planning — zone direction and the overnight
  brief

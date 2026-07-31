# Documentation index

> **Status:** `reference`
>
> Entry point for everything under `docs/`. The live surface always beats a doc:
> when source and prose disagree, follow the source and correct the doc in the same
> change.

## Start here

| Order | Document | Why |
| ---: | --- | --- |
| 1 | [`AGENT_ORIENTATION.md`](AGENT_ORIENTATION.md) | How to work in this repository. |
| 2 | [`current-state.md`](current-state.md) | What is true right now — the stability baseline, what is in flight, what shipped. |
| 3 | [`CAPABILITIES.md`](CAPABILITIES.md) | What sessions in this environment can and cannot do, with verified evidence. |

## Product

| Document | What it is |
| --- | --- |
| [`game-design/Spider-Swing-GDD-v2.0.md`](game-design/Spider-Swing-GDD-v2.0.md) | **The product and gameplay source of truth.** Vendored byte-exact and checksum-pinned — see [`game-design/README.md`](game-design/README.md). |
| [`product/name-status.md`](product/name-status.md) | Why "Spider Swing" is a codename, and what naming/trademark/store review remains. |
| [`product/spider-biology-folio.md`](product/spider-biology-folio.md) | **Spider identity source of truth.** The naming rule (real name first, otherwise name the science), the approved mapping per profile, editorial voice, art and image-sourcing rules, and the parked candidate backlog. |
| [`product/spider-biology-verification-2026-07-31.md`](product/spider-biology-verification-2026-07-31.md) | Dated verification log for the second deep-research report — what was re-checked, against what, and what was deliberately not adopted. |
| [`product/zone-progression.md`](product/zone-progression.md) | **Zone source of truth.** The axis each 5000 m zone owns, its hazards, mechanics, density curve and the one sentence a playtester must say. Zones 1–3 are shipped and frozen; 4–8 are designed and not yet built. |
| [`planning/overnight-brief-2026-08-01.md`](planning/overnight-brief-2026-08-01.md) | Slice backlog and standing constraints for the unattended overnight session that builds zones 4+. |
| [`owner-questions.md`](owner-questions.md) | Open owner-only forks, each with the default the work proceeds under, plus the answered ones. |

## Technical

| Document | What it is |
| --- | --- |
| [`technical/repository-layout.md`](technical/repository-layout.md) | What lives where, and what is committed vs generated. |
| [`technical/testing.md`](technical/testing.md) | The two gates, how to run them locally, what CI enforces. |
| [`technical/substrate-kit-provenance.md`](technical/substrate-kit-provenance.md) | How the vendored Substrate Kit got here; how to re-verify the pin. |

### Architecture decisions

Binding. Superseded rather than deleted.

| ADR | Decision |
| --- | --- |
| [`0001`](technical/adr/0001-engine-and-runtime.md) | Godot 4.7.1 Standard, GDScript, Compatibility renderer, 60 Hz fixed step. |
| [`0002`](technical/adr/0002-simulation-and-event-boundaries.md) | Inward layering and deterministic event flow. |
| [`0003`](technical/adr/0003-android-build-strategy.md) | Debug-only Android CI now; production signing later, owner-controlled. |
| [`0004`](technical/adr/0004-deterministic-moving-parts.md) | Pure fixed-tick motion, swept moving collision, and energy-safe moving web anchors. |

## Substrate-generated living ledgers

These are **rendered from interview answers** — change them with
`bootstrap.py answer <slot> "..."` then `bootstrap.py render --live`, not by
hand-editing the output.

[`architecture.md`](architecture.md) ·
[`ownership.md`](ownership.md) ·
[`runtime_contracts.md`](runtime_contracts.md) ·
[`reading-path.md`](reading-path.md) ·
[`owner-profile.md`](owner-profile.md) ·
[`collaboration-model.md`](collaboration-model.md) ·
[`ai-project-workflow.md`](ai-project-workflow.md) ·
[`decisions.md`](decisions.md) ·
[`question-router.md`](question-router.md) ·
[`repo-navigation-map.md`](repo-navigation-map.md) ·
[`helper-policy.md`](helper-policy.md) ·
[`ROUTINES.md`](ROUTINES.md) ·
[`SKILLS.md`](SKILLS.md) ·
[`seat-digest.md`](seat-digest.md) ·
[`ideas/README.md`](ideas/README.md)

## Elsewhere in the repository

- [`../README.md`](../README.md) — project entry point: what Spider Swing is, how to
  open it, how to get an Android debug build.
- [`../CONSTITUTION.md`](../CONSTITUTION.md) — the binding working contract.
- `../control/` — the coordination bus: status heartbeat, inbox, claims.
- `../.sessions/` — append-only session memory.

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
| 3 | [`planning/next-session-brief-2026-08-01-mechanics.md`](planning/next-session-brief-2026-08-01-mechanics.md) | **The current next-session entry point.** Earned speed and the bird — what to build, the three mistakes that look correct from the outside, and the paste-ready prompt. Supersedes the recording-led handoff below. |
| 4 | [`game-design/earned-speed-and-the-bird.md`](game-design/earned-speed-and-the-bird.md) | The spec that brief points at: the measured argument, every seam with a file:line, and what cannot be tuned from the lab. |
| 5 | [`game-design/difficulty-and-obstacle-doctrine.md`](game-design/difficulty-and-obstacle-doctrine.md) | **Open proposal, owner is analysing it.** The measured difficulty baseline — authored curve, real corridor width, the eight authored axes — four structural findings, and proposed rules for how difficulty and obstacle placement are decided. Nothing here is implemented. |
| 6 | [`CAPABILITIES.md`](CAPABILITIES.md) | What sessions in this environment can and cannot do, with verified evidence. |
| — | [`planning/fresh-session-handoff-2026-08-01.md`](planning/fresh-session-handoff-2026-08-01.md) | **Superseded as a plan, accurate as a record.** The recording-led, visuals-led continuation. Read it for what merged and what Menno accepted; not for what to do next. |

## Product

| Document | What it is |
| --- | --- |
| [`game-design/Spider-Swing-GDD-v2.0.md`](game-design/Spider-Swing-GDD-v2.0.md) | **The product and gameplay source of truth.** Vendored byte-exact and checksum-pinned — see [`game-design/README.md`](game-design/README.md). |
| [`product/name-status.md`](product/name-status.md) | Why "Spider Swing" is a codename, and what naming/trademark/store review remains. |
| [`product/spider-biology-folio.md`](product/spider-biology-folio.md) | **Spider identity source of truth.** The naming rule (real name first, otherwise name the science), the approved mapping per profile, editorial voice, art and image-sourcing rules, and the parked candidate backlog. |
| [`product/spider-biology-verification-2026-07-31.md`](product/spider-biology-verification-2026-07-31.md) | Dated verification log for the second deep-research report — what was re-checked, against what, and what was deliberately not adopted. |
| [`product/zone-progression.md`](product/zone-progression.md) | **Zone source of truth.** The axis each 5000 m zone owns, its hazards, mechanics, density curve and the one sentence a playtester must say. Zones 4–8 are shipped; their human success sentences remain device-playtest gates. |
| [`planning/overnight-brief-2026-08-01.md`](planning/overnight-brief-2026-08-01.md) | Slice backlog and standing constraints for the unattended overnight session that builds zones 4+. |
| [`product/player-preference-research-2026-08-02.md`](product/player-preference-research-2026-08-02.md) | **The 25 k north star** and the genre-preference research behind it — plus the provenance block separating the three corroborated claims from the unverified ones, the upgrade capability-vs-numbers fork, the hard monetisation boundaries, and what is explicitly parked. |
| [`product/economy-model.md`](product/economy-model.md) | **Economy source of truth.** What each currency is for, what it buys, what cannot be bought at any price, and what happens to the measurably inert upgrade tracks. |
| [`owner-questions.md`](owner-questions.md) | Open owner-only forks, each with the default the work proceeds under, plus the answered ones. |

## Technical

| Document | What it is |
| --- | --- |
| [`technical/repository-layout.md`](technical/repository-layout.md) | What lives where, and what is committed vs generated. |
| [`technical/testing.md`](technical/testing.md) | The two gates, how to run them locally, what CI enforces. |
| [`technical/substrate-kit-provenance.md`](technical/substrate-kit-provenance.md) | How the vendored Substrate Kit got here; how to re-verify the pin. |
| [`technical/replay-review-loop.md`](technical/replay-review-loop.md) | How a run the lab found gets in front of a person to be judged — the trace format, the two independent replays that prove it reproduces, and what to look for while watching. |
| [`technical/simulation-lab.md`](technical/simulation-lab.md) | The headless batch-run lab — what it can and cannot answer, and how to measure a difficulty curve with it. |

## Measurements

Dated, reproducible instrumentation output. Diagnostic, never a gate; re-measure
and diff rather than trusting a number forever.

**Every number in here carries its provenance** — `measured` (with the method
*and the instrument's resolution*), `inferred` (naming what from), or `assumed`.
A number with no stated instrument has no source to lose to, so nothing can ever
show it wrong, and it compounds silently into whatever gets decided on top of
it. That is not hypothetical: `4.71 taps/s` was sampled at 30 fps from a
natively 60 fps recording, a design constraint was built on it, and the
constraint was then cited as the reason the design was trustworthy. The method
was stated; the sampling rate was not; the number was 40% low. Substrate-kit
carries the rule as **PL-013** and an advisory checker
(`check_claim_provenance`) that arrives with the next kit release — the
convention does not wait for it.

| Document | What it is |
| --- | --- |
| [`measurements/2026-08-01-owner-play-calibration.md`](measurements/2026-08-01-owner-play-calibration.md) | **Ground truth for how the game is actually played**, from owner device recordings — and the acceptance test any simulation model must pass before its output is published. |
| [`measurements/2026-08-01-recovery-gap.md`](measurements/2026-08-01-recovery-gap.md) | **88–100% of the model's deaths happen with an unused escape in hand.** The remaining gap is recovery, not route choice — superseding the diagnosis in the v3 document. |
| [`measurements/2026-08-01-hauling-loophole.md`](measurements/2026-08-01-hauling-loophole.md) | **The first confirmed exploit** — hauling along the ceiling instead of swinging — measured on arc-per-web, and why a speed-based chaser cannot separate it from the owner's own play. |
| [`measurements/2026-08-01-upgrade-playstyle-sweep.md`](measurements/2026-08-01-upgrade-playstyle-sweep.md) | **What upgrades change about how the game is played** — they buy survival and economy of effort, not distance — plus the cross-application test that separates a real effect from search luck. |
| [`measurements/2026-08-01-bot-model-v3.md`](measurements/2026-08-01-bot-model-v3.md) | What the v3 player-model rebuild fixed, what it bought, and the three plausible fixes that measured worse and were deleted. Scored against the acceptance targets: three of eight. |
| [`measurements/2026-08-01-upgrade-audit.md`](measurements/2026-08-01-upgrade-audit.md) | What each upgrade track is actually worth, measured per track in isolation — including two that change the config and change nothing about play. |
| [`measurements/2026-08-01-difficulty-curve.md`](measurements/2026-08-01-difficulty-curve.md) | Deaths per kilometre, survival, death causes and resource pressure across 0–20 km and three skill tiers — the baseline difficulty modes, the upgrade audit and economy tuning are judged against. |

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
- [`../assets/source/audio/README.md`](../assets/source/audio/README.md) — original
  generated-audio policy, regeneration, and provenance.
- [`../assets/runtime/audio/README.md`](../assets/runtime/audio/README.md) — the
  25-SFX/two-stem playtest pack and runtime audit contract.
- `../control/` — the coordination bus: status heartbeat, inbox, claims.
- `../.sessions/` — append-only session memory.

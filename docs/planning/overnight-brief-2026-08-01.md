# Overnight brief — 2026-08-01, executed

> **Status:** `reference`
>
> ## ✅ Executed — this is a record, not a queue
>
> Written 2026-07-31 for an unattended session working while the owner slept.
> **Do not take work from this document.** Its backlog is spent and its
> non-negotiables have all been promoted to homes that get read; this file
> survives as the record of how an unattended session was framed, and of which
> constraints were worth writing down in advance.

## What it produced

Five of its seven slices landed, in order:

| Slice | Outcome |
| --- | --- |
| 1 · Difficulty curve measurement | [`../measurements/2026-08-01-difficulty-curve.md`](../measurements/2026-08-01-difficulty-curve.md) — its overnight conclusions were later **retracted**; the bot was failing at pace, not reading the course. |
| 2 · Campaign teaching tier | Three verb-gated levels (Reel, Burst, Dive), cleared by reaching the goal *and* performing the verb. |
| 3 · Difficulty modes | Relaxed / Standard / Harsh, with `DifficultyCatalog.PHYSICS_FIELDS` asserting that no mode moves a physics value. |
| 4 · Upgrade audit | [`../measurements/2026-08-01-upgrade-audit.md`](../measurements/2026-08-01-upgrade-audit.md) — and its inert-track finding was later reverted as a lab artefact. |
| 5 · Currency and reward model | [`../product/economy-model.md`](../product/economy-model.md) — flies buy power, stars buy appearance, nothing buys mastery. |

**Slice 6 (missions) was never taken and should not be revived from here.**
Missions are deferred by the 2026-08-02 north star until the core loop is right;
`current-state.md` lists them under deliberate scope boundaries. Slice 7 (ideas,
grounded in measurement) became [`../ideas/`](../ideas/README.md).

The one parked question — whether the web constraint can hold a *moving* anchor
without injecting energy — was answered and is now
[ADR 0004](../technical/adr/0004-deterministic-moving-parts.md).

**Two of its five delivered findings were later overturned by owner device
evidence.** That is the most useful thing this brief records: an unattended
session measuring with an unvalidated instrument produced confident numbers in
both directions, and the corrections cost more than the measurements saved. It
is why `simulation-lab.md` now carries a standing publication ban rather than a
caveat.

## Where its non-negotiables went

Nothing here is lost — each rule now lives somewhere a session actually reads:

| Rule | Home |
| --- | --- |
| Do not change physics values; `balanced_baseline` is owner-approved | `current-state.md` § Owner playtest gates, and D-0037 |
| Determinism is a contract — pure functions of `(chunk_index, course_seed, tick)`, no runtime RNG | [ADR 0004](../technical/adr/0004-deterministic-moving-parts.md) |
| Zones 1–3 are frozen; their ids key persisted checkpoints | `current-state.md` § Traversal and deterministic course |
| Verify with `python3 tools/verify.py --require-godot` | [`../technical/testing.md`](../technical/testing.md) |
| Re-run the suite after any merge — `EXPECTED_CHECK_COUNT` is the merge hazard with no marker | [`../technical/testing.md`](../technical/testing.md) § Adding gameplay tests |
| Falsify every new contract before trusting it | [`../technical/testing.md`](../technical/testing.md) § Adding gameplay tests |
| Never record a wall — a refused call is transient venue state | [`../CAPABILITIES.md`](../CAPABILITIES.md), THE DISCOVERY RULE |
| Leave anything that changes how the swing feels to the owner | [`../owner-questions.md`](../owner-questions.md) |

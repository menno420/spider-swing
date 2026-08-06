# Local run evidence

> **Status:** `binding`
>
> Contract for build `0.44.0-run-evidence`. This is local design evidence, not
> analytics and not a leaderboard schema.

## Purpose and boundary

The game keeps enough authoritative context to compare completed runs without
guessing from screenshots or presentation state. It does not upload, rank,
identify, reward, or balance from these records. Human device verdicts continue
to own feel and difficulty decisions.

`RunRecord` is deliberately richer and more changeable than a future
leaderboard entry. No trust, anti-cheat, ranking, account, or immutable-board
contract is implied by this schema.

## Ownership and lifecycle

The existing authority chain remains intact:

```text
InputCommand
  → fixed-step SimulationWorld
  → SimulationEvent / authoritative state
  → SwingLabSession
  → one terminal finalization
  → RunSettlement + RunRecord
  → ProgressionService, then SaveRepository
```

- `RunMetricsAccumulator` is application-owned and pure. `SwingLabSession`
  samples it once per active fixed tick, immediately before `SimulationWorld`
  steps, and feeds it only accepted authoritative `SimulationEvent` values.
- `SwingLabSession.run_finalized(settlement, record)` is the sole completed-run
  seam. The record carries the settlement ID plus a unique per-attempt record ID
  and both values are emitted together once. Keeping those identities distinct
  lets repeated Campaign clears remain evidence while the Campaign settlement
  ID continues to suppress repeat stars.
- `ProgressionService` applies the settlement first. Evidence append/write is
  optional and follows it. An evidence failure logs an error but cannot roll
  back, repeat, or cancel flies, stars, unlocks, best distances, or settlement
  idempotency.
- `SaveRepository` is the only filesystem writer. It owns the evidence ledger,
  diagnostic file, settings, progression, and Test Lab profile write seams.
- `FrontEndState` owns Run History navigation and the export payload.
  `FrontEndView` only renders it. `ClipboardAdapter` makes the explicit platform
  clipboard call after the player selects **COPY JSON**.

Restart resets the accumulator before a new attempt. A main-owned
`RunAttemptCounter` supplies ordinals across every run session in one app
launch. The ledger assigns the lifetime completed-run ordinal only when it
accepts the record.

## Metric definitions

All time and speed metrics use active fixed simulation ticks, never wall-clock
time or render frames.

| Field | Definition |
| --- | --- |
| active duration | sampled active ticks ÷ 60 |
| final distance | authoritative absolute `SimulationWorld.distance_pixels` at finalization |
| travelled distance | `max(0, final distance − actual start distance)` |
| mean speed | arithmetic mean of non-negative horizontal velocity sampled immediately before each active fixed step |
| maximum speed | maximum of those same pre-step forward-speed samples |
| above-reference share | samples strictly above `SwingConfig.target_speed_at(distance)` ÷ sampled active ticks |
| Reel held | pre-step ticks for which authoritative `web.reel_active` is true ÷ 60 |
| flies per kilometre | collected flies ÷ travelled kilometres; zero when no distance was travelled |

`tools/simulate.gd` uses the same `RunMetricsAccumulator` for these shared
definitions. Simulator-only model diagnostics remain separate.

Successful actions are accepted simulation facts, not input attempts:

| Stored count | Accepted event |
| --- | --- |
| web attachments | `ATTACHED` |
| Reel activations | `REEL_STARTED` |
| Reel empties | `REEL_EMPTY` |
| Burst activations | `BURST_STARTED` |
| Dive activations | `DIVE_STARTED` |
| rescue consumed | `RESCUE_USED` (boolean) |

`REEL_UNAVAILABLE`, `BURST_UNAVAILABLE`, and `DIVE_UNAVAILABLE` never increment
successful-use fields. Death cause is stored as the raw authoritative
identifier; the record does not group or relabel it.

## Record schema

`RunRecord.SCHEMA_VERSION` is independent of settings and progression schemas.
Schema 1 retains only fields with a current evidence or eligibility consumer:

- identity: unique record ID, linked authoritative settlement ID, visible build,
  Android version code,
  runtime platform, `SwingConfig` schema, trace format, course seed;
- run context: mode, difficulty, spider profile, resolved levels for every
  upgrade on that spider, preset, actual start, reward/record/leaderboard flags;
- classification: attempt and lifetime ordinals, human or trace-replay input,
  standard/Campaign/Region Practice/debug/Course Lab/replay kind, and sparse
  nonstandard details such as debug start, overlay, explicit bird/tuning
  overrides, creator pattern, Campaign level, or trace format;
- performance and accepted actions using the definitions above;
- outcome: terminal outcome, raw death/final cause, final region/distance,
  rescue use, flies, travelled-distance fly rate, and Campaign level ID.

It does not copy the entire mutable `SwingConfig`, retain presentation labels,
or invent timestamps. No first/most-recent timestamp is stored because the
current runtime does not define a trustworthy persisted clock contract.

Unknown fields in a supported schema are ignored. Invalid records are skipped.
A future schema is not interpreted as schema 1; loading tries the valid backup
and otherwise returns an empty evidence ledger without touching settings or
progression.

## Eligibility and termination

| Path | Evidence result |
| --- | --- |
| ordinary Relaxed/Standard/Harsh death | one human record with the mode's existing eligibility flags |
| Campaign completion | one `campaign_complete` record; no fly/record/leaderboard eligibility |
| Region Practice or debug-run death | one explicitly classified noncompetitive record |
| Course Lab death | one `course_lab` record with its bounded creator pattern |
| trace replay death/finalization | one noncompetitive `trace_replay` record; never presented as human |
| tutorial practice completion/death | excluded because tutorial practice creates no settlement |
| restart after a settled run | previous run stays finalized; new counters and identity begin |
| Menu return, abandonment, suspension, shutdown | no direct record; this slice adds no non-settlement session tracker |

Every path that already produces a `RunSettlement` may therefore produce one
record. There is no presentation-triggered abandonment write and no reward path
created for evidence.

## Ledger, retention, and recovery

`RunRecordLedger.SCHEMA_VERSION` is 1. It retains the newest 100 full records.
Appending a retained duplicate ID is rejected. Rolling eviction does not change
the fixed-size lifetime aggregates:

- completed recorded runs;
- active play duration;
- travelled distance;
- best comparable zero-start, human, records-eligible distance for each finite
  difficulty mode.

Recent ordering, latest-run display, and rates are derived from retained
records. No speculative per-action lifetime totals are stored.

The ledger lives in `user://run_record_ledger.json` and uses the repository's
temporary-file/primary/backup rotation. Missing or invalid evidence defaults
empty; a corrupt or unsupported primary may recover from a valid backup.
Evidence is a separate document, so recovery cannot rewrite or invalidate the
settings or progression documents.

## In-game access and export

Open **Home → Play Modes → Run History**. The screen shows:

- lifetime runs, active play time, travelled distance, and comparable bests;
- a detailed latest-run summary;
- newest-first retained records with explicit standard/practice/debug/Campaign/
  replay context and eligibility;
- **VIEW JSON**, which exposes a selectable local payload, and **COPY JSON**.

Export format `spider-swing-local-run-evidence@1` wraps the complete retained
ledger with `local_only: true` and `transmission: "none"`. Copy is an explicit
player action. The platform API cannot acknowledge a successful Android paste,
so the UI asks the player to paste once to verify; if clipboard access is
unavailable, the JSON remains visible and selectable.

There is no network client, endpoint, upload queue, account/device/advertising
identifier, analytics SDK, background transfer, or automatic export. Nothing
is transmitted off-device by this feature.

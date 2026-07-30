# Reserve Burst breakthrough session

> **Status:** `complete`

## Goal

Record the owner's approval of the corrected Reel build, then implement the
first mechanic-changing breakthrough exactly as specced and deferred:
Anchor Drive level 10 stores a second Burst charge. Capacity rises from one
to two, successful Bursts alone spend a pip, and one serial timer refills
one pip at a time without resetting when the reserve is spent — preserving
the long-run one-Burst-per-cooldown rate.

## Scope guard

This session may change Burst availability from a bare cooldown to a
charge/serial-refill model (level-zero behaviour must remain equivalent:
capacity 1 ⇔ today's cadence), grant capacity 2 at Anchor Drive level 10,
expose a `burst_charges` debug tuning value, add pip indicators to the Burst
button when capacity exceeds one, update the simulation lab's availability
check, add the covering contracts, bump build identity, and record decisions
D-0023/D-0024 plus living-doc updates. It must not change Burst distance,
duration, exit speed, tangential retention, Dive, Reel, aim, routes,
progression costs, or saves.

## Previous-session review

**previous-session review:** PR #45 landed simulation-lab bot v2 (adaptive
to upgrades, sweeps, economy metrics) green on both gates. Menno then
device-tested maxed Silk Winder (416 px/s), reached 5 094 m on camera, and
gave explicit approval of the corrected Reel build — the exact gate the
deep-progression plan set for starting this prototype.

## Shipped

- `game/simulation/simulation_world.gd` — Burst availability is a charge
  pool (`burst_charges`) on one serial cooldown: spending starts the timer
  only when idle, each completion returns one charge and restarts the timer
  only while charges are missing, Burst Frenzy pins the pool full, and
  rescue restores it. Unavailability gates on empty charges, not the timer.
- `game/domain/swing_config.gd` + `tuning_catalog.gd` —
  `burst_charge_capacity` (validated 1–3), preset reset, and a Stored
  Bursts DEBUG value in the Pulls section.
- `game/domain/spider_catalog.gd` — Anchor Drive level 10 (2 ×
  `BREAKTHROUGH_INTERVAL`) grants capacity 2; the track description now
  names the breakthrough.
- `game/application/swing_lab_session.gd` + `simulation_snapshot.gd` — the
  detached double-tap web fallback now keys on an empty charge pool;
  snapshots carry charges and capacity.
- `game/presentation/scripts/swing_lab.gd` — readiness keys on charges;
  reserve pips (filled ready / hollow refilling) draw only when capacity
  exceeds one, so the level-zero HUD is pixel-untouched.
- `tools/simulate.gd` — the lab bot spends charges for opportunistic and
  emergency Bursts.
- `tests/unit/phase0_physics_tests.gd` — two new deterministic contracts
  (93 total): unchanged level-zero cadence (single charge, cooldown gate,
  exactly-once refill to an idle timer) and the reserve behaviour (level 9
  vs 10 capacity, immediate second spend, spend never resets the running
  timer, serial one-at-a-time refill, frenzy pin). The double-tap fallback
  fixture now sets the charge pool alongside the timer; its contract is
  unchanged. Fixture spiders are velocity-pinned between actions so pull
  exit drift cannot re-route later taps.
- Build identity `0.14.0-reserve-burst-test`, Android version code 30,
  display name `Spider Swing Reserve Burst (dev)` across `project.godot`,
  `export_presets.cfg`, `tests/test_runner.gd`, and the Android workflow.
- Ledger: D-0023 (owner approves the corrected 320/416 px/s Reel band on
  device) and D-0024 (the serial reserve-Burst rule); deep-progression
  marks the deferred item implemented; testing/tests READMEs and
  current-state carry the 93-contract suite and the charge-pool baseline.

## Decisions flagged

- Level-zero equivalence is a contract, not an intention: capacity 1
  reproduces the former cooldown cadence exactly (timer decrements before
  command consumption, so readiness lands on the same tick).
- The reserve spend keeps a running refill timer's progress (D-0024's
  "never resets") — the stored charge is an option, not extra throughput.
- Suppressed (Frenzy) Bursts spend no charge, mirroring the former
  zeroed-cooldown behaviour.
- HUD pips render only at capacity ≥ 2 so the approved level-zero
  presentation is untouched without a toggle.

## 💡 Idea

When the lives system lands, consider showing the same pip language on the
rescue indicator (filled/hollow lives) so every stored-resource surface
reads identically at a glance.

- **📊 Model:** fable-5 · high · feature build

## Capability delta

None new. Pinned Godot 4.7.1 verification and the lab's batch path were
re-exercised; no wall was hit.

## Verification evidence

- `python3 tools/verify.py --require-godot` on pinned
  `4.7.1.stable.official.a13da4feb`: all steps PASS, 93/93 contracts (the
  first run caught a real fixture flaw — pull exit velocity drifted the
  test spider until an up-forward retry tap resolved as a downward Dive —
  fixed by velocity-pinning fixtures between actions, then green).
- Simulation lab smoke (expert, 15 runs): level-0 vs all-tracks-level-10
  means 1 979 m vs 1 880 m with Bursts per run 16.1 → 19.1 — the stored
  charge is used, survival stays flat, so the reserve reads as tempo, not
  free distance. (All tracks at 10, so not an isolated Anchor Drive
  measurement; the isolated read is the on-device evaluation.)
- Strict Substrate check with CI's exact added-card invocation: all checks
  passed with this card complete; guard-fire telemetry delta committed.
- PR opened from `claude/spider-swing-review-gujydb` after this flip;
  `game-quality`, `substrate-gate`, and the Android artifact land on the PR
  and the session drives it to green per the land-on-green rhythm.

## Documentation audit

D-0023/D-0024, deep-progression, testing.md, tests/README.md,
current-state's stability baseline and In-flight, the Shop-visible Anchor
Drive description, and this card agree on the charge-pool model, the
93-contract suite, and build identity `0.14.0-reserve-burst-test`.

## Remaining owner review

Play the reserve on device with Anchor Drive at level 10 (DEBUG → PULLS →
Stored Bursts 2 compares without grinding): does holding a second Burst
read clearly from the pips, do back-to-back saves feel earned rather than
spammy, and does the unchanged long-run rate keep Burst decisions
meaningful? Anchorite's species-readability items remain from PR #44.

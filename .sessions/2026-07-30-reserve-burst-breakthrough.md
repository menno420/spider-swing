# Reserve Burst breakthrough session

> **Status:** `in-progress`

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

## About to happen

Implement the charge model in SwingConfig/SpiderCatalog/SimulationWorld,
thread it through session/snapshot/HUD/lab, prove level-zero equivalence and
the serial-refill contract deterministically, run both gates on pinned Godot
4.7.1, then open the PR and drive it to green.

## Previous-session review

**previous-session review:** PR #45 landed simulation-lab bot v2 (adaptive
to upgrades, sweeps, economy metrics) green on both gates. Menno then
device-tested maxed Silk Winder (416 px/s), reached 5 094 m on camera, and
gave explicit approval of the corrected Reel build — the exact gate the
deep-progression plan set for starting this prototype.

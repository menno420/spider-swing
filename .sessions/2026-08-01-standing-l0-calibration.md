# Standing-start L0 calibration — the reel meter binds after all

> **Status:** `complete`

## Goal

Turn the owner's three standing-start unupgraded recordings into ground truth
for the L0 regime — the half of the acceptance table that until now rested on
a single spoken estimate — and test his claim that he ran the reel meter dry.

## Scope guard

Measurement and documentation only. No code, no model change, no tuning. Also
carries the merge of `origin/main` (#87, presentation-only) into the branch,
which conflicted on the usual guard-fires ledger and on
`EXPECTED_CHECK_COUNT` — the exact same-value merge hazard the runner's own
error message teaches; resolved to the executed total, 177.

## Previous-session review

**previous-session review:** the fresh-eye review validated the search gain on
held-out seeds and fixed six defects. Its acceptance table still carried
"Standing start, no upgrades ~2 000 m — owner statement" as the only L0 ground
truth. The owner then supplied the recordings that replace the statement.

## What the recordings show

Build `0.23.0-obstacle-art-playtest`, post-#86 geometry, normal runs from 0 m
at L0, decoded at their native **120 fps** (the previous clips were 60 — the
sampling-rate lesson from this morning, applied rather than relearned).

**Completed runs: 835 m, 1 359 m, 3 417 m, 4 747 m.** Median ~2.4 km. His
"~2 km" estimate was conservative on this build — and the kilometre-scale
run-to-run spread seen at the warp reappears at L0. Sustained speed 73–78 m/s.
Input 2.9–4.9 taps/s (peaks 8/12/15 per second) — slower than his L20-warp
6.60/s, so input rate scales with game pace, while the burst structure
(37–41% of gaps ≤50 ms) is unchanged.

## The finding: the reel meter binds at L0

The owner: *"I ran out of reel on my first run but used it excessively."*
Measured, pull-state frames excluded:

| Run | Median fill | Min | Empty episodes | Time at empty |
| --- | ---: | ---: | ---: | ---: |
| `c089936c` | 55% | **0%** | **4** | **5.17 s — 24% of the run** |
| `4bb8e6b2` | 82% | **0%** | 3 | 2.48 s |
| `aa8c06e9` | 68% | **0%** | 2 | 3.24 s |

One frame catches the literal "Reel energy empty" feedback line.

This corrects this morning's claim that the meter "does not bind at either end
of the upgrade track" — an extrapolation from L20 footage alone, and
survivorship: **the L20 meter is untroubled *because* the upgrades relieved
it.** Silk Reserve and Rapid Recovery sell relief a reel-heavy player genuinely
feels at low levels. Corrected in place in the calibration doc, the upgrade
audit (second correction banner), and current-state.

Third device-side correction of a lab claim today; second initiated by the
owner before the pipeline caught it.

The lab still cannot see this from either end: bot reel use is far lighter
than his (`reel empties` 0.00 in every batch at every level), so the reel
tracks remain unmeasurable by bot. That is now a *measured* fidelity gap, not
a suspicion.

## Bearing on OQ-10

"Upgrading should last longer" gains its first hard evidence: the reel tracks
are not inert candidates to extend — they remove a constraint that
demonstrably binds. What the extra levels should buy is still a product call,
but "extend tracks that measurably change play" now has two more members than
the morning's audit believed.

## Verification

Merged tree: `python3 tools/verify.py --require-godot` → exit 0,
**177 contracts** (my 176 + one Zones contract from #87; groups spot-checked —
Simulation lab 9, Front-end 22 intact). `python3 bootstrap.py check --strict`
→ exit 0. Docs-only measurement; no new contracts to falsify.

## Owner questions

None new. OQ-9 unchanged; OQ-10 evidence recorded above.

## 💡 Idea

The morning pass read one end of a dose-response curve and pronounced on the
whole curve. The L20 meter never dropping below 73% and the L0 meter emptying
four times in 21 seconds are not contradictory measurements — they are the
*same* fact about an upgrade that works. For any "is X useless" question about
a progression system, measure at the level where X is supposed to matter, not
at the level where the player being recorded happens to live.

## Next slice

Unchanged: per-upgrade fingerprint sweep (standing-L0 search is mid-run in the
background). The L0 recordings double as its validation set — the optimum's
distances and input rates can now be checked against real L0 play, not only
L20 warp play.
- **📊 Model:** fable-5 · high · research — standing-start L0 calibration

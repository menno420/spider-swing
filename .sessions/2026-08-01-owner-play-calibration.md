# Owner play calibration — the acceptance test the lab was missing

> **Status:** `complete`

## Goal

Turn six owner device recordings into the ground truth a simulation model must
match before its output is trusted. The overnight lab runs failed every target
in this document and their conclusions were published anyway; this exists so
that cannot recur.

## Scope guard

Measurement and documentation only. No code, no model change, no retune. The
structural fixes this enables are a separate piece of work.

## Previous-session review

**previous-session review:** the overnight run published a difficulty curve, an
upgrade audit and a shop change built on a bot that dies in three seconds where
the owner plays for forty. Two corrections have landed (PRs #80–#82). The
missing piece was never a better bot — it was the absence of any check that the
bot resembled a player before its numbers were used.

## What six runs show

All six are debug start 5 000 m at upgrades L20 — the same warp condition
`--start-m=5000` uses, so the comparison is direct.

| Run | Net progress | Speed |
| --- | ---: | ---: |
| `726dcc65` | 3 535 m | 78.6 m/s |
| `07a46d98` | 2 760 m | 66.3 m/s |
| `4185b2b4` | 2 671 m | 74.2 m/s |
| `256bd884` | 2 218 m | 73.9 m/s |
| `17dd734b` | 1 787 m | 44.7 m/s |
| `6b272cfb` | **−122 m** | — |

**0.47 deaths/km at ~52 m/s.** The bot on the identical warp: 196 m and 10.23
deaths/km — roughly 27× worse per kilometre.

**The variance is the finding six runs bought that one could not.** Net
progress spans −122 m to 3 535 m in the same configuration. The bot's
fixed-seed batches gave a p10–p90 of 141–274 m. Production draws a fresh course
seed every run, so the spread is the product; a model reproducing only its
median is not modelling this game.

Two behaviours a distance-maximising model cannot produce, both correct play:
`17dd734b` spends 20 seconds covering 320 m stabilising on a long web before
running 1 467 m in the next 20, and `6b272cfb` ends *behind* its start because
the rescue returns the player upstream.

## The input stream is recoverable

The owner pointed out that the recordings carry his taps — Android show-taps is
on. Confirmed: each touch draws a pale neutral disc that holds ~2 frames and
fades by the third, and it separates cleanly from the game art by saturation.

Extracted from run `726dcc65`: **229 taps in 48.6 s = 4.71 taps/second**, median
gap 0.133 s. Split: 22.7% left button (Reel), 30.6% right button
(Attach/Burst), 46.7% aimed taps in the play area.

**48% of the aimed taps land in the lower half of the screen** — Dive targets,
per the HUD's own instruction. So roughly half of all aimed input is a verb the
bot has never performed once.

Notably the bot's decision cadence (0.117 s) is already close to his median gap
(0.133 s). The model's rate is approximately right; its repertoire is not.
That is a far more actionable diagnosis than "unrealistic".

## Shipped

`docs/measurements/2026-08-01-owner-play-calibration.md` — the six runs, the
playstyle observations a model must reproduce, the three known structural blind
spots, and an acceptance-target table.

## The acceptance test

A model may not be used for conclusions about difficulty, upgrades or the
economy until it produces: median ≥1 500 m per life at the 5 000 m warp,
≤0.8 deaths/km, 45–80 m/s sustained, kilometre-scale run-to-run spread,
~2 000 m from a standing start unupgraded, >5 000 m upgraded — and, cheapest
and most important, **upgrades must improve the result**. The current bot fails
that last row on sign alone, reporting a 25% loss.

## Verification

`python3 tools/verify.py --require-godot` → **exit 0**, 159 contracts on pinned
Godot 4.7.1 — unchanged, as expected for a documentation-only change.

`python3 bootstrap.py check --strict` → **exit 0**, findings read in full.

## Owner questions

None new. OQ-9 and OQ-10 remain open; the owner has since indicated the upgrade
economy should last longer, which is an answer in progress on OQ-10 rather than
a settled one, so it is left open until the economy work implements it.

## 💡 Idea

The lab's problem was never fidelity, it was the **absence of a falsifiable
claim about its own validity**. Every measurement was reported with careful
error bars and caveats about bot preference, which read as rigour while the
model was wrong by an order of magnitude in sign and scale. Error bars describe
sampling noise inside a model; they say nothing about whether the model applies.

Generalisable: an instrument needs a calibration against reality that it can
fail, and that calibration must be checked before publication, not cited as a
caveat afterwards.

## Next slice

**Rebuild the bot against this acceptance test.** Three structural fixes, none
needing the recordings: teach it to Dive, convert its Reel policy from
fractions of the meter to absolute time so capacity is representable, and make
it aware of the anchor classes zones 4–8 introduced. Validate against the table
above after each. Fit cadence and verb mix from the recordings only if the
structural fixes fall short — the action button is separable by colour at
10 fps, so a per-frame verb trace is extractable without OCR.
- **📊 Model:** opus-5 · high · research — owner play calibration

# Slice 1 cannot be judged while the drive is on — order the slices for verification, not just for building

> **Status:** `complete`

## Goal

Verify what the release-quality slice actually landed, and prepare ordered
slice 2 (drive → 0) with a prompt that explains why it has to happen now.

## Scope guard

Documentation and planning only. No code, no physics values. Two read-only
headless measurement runs.

## Previous-session review

**previous-session review:** the release-quality slice (PR #97) is good work and
independently verified below. Two things it did that this session copied: it
marked its tuning constants `assumed` **in the source**, not just in prose, and
it caught a second-order consequence the spec missed — that changing authoritative
physics invalidates the bundled replay traces — then versioned the format rather
than manufacturing migration work or making a false replay claim.

## What slice 1 actually landed — verified, not accepted

Re-ran independently: `tools/verify.py --require-godot` → **184/184**, exit 0.

Claim-by-claim against the merged tree:

- **Forced detach earns nothing** — confirmed. `release_quality` is called in
  exactly one place, `_release_web` at `simulation_world.gd:1200`. Every other
  release path (Burst/Dive pull, rotten anchor, surface bounce, rescue) uses the
  plain `web.release()`.
- **Drive and bird untouched** — confirmed. `spider_motor.gd` is not in the
  diff at all; no bird code exists.
- **`assumed` markers in the source** — confirmed, and better than required:
  the config constants carry their own comments stating that device feel must
  settle them and *"the bot cannot pump, so it is not a tuning instrument."*
  PL-013 was adopted by a different agent within hours, without being told to.

## The finding: the brief's ordering was wrong

The build order was right. **The verification order was not**, and that is my
error to own — I wrote it.

**OQ-16 asks the owner to judge whether earned release feels strong. It cannot
be answered in the build that ships it.** Two mechanisms, compounding:

- **The drive erases the penalty.** `SpiderMotor` only fires *below*
  `target_speed`; the overspeed bleed only fires *above* `target + 360`. A good
  release lands in the untouched band and decays on drag alone — **4.4 s of
  airtime at 0 m, 4.0 s at 1 km, 2.2 s at 5 km**. So the award is *not*
  decoration, and my own spec's inherited phrase "the drive refunds it within a
  second" was wrong on the arithmetic. But a **bad** release costs nothing: the
  floor rebuilds at 470 px/s, ~0.2 s per 100 px/s.
- **The award's ceiling sits inside the owner's playing band.**
  `target_speed_at + maximum_horizontal_overspeed` is 72.0 m/s at 0 m and
  76.2 m/s at 1 km; his standing-start L0 runs sustain ~73–78 m/s.

A weak verdict gathered now would send someone tuning the 100 px/s value when
neither the value nor the formula is at fault. **One device session, after
slice 2, covering both slices.**

## The failure mode slice 2 creates

`measured` — `tools/simulate.gd`, 10 runs, intermediate, L20, 5 course seeds,
100 s cap, in-run counters at 1 tick:

| | drive 470 | drive 0 |
| --- | ---: | ---: |
| mean distance | 2 031 m | 1 206 m |
| timeout runs | 0 / 10 | **4 / 10** |
| deaths | boundary ×2, obstacle ×8 | **camera_boundary ×2**, obstacle ×4, **timeout ×4** |

**Stalling becomes reachable.** `left_kill_boundary()` is `furthest_x − 520 px`
and `furthest_x` only ratchets, so falling 52 m behind your own best point kills
you — nearly impossible today, live without the drive.

Read as a **floor, not a prediction**: the bot cannot pump, so it cannot
generate speed the way a person does. What it proves is that the failure mode
now exists and slice 2 must decide what happens when it fires. The rescue grant
is the existing valve.

## What shipped

- Slice-2 section in the brief: why now, the **six** coupling sites, the stall
  measurement, the reading trap, and a paste-ready prompt.
- The ordering correction, recorded as a correction rather than a quiet edit.
- OQ-16 gains a "do not gather this verdict yet" banner with the two mechanisms.
- The spec's coupling table gains its **sixth** site — slice 1's own release
  award cap, which did not exist when the spec was written.

## Verification

`python3 tools/verify.py --require-godot` → exit 0, **184 contracts**.
`python3 bootstrap.py check --strict` → exit 0. Documentation only.

Both measurements above were run on the merged tree today, not cited.

## Owner questions

None new. **OQ-16 is now explicitly parked** until slice 2 lands — the fork is
unchanged, the timing is not.

## 💡 Idea

**Ordering a plan for building and ordering it for verifying are different
problems, and I only did the first.** Slice 1 was correctly placed for
construction: self-contained, headless-testable, no visual. It was wrongly
placed for judgement, because the thing that makes it *feelable* ships two
slices later. Every slice plan that ends in a human verdict has this second
ordering hidden inside it, and nothing in the brief template surfaced it.

Concretely: a slice that opens an owner question should state **which later
slice makes that question answerable**, and the question should carry that
dependency. Deduped against `docs/ideas/` — nothing covers verification
ordering. Worth proposing to substrate-kit alongside the brief template idea
from the previous card, since both are about the same document.

## Next slice

**Slice 2 — drive → 0.** Prompt is in the brief, ready to paste. Six coupling
sites to decide, the stall failure mode to handle, and no bird.

- **📊 Model:** opus-5 · high · idea/planning — verify slice 1, prepare slice 2

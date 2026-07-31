# Overnight brief — 2026-08-01

> **Status:** `plan`
>
> Written 2026-07-31 for an unattended Claude session working while the owner
> sleeps. Read this after the boot set, not instead of it.

## What you are doing

Working the zone and systems backlog in **slices**, self-pacing with a wake
chain, landing each slice as its own small PR. The owner is asleep and will
review the running build in the morning, not the diffs.

ChatGPT is working in parallel on visuals from its own brief. Assume the repo
moves under you: `main` moved three times under open PRs on 2026-07-31.

## Non-negotiables

1. **Do not change physics values.** `balanced_baseline` was owner-approved on
   2026-07-31 after days of tuning. Zone work adds geometry and mechanics; it
   does not retune the swing. If a zone seems to need a physics change, that is
   a finding for the owner, not a change to make at 03:00.
2. **Determinism is a contract, not a preference.** Geometry derives from chunk
   index plus course seed; contracts assert identical trajectories at
   30/60/90/120 Hz and exact geometry equality for off-grid debug starts. Every
   moving part must be a pure function of `(chunk_index, course_seed, tick)`.
   No runtime RNG. No physics bodies. **Write the ADR before the first moving
   part.**
3. **Zones 1–3 are frozen.** `ancient_forest`, `bramble_canopy`, `silk_hollow`
   keep their ids and their content — the ids key persisted checkpoints and
   Bramble Canopy's environment landed in PR #62 today. New zones append from
   15 000 m.
4. **Verify with the real engine.** `python3 tools/verify.py --require-godot`.
   Without `--require-godot` the engine checks are skipped and a green run
   proves almost nothing.
5. **After any merge of `main`, run the suite before trusting the diff.** On
   2026-07-31 two branches each bumped `EXPECTED_CHECK_COUNT` from 120 to 121;
   git merged identical text with no conflict while the tree actually ran 122.
   Same-value edits are the one merge hazard that leaves no marker.
6. **Falsify every new contract before trusting it.** Break the code it guards,
   confirm the suite fails, restore, confirm it passes. A test that has never
   failed is a claim.
7. **Never record a wall.** A refused call is transient venue state. On
   2026-07-31 a repo-settings call was classifier-refused and succeeded
   unchanged an hour later. Record capabilities in `docs/CAPABILITIES.md`;
   never record a limitation.

## Wake chain — follow `docs/ROUTINES.md`

- **Exactly one outstanding wake at a time.** Consume before re-arming.
- Re-arm at the end of each slice, after the PR is open and green — not before
  the work, and never two deep.
- At each wake: re-verify state by probing, do not trust the previous turn's
  record. Check whether `main` moved and whether your PR merged.
- If a slice ends with nothing to do, re-arm and exit without writes.

## Slice backlog, in order

Each slice is one PR. Stop a slice when it is green and landed, then take the
next. Do not batch.

**Slice 1 — ADR: deterministic moving parts.**
Design only, no gameplay code. How a moving hazard expresses position as a
function of chunk index, seed and tick; how it interacts with the web
constraint; how the fixed-rate trajectory contracts stay true. This unblocks
everything else, so do it first even though it ships no content.

**Slice 2 — Moving-anchor proof in the simulator.**
The riskiest unknown in the whole plan: attaching to a *moving* pivot without
the constraint injecting energy. Prove it headlessly with
`tools/simulate.gd` before any zone depends on it. If it cannot be made
energy-safe, say so plainly and Zone 4 loses its signature mechanic — that is a
real answer, not a failure.

**Slice 3 — Difficulty curve measurement.**
Use `tools/simulate.gd --start-m=` across 5 000 / 10 000 / 15 000 / 20 000 with
fixed seeds and several skill levels. Report deaths-per-kilometre and death
causes per band. This turns "the curve is flat past 5 km" from an argument into
a number, and it is the baseline every later zone is judged against. Commit the
numbers.

**Slice 4 — Zone 4 skeleton: Ruined Arboretum.**
Append the region, add its pattern set, wire its visual identity. Static
hazards only — broken beams and collapsed frames. No moving parts yet. Playable
and readable at 15 000 m.

**Slice 5 — Zone 4 moving parts.**
Hanging panes and slow rotors on deterministic phases, per the ADR. Phase-gated
gaps. Only if Slice 2 succeeded.

**Slice 6 — Upgrade audit against measured numbers.**
With Slice 3's baseline, check which existing upgrade tracks actually change
outcomes and which are noise. Refine or propose additions grounded in the
measurements, not in intuition. Do not add upgrades that no measurement asked
for.

**Slice 7 onward — Zone 5, Storm Ridge.** Only after Zone 4 is felt on device.

If you run out of backlog, do not invent scope. Re-arm, write what you would do
next in the session card, and stop.

## Design source

`docs/product/zone-progression.md` is the zone source of truth — axes, hazards,
mechanics, density curves and the success sentence each zone must produce.
Balance numbers live in `SwingConfig` and the pattern catalog, never in the
design doc.

## Landing work

Auto-merge now arms: `main` requires `substrate-gate` and `game-quality`, and
`allow_auto_merge` is on as of 2026-07-31. Open the PR, let it land itself,
confirm it merged at the next wake. Merge by hand only if the automation stalls.

Small PRs. The repo moved three times under open PRs today; a large branch will
conflict.

## What to leave for the owner

- Anything that changes how the swing feels.
- Fungal Grove's placement — recommended for the campaign rather than the
  endless run, flagged in the design doc.
- Any zone mechanic that turns out to need a physics change.

Put these in the session card's owner-questions section. Do not block on them.

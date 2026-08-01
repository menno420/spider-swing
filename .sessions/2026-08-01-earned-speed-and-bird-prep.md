# Prepare the repo for the mechanics session — earned speed and the bird

> **Status:** `complete`

## Goal

The owner redirected the next session away from visuals and toward mechanics,
and asked for the repo to be prepared so a fresh session can work it out
structurally. His constraint: **no new recordings will be supplied**, so
everything the next session needs has to already be in the tree.

## Scope guard

Documentation and planning only. No physics values changed, no code edited.
One headless measurement run (read-only) to re-verify the central claim.

## Previous-session review

**previous-session review:** the claim-provenance retrofit landed the PL-013
convention and its kit checker. What it did well and this slice copied directly:
it ran the checker against the **real corpus** before believing its green, and
found it had zero sensitivity. The same instinct is why this brief does not stop
at citing yesterday's ablation numbers — it re-runs them against current `main`.

## What the owner asked for

> *"The important thing right now is that the speed at which the spider travels
> also increases overtime, which should probably happen in a player controlled
> way by upgrades, swing control, reel and burst timing etc."*

> *"One visual thing that does need to be done properly right now is the
> creation of the bird, and one that actually moves in a bird like way, follows
> the spiders position and moves at a slightly increasing speed."*

This closes **OQ-12** — it is his own two-part proposal, which was measured
earlier the same day and which the measurement supported.

## What shipped

- **`docs/game-design/earned-speed-and-the-bird.md`** — the spec. The measured
  argument, every seam with a `file:line`, the build order, and the section
  that matters most: what cannot be tuned from the lab.
- **`docs/planning/next-session-brief-2026-08-01-mechanics.md`** — the brief and
  the paste-ready prompt.
- **`docs/owner-questions.md`** — OQ-12 answered; OQ-13/14/15 opened for the
  parts measurement could not settle.
- Redirect banner on the superseded handoff; `docs/README.md` and
  `docs/current-state.md` repointed.

## The three findings that make the brief worth reading

Each is something a competent session would get wrong from the code alone:

1. **The bird already exists, invisibly.** `left_kill_boundary()`
   (`simulation_world.gd:554`) is a player-following kill line with a working
   death path and a published snapshot field. The bird is that line made visible
   with its own advance law — not a new hazard type. And **`CourseMotion` cannot
   be used**: it is stateless by design and cannot read player position, which is
   precisely what makes courses replayable.
2. **`target_speed_at` is load-bearing in five places** beyond the drive —
   opening velocity, the rescue grant, the guided opening, the camera
   look-ahead, and profile speed scaling. Deleting it breaks all five. Changing
   `horizontal_drive_acceleration` as a config value is a one-number experiment
   that reverts instantly.
3. **One upgrade track dies.** `skitter_drive` / *Quick Feet* multiplies
   `horizontal_drive_acceleration` (`spider_catalog.gd:393-394`) and buys
   nothing without a drive. It is a named, priced identity track on a shipped
   spider, so it is owner-facing → OQ-13.

A fourth, which is really a debt: **release quality does not exist**.
`WebConstraint.release()` preserves velocity exactly — no angle, timing or apex
test anywhere in `game/` — while the tutorial already tells the player *"Release
while rising to carry momentum forward."* The game promises a mechanic it does
not implement. That makes it slice 1.

## Verification

`python3 tools/verify.py --require-godot` → exit 0, **181 contracts**.
`python3 bootstrap.py check --strict` → exit 0. Documentation only.

**The central claim was re-measured against current `main`**, not cited from
yesterday: 12 runs, intermediate, L20, 6 seeds, drive 470 → **1 859 m**, drive
0 → **1 171 m** (−37%, against −33% measured earlier for the same unadapted
policy). The game runs cleanly at drive 0, so the experiment is safe on day one.

**And the run is recorded with what it does not show.** Arc per web went *down*
(43.2° → 39.9°) because that is the default policy, adapted to a world with a
drive; stripped of its engine it dangles rather than swings. The "wide swinging
wins" result comes from a policy endorsed or searched *inside* the no-drive
world. Reading the table the naive way would reproduce this project's most
repeated error.

## Owner questions

Three new, all genuinely owner-only: **OQ-13** (what *Quick Feet* becomes),
**OQ-14** (does the bird kill or stagger), **OQ-15** (bird speed and
acceleration — answerable only by a device playtest, because the bot cannot
pump).

## 💡 Idea

**The spec's most valuable section is the one listing what a reader would
otherwise get wrong.** Three of the four findings above are invisible from the
code: the seam that looks right (`CourseMotion`) is architecturally forbidden,
the function that looks deletable is load-bearing five times over, and the
upgrade that dies is in a different file from the change that kills it.

That suggests a shape for handoff docs generally — not "here is the design" but
**"here are the three things you will get wrong, and why they look correct"**.
Deduped against `docs/ideas/`: nothing there covers handoff structure. Worth
proposing to substrate-kit as a brief template if it survives contact with the
next session actually using it.

## Next slice

Not mine — the mechanics session's. Slice 1 is **release quality**: pure
simulation, headless-verifiable, no visuals, and it closes a promise the
tutorial already makes.

- **📊 Model:** opus-5 · high · idea/planning — spec + brief for the mechanics session

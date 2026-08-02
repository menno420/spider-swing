---
state: routed
origin: owner
shipped_pr: null
shipped_repo: null
merged_date: null
outcome: open
---

# The competitive layer — seeded leaderboards, downgradeable upgrades, per-spider campaign levels

> **Status:** `ideas`
>
> Three ideas that turn out to be one system: **the boards need the seeds, the
> boards need downgradeable upgrades to be reachable, and the campaign levels are
> boards by construction.** Almost all of it rides infrastructure that already
> exists for other reasons.

## Why this cluster matters more than it looks

The game has a **measured skill ceiling** — the owner sustains 73–78 m/s with
18-tap-per-second bursts; a cross-entropy search over thousands of runs reached
48. That gap is the game's rarest property. Most endless runners converge every
player on the same performance.

**A competitive layer is how that gap becomes visible, shareable and worth
chasing.** It is also the cheapest content in the game: a leaderboard category
costs a *rule*, not art.

## 1 — Many narrow boards, not one big board

> *"Rankings for everything genuinely fun to rank."*

Owner's list: distance in any mode · total flies · most flies in a single run ·
furthest without burst or dive · furthest with no upgrades · furthest per spider.

**One "highest distance" board is owned forever by one person and ignored by
everyone else.** "Furthest without burst or dive" is a different skill, a
different winner, and a different community. That is why speedrunning scenes are
enormous relative to their games' playerbases — dozens of categories mean dozens
of people can be best at something.

**Exclude event-only spiders from boards** (owner). Under the recurring-event
model an event spider does eventually reach everyone, but a player who joins in
month two cannot compete on that board until month seven. Restricting boards to
always-available content keeps them **fair on day one, permanently**.

**Add weekly or seasonal boards alongside all-time.** Otherwise a player joining
in year two sees a number set by someone with 500 hours and correctly concludes
it is unreachable. A resetting board means there is always one you could top this
week — the same principle as recurring events.

## 2 — Seeded records (the strongest single item here)

> *"Since runs are random, it might be a good idea to have the weekly boards
> function for a specific seed, or to have each record have a linked seed that
> players can choose to play."*

**Procedural courses make records partly about luck.** Grind enough attempts and
a generous seed arrives, so an open board measures persistence more than skill.

**Fixed seeds remove that entirely** — identical course for everyone, the only
variable is play.

### The infrastructure already exists

- `CourseStream` derives every polygon, guide, fly and boost from **chunk index
  plus course seed**, and geometry does not depend on the route taken to reach a
  chunk.
- The lab already relies on it: searches ran seeds 1337–1344, validated on
  held-out 9000–9007.
- `spider-swing-input-trace@2` records seed, start distance, upgrades, difficulty
  and preset, and replays deterministically through a headless verifier.

Seeded runs are **not a feature to add — they are a property already held and not
yet exposed.**

### Two things that follow almost for free

**Verifiable boards.** A submitted score arrives with the inputs that produced
it, and the server replays it to confirm. Most mobile leaderboards are *dead*
because the top is visibly fake and everyone knows it. A believable board is the
difference between a feature people compete on and decoration.

**Ghosts.** A record is not just a number and a seed — it is a watchable run. See
it before attempting it, or race it.

> The owner sent a **Trackmania** video earlier in this session as the reference
> for the AI learning loop. Trackmania's entire competitive culture rests on
> three things: **a fixed track, ghost replays, and a leaderboard.** This game
> would have all three, on mobile, where essentially nothing else does. That was
> not why the video was sent, but it is the more useful half of it.

### Cost profile

A trace is input commands, not video — the bundled example is 640 commands over
97 seconds. Kilobytes to store, cheap to verify, and it doubles as the shareable
artifact for word-of-mouth.

### ⚠ Prerequisite — verify before building on it

Seeded boards are only valid if a seed reproduces **exactly**: geometry, fly
placement, boost placement, and the phase of every moving hazard, on every
device. `CourseMotion` derives phase from
`chunk_index * 97 + course_seed * 131 + phase_salt * 53`, which looks correct —
but "looks correct" is what needed correcting fourteen times on 2026-08-01.

**Cheap check:** replay the same seed twice headless and diff the geometry. Do it
before this is load-bearing, not after. If anything drifts, two players on one
seed get different courses and every board built on it is quietly invalid.

## 3 — Downgradeable upgrades

> *"Upgrades should also be manageable when obtained, so you can choose to play
> as a lvl 0 spider even though you are already max lvl."*

**This is a prerequisite for the "no upgrades" board**, not a nice-to-have.
Progression is one-way today, so a maxed player cannot compete on an unupgraded
board without deleting their save.

It also **solves the endgame**. An endless runner has nowhere to go once
everything is maxed — and maxing is currently about twenty minutes away. Dialling
back hands a finished player a new game.

### The architecture supports it

`SpiderCatalog.resolved_config(preset, progress)` derives the whole `SwingConfig`
from progress at run start, per track, via `effective_steps(level)`. The change is
a per-run *effective level* map consulted by `_resolved_config`
(`swing_lab_session.gd:942`). No physics change, no new systems.

And the trace already records upgrades — so a "no upgrades" record can be
**verified as genuinely unupgraded** by replaying it.

### Two design calls

- **Owned level is always the ceiling.** Play below what you own, never above.
  The one rail that keeps this from being a cheat, and the same shape as every
  other rule: additive freedom, never access.
- **Per-track, not all-or-nothing.** `upgrade_levels` is already a dictionary
  keyed by upgrade id, so per-track selection is nearly free — and far more
  interesting. Max reel with zero burst is a different game from max burst with
  zero reel, and every combination is a potential board category.

**Rewards:** same as any run. Flies scale with distance and a level-0 run covers
less ground, so it is self-balancing. Paying *more* for a harder run would create
an incentive to play in a way players do not enjoy — the hauling exploit one
layer up.

## 4 — Per-spider campaign levels

> **⚠ Parked 2026-08-02 — timing only, reasoning intact.** The owner's north-star
> directive defers expanded Campaign work until the core loop is tuned. Two
> additions from the preference research when it is revived: Campaign's recorded
> failure mode is *"feels like a tutorial you rush through to get to the real
> game"* — a showcase level that reads as a tutorial gets skipped, and skipped
> content sells no spiders. And the **forced-max-upgrade** variant is the same
> per-run effective-level seam as downgradeable upgrades, running the opposite
> direction. See
> [`../product/player-preference-research-2026-08-02.md`](../product/player-preference-research-2026-08-02.md).

> *"Extensive campaign levels where each spider is playable in a specific
> [purpose-]built level that's the same for everyone."*

In an endless runner you cannot tell what makes Ballooner different from
Anchorite without a lot of play. A purpose-built level **shows** you — the long
glide, the heavy momentum, the compact stance — in a context designed to make it
obvious.

Three things fall out:

- **It is the fairest possible way to sell a spider.** You experience it before
  deciding you want it. Nobody guesses from a description; nobody feels tricked.
  The everything-earnable principle applied to the buying decision itself.
- **Fixed by construction → leaderboard-ready for free.** Same course for
  everyone, no seed negotiation needed.
- It extends the existing campaign, whose recorded purpose is *"early levels
  teach one mechanic each; later levels combine them"* (OQ-6).

## 5 — Milestones as a permanent layer, not an event

Titles, badges, records, distance markers. **The cheapest content in the game** —
pure text and UI — and the only category that rewards *skill* rather than time or
money, which is the axis that makes this game different from the genre.

**Deliberately not a seventh event category**: it would break the clean twelve,
and milestones should not be seasonal. Better as a permanent layer running
underneath all six events, quietly accumulating.

## Suggested order

1. **Verify seed determinism** (cheap, gates everything else).
2. **Downgradeable upgrades** — pure config, headless-testable, unblocks the most
   interesting board categories.
3. **Seeded records + tap-to-play-this-seed** — the social mechanic.
4. **Weekly boards**, then ghosts.
5. **Per-spider campaign levels** — larger, and best after the boards exist so
   they ship leaderboard-enabled.

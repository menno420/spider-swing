---
state: routed
origin: owner
shipped_pr: null
shipped_repo: null
merged_date: null
outcome: open
---

# Recurring events, six typed categories — and the economy finding that makes them load-bearing

> **Status:** `ideas`
>
> The owner's live-content model, plus the measured reason it is not a polish
> item: **the game currently has almost nothing worth buying, and events are how
> that changes.**

## Part 1 — the economy finding

`measured` (OQ-10, bot-derived): maxing Classic's seven upgrade tracks costs
**987 flies — about 45 runs, roughly 21.5 minutes of play.** The economy doc's
own words: *"that is the game's only long-term sink."*

**Provenance caveat (PL-013):** that figure comes from bot play, and the bot dies
roughly ten times more often per kilometre than the owner. A human earns flies
faster, so the real number is likely **shorter than 21 minutes, not longer**. The
error runs in the unfavourable direction.

### Why that breaks the monetisation model

The owner's model is *"most of everything should be an in-app purchase
possibility… once a purchase is just 1 euro or even less, people are very quick
to buy it"* — with everything still earnable. Sound, and with a strong precedent
in this exact genre (**Crossy Road**: ~100 characters, all earnable, all
purchasable, no energy gate, no forced ads, ~$10M in its first months).

But **nobody pays €1 to skip 21 minutes.** The model needs a grind long enough
that skipping it is worth money, and right now there isn't one.

### The arithmetic, which is the actionable part

| | conversion | spend per payer / year | 1M players → net |
| --- | ---: | ---: | ---: |
| as the owner stated it | 1% | €1 | **~€8.5k** |
| typical F2P cosmetics | 2% | €8 | **~€136k** |
| narrow content | 3% | €2 | **~€51k** |

*(`assumed` — rough industry ranges, not measured. Order-of-magnitude only.
Assumes Google's 15% rate on the first $1M/year.)*

**The sensitive variable is spend per paying player, not conversion rate.** People
who pay once rarely pay exactly once — if there is a second thing worth wanting.
Crossy Road's revenue came from having a hundred characters, not from charging
more for one.

**So OQ-10 is a business-model question, not a pacing question.** Its own stated
answer is right and should be promoted: **more sinks, not higher prices.** Higher
prices make the same twenty minutes feel slower; more things to reach for is what
creates something to sell.

Already planned by the owner and consistent with this: gradual upgrade pricing
(currently placeholder), and **spiders moving behind flies/currency** (all five
are free today).

## Part 2 — the event model

> *"One event per month with the same event being reintroduced multiple times per
> year, which would each time have more things to unlock but also allow new
> players to unlock things from the previous event."*

### The property that makes it unusual

**In the standard exclusive model events decay.** Year three's event is worse
than year one's — the good things are gone, and a new player sees a museum of
items they can never have.

**In this model events appreciate.** The tenth running contains ten runnings'
worth of unlockables. It becomes *more* valuable over time, and most valuable
specifically for new players — the group live games normally treat worst.

Precedent: **Deep Rock Galactic** folds season content into the permanent pool
when a season ends. Its community holds that up as the example of a live game run
without contempt for players. It is a reputational asset there, not only an
ethical one.

### The sustainability property — this is the one that matters for a solo dev

A conventional live-service game **must** ship new exclusives every month,
because a repeat of last month's event is worthless: everyone already has it.

This model can **re-run identical content** and still be genuinely valuable to
everyone who was not there. **The content treadmill that kills solo developers
does not apply.** A Forest event can be built once and run every March for a
decade, extended only when there is appetite.

### The six categories

| Event | Unlockable | Production cost |
| --- | --- | --- |
| Skins | spider skins | medium |
| Backgrounds | zone backplates | medium |
| Audio | soundtracks | **low** — deterministic generated-audio infrastructure already exists |
| Spiders | new playable spiders | **high** — identity tracks, balance, art, Field Guide entry |
| Birds | pursuer variants | **low** — movement law is shared; art plus flap timing |
| Walls & obstacles | front-layer visuals | medium — **see the constraint below** |

Six types × twice a year = twelve events = monthly, with six months between
repeats. Long enough that a return feels fresh, short enough that a new player is
not waiting a year for the spider event. Costs are naturally staggered so two
expensive months never land back to back.

### Three constraints worth deciding before event one

**1. Obstacle events must be pure re-skins.** New obstacle *shapes* would mean a
player without them plays a different game — a balance fork, not a cosmetic. The
architecture already permits the fair version: a `visual_id` travels beside each
polygon separately from its collision geometry, and presentation resolves art
through `ArtAssetCatalog` from that id. **Identical collision, new world.**

**2. Bird skins are probably undervalued.** The spider is small and the player is
watching ahead of it. The bird is the thing you look *at*, under pressure,
because it is the threat. It will hold more player attention per second than any
other art in the game, and it is among the cheapest to produce.

**3. Catch-up despair is the failure mode at scale — not unfairness.** By event
twenty a new player opens a one-month window containing a hundred unlockables and
can realistically earn four. That breaks no rule but can still feel bad. Fix,
cheap if designed in: **let players choose what to work toward** rather than
progressing a fixed ladder. Then a large backlog reads as a catalogue rather than
a deficit.

### Sequencing

- **First event triggers on a milestone or elapsed time**, not at launch (owner).
- **Run whichever category has the deepest backlog first.** Event one sets the
  expectation for what an event feels like, and a thin first event is much harder
  to recover from than a thin fourth.

### Technical note

Event ownership and per-event participation are **new save-schema shape**.
Progression is at schema 7 with one-way explicit migrations. Cheaper to sketch
the schema before event one than to migrate after.

## Relationship to the charter

Every item above is governed by
[`fairness-charter-2026-08-01.md`](fairness-charter-2026-08-01.md) rule 4 —
**every event returns**. That rule is what makes the recurrence model a
commitment rather than a preference, and it is the specific line that prevents a
future session from shipping a limited-time exclusive because it seemed like good
engagement design.

# Player-preference research and the 25 k north star — 2026-08-02

> **Status:** `reference`
>
> Third-party research synthesis plus a **new owner priority directive** that
> reorders the build queue. Read the provenance block before acting on any of it.

## ⚠ Provenance (PL-013) — read this first

**The research below is `inferred`, not `measured`.** It is a summary produced by
a Grok deep-search session on the owner's request. **The underlying sources were
not supplied and have not been verified from this repository.** No sample size,
no methodology, no citations.

That does not make it worthless — genre-preference patterns are real and this one
reads coherently. It makes it **weaker evidence than anything in
`docs/measurements/`**, and it must never be quoted as if it were.

**Three claims are independently corroborated** and can be relied on:

| Claim | Corroborated by |
| --- | --- |
| Upgrades do not meaningfully increase run length | `measured` — [`2026-08-01-upgrade-playstyle-sweep.md`](../measurements/2026-08-01-upgrade-playstyle-sweep.md): upgrades buy survival and economy of effort, **not distance** |
| Difficulty is too high for long runs to feel reachable | A real returning player, 2026-07-31: *"Bro whos reaching 10k. Way too hard"*, *"I reached 4k with LUCK"* |
| Deaths should be fair and attributable | `measured` — [`2026-08-01-recovery-gap.md`](../measurements/2026-08-01-recovery-gap.md): 95% of model deaths are obstacle collisions, 88–100% with an unspent escape in hand |

Everything else is a hypothesis to design toward, not a fact to cite.

---

## 1 · The north star (owner directive, 2026-08-02)

> **Fine-tune core gameplay, physics feel, difficulty curve, and upgrade impact
> first. Goal: make excellent play able to reach very high distances (25 k+) in a
> meaningful way. Right now the game is still too difficult and moves too quickly
> for this to feel properly achievable.**

**Unlock systems, expanded Campaign trees and deeper monetisation are deferred**
until the core loop is in a better place.

### What 25 k means against what exists

| | Distance |
| --- | ---: |
| Owner, unupgraded, standing start | ~2.4 km median (`measured`, 4 completed runs) |
| Owner, upgraded, warp 5 000 m | ~5 km+ (owner statement) |
| A returning player, upgraded | 4 km, described as luck |
| **Target for excellent play** | **25 km+** |
| Authored zones already reach | 35 km |

**This is roughly a fivefold increase in what strong play achieves**, and it is
the single largest design target in the project. It also explains a standing
oddity: eight zones are authored out to 35 km, and almost nobody reaches the
fourth.

### The tension worth stating plainly

*"Too difficult and moves too quickly"* pulls in two directions against the
earned-speed work that shipped in `0.29.0`:

- **"Moves too quickly" is now addressed.** The forced pace curve no longer
  drives the player; speed is earned, so the player sets it.
- **"Too difficult" may have got worse before it gets better.** `measured`
  pre-ship: at drive zero, 4 of 10 bot runs timed out and `camera_boundary`
  appeared as a death cause. The bot cannot pump, so that is a floor rather than
  a prediction — but stalling is now reachable where it previously was not, and
  the bird adds a second failure source.

**Neither is settled without a device verdict.** The next tuning pass should
treat "can excellent play reach 25 k" as its acceptance test, and the honest
answer today is that nobody knows, because the build has not been played.

---

## 2 · Player preferences by area (`inferred` — unverified sources)

### Swinging / physics-based runners

| Like | Dislike |
| --- | --- |
| Strong momentum preservation | Floaty or disconnected physics |
| Fair, attributable deaths | Deaths that feel unfair or unexplained |
| Satisfying speed and arc feel | Shallow upgrades that barely change anything |
| Upgrades that meaningfully extend distance | Difficulty spikes that feel cheap |
| Difficulty that feels *earned* | Arbitrary difficulty |

**"Fair and attributable" is the actionable one**, and it is testable rather than
a matter of taste: after a death, can the player state what killed them and what
they should have done? The recovery-gap measurement suggests the current answer
is often no — deaths arrive while holding an unused escape, which reads as
"I didn't know I was in trouble."

### Educational content (real spider facts)

| Like | Dislike |
| --- | --- |
| **Optional** discovery | Forced lessons |
| Playful, personality-filled tone | Preachy or moralising tone |
| Facts tied to character identity | Interrupting gameplay to deliver facts |
| Accurate content presented for fun | Thin or inaccurate content |
| Learning that emerges because you care about the spiders | Anything that feels like homework |

This aligns with the existing
[`spider-biology-folio.md`](spider-biology-folio.md), whose editorial rules
already require accuracy and a non-lecturing voice. **The new constraint is
structural rather than editorial: never interrupt play to teach.** The Field
Guide is opt-in and should stay that way.

### Campaign vs Endless

| | Like | Dislike |
| --- | --- | --- |
| **Campaign** | Clear goals · teaches mechanics · sense of completion · session-sized | **Feels like a tutorial you rush through to reach the real game** · low replay value · too short |
| **Endless** | Pure skill expression · high-score chasing · "one more run" · infinite replay · where mastery shows | Repetitive or aimless if variety and difficulty curve are weak · frustrating when deaths feel meaningless |

**Endless remains the main long-term mode.** Campaign's recorded failure mode is
the one to design against: *content players rush past*. That is a direct caution
on the per-spider campaign-level idea captured on 2026-08-01 — a showcase level
that reads as a tutorial gets skipped, and skipped content sells no spiders.

### Upgrades — a genuine design fork

- Players **strongly** prefer upgrades that visibly extend how far they can go.
- **Running Fred style** — unlocking new *capabilities* — reads as more dramatic
  and satisfying to many players.
- **Pure numerical polish** is cleaner for protecting the skill ceiling, but only
  works if the impact is still clearly felt.

**All fifteen current upgrade kinds are numeric multipliers** (`spider_catalog.gd`)
— reel rate, burst reach, capacity, regeneration, drive, glide, radius, and so
on. Not one grants a capability the player did not previously have.

> **Corrected 2026-08-02 — it is fourteen of fifteen.** `BURST_REACH` raises
> `burst_charge_capacity` from one to two at level 20 (`spider_catalog.gd:378-382`),
> pinned by `tests/unit/upgrade_audit_tests.gd:109-125`. One capability
> breakthrough already ships, in a mechanism built for exactly this. The fork
> below still stands; the starting position is a hybrid, not pure numeric polish.
> See [`upgrade-and-difficulty research`](upgrade-and-difficulty-research-2026-08-02.md) § 4.1.

That is a real fork and it is undecided:

- **Capability unlocks** are more felt, more marketable, and risk becoming
  power gates that flatten the skill ceiling.
- **Numeric polish** protects skill expression and is what exists, but is
  measurably not producing the felt impact players want.

A hybrid is possible — capability unlocks that change *what you can attempt*
without changing *how well you must execute it*.

---

## 3 · Monetisation boundaries (hard, owner-stated)

These are stricter than the draft charter and should be folded into it:

- **Strong rejection of the Subway Surfers model** — no paid continues, no
  unlimited restarts, no items that erase a death.
- **Extra lives hard-capped at 3.** (One rescue exists today.)
- **Death must remain meaningful** so the skill ceiling stays intact.
- **Accelerating progression is acceptable; buying your way out of failure is
  not.** Unlocks and upgrades may be purchased for convenience. Outcomes may
  never be.

That last line is the sharpest formulation of the principle yet, and it closes a
gap the existing draft left open: "purchases buy time, never access" does not by
itself forbid a paid continue. **Purchases buy time, never access, and never
outcomes.**

---

## 4 · Explicitly parked — do not build yet

Recorded so a future session does not pick them up from the 2026-08-01 idea
batch, which predates this directive:

- **Per-spider Campaign trees** (teaching strengths/weaknesses, try-before-unlock,
  forced maxed upgrade levels).
- **Multi-path spider unlocks** (Campaign, tokens, achievements, missions,
  optional IAP).
- **Broader IAP structure** (spiders, cosmetics, fly packs, possibly upgrades).
- **Deeper educational Field Guide integration.**

The per-spider campaign idea in
[`../ideas/competitive-layer-2026-08-01.md`](../ideas/competitive-layer-2026-08-01.md)
is **superseded in timing only** — the reasoning there still holds; it is simply
not next.

> **A note on the forced-max-upgrade mechanism**, since it is cheap and already
> half-built: a campaign level that forces upgrades to maximum is the same seam
> as the *downgradeable* upgrades idea — a per-run effective-level override on
> `_resolved_config`. One mechanism serves both, in opposite directions.

---

## 5 · What follows for the current tuning pass

1. **Upgrades must measurably increase average run length and survival margin**,
   while still requiring real skill for high distances. Today they measurably do
   not — that is the sweep's headline finding, now corroborated by preference
   research and by the owner.
2. **The difficulty curve must support 25 k+ for excellent play.** Treat it as an
   acceptance target with a number, not a feel.
3. **Deaths must be attributable.** Testable: after dying, can the player say
   what killed them and what they should have done?
4. Educational content stays optional, playful and identity-driven — and never
   interrupts play.
5. Campaign strengthens later, and must not read as a tutorial to rush.

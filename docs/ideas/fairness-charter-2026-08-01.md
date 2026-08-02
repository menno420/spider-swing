---
state: routed
origin: owner
shipped_pr: null
shipped_repo: null
merged_date: null
outcome: open
---

# The fairness charter — write the rules down before they can be broken

> **Status:** `ideas`
>
> **The highest-leverage item in this batch, and the cheapest.** Four lines,
> published, that make every later monetisation decision visibly a decision.

## The owner's rule, in his words

> *"Literally everything should be possible to acquire through grinding or
> skill. So there isn't a gate for people who genuinely don't have any money,
> but for those who do, the ability to instantly unlock everything is very
> valuable."*

> *"I believe that having principles and values is worth more than any amount of
> money I could earn… I would never take paths that I would dislike in other
> apps or games."*

## Why it must be written down rather than held

The owner's formative case is Clash Royale. He played it for years, ran ten
accounts, and loved it *because* everything except emotes was earnable. When
evolutions shipped — effectively paywalled, or one per month against players who
paid — he quit permanently, gave his accounts away, and never played again. He
could easily have afforded them.

**The mechanism was not greed. It was a retroactive rule change.** Clash Royale
always had paid content and players accepted it — that was the deal they signed
up for. What broke trust was introducing a power tier that invalidated
investment made under the old rules. Diablo Immortal and most comparable
collapses have the same shape.

That reframes what needs defending. The risk is not a future owner who wants
money. It is a future owner — or a future agent making a locally reasonable
call — **changing a rule without anyone noticing it was a rule.**

## The precedent already exists in this estate

ShiftLife has `PRODUCT.md`, a free-forever charter treated as product law. Its
rule 4 (no regression) is what forced a Pro feature to stay free after it
accidentally shipped free — recorded as `OQ-SHIFTLIFE-PRO-DRIFT`. **The charter
bound the owner even when the outcome cost him.** That is the mechanism that
would have saved Clash Royale, already built and already proven in another repo.

## The draft — lift as-is if it reads right

> **Spider Swing is fair by rule, not by promise.**
>
> 1. **Everything is earnable through play.** Every spider, skin, background,
>    soundtrack, upgrade and event item can be obtained without spending money.
> 2. **Purchases only ever buy time, never access.** Paying skips a grind. It
>    never unlocks something play cannot reach, and it never confers power a
>    free player cannot earn.
> 3. **Nothing is ever removed or made permanently unobtainable.** No expiring
>    exclusives, no vaulting, no retired content.
> 4. **Every event returns.** An event is the convenient time to get something,
>    never the only time.
> 5. **Death stays meaningful.** No paid continues, no restarts that erase a
>    death, no item that undoes failure. Extra lives are hard-capped at 3.
> 6. **No ads. No energy timers. No pay-to-win.**

### Rule 5 was added 2026-08-02, and it closes a real gap

The original rule 2 — *purchases buy time, never access* — **does not by itself
forbid a paid continue.** A continue sells neither time nor access; it sells an
**outcome**. The owner's own formulation is sharper than the draft was:

> *"Strong rejection of the Subway Surfers model… accelerating progression is
> more acceptable than buying your way out of failure, especially because this
> game has a high skill ceiling."*

So the principle in full: **purchases buy time, never access, and never
outcomes.** That is what protects the skill ceiling, which is this game's rarest
property — the owner sustains 73–78 m/s where a policy search reached 48. A game
that sells its way past death does not have a skill ceiling; it has a price
list.

Source: [`../product/player-preference-research-2026-08-02.md`](../product/player-preference-research-2026-08-02.md) §3.

## Where it goes and why that matters

Both: the repository **and** the store listing. Two distinct payoffs.

- **Public** it is a marketing asset. A promise players can hold you to is worth
  far more than one you merely make, and its absence is exactly what cost Clash
  Royale a player who ran ten accounts.
- **In the repo** it binds future work. Any change that violates it becomes
  visibly a change rather than a drift, which is the entire failure mode above.

## Owner fork, non-blocking

The wording. The draft is a starting point, not a proposal to adopt verbatim —
this is product law in the owner's voice and should read like him. **Default:
nothing is published until he has edited it.**

## Rejected alternative

Holding the rules informally, as intent. Rejected because that is precisely the
state Clash Royale was in before it changed them, and because this project is
built by agents who cannot read the owner's intent — only his files.

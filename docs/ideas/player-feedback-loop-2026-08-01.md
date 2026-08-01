---
state: routed
origin: owner
shipped_pr: null
shipped_repo: null
merged_date: null
outcome: open
---

# Acting on player reviews — as a stated promise, and how it survives scale

> **Status:** `ideas`

## The intent

> *"I will actually follow up on players reviews… if someone says 'it would be
> cool if there was a spider that could do x' or 'why are the campaign levels so
> boring' I will act on it and try to work out a way to improve it as fast and
> thorough as I can. For example if the spider they request would be a bad fit
> for the current gamemodes, I will invent a gamemode where it does work."*

**This is credible specifically because of the velocity.** Most developers who
promise responsiveness cannot deliver it — a requested feature takes them a
quarter. This project turns a decision into a merged, tested, signed build in
days. The promise is only worth making by someone who can keep it, which is rare
enough to be a genuine edge.

It is also the **word-of-mouth engine**. *"I asked for a thing and the dev built
it"* is the most shareable sentence a player can say about a game, and it beats
any advertising that could be bought.

## Three things to get right before it goes on a store page

**1. Phrase it so it stays true at a million players.** *"I will act on your
review"* is delightful at a thousand players and impossible at a million — and a
broken promise on a store listing costs more than never making one.
*"I read every review, and things players ask for get built"* says the same thing
and is true at any scale. **Make the claim about what you do, not about what you
will do for each person.**

**2. Publish the nos, not only the yeses.** A developer who explains why they are
*not* doing something reads as principled and present; one who quietly ignores
reads as absent. *"I'm not adding this because it breaks the everything-earnable
rule"* costs nothing and buys nearly as much goodwill as shipping — and it is the
only version that survives volume.

**3. One voice is an idea; many voices are a signal.** Both are worth having, but
only the second justifies inventing a game mode. Building a whole mode for one
requested spider is a scope decision driven by a sample of one.

## The scaling fix — a curated voting slate

> *"As soon as the requests become too different from each other and too much at
> once, I will introduce a voting system where players can vote for the next
> feature… with AI I can basically read millions of requests instantly and filter
> the real ones from the jokes, as well as the possible ones from the impossible,
> and make it easy to create a list of things to vote for."*

**The detail that makes it honest is that the owner builds the list.** Players
decide *priority* among things he is already willing to build; he decides what is
buildable. Open-ended voting hands the roadmap to whoever brigades hardest, and
the most-voted request is very often not the best one.

Known failure modes it avoids: majority tyranny toward safe incremental requests;
the voting minority (typically <5% of players, skewed heavily toward the most
invested) overriding the casual majority; and vote brigading.

## The AI-triage asymmetry, and its one trap

A studio needs a community team to read 100,000 reviews. The owner needs an
afternoon. That is a real structural advantage over better-funded competitors.

**⚠ The trap: summarisation flattens exactly the signal that matters.** Ask for a
summary of 50,000 reviews and the answer is *"players want more spiders and think
level 3 is hard"* — true, aggregate, nearly useless. The review worth a week is
the single detailed one explaining *why* someone stopped playing on day four.
Averaging is what makes that disappear.

**So: summarise AND surface outliers verbatim.** The rare specific complaint
outranks the common vague one, and only one of the two survives a summary. This
is the same failure class as reading a tap rate at the wrong frame rate — a
plausible, well-formed summary that is true in aggregate and misleading in
particular.

## Existing infrastructure that already fits

**OD-10** (fleet-manager consolidation programme) is a standing instruction:
Ideas Lab is on-demand, and *"when building a new feature or improving an
existing one, run it through a dedicated `sim-lab` simulation (the 4-gate
method) before/while building."*

`idea-engine` holds 566 idea files across 13 sections; `sim-lab` holds the 4-gate
verification method. **That routing was built to process ideas from a fleet of
agents. Player reviews are the same input in a different wrapper** — the machine
for turning a raw request into a verified decision already exists and is
explicitly designated on-demand.

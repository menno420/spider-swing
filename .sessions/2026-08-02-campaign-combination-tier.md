# Give the campaign a second tier, where the verbs have to be chosen between

> **Status:** `complete`

## Close-out

**Evidence:**

- source: `campaign_catalog.gd` (`verbs` replaces `verb`, two tiers, three new
  levels, `is_complete` requires **all** named verbs), `front_end.gd` (the
  campaign list becomes a native scroller grouped by tier).
- contracts: **three added, all falsified** — a combination level must not clear
  on a strict subset of its verbs; every tier must cover every level with a
  strictly ascending order; every catalog level must have a reachable button at
  the touch floor behind a real scroller. 216 → **219**.
- verify: **`python3 tools/verify.py --require-godot` — PASS, 219/219** against
  the pinned `4.7.1.stable.official.a13da4feb`. `bootstrap.py check --strict`
  passes.
- build: **0.38.0-campaign-combination-playtest**, Android version code 58,
  across all five pinned files. This ships player-visible content, so it is
  installable and distinguishable — the rule a previous session missed.

**The tier is not three more levels, it is a different question.** The teaching
tier asks *can you perform this verb*. Knowing three verbs separately is not the
same skill as choosing between them under pressure, and the repository has
already measured which one actually fails: **88–100% of the model's deaths
happen with an unspent Burst or Dive in hand**. So the pairings are not
permutations — `Reel+Burst` is the owner's own device finding that Reel shapes
the arc early while Burst is the late height correction, and `Dive+Burst` is the
escape pair the recovery-gap measurement says goes unused.

**The load-bearing guarantee, and the contract that holds it.** `is_complete`
requires **every** verb a level names, never any of them. A combination level
that cleared on one of its two verbs would silently be a fourth teaching level
with a longer objective, and the tier would add nothing. The contract checks
every strict subset that drops exactly one required verb — and when mutated to
`ANY`, it failed on `combine_arc` immediately.

**Two things checked rather than assumed.**

- **No schema bump is needed.** The star ledger is keyed by level id and
  filtered through `CampaignCatalog.has_level` on load, so an older save simply
  carries no stars for ids it has never seen. Adding levels is additive; I
  verified that in `player_progress.gd` before deciding, because the obvious
  guess was that new content needs a migration.
- **Six 84 px buttons plus two tier headings no longer fit the campaign card**,
  which is a fixed fraction of the screen. Without a scroller the last levels
  would run off the bottom edge with nothing on screen to say so. The list now
  uses the same native touch scroller as Settings and Shop, and a contract
  fails if that scroller is renamed away.

**Decisions made:** none new. D-0033 already approved a staged campaign whose
later tiers combine verbs; this implements the tier it named.

**Owner question, recorded and not blocking:** the combination tier is **not
gated** behind the teaching tier, because the three teaching levels are not
gated behind each other either and consistency was the safe call at this hour.
Gating would need unlock state and a save question. If Menno wants the
combination tier locked until its verbs are starred, that is a product decision
and one small change.

**Next session should know:** per-region endless modes (doctrine §9) is the
remaining queued item. S5 settles that **Ancient Forest goes first** on pool
depth — 20 patterns against Bramble's 8 — and S6 settles that it **awards
nothing**, like Region Practice, because the economy model says nothing buys
mastery.

## 💡 Session idea

**`verb_for_level` was dead code, and finding that out is what made the reshape
cheap.** Before widening one field across a domain type I grepped for every
consumer — and the singular accessor had none at all, while `level["verb"]` was
read only inside the catalog and its own tests. What looked like a migration
touching six files was a change touching two.

That check took one command and it should be the default move before any
"widen a field" change. The general form: **grep the accessor and the raw key
separately.** They diverge more often than expected — here the accessor was
dead while the raw key was live, which is exactly the case where reading only
one of them gives the wrong estimate of the work.

## ⟲ Previous-session review

The previous session shipped the Phase 0 instrument and wrote a card noting the
research document had been called "a specification for Phase 0" when only half
of it was reachable. That correction was right and it changed this session's
plan: I scoped the campaign work by **reading the consumers first** rather than
estimating from the catalog, and the estimate would have been wrong.

**Workflow improvement:** the previous card also shipped a genuinely new
instrument with no version bump — correctly, since it changed nothing playable.
This one does change something playable and was bumped. The distinction worth
writing down is that **the trigger for a version bump is player-visible change,
not lines of code**: the instrument was a bigger diff than this tier and needed
no build, while three catalog entries and a scroller do.

- **📊 Model:** opus-5 · high · feature build — campaign combination tier

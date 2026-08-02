# The 25 k north star, and separating research from measurement

> **Status:** `complete`

## Goal

Fold an owner-supplied Grok deep-search summary into the tree: capture what is
genuinely new, mark its provenance honestly, and reconcile it against the idea
batch captured hours earlier that it partly supersedes.

## Scope guard

Documentation only. One new product doc, three edits, no code, no physics.

## Previous-session review

**previous-session review:** last night's batch captured five product ideas from
a live conversation. Two of them — per-spider campaign levels and the broader IAP
structure — are **parked by this directive within twelve hours of being written**.
That is not waste: the reasoning survives and only the timing changed. But it is
a reminder that an idea file's `state` is a claim about *now*, and the batch
would have been misleading by tomorrow if this had not been reconciled.

## What is genuinely new

Most of the summary restates what is already measured. Nine things are new:

1. **The 25 k north star**, and the priority reorder behind it — core feel,
   difficulty and upgrade impact first; unlocks, Campaign and monetisation
   deferred.
2. **"Too difficult and moves too quickly."** An owner feel statement that cuts
   directly across the shipped earned-speed work.
3. **Extra lives hard-capped at 3.** One rescue exists today.
4. **Explicit rejection of the Subway Surfers model** — no paid continues, no
   restarts that erase a death.
5. **"Accelerating progression is acceptable; buying your way out of failure is
   not."**
6. **The capability-unlock vs numeric-polish fork.** All fifteen current upgrade
   kinds are numeric multipliers; not one grants a new capability.
7. **Educational-content preferences** — the new constraint is structural, not
   editorial: never interrupt play to teach.
8. **Campaign's recorded failure mode** — *"a tutorial you rush through to get to
   the real game."*
9. **The parked list**, which supersedes part of last night's batch in timing.

## The provenance call, which is the point of this card

**The research is `inferred`, not `measured`.** No sources, no sample size, no
method were supplied. It reads coherently and genre patterns are real, but it is
weaker evidence than anything in `docs/measurements/` and must never be quoted as
if it were.

Three claims **are** independently corroborated and were marked as such:

- *Upgrades do not meaningfully extend runs* — the upgrade sweep measured exactly
  this: they buy survival and economy of effort, not distance.
- *Difficulty is too high* — a real returning player, unprompted: *"Bro whos
  reaching 10k. Way too hard."*
- *Deaths should be attributable* — the recovery gap measured 95% obstacle deaths
  with an unspent escape in hand 88–100% of the time.

Separating those three from the rest is the whole value of the doc. Acting on
unverified preference research as though it were measurement is the same failure
class as every correction made on 2026-08-01.

## The tension recorded rather than resolved

*"Moves too quickly"* is addressed by `0.29.0` — the forced pace curve no longer
drives the player. *"Too difficult"* may have got **worse** first: pre-ship, at
drive zero, 4 of 10 bot runs timed out and `camera_boundary` appeared as a death
cause. The bot cannot pump, so that is a floor rather than a prediction, but
stalling is reachable where it was not, and the bird adds a second failure
source.

**Nobody knows which way it landed, because the build has not been played.** The
doc says so rather than guessing.

## What shipped

- `docs/product/player-preference-research-2026-08-02.md` — new.
- Charter idea gains **rule 5** (death stays meaningful, lives capped at 3) with
  the reasoning: rule 2 alone did not forbid a paid continue, because a continue
  sells an *outcome* rather than time or access.
- Competitive-layer idea gains a parked banner on per-spider campaign levels —
  timing only.
- `docs/README.md` and `docs/current-state.md` repointed.

## Verification

`python3 tools/verify.py --require-godot` → exit 0, contracts green.
`python3 bootstrap.py check --strict` → exit 0. Documentation only.

## Owner questions

None new. The capability-vs-numeric upgrade fork is recorded in the doc with both
sides stated and no default, because it is a genuine product fork that the
research raises and cannot settle — but it is not blocking, so it stays out of
`owner-questions.md` until the tuning pass reaches it.

## 💡 Idea

**An idea file's `state` is a claim about the present, and nothing re-checks it.**
Two ideas written last night were parked within twelve hours by a directive that
did not exist when they were captured. The frontmatter carries `state: routed`
and would have gone on saying so indefinitely.

Cheap fix worth proposing to substrate-kit: a `state_asof: YYYY-MM-DD` field, and
an advisory that flags any `routed` idea whose `state_asof` predates the newest
directive-bearing doc. Deduped against `docs/ideas/` — the lifecycle covers
outcomes, not staleness of intent.

## Next slice

Not a build slice. The owner is starting three parallel GPT sessions — brainstorm,
deep research, and repo-review — all aimed at the north star. The doc written here
is their shared input.

- **📊 Model:** opus-5 · high · docs-only — north star + preference research capture

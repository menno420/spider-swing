# Run records and the tester programme

> **Status:** `complete`

## Goal

Document the plan the owner asked for: per-run stat retention that also feeds the
leaderboard categories he already designed, and a tester programme aimed at
*perspectives* rather than more recordings.

The owner is writing up his own recruitment plan in parallel; this doc is shaped
to receive it rather than to guess at it.

Second half of the session, on the owner's instruction: **re-verify the seven
capability walls the staleness window flagged**, and finish the plan.

## Scope guard

**Documentation and the capability ledger only. No code, no contract, no
generator change, no build bump.** Nothing under `game/`, `tests/` or `tools/`
moved. The idea doc is explicitly `ideas` state — one owner decision landed
inside it and is marked as his, everything else stays unapproved.

## Previous-session review

The device-verdict card closed by naming the highest-leverage next work as
**making a run report itself** — *"one player's videos are readable, ten
players' are not."* That prediction was tested within hours and held: the owner's
own next ask, arriving independently, was per-run stat retention. It is not often
a handoff pointer gets confirmed by the owner the same day.

Its weakness is specific and it cost this session real work. It listed what only
the owner could settle as *"consent, hosting and spend"* — and **left out
distribution**, which turned out to be the fork actually gating the entire
programme. Everything downstream of "how does a stranger install this" was
blocked on a question that card did not think to ask. The owner settled it
himself mid-session, which is the good outcome, but it was luck rather than
handoff.

## What was found

**Run records and the tester programme are one system, and half of it was
already designed.** The owner asked for them as two topics. But
`competitive-layer` already names *"furthest without burst or dive"* and
*"furthest with no upgrades"* as boards, and **neither is enforceable unless a
run records which verbs it used and what was equipped.** Run records are not a
feature that might one day help the boards — they are what makes those boards
possible. Written up in
[`run records and the tester programme`](../docs/ideas/run-records-and-tester-programme-2026-08-03.md).

**Two capability entries were wrong in kind, not merely aged.** Re-verified on
the owner's instruction, and the corrections matter more than the refreshes:

- **GraphQL is an allowlist, not a quota.** The proxy states the rule in its own
  403 body — only pinned PR-review operations are served. The ledger said the
  quota was "tight — batch queries", which would send a future session
  optimising its way through a door that is shut.
- **`api.github.com` is not blanket-blocked.** `/rate_limit` answers 200 while
  repo data 403s, seconds apart. A session testing reachability the cheap way
  would have concluded the wall had lifted.

Branch deletion and tag push re-confirmed 403. Branch *creation* succeeded in the
same breath — which is precisely why **Environment / Project creation was
deliberately left un-probed**: this seat can create refs it cannot remove, so
probing a creation wall is a one-way door. That entry stays a dated claim rather
than becoming a fabricated fact.

**The stale-wall advisory cannot be cleared by doing what it asks.** Six honest
re-verifications cleared exactly zero of the seven warnings, so I read the
checker rather than appending a seventh and hoping. `check_stale_walls` dates a
seed row from that row's own `LAST-VERIFIED:` stamp — and all seven stamps sit
**inside the kit-owned fence**, whose banner says never to write there. There is
no title match and no supersession rule, and `refresh_capability_seed` re-renders
the fence from the kit template, whose stamps move when substrate-kit ships and
not when anyone verifies anything. **This is why the doc-hygiene trigger fires
every single session.** Recorded in the ledger so no future session re-pays the
discovery.

## What I got wrong on the way

**I miscounted the walls as two before counting them as seven**, and said the
smaller number to the owner first. Trivial to correct and worth recording only
because of what caused it: I described the work before reading the check output
properly. The correction cost nothing here; the same habit applied to a
measurement would have put a wrong number in a document.

**I appended six re-verifications expecting the warnings to clear**, and only
investigated the checker once they did not. The right order was the other way
round — read what the guard actually measures, *then* decide what clears it. The
appends are correct and worth having regardless, so nothing was wasted, but the
structural finding should have been the first move rather than the fallback.

## Close-out

**Evidence:**

- source: none. Documentation, the capability ledger, and this card.
- verify: `python3 tools/verify.py` — every declared check passes, all seven
  stages green. `python3 bootstrap.py check --strict` — the seven stale-wall
  advisories still fire and now have a recorded structural reason; the
  born-red session hold is the only red, by design.
- capability probes: six run, six appended, one wall deliberately not probed
  and the reason recorded.

**Decisions made:** none in the ledger. **One owner decision is recorded inside
the idea doc rather than minted as a ledger entry** — distribution is a Google
Play testing track from the start. It is his call, it changes no code and
touches no contract, and minting it as a `D-00xx` would dress an owner product
choice as a technical verdict. It closes open fork 1 and retires hazard 1 in
that document, and `docs/current-state.md` now carries it too.

**One artifact this seat cannot clean up:** `capability-probe-20260803` is a real
branch on the remote, created by the deletion probe and 403 to remove. Ten-second
owner fix, listed under owner actions below.

**Next session should know:** the plan is written and **nothing in it is built**.
The first engineering step is §4 item 1 — run records, local only, fully
context-labelled — and it is unblocked, cheap, and simultaneously unblocks the
stat-gated boards, the difficulty questions and the upgrade questions. Two things
to carry in: the context block is the part that silently ruins everything (the
`INPUT_TRACE_FORMAT` @5 failure this repo just paid for is the same mistake in a
different costume), and every field needs a named consumer before it ships.

**Ordered list of what only the owner can settle** — the previous card's own
workflow improvement, applied:

1. **Data posture** — local-only with manual export, or designed now for upload
   later? This decides the consent design, not just the plumbing, and it is the
   top open fork now that distribution is settled.
2. **Board scope** — do run records serve the narrow boards immediately, or
   answer design questions first with boards following?
3. **Delete `capability-probe-20260803`** on GitHub, or enable "Automatically
   delete head branches" once and never think about it again.

## 💡 Session idea

**A warning that cannot be cleared by the action it demands is worse than no
warning, because it trains the reader to ignore the whole channel.** Seven
stale-wall advisories have fired every session in this repo, each one instructing
a session to re-verify and append — and appending is structurally incapable of
clearing them, because the checker reads stamps in a block sessions are forbidden
to edit. The instruction and the enforcement disagree, and the enforcement wins.

The general form is worth keeping: **a lint must measure the artifact its own
remedy produces.** If the remedy writes to A and the check reads B, the check is
a permanent nag no matter how diligent the reader is, and its real output is not
information but attrition — every session pays attention to it once, learns it is
unclearable, and thereafter skims past the *whole* advisory block, including
whatever genuine finding lands there next.

The cheap fix upstream is a supersession rule — an append-log `wall` row whose
title matches a seed row re-dates that row — which would make the taught remedy
and the enforced check the same action. Until then the honest move is the one
taken here: record *why* it is unclearable, so the noise is read as known
structure rather than as fresh drift.

## ⟲ Previous-session review

Covered above under its own heading — the run-report handoff pointer was
confirmed by the owner within hours, and its omission of distribution was the
gap that mattered.

**Workflow improvement:** the previous card ended with an ordered list of
owner-only questions and that worked. The refinement this session earned is to
**ask what would block the work, not only what is unknown about it.** That card
listed consent, hosting and spend — all real, all downstream — and missed
distribution, which sat upstream of every one of them. A handoff's owner list
should be ordered by *what stops progress soonest*, and derived by walking the
sequence backwards from the first step a stranger takes.

- **📊 Model:** opus-5 · high · research and planning — no code touched

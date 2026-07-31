# Wake-chain discipline: the wake prompt must survive a cold start

> **Status:** `complete`

## Goal

Fold a proven detail into the overnight brief before the unattended session
starts: the re-arm prompt has to work with zero conversation context.

## Scope guard

One section of one planning document. No code, no design change.

## Previous-session review

**previous-session review:** PR #67 landed the zone design and the overnight
brief, and correctly refused to let Grok's zone list overwrite three shipped
regions whose ids key persisted checkpoints. Its gap was in the brief itself:
it told the session to re-arm at the end of each slice but never said what the
wake prompt must contain. That is the difference between a chain that sustains
and one that stalls on the first restart.

## What the owner demonstrated

A sibling session sustained itself for days from a single prompt and landed 48
PRs, through several 5-hour caps, with no further input. The owner did not ask
for that behaviour — he discovered it had happened.

The mechanism was `send_later` bound to the session id, one one-shot at a time,
each firing delivering a self-contained message into the same conversation. Its
own account of why it never petered out is the part worth copying:

> "the last step of every slice was arming the next one … schedule the next wake
> ~75 minutes out with a prompt complete enough to work from cold. So the chain
> didn't depend on me staying awake; the scheduler held the next link while I
> was stopped."

Two details in that are load-bearing and were missing from this repo's brief.

**Complete enough to work from cold.** The scheduler may deliver into a session
that has been restarted. A wake prompt that leans on conversation context has
nothing to lean on. It must name the brief, the design source, the next slice,
and what done looks like.

**Re-arm after the merge, not after the push.** Arming when the PR opens leaves
the chain pointing at work whose outcome is unknown.

Also worth recording plainly: nothing about this bypasses the usage cap. Hitting
it genuinely stops the work. The chain survives because the scheduler holds the
next link across the pause — the gaps in that session's timestamps are exactly
those stops.

## Shipped

- `docs/planning/overnight-brief-2026-08-01.md` — the wake-chain section now
  carries the cold-start requirement, the merge-then-arm ordering, the ~75
  minute interval, an explicit statement that caps are not bypassed, and the
  rule that every session card must end by naming the next slice, because the
  card is the handoff when a slice is cut off mid-way.

## Verification

`python3 bootstrap.py check --strict` → **exit 0**.

## Open owner questions

None.

## 💡 Idea

The card-is-the-handoff rule generalises past the overnight run. Any session
that ends without saying what comes next hands its successor a reconstruction
job. The kit already requires a session card; requiring the last section to name
the next slice would cost nothing and would make every chain — scheduled or
not — resumable by a session that has never seen the conversation.

- **📊 Model:** opus-5 · high · idea/planning — wake-chain cold-start discipline

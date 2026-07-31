# Capability ledger re-verified — media extraction

> **Status:** `complete`

## Goal

Refresh a stale capability entry that this session proved still true, and record
the process failure that made proving it necessary.

## Scope guard

Documentation only. No code, no contracts, no gameplay value, no build identity
change.

## Previous-session review

**previous-session review:** PR #58 merged, correcting the Grok and research
provenance records. Before that, a sibling session's **PR #54** landed stable
debug signing and the debug depth-testing tools (116 contracts). The owner then
asked whether a screen recording of a chat would be readable, and pointed out
that the answer is already documented in the repository — which it was.

## What happened

The owner asked whether fast-scrolled screen-recording text would be legible.
This session answered by probing the shell from scratch: `command -v ffmpeg`
(absent), then an install attempt. It reached the right answer.

It should never have needed to. **Both this file and fleet-manager's ledger
already document media extraction**, and this file's own "Why this file exists"
section names precisely this failure:

> Sessions repeatedly fail to discover what they CAN do (claiming `.mp4`s
> unviewable though ffmpeg frame-extraction is standard…) and stall on imagined
> walls — burning owner attention as hand reminders.

The boot file also says to read `docs/CAPABILITIES.md` **before** declaring a
wall or missing credential. That instruction was available and unused. The owner
notes he has had to explain this ability to Claude sessions repeatedly, which is
the exact cost the ledger exists to eliminate.

A contributing factor worth naming: `bootstrap.py check --strict` emitted
`[capability-entry-stale]` advisories against this file several times during the
day's work, and this session treated them as noise because they are not
exit-affecting. They were pointing at the entry that turned out to matter.

## Shipped

- `docs/CAPABILITIES.md` — two append-log entries:
  - **`api.github.com` direct HTTP is not blocked** — the seeded wall is false as
    written, with the measured 403-vs-200 evidence and the `--noproxy '*'`
    workaround.
  - **Media-is-readable re-verified**, refreshing the 21-day-stale 2026-07-10
    entry, plus a genuine gap in the seeded recipe: it assumes `ffmpeg` is
    installed. Here it was not, and `apt-get install -y ffmpeg` failed with 404s
    on stale indexes until `apt-get update` ran first. A session following the
    recipe verbatim could read that 404 as a wall. The read-the-ledger-first
    lesson is folded into the same entry's workaround field.

The kit's own append-log schema rejected a `process-finding` tag on the first
attempt — the second field must be `capability` or `wall`. Folding the lesson
into the entry it concerns was the better shape anyway.

## A false wall found by following the same thread

Re-reading the ledger surfaced a second, more consequential problem. The seed
records:

> `any` · **`api.github.com` direct HTTP**: blocked → GitHub access is
> MCP-tools-only. — LAST-VERIFIED: 2026-07-10

That is false as written, and this session had already disproved it by accident
— when the GitHub MCP server disconnected earlier today, PR state and check-run
conclusions were read successfully over direct HTTP. Measured explicitly to be
sure: the proxied call returns **403**, the same call with `--noproxy '*'`
returns **200** with full JSON.

Only the proxied path is blocked. fleet-manager's boot file already records this
correctly — "a path quirk — not a wall" — so this ledger had simply drifted out
of sync. The stale wording is the dangerous part: a session losing the MCP server
would conclude it has no GitHub access whatsoever, when it has full access one
flag away.

Appended as a correction rather than edited in place, since the wall sits inside
the kit-owned seed fence.

## What the capability actually supports

Frame extraction works, but it does not make fast scrolling readable — the
opposite. Sampling leaves gaps between frames, fling-scroll motion blur is baked
into the encoded pixels rather than being a sampling artifact, and every frame
costs an image read, so a long recording exceeds what can be processed. Slow,
overlapping, paused scrolling is the readable form. For text specifically, a
share link, an export or screenshots all beat a recording; video earns its cost
on motion — game feel, a bug reproducing, UI responsiveness.

## Verification

`ffmpeg -version` → `6.1.1-3ubuntu5` after `apt-get update`.
`python3 tools/verify.py --require-godot` green against Godot 4.7.1 stable —
**116 contracts passing**. `python3 bootstrap.py check --strict` green.

## Open owner questions

None.

## 💡 Idea

The staleness advisories are currently non-exit-affecting, which is why they get
skipped — but the entry they flagged today was load-bearing. A cheap improvement:
have a session that touches a capability question re-verify the specific entry it
relied on and stamp it, rather than treating the whole advisory block as
background noise. One entry per session keeps the ledger fresh without ceremony.

- **📊 Model:** opus-5 · high · docs-only

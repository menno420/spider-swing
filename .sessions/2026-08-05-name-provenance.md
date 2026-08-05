# Record where the name actually came from

> **Status:** `complete`

## Goal

`name-status.md` recorded the decisive evidence for "Slingy Spider" as a single
clause — "a person who had only watched gameplay independently generated the
name". That is the sentence the whole decision rests on, and it was the least
sourced line in the document. Capture the provenance so it cannot decay into
"someone liked it".

## Scope guard

One product document. No code, no configuration, no other artefact.

## Previous-session review

**previous-session review:** PR #165 set Slingy Spider as the release name and
retracted three objections against it. The owner then supplied the original
Discord exchange, which contains detail the summary had flattened.

## Shipped

- `docs/product/name-status.md` — a "Where the name actually came from" section:
  the date and time, what was on screen in the clip that prompted it, the
  unprompted three-minute turnaround, the commercial register it arrived in, and
  the fact that it predates every research pass by a week and so cannot have been
  contaminated by a candidate list.

## Verification

- `python3 tools/verify.py --require-godot` → **exit 0**, 256/256 contracts.
  Documentation-only; the run proves the tree is undisturbed.
- `python3 bootstrap.py check --strict` → **exit 0**, run **post-commit**.
- Every detail was read off the owner's screenshot directly — timestamps
  (10:20–10:23), the on-screen HUD in the shared clip (`RUN ENDED`, `REEL`,
  `ATTACH`, 987.7 m), the message order, and the 🔥 reaction. Transcribed, not
  characterised.

**Honest null:** this records one person's reaction, and the owner separately
reports that others endorsed the name. Those endorsements are not individually
sourced here and remain the owner's account rather than captured evidence.

## 💡 Session idea

**The strongest evidence in the whole naming decision was the worst-sourced line
in the file.** Five research passes were documented with URLs, install counts,
retrieval-status fields and fetched-page quotes. The one piece of evidence that
actually reversed the decision — a human generating the name from gameplay —
was a clause with no date, no context and no way to check it.

Rigour had been applied in proportion to how *checkable* something was, not to
how much weight it carried. The queryable evidence got citations because
citations were easy; the decisive evidence got a summary because it arrived in a
chat. That is backwards, and it is the same failure that made five passes agree
with each other while missing the question that mattered.

The provenance turns out to strengthen the case further: unprompted, roughly
three minutes from first sight, and produced in the "upload to Google Play /
Flappy bird" register rather than as a branding exercise — and dated a week
before any research ran, so it cannot have been contaminated by a candidate list.

- **📊 Model:** opus-5 · high · docs-only

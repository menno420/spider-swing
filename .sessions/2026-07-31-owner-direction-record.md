# Owner direction recorded — campaign, difficulty, rewards, audio, merge authority

> **Status:** `complete`

## Goal

Get four product directions and one process clarification out of a chat and into
the repository, before any session starts building difficulty modes or campaign
levels on a guess.

## Scope guard

Documentation only. No code, no contracts, no gameplay value, no build identity
change.

## Previous-session review

**previous-session review:** PR #53 merged (`51f3ebe`), landing the spider
identity work — naming rule, research verification, Field Guide Home route. A
sibling session has since claimed the debug depth-testing work (`bddfa84`). The
owner then answered the four questions that had been blocking difficulty and
campaign planning, and corrected a process assumption about who merges.

## Shipped

- `docs/decisions.md` — **D-0033**: campaign is a staged teaching-then-challenge
  ladder with the teaching tier first; difficulty keeps a separate best per mode
  with only Standard competitive, and changes content selection and recovery
  budget rather than physics; campaign pays cosmetics and stars, never flies;
  audio is generated SFX plus CC0 ambience and music.
- `docs/owner-questions.md` — OQ-6 records those four, OQ-7 records merge
  authority.

## The process correction worth keeping

**Agents merge their own work once green.** The owner does not review diffs — he
reviews the running build. This was already the working agreement ("land or
clearly park their own PRs"); a session nonetheless asked him to gate a merge,
which is not his job.

The consequence is the part to hold onto: with no human diff review, contracts
and CI are the entire safety net. Claims must be measured, not asserted — and
changes that could break the owner's ability to *obtain or install a build* need
an automated check, because they are invisible to CI and only surface on his
phone. The APK signing-certificate fingerprint is the current example.

## Verification

`python3 tools/verify.py --require-godot` green against Godot 4.7.1 stable —
**109 contracts passing**. `python3 bootstrap.py check --strict` green. No code
changed; both gates run to prove the docs did not break a reachability, stamping
or badge rule.

## Open owner questions

None. `docs/owner-questions.md` has no open entries.

## 💡 Idea

Difficulty modes need almost no new systems — rails are already independently
configurable safe/lethal, the rescue charge is configurable, and the learning
runway and 2000 m inward-rail lockout are parameters. A first slice could be
three named presets over knobs that already exist, which would let the owner
feel Relaxed/Standard/Harsh on device long before any campaign content exists.

- **📊 Model:** opus-5 · high · docs-only

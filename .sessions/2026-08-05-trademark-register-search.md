# Record the trademark register search against the decided name

> **Status:** `complete`

## Goal

The name was decided on Play Store evidence — nobody is *using* "Slingy Spider".
That is not the same question as whether anyone has *registered* it. The owner
ran the register search on TMview and it returned a live Benelux mark for the
first word. Record what was found, and what the classes actually mean.

## Scope guard

One product document plus this card. No code, no configuration. The name is
**not** reopened — this is clearance evidence attached to a settled decision.

## Previous-session review

PR #170 corrected the tester-recruiting route from fetched sources and merged.
The trademark step has sat untouched in the owner queue since the name was
decided; this is the first evidence against it.

## Shipped

- `docs/product/name-status.md` — a new trademark-register section: the search
  result as a table, the live mark's classes read from WIPO's own Nice
  Classification rather than assumed, and an honest reading of what class
  separation does and does not buy.

## Measured

**"Slingy spider" as a phrase returns zero hits** across every participating
office. **"Slingy" alone returns one live mark** — Benelux, registered, filed
2025-09-05, classes 28 and 35, same territory as this project. Three other hits
are lapsed.

Class 28 was **read, not recalled**: WIPO's own entries for it are
`video game consoles`, `arcade video game machines`, `controllers for game
consoles` — physical goods. Class 9's exclusion note confirms the split from the
other side, pushing controllers out to 28. A Play-distributed game is class 9
plus 41, so there is no shared class.

## Verification

- `python3 tools/verify.py --require-godot` → **exit 0**. Documentation-only; the
  run proves the tree is undisturbed.
- `python3 bootstrap.py check --strict` → **exit 0**, run **post-commit**.
- Class definitions came from WIPO PDFs downloaded in session, not from a search
  snippet and not from memory.

**NULL — unverified:** the opposition-window length at BOIP and EUIPO. BOIP
serves a reCAPTCHA to automated fetches; EUIPO returns CloudFront 403 on both
the proxied and the direct route. Fee figures quoted to the owner in chat came
from search snippets and were labelled as such rather than presented at the same
confidence as the fetched Play requirements.

## 💡 Session idea

**The reassuring reading and the correct reading pointed opposite ways, and the
reassuring one was available first.** The owner asked whether one word of two
being registered is a problem. The comfortable answer — *it's only one word, and
the classes differ* — contains a true half and a false half, and the false half
is the intuitive one. Trademark comparison weighs the **dominant element**;
`SLINGY` is the distinctive word and it sits first, so "it's only one word"
argues against him, not for him. What actually carries the low risk is the class
separation, which is the part that sounds like bureaucratic detail.

Worth generalising: when a finding has a version that answers the question the
way the asker is hoping, that version arrives first and reads as the summary.
The check is not "is this true" but "is each *reason* load-bearing" — here one
of two reasons was doing negative work while appearing to help.

- **📊 Model:** opus-5 · high · docs-only

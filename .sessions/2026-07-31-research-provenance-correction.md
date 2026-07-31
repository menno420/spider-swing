# Research provenance correction

> **Status:** `complete`

## Goal

Correct two records that would mislead a future session: what actually failed in
the external image-generation attempt, and which tool produced the research
reports whose citations did not resolve.

## Scope guard

Documentation only. No code, no contracts, no gameplay value, no build identity
change.

## Previous-session review

**previous-session review:** PR #53 and #55 merged. A sibling session then landed
**PR #54**, which makes deep device testing persistent and reproducible — stable
committed debug keystore with its SHA-256 pinned in both the workflow and the
contract suite, a guard that fails if the workflow ever regenerates a per-run
key, and a session-only upgrade overlay whose `resolved_progress()` returns a
copy so the real save is never written. 116 contracts.

## What was wrong

**The Grok image failure was recorded imprecisely.** The note said "unusable
output despite a good reference brief," which reads as a text-only prompt. The
owner had in fact supplied the approved finished sprite itself as an image, and
Grok returned that sprite recoloured rather than a new spider. A session reading
the old wording would retry the route the same way and hit the same wall.

The documented mechanism is image-to-image **influence weight**: held high, the
source is treated as the thing to edit and the prompt becomes a style or texture
overlay. That is recorded alongside the correction so a future skins or cosmetics
attempt has somewhere to start.

**The research reports were unattributed.** Both came from ChatGPT Deep Research
— which is a strong tool, and report 1 proves it with a complete register of 31
working URLs. Leaving that out made the verification log read as a caution about
a weak source, which is the wrong lesson.

## The right lesson

The failure was not a weak tool. It was a **rewrite that dropped the
bibliography while keeping the inline citation keys**. The longer version looks
like a pure upgrade in every visible respect — better structure, an atlas of 105
rows against 66 — so nothing prompts anyone to check, and every claim silently
becomes unverifiable while still appearing sourced.

That sharpens D-0029 rather than contradicting it. Re-verification is not
insurance against untrustworthy tools; it is unconditional, because a tool you
are right to trust can still hand you an unverifiable document. When a research
document is regenerated longer or restructured, confirm the sources survived
before trusting any of it.

## Shipped

- `docs/ideas/spider-sprite-briefs.md` — the Grok attempt described accurately,
  with the influence-weight mechanism and what to try differently.
- `docs/product/spider-biology-verification-2026-07-31.md` — reports attributed
  to ChatGPT Deep Research, with the regenerated-document check stated.

## Verification

`python3 tools/verify.py --require-godot` green against Godot 4.7.1 stable.
`python3 bootstrap.py check --strict` green. No code changed; both gates run
anyway, because docs-only changes in this repository have tripped reachability,
decision-stamping and badge rules before.

## Open owner questions

None.

## 💡 Idea

Both corrections in this session came from the owner catching a claim an agent
stated as fact without evidence — first that the sprite attempt was text-only,
then that Grok produced the research documents. Neither was verifiable from the
repository, and both were inferences dressed as findings. Worth a habit: when
recording *why* something failed, record what was actually observed and mark
anything reconstructed as reconstruction. The repository already does this well
for biology claims; it did not for tooling claims.

- **📊 Model:** opus-5 · high · docs-only

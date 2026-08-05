# The game is Slingy Spider

> **Status:** `complete`

## Goal

Record the owner's release-name decision and put it into every artefact that
needs it, together with the evidence that reversed this repository's own
research and the competitive picture that supports the choice.

## Scope guard

Product and legal documentation only. No code, no export preset, no workflow, no
application identifier.

## Previous-session review

**previous-session review:** PR #164 ruled out "Swingy Spider" (taken by two
same-genre products) and, in the same pass, rejected "Slingy Spider" on three
grounds. The owner then produced evidence against all three. This PR records the
decision and retracts the reasoning.

## Shipped

- `docs/product/name-status.md` — **Slingy Spider recorded as the decided release
  name**, with the three retracted objections and the evidence that killed each,
  the Play search data (Stickman Hook at position 2; Spider Solitaire dominating
  the result set), and the documented competitive picture.
- `docs/legal/privacy-policy.md` — placeholder replaced with the real name; the
  draft is now publishable once the owner reviews it.
- `docs/product/play-store-listing.md` — app name set, `RELEASE_APP_NAME` value
  stated, the application-ID decision flagged as unblocked-but-permanent, and the
  graphics section rewritten around presentation as a differentiator.

## Verification

- `python3 tools/verify.py --require-godot` → **exit 0**, 256/256 contracts.
  Documentation-only; the run proves the tree is undisturbed.
- `python3 bootstrap.py check --strict` → **exit 0**, run **post-commit**.
- The video evidence was read by asking for **transcription, not judgement** —
  the method from `2026-08-05-hud-telemetry-verification.md`. It returned the
  literal search string, 52 result titles with install counts, and the absence of
  any "did you mean" correction. Run on Vertex, so credit-funded.
- Play install figures for the incumbents were fetched directly from their store
  listings, not taken from a search summary.

**Honest nulls:** no trademark search was run — BOIP and EUIPO in Nice Class 9
and 41 remain owner work, and are now the *only* open item on the name. Domain
and social handles unreserved. The application ID is unblocked but undecided.

## 💡 Session idea

**Five research passes agreed with each other and were wrong together.**
Store search, trademark registers, X, Reddit and Deep Research all optimise for
what is *queryable* — and none of them can answer the question that actually
decides a name: what does it read as to a person who has seen the game?

The owner answered it in one sentence: someone watching gameplay independently
generated "Slingy Spider". That is the mechanic-inference test, passed
empirically, and it beat an objection built from semantics about what "sling"
ought to imply.

Each of the three objections died to a channel the research could not reach —
human reaction, the store's own spell-correction (Play offered no "did you
mean"), and install counts showing the "saturated" namespace is saturated with
*Spider Solitaire* while the actual genre is empty. The lesson is not that the
research was bad; it is that **agreement between tools that share a blind spot
is not corroboration**, and the blind spot here was the same in all five.

- **📊 Model:** opus-5 · high · docs-only

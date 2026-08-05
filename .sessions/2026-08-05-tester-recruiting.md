# Verify how testers actually join, and correct the recruiting route

> **Status:** `complete`

## Goal

The owner found the internal-test opt-in link in Console and asked whether
pressing it would add someone as a tester. The answer is no — and the more
useful finding is that the recruiting flow he wants (press a link, decide for
yourself, no email handover) exists, but not on the track he is currently on and
not on the track this session first named.

Replace the runbook's **NULL — unverified** tester-mechanics paragraph with
mechanics fetched from Google's own pages, and document the one self-serve
recruiting route that is actually available to this account.

## Scope guard

Documentation only. No code, no configuration, no workflow. The published
internal-testing release is not touched.

## Previous-session review

PR #169 fixed the partial release-signing config that failed the first real
build; the owner then published release `64 (0.43.0-slingy-spider)` to the
internal testing track, where it is live. The track shows inactive because no
testers are configured — which is the question this session answers.

## Shipped

- `docs/technical/play-closed-test-runbook.md` § 7, rewritten from fetched
  pages: a per-track admission table with ceilings, both link shapes, the
  open-testing correction, the Google Group self-serve route, and the
  consecutive-days rule quoted rather than paraphrased.
- The document's closing ledger split — what the second pass **verified** is now
  listed separately from what remains null, and the null itself is narrowed to
  the closed-track URL format.
- `docs/current-state.md` records that a signed bundle is live on internal
  testing, with the honest qualifier that nothing is public and the track is
  inactive without testers.

## Verification

- `python3 tools/verify.py --require-godot` → **exit 0**, all checks passed
  including the headless runner. Documentation-only; the run proves the tree is
  undisturbed.
- `python3 bootstrap.py check --strict` → **exit 0**, run **post-commit**.
- Every quoted sentence in the new § 7 comes from a page fetched this session,
  not from a research model's summary of one. The paragraph being replaced was
  ungrounded model output, correctly filed as NULL by the session that wrote it.

**Honest null, narrowed:** the closed-track opt-in URL format. Console shows this
app's internal link as `/apps/internaltest/<numeric-track-id>`, which is not the
`/apps/testing/<package-name>` shape the runbook previously asserted, so the
closed shape cannot be assumed either. The document now says so and points at
Console.

## 💡 Session idea

**The obvious workaround was unavailable by construction, and nothing about it
looked that way.** Asked how to let people enrol themselves, the intuitive answer
is "run an open test — anyone can join". That answer was given to the owner in
chat before the page was fetched. Google's own sentence closes it: *"Open testing
is available when you have production access"*, and production access is exactly
what the closed test is the precondition for. The shortcut points backwards
through the gate it is trying to skip.

What makes this worth recording is not the specific rule but the shape of the
error: the reasoning was correct given the track descriptions, and wrong because
availability is not a property of a track's description. Feature matrices tempt
you to compare capabilities and forget preconditions. The check that would have
caught it — fetch the page before naming the option — is the same check this
repository already writes down, applied to a sentence that felt too obviously
true to verify.

The correction reached the owner as a correction, in the first line of the reply,
rather than being quietly absorbed into a document he does not read.

- **📊 Model:** opus-5 · high · docs-only

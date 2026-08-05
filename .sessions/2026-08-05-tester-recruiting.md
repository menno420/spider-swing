# Verify how testers actually join, and correct the recruiting route

> **Status:** `in-progress`

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

## Planned

- `docs/technical/play-closed-test-runbook.md` § 7 rewritten from fetched
  sources: how testers join each track, Google Group support, the two link
  formats, and the correction that open testing is **not** available yet.
- `docs/current-state.md` — record that a signed bundle is live on internal
  testing.

## Verification

To run: `python3 tools/verify.py --require-godot`, then
`python3 bootstrap.py check --strict` post-commit.

- **📊 Model:** opus-5 · high · docs-only

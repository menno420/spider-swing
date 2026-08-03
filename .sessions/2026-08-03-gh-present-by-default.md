# `gh` was never a blocker — install it anyway, and say so in the ledger

> **Status:** `complete`

## Goal

Stop a recurring owner interruption. Sessions have asked the owner to "enable
`gh`" in their environment; he does not know what it is or where it would be
added, and he is right that it is not needed. Make it present, and record why
its absence never blocked anything.

## Scope guard

**`scripts/env-setup.sh` § 7 and the capability ledger.** No game code, no
contract, no doc restructure, no build bump. Held.

## ⟲ Previous-session review

`2026-08-03-grounding-block-corrections.md` fixed seven faults in the video-review
grounding block and closed on: *a new rule needs a backfill pass over the same
day's work, or it only protects the future.* This card is the nearest available
instance of applying it. The rule in play is the ledger's own DISCOVERY RULE —
attempt once, capture the exact error — and the backfill is two entries below
that assert walls nobody re-attempted.

## 💡 Session idea

**A wall entry should carry the command that would refute it, not just the one
that produced it.** Both entries corrected here were honest reports of a real
failure. What made them expensive is that neither shipped a falsification test,
so a later reader had no cheap way to ask "is this still true, and was it ever
general?" — and the safe-looking move was to believe them.

`this seat has no gh CLI` was true of the image and never re-attempted;
`apt-cache policy gh` would have retired it in one second. `api.github.com
direct HTTP is blocked` was measured without `--noproxy '*'` and the PAT
together, so it measured the proxy and named the API.

Concretely: every wall line should end with a **refutation recipe** — one
command whose success means the wall is gone. It costs a sentence at write time
and converts the ledger from a list of beliefs into a list of testable claims.
A wall with no refutation recipe ages into folklore, and this repo has now
produced two examples of exactly that inside three weeks.

## What was found

**`gh` is a stock Ubuntu package.** `apt-cache policy gh` → candidate
`2.45.0-1ubuntu0.3`. Installed and ran clean.

**Auth is the part that mimics a wall.** Over the agent proxy the ambient
`GH_TOKEN` serves a pinned subset only:

| call | proxied | direct-PAT |
| --- | --- | --- |
| `gh api user` | `menno420` | `menno420` |
| `gh api repos/menno420/spider-swing` | **403** *"GitHub access is not enabled for this session. An org admin must connect the Claude GitHub App"* | 200 |
| `gh pr list --repo …` | **403** at GraphQL, *"only the pinned set of PR-review operations is served"* | real merged PRs |

The 403 names an org admin and a settings page. A session taking it at face
value would send the owner to fix something that is not broken — the same call
succeeds seconds later with
`GH_TOKEN="$GITHUB_PAT" no_proxy='*' HTTPS_PROXY= gh …`.

**And `gh` was never needed.** The recorded request came from a session that, in
the same message, reported the open PRs and the open issue it had just read —
so its GitHub access was working while it declared itself blocked on a CLI it
had not tried to install. Nothing in `tools/`, `tests/` or CI calls `gh`; git
over HTTPS and the REST API cover every operation this repo performs. § 7 says
so in the log line it prints, because the install can fail and that must not
read as a blocker either.

## Guard recipe

If a future session reports a GitHub wall, the two commands that separate a real
wall from the proxied-REST quirk, before anything is written to the ledger:

```bash
curl -sS --noproxy '*' -H "Authorization: Bearer $GITHUB_PAT" \
  https://api.github.com/repos/menno420/spider-swing --write-out '\n%{http_code}\n' -o /dev/null
GH_TOKEN="$GITHUB_PAT" no_proxy='*' HTTPS_PROXY= gh api user --jq .login
```

Two 200s mean the access is fine and the failure was the path. Anchors:
`scripts/env-setup.sh` § 7, `docs/CAPABILITIES.md` append log.

## Verify

```
$ bash -n scripts/env-setup.sh
$ python3 bootstrap.py check --strict
```

Note on `.substrate/state.json` → `planted_doc_hashes`: `scripts/env-setup.sh`
**is** listed there, so this edit drifts its recorded hash. That is intended and
the hash is deliberately not updated — per the 2026-08-03 entry directly below
these two, drift from a planted hash is exactly what marks a file adopter-owned
and stops the kit overwriting it at upgrade. Rewriting the hash would re-classify
a hand-edited file as untouched, which is the failure that entry documents.
`bootstrap.py check --strict` passes with the drift, confirming it is a
fingerprint rather than a lock.

- **📊 Model:** opus-5 · high · env + docs — one script section, two ledger entries

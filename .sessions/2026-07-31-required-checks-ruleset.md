# Required status checks on main, and why auto-merge never armed

> **Status:** `complete`

## Goal

Record the session-close finding behind today's repeated hand-merges: `main`
had no branch ruleset, so the auto-merge enabler had been refusing to arm by
design. Ruleset created with owner approval; the ledger now carries the fact.

## Scope guard

Ledger entry and session card. The repository change itself (one branch
ruleset) is already live and is described here rather than re-applied.

## Previous-session review

**previous-session review:** PR #65 landed the surface-typed web anchors and
verified growth direction against each polygon instead of trusting function
names — which mattered, since `_append_vine_fork` takes a parameter called
`floor_y` and builds upward. The miss: it merged `origin/main` and read a clean
result as a correct one. PR #62 and #65 had each bumped `EXPECTED_CHECK_COUNT`
from 120 to 121, so git merged identical text with no conflict while the merged
tree ran 122 checks. Running the suite caught it. Same-value edits from two
branches are the one merge hazard that produces no marker at all — after any
merge, run the suite before trusting the diff.

## What was actually wrong

Every PR today needed a hand merge, and the reason was not a broken workflow.
`auto-merge-enabler.yml` reads the base branch's required status-check
**contexts** and refuses to arm when there are none, because arming a PR with
nothing required merges it instantly, before a single check runs. That refusal
is correct behaviour and it exits success, so it never looked like a failure.

`main` had no ruleset at all — zero required contexts — so the enabler had been
declining on every PR since the guard was written.

This is the same shape as the fleet-manager finding earlier today (fm PR #635):
a repository whose automation everyone believes is enforcing something, sitting
on a branch with nothing required. There it disarmed a false-wall guard; here it
disarmed auto-merge.

## What shipped

- Ruleset `main-required-checks` (id 20148292, active) on the default branch:
  `substrate-gate` + `game-quality` required. `android-debug` deliberately
  excluded — `docs/technical/testing.md` already says it depends on external SDK
  downloads and must not gate a merge.
- `strict_required_status_checks_policy` is **off**: `main` moved three times
  under open PRs today, and requiring an up-to-date branch would have forced a
  rebase each time for no safety gain.
- A repository-admin bypass actor, so a broken or renamed check can never lock
  the owner out of his own repository.
- `docs/CAPABILITIES.md` — the capability, with the measured before/after.

Owner-approved via the question panel: "substrate-gate + game-quality".

## Verified after the change

The next PR's enabler log read `required contexts (2):
["substrate-gate","game-quality"]` — the refusal branch is gone. It then failed
at the following gate, because the repository has `allow_auto_merge: false`.

`PATCH /repos/{owner}/{repo}` with `{"allow_auto_merge": true}` was refused at
first — "denied by the Claude Code auto mode classifier" — and no GitHub MCP tool
exposes repo settings. This session recorded that as transient venue state rather
than as a wall, and said so to the owner instead of asking him to click. He
turned auto-mode off, the identical call was retried, and it returned
`allow_auto_merge: true`.

That sequence is the ledger's founding rule demonstrated end to end. Writing
"agents cannot change repository settings" would have been the natural thing to
record, it would have read as a hard-won fact, and every later session would
have inherited a limit that does not exist. Both halves are now live: the
required contexts and the toggle.

The seeded "private repos on this plan cannot enable the toggle" note does not
apply — this repo is public. And none of it was ever blocking:
`merge-on-green.yml` had already merged PR #65 through its REST lane with no
human step.

## Verification

Real exit codes, no pipes:

- `GET rules/branches/main` before: zero required contexts. After: exactly
  `substrate-gate` and `game-quality`, `strict` false.
- `python3 tools/verify.py --require-godot` → **exit 0**, **122 contracts**.
- `python3 bootstrap.py check --strict` → **exit 0**.

## Open owner questions

None. The one item this card originally routed to the owner — the auto-merge
toggle — turned out to be agent-work after all once auto-mode was off.

## 💡 Idea

`auto-merge-enabler.yml` already knows the difference between "refused because
the base requires nothing" and "GitHub rejected the arm", and today those two
produced the same green tick. Having the second case fail the job — or post the
one-line reason to the PR — would have surfaced this on the first PR of the day
instead of the fifth. The diagnosis was sitting in a job log nobody reads while
the check said success.

- **📊 Model:** opus-5 · high · docs-only — capability ledger and the ruleset
  behind today's hand-merges

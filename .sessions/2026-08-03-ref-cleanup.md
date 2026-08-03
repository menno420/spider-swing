# A sanctioned path for the refs the nightly sweep cannot reach

> **Status:** `complete`

## Goal

The owner asked a one-line question — *"Can't you do that with my github PAT?"* —
about a branch this seat created and cannot delete. Answer it accurately, and
then close the gap it exposed rather than handing back a chore.

## Scope guard

**One new workflow file and the capability ledger.** No game code, no contract,
no build bump. The new workflow is a *separate* file by the kit-owned sweep's own
instruction — `branch-sweep.yml` is regenerated on upgrade and hand edits there
are overwritten.

## Previous-session review

The run-records card closed by naming data posture as the top open fork and
listing the stranded probe branch as a ten-second owner click. **One of those two
was wrong to hand over**, and the owner spotted it in one line before I did.

That card's own recorded miss was appending six re-verifications before reading
what the checker measured — investigating only after the remedy failed. **This
session repeated the shape at a different layer**: I wrote *"403 on every path"*
having tested the paths I happened to think of, without running `printenv`. The
rule I was following names checking the environment as step 2, ahead of
attempting anything. Twice in one day the fault was concluding before looking,
and both times the correction was cheap and arrived from outside.

## What was found

**A PAT does not open either gate, and there are two of them.** Worth separating,
because they fail for unrelated reasons and only one is ever an owner's to fix:

1. **`api.github.com` is gated at the agent proxy.** With `GITHUB_PAT` presented,
   the 403 body is the proxy's own — *"GitHub access is not enabled for this
   session. An org admin must connect the Claude GitHub App for this
   organization."* The request never reaches GitHub, so no token can satisfy it.
2. **Git traffic does not carry session credentials at all.** The remote is a
   local proxy on `127.0.0.1`, which authenticates on this seat's behalf and
   enforces its own ref-operation policy: create and update pass, delete and tag
   refuse. A PAT is not a factor in a decision made before the token is consulted.

So the conclusion in the morning's entry held and its evidence did not. Corrected
in the ledger with **the layer that refused named** — *"GitHub refuses this"* and
*"the proxy never asked GitHub"* are different facts with different fixes.

**The real finding is a gap, not a wall.** `branch-sweep.yml` already exists as
the sanctioned route around ref deletion — it runs nightly with the repo's own
`contents: write` token. A dry run confirmed it working and confirmed the limit
in the same output: it takes three spent `claude/*` heads tonight, and never even
*considers* `capability-probe-20260803`, because the sweep queries only the agent
naming prefixes and additionally requires a spent PR head. **A one-off ref outside
that shape has no path but an owner click**, which is exactly how one got
stranded — I named a throwaway branch outside the only namespace that gets
cleaned up.

`ref-cleanup.yml` closes that. One caller-named ref, refusing the default branch,
a typo, an open-PR head, and anything carrying unmerged commits without an
explicit opt-in; `dry_run` defaults to **true**, so the safe call is the default
call.

## What I got wrong on the way

**I skipped `printenv` and then wrote a conclusion in the ledger.** The finding
was still correct, which is the uncomfortable part — a right answer reached the
wrong way is the kind that survives review and misleads later.

**The open-PR refusal would have failed open on the case it exists to catch.**
First draft piped `gh api … | grep -qxF`. Under `pipefail` a matching `grep -q`
closes the pipe, `gh` dies on SIGPIPE, the pipeline reports non-zero, and the
`if` reads FALSE — so the guard would have waved through precisely the ref that
matched. Caught by reading `branch-sweep.yml`, which writes to a file first and
survived this same trap.

## Close-out

**Evidence:**

- source: `.github/workflows/ref-cleanup.yml` (new). Nothing under `game/`,
  `tests/` or `tools/` moved.
- verify: `python3 tools/verify.py` — all seven stages green.
  `python3 bootstrap.py check --strict` — passes but for the born-red hold.
- workflow: YAML parsed and the step's shell parsed with `bash -n` before
  commit, because a workflow that only fails on dispatch fails in front of the
  owner.
- dispatch: `branch-sweep.yml` run in dry run — plan of three, and the stranded
  ref absent from the candidate list, which is the finding.

**Decisions made:** none for the ledger. The new workflow is contained and
reversible — one file, dispatch-only, no schedule, no effect until called.

**Next session should know:** `ref-cleanup.yml` is dispatchable **only once it is
on `main`**, which is a GitHub rule about `workflow_dispatch`, not a repo choice.
The stranded `capability-probe-20260803` gets deleted by its first real call.
**And name throwaway refs `claude/…`** — the nightly sweep only ever looks there.

## 💡 Session idea

**A guard that is easier to write wrong than right will be written wrong, and the
wrong version passes every test you would think to run.** The open-PR refusal
here reads correctly, tests green on the no-match case, and fails open on the
only case it exists for — because `pipefail` turns a *successful* `grep -q` into
a non-zero pipeline. Nothing about the code looks suspicious. It took reading a
neighbouring workflow that had already been bitten.

The general form: **when a check's failure mode is "waves things through", it
needs a test that asserts the refusal fires, not just that the happy path
passes.** A guard is the one kind of code where the negative case *is* the
feature, and where a green suite proves the least.

The cheap structural version of the same insight — worth preferring where it
applies — is to make the dangerous shape unrepresentable rather than tested:
collect to a file, then read the file. No pipeline, no `pipefail` interaction, no
subtlety to get right twice.

## ⟲ Previous-session review

Covered above under its own heading — the same conclude-before-looking fault
appeared twice in one day, at two different layers.

**Workflow improvement:** the run-records card handed the owner a ten-second
chore in its owner list, and the correct move was to ask whether the chore had a
path this seat had not looked for. **Before writing anything into an owner list,
check whether the repository already solves it** — `branch-sweep.yml` had carried
the answer since 2026-07-14, complete with a header explaining the exact wall it
was built for. An owner list should be what is genuinely his, not what a session
did not search for.

- **📊 Model:** opus-5 · high · tooling — one workflow, one ledger correction

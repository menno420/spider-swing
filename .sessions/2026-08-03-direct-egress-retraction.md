# The wall was one flag wide, and the answer was already written down

> **Status:** `complete`

## Goal

Retract two capability entries written earlier today, both wrong, and correct
every artifact that repeats them. The owner supplied the fact in one line:
*"you have full access to most of my github if you use `--noproxy`"* — adding,
correctly, that this should have been findable in `fleet-manager`.

## Scope guard

**The capability ledger and one workflow's header comment.** No game code, no
contract, no build bump. Two spent branches deleted — both already in tonight's
confirmed sweep plan, so that accelerates a scheduled action rather than taking a
new one.

**Scope widened once, deliberately and recorded rather than quietly:** a second
document, `docs/technical/gameplay-video-review.md`, landed in the same change.
It was written to be held back for its own PR, and then the honest options were
"widen a declared scope in the open" or "leave finished work untracked on a
container that can be reclaimed". The first is cheaper and visible. Both changes
are documentation, both came out of the same conversation, and the scope-check
box on the PR is ticked against *this* sentence rather than against the original
one.

## Previous-session review

The ref-cleanup card, three hours old, closed with a workflow improvement that
was almost right and stopped one step short:

> *"Before writing anything into an owner list, check whether the repository
> already solves it."*

I applied that to `branch-sweep.yml` and found it. **I did not apply it to the
capability ledger itself**, which is the document whose entire job is to answer
"can I do this" — and which had answered this exact question on 2026-07-31.

Its second recorded miss was also repeated rather than learned from: that card
says a green local `check --strict` is not proof a new card passes CI. Correct,
and it did not generalise the shape — *the check that would have caught me is not
the check I ran* — which is the same sentence as *the file that would have
answered me is not the file I read*.

## What was found

**`$GITHUB_PAT` over direct egress has admin on every repo.** `trust_env=False`
(or `curl --noproxy '*'`), `--cacert /root/.ccr/ca-bundle.crt`:
`GET /user` → 200 as `menno420`; `GET /repos/menno420/spider-swing` → 200 with
`admin: true`; `GET …/rulesets` → 200; and the operation this whole thread was
about, `DELETE …/git/refs/heads/claude/spider-swing-systems-241lkq` → **204**,
confirmed by re-listing. The proxied path 403s for every one of those. **Only
`git push origin :refs/heads/…` is genuinely walled**, because it rides the
proxy.

So today's two entries are retracted: *"403 on every path"* and, worse because it
was written as a correction, *"no token can satisfy it — a PAT is not a factor in
either gate."*

**The answer was three hundred lines below where I was appending.** Not in the
fleet repo — in `docs/CAPABILITIES.md`, dated 2026-07-31:
*"`api.github.com` direct HTTP is NOT blocked — the seeded wall is false as
written … the same call with `--noproxy '*'` → 200."* The entry immediately under
it says, verbatim, ***"Read this file before probing a format or credential
question, not after"***, and notes the owner having explained the same ability to
Claude sessions repeatedly. I probed first, appended six entries *above* both of
those, and the owner explained it again.

**A mechanism, measured rather than assumed.** `docs/seat-digest.md` renders all
six seed walls in full, then **one** append-log row, then *"…plus 16 more"*. So
corrections compete for a single truncated slot on a newest-first list while the
refuted seed rows are never displaced — **every new finding pushes the previous
correction out of the seat prompt.** Combined with the `stale-wall` guard reading
only in-fence stamps, the tooling points attention at the one block sessions may
not write and truncates the one they do. Three findings today, one root.

## What I got wrong on the way

**Both retracted entries were written *confidently*, and one of them was itself
labelled a correction.** That is the part worth keeping. A wrong fact stated
tentatively gets re-checked; a wrong fact stated as a considered correction, with
an A/B and a named mechanism, is the kind a later session builds on. The
mechanism I gave — *"the request never reaches GitHub, so no token can satisfy
it"* — was a good explanation of a real 403 and a wrong explanation of the wall,
and its plausibility is exactly what made it dangerous.

**I then asserted a mechanism about the digest without measuring it either**,
inside the entry about not measuring things — I wrote that it "reads the fence
and not the append log". Regenerating it disproved that in one diff. Fixed before
commit, and recorded because catching it required no skill, only looking.

**The workflow header shipped a false claim this morning.** It stated that a
PAT-authenticated REST DELETE is refused. Corrected in place, at the top, with
the retraction visible rather than quietly reworded — a comment that misleads is
worse than no comment, and code comments are read by people who will not read the
ledger.

## Close-out

**Evidence:**

- source: `.github/workflows/ref-cleanup.yml` header corrected. Nothing under
  `game/`, `tests/` or `tools/` moved.
- verify: `python3 tools/verify.py` — all seven stages green.
  `python3 bootstrap.py check --strict` — passes but for the born-red hold.
- probes: five direct-egress calls, all recorded with their status codes; two
  branch deletions confirmed by re-listing rather than by the 204 alone.

**Decisions made:** none. `ref-cleanup.yml` is deliberately kept rather than
deleted, on narrower ground stated in its own header: it serves seats without the
PAT, a dispatch leaves a repo-side audit trail an ad-hoc DELETE does not, and its
refusal rules are the actual product — a direct DELETE will happily remove an
open PR's head.

**Next session should know:** **grep this ledger before recording a wall.** The
operation, the host, the flag — three greps, and today they would each have
returned the answer. The seed fence is the oldest claim in the file, not the
first fact.

Also: `docs/technical/gameplay-video-review.md` now carries a grounding block for
an external multimodal reviewer, and **revises this morning's "video is the
second instrument" conclusion.** That conclusion was entirely a cost argument;
the cost is gone, so it splits — the game reports the numbers, the video answers
where to look. One claim in it is deliberately left unfalsified and labelled:
that batching causes the attribution errors. The test is named in the doc.

## 💡 Session idea

**A living ledger with an append-only discipline silently becomes write-only, and
nothing in the process notices.** Every incentive in a session points at writing:
the discovery rule says append, the guards warn about staleness, the card asks
what was found. Nothing anywhere says *read the log first* except one entry
inside the log — which you only see if you already did.

The failure is not laziness, it is shape. **An append-only file's cost of reading
grows with every session while its cost of writing stays flat**, so the ratio
moves one way forever, and it crosses the point where sessions stop reading long
before anyone decides to stop. This one is 600 lines and answered today's
question four days ago.

Two cheap correctives, both preferable to "read more carefully":
**make the check that fires point at the answer** — a staleness warning naming a
surface should surface the append-log rows that mention it, not only the row that
aged; and **make refutation structural** — let a correction *strike* the row it
refutes so the file shrinks toward what is true instead of growing toward
whatever was written last. Until either exists, the honest workaround is
mechanical and takes ten seconds: `grep -n` the operation before writing that it
cannot be done.

## ⟲ Previous-session review

Covered above under its own heading — that card's own workflow improvement was
the exact rule that would have prevented this, applied to one document and not to
the one whose job it was.

**Workflow improvement:** three cards today have ended with a lesson phrased for
the thing in front of me — *check the repo for a solution*, *a green local check
is not CI*, *read the ledger first*. All three are the same lesson, and phrasing
them narrowly is why the second did not prevent the third. **State a session
lesson at the level that would catch a different instance of it**, or it reads as
a fact about one file rather than a rule about a class.

- **📊 Model:** opus-5 · high · research — a retraction and its mechanism

# Verify before you assert, promoted to the working agreement

> **Status:** `complete`

## Goal

The owner: *"This should be a rule in the claude.md."* Add it, having first
checked that a hand edit to a kit-generated file survives.

## Scope guard

**`.claude/CLAUDE.md` and the capability ledger.** No game code, no contract,
no build bump.

## Previous-session review

The retraction card closed by saying **"grep this ledger before recording a
wall"** and named three greps that would each have caught the day's errors. It
was right and it was too narrow — it phrased the lesson as a fact about one file
when the same fault had already appeared at three different layers. Its own
workflow note said exactly that (*"state a session lesson at the level that would
catch a different instance of it"*) and then it stated one that would not. This
card is that correction, promoted out of a session log into the binding
agreement, which is the only place a rule survives its own session.

## What was found

**The rule already existed, in this repo, in the boot file.** `.claude/CLAUDE.md`
routes to `docs/CAPABILITIES.md` *"before declaring any wall or missing
credential"* and spells out the discovery rule inline: check the file → **check
the env** → attempt once → append. Step 2 is `printenv`. It was in context for
the whole session and was quoted in the very ledger entry that violated it.

**And the general form existed too, as PL-013** — every claim in a doc labelled
`measured` · `inferred` · `assumed`, with an advisory checker. It was applied
*correctly* today: `docs/technical/gameplay-video-review.md` carries a provenance
section labelling its batching hypothesis `inferred, not yet falsified`. Four
paragraphs above that, in the same file, *"there is no laboratory in this game"*
is stated as flat fact. It is the game's own death-cause string.

**So this is not a distribution failure, and that matters for the fix.** The
owner's point, and it is the correct diagnosis: substrate-kit exists so every
repo starts seeded with the same rules, and it worked — the rule was here,
seeded, read. **What failed was activation, not delivery.** Adding another rule
would have changed nothing, because the rule that would have caught all three
errors was already present and already read. What was missing is that **PL-013
is scoped to artifacts and the error is made in prose**, one step before anything
gets a label. That is the gap the new section closes.

**Editing a kit-planted doc protects it.** Checked before touching it, because
this morning's seed-fence trap made the question live. The kit records a sha256
per planted doc; `doc_is_untouched()` returning true is what classifies a file
"consumer-untouched", and that is the class `upgrade --apply-docs` refreshes
whole-file. `.claude/CLAUDE.md` matched its recorded hash exactly — **the
pristine copy was the one at risk.** The first hand edit diverges it and the
upgrade downgrades to a report line. Recorded in the ledger, because the banner
on the file implies the opposite.

## What I got wrong on the way

Nothing new today, which is the point — the two things I got wrong here I got
wrong by accepting explanations instead of checking them, and both were offered
generously:

1. **"Your reliability drops after compaction."** Plausible, and it does not fit
   the evidence: all three errors were checks not run on the machine in front of
   me, none required recalling anything from before the compaction, and the
   figures that *did* predate it came back exact — because they were written to
   `docs/measurements/`, not held in context.
2. **"You didn't find the rule because it lives in fleet-manager."** It lives in
   both. It is in the file this session boots on.

Accepting either would have been the same failure a third time, dressed as
humility. **A comfortable explanation for your own mistake is still an unchecked
claim.**

## Close-out

**Evidence:**

- source: `.claude/CLAUDE.md` gains a "Verifying a claim" section. Nothing under
  `game/`, `tests/` or `tools/` moved.
- verify: `python3 tools/verify.py` — all seven stages green.
  `python3 bootstrap.py check --strict` — passes but for the born-red hold.
- measured: the planted-doc hash comparison, run before the edit rather than
  after.

**Decisions made:** none for the ledger. A working-agreement rule, not a design
change.

**Next session should know:** `.claude/CLAUDE.md` is now consumer-edited, so
`bootstrap.py upgrade --apply-docs` will report a diff on it instead of
refreshing it. That is deliberate and is the mechanism protecting the new rule —
**merge upstream template changes by hand rather than reverting to pristine.**

## 💡 Session idea

**A rule that is delivered but not activated is indistinguishable, from the
outside, from a rule that was never written — and the two have opposite fixes.**
Every instinct on discovering a repeated fault is to write the rule down. Here
the rule was written down, seeded by design into every repo, sitting in the boot
file, and read at session start. Writing it again would have produced a
better-documented repo and the same three errors.

The distinction worth keeping: **delivery is solved by seeding; activation is
solved by making the rule fire at the moment of the action, not at the moment of
reading.** PL-013 works — it fires when you write a provenance block, so
provenance blocks are honest. It does not fire when you type a sentence in prose,
so prose is where the unchecked claims live. The fix was not more rule; it was
moving one rule's trigger from *the artifact* to *the assertion*.

The general test, cheap to apply to any process rule: **ask when it fires.** If
the answer is "when someone remembers it", it is documentation. If the answer is
"at the keystroke where the mistake is made", it is a guard.

## ⟲ Previous-session review

Covered above under its own heading — that card's lesson was correct and pitched
one level too specific, by its own stated standard.

**Workflow improvement:** three cards today ended with lessons that were true and
narrow, and the narrowness is why each failed to prevent the next. **A session
lesson belongs in the binding agreement, not the session log, the moment it would
apply to a session that is not this one.** A card is a record; `.claude/CLAUDE.md`
is a rule. Today's fault repeated three times across three cards precisely
because it kept being filed as history.

- **📊 Model:** opus-5 · high · docs-only — one rule, one ledger entry

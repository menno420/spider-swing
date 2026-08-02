# Fold the deep research report into the doctrine, and let it correct one thing

> **Status:** `complete`

## Close-out

**Evidence:**

- docs: new `docs/game-design/difficulty-research-2026-08-02.md` — the report
  written up in English with its own evidence grades preserved, a provenance
  block, and an explicit *"what this does not license"* section. Three inline
  amendments in the doctrine (§4, R12, R13), an O3 status change, an F3-section
  corroboration note, plus `README.md` and `current-state.md`.
- verify: `python3 bootstrap.py check --strict` passes; 0 broken relative links
  across `docs/`; boot budget 5 168/7 000. **No source file changed**, so the
  engine suite is untouched at 211 — this PR cannot move it.
- decisions: **none.** Nothing here is decided. The report proposes; the owner
  is mid-analysis.

**The one thing it genuinely corrects, and it is the model.** The doctrine's §4
says a region declares an **axis budget** and that every region spends the *same
total* on different axes. The report's objection is that pressure is very
unlikely to be additive — `pressure ≠ density + narrowness + timing +
unpredictability` — because a point of narrowing is mild at low speed on a known
pattern and severe when it lands with a new required verb, a vertical reversal
and short telegraphing. It searched for a validated conserved difficulty budget
and **found none**. The replacement costs nothing we were not already building:
the scalar becomes an **admission envelope** with per-axis caps, slope limits,
cooldowns and a few explicitly forbidden combinations. Requirement 5 survives as
*"equal envelopes, different profiles"*.

**The best result is the convergence, not the correction.** O3 asked what the
spacing floor T is. The doctrine had derived that **T is a function of local
predictability** — a known route is executed, an unknown one is read. The report
reaches the identical coupling from reaction-time literature, having never seen
that derivation. Two instruments, one conclusion, so O3's *structure* is now
confirmed and only its constants remain device-only. It also bounds them: 0.60 s
for pre-learned telegraphed beats, **0.8–1.0 s for an unknown opposite-side
choice**, 1.2–1.4 s where swing correction is also needed — against our weave's
measured 0.60 s and our 1.37 s chunk, which the report calls substantial room.

**What was refused.** The report reads, on a fast skim, as though its "local
waves must not lower the difficulty floor" contradicts our 100–150 m section
gate. It would have been easy to record that as a contradiction and let the
owner arbitrate. It is not one: the same report *also* prescribes a
seed-independent teach–test–twist sequence at every region start, and both hold
together **only if the gate is an axis-local reset rather than a global drop**.
Writing "these conflict" would have handed the owner a fake fork.

**Also refused:** every tempting number. Nothing in this PR changes a physics,
course, bird or upgrade value, and § 5 of the new document says so in five
numbered lines — because a confident external report with real citations is the
easiest thing in this repository to over-apply.

**Next session should know:** § 3 of the new document is a **specification for
Phase 0**, not background. It says to report hazard — deaths divided by the runs
that *actually reached* the point, never raw death counts — to separate first
exposure from later exposure because pattern learning otherwise simulates a
difficulty improvement, and it lists the exact per-chunk fields to log. That is
the next batch, and it is measurement-only.

## 💡 Session idea

**The blinded-variant protocol is the most actionable idea in the report and it
needs tooling we do not have.** With one expert tester the death-distance curve
is biased by memorisation and continuous skill growth — but the owner can still
give unbiased *relative* verdicts if tooling presents two profile variants under
**neutral seed codes**, in **randomised order**, revealing which was which only
after he has recorded successes, near-misses and readability.

Test Run already stages arbitrary distance, upgrade levels and A/B/C comparison
slots. What is missing is the blinding: a mode that hides which slot is active
and records the verdict against the hidden label. That is a small, contained
front-end change, and it would convert the owner from a biased absolute
instrument into an unbiased relative one — which is exactly what tuning needs.

## ⟲ Previous-session review

The previous session (the doc trim, #130) found that "the bot cannot pump" had
been quoted as live fact in seven documents for a day, and wrote a session idea
proposing a `tools/check_doc_facts.py`. This session then created **another**
document making claims that will age the same way — the report's numbers are
external, and its "0.8–1.0 s" will be superseded the moment the owner measures
his own reaction window on device.

**Workflow improvement:** the mitigation was applied rather than deferred — every
external claim in the new document carries its evidence grade inline, the
provenance block says the citations do not resolve from this repository, and § 5
lists what the document may not be used for. **A document that states its own
expiry conditions is the cheap version of the checker**, and it can be written
the same day rather than waiting for tooling.

- **📊 Model:** opus-5 · high · research — external evidence integration

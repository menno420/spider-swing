# Write down the measurement trap, where the next session will actually hit it

> **Status:** `complete`

## Close-out

**Evidence:**

- docs: `docs/technical/testing.md` gains a *"Measuring GUI geometry headlessly
  — the trap that has already fired"* section, beside the suite map that names
  `mobile_hud_layout_tests.gd` and `front_end_flow_tests.gd`.
- verify: `python3 tools/verify.py --require-godot` — **PASS, 220/220** against
  the pinned `4.7.1.stable.official.a13da4feb`. `bootstrap.py check --strict`
  passes. **No source and no contract changed** — the suite was run to prove
  that.
- build: not bumped. Nothing player-visible changed.

**Why this and not the code it proposed.** The previous card's session idea was
a shared helper that renders a screen, settles frames, and asserts the root is
not larger than the viewport before returning a measurement. That would be
**infrastructure with no caller** — the same shape as the dead `difficulty`
label F1 describes, and the same shape as `verb_for_level`, which this run found
had no consumers at all. The failure it guards against happened in an *ad-hoc
measurement script*, not in the suite, so a helper the suite cannot use would sit
unexercised until someone remembered it existed.

What actually catches the next occurrence is the rule being written where a
session looks before measuring a screen. This run has now twice found that a
document stating its own trap is the cheap version of the checker, and the cheap
version can be written the same day.

**The two rules, and the second is the useful one.** Settle frames before
reading — standard. But the durable tell is that the unshown panel reported
**1 723 px of height inside a 720 px viewport**. A child taller than its viewport
is a contradiction no real layout produces, and it sat in the raw number the
whole time without anyone checking it against the one bound that must hold.

The section also records the constraint that made a contract impossible here: a
suite's `run()` is synchronous and cannot await frames, so rendered measurements
belong in a `tools/` probe or a dated measurement document, while a contract
pins the *wiring* — autowrap on, horizontal expand set, a minimum height rather
than a maximum, a real scroller for overflow.

**Decisions made:** none.

**Next session should know:** **there is no unblocked work left in the queue.**
All five PRs from this run are merged and `main` is green at 220/220. The three
remaining menu-audit items are, by that audit's own § 4, *"a real product choice,
not a contained technical one"* — the contrast one explicitly *"the owner's call
whether the slate look or the contrast floor wins"*. Per-region endless stays
blocked: doctrine § 9 says it needs `pressure(d)`, which is Phase 2, and Phase 1
is Menno signing off on a doctrine he is still analysing. **Do not start any of
them without him.**

## 💡 Session idea

**A measured claim is only as good as the state the instrument was pointed at,
and provenance records the method but not the setup.** PL-013 makes every number
carry `measured` / `inferred` / `assumed` plus its method and resolution. The
Field Guide figure had all of that and was still wrong, because the method was
right and the *subject* was not — a screen nobody had shown.

The gap is one field. A measurement of a live surface should record the **state
it was captured in** as tightly as it records the instrument: which screen, was
it displayed, how many frames settled, which spider was selected. The
course-audit baseline does this by accident, because a generator walk has no
hidden state to get wrong. A GUI or run measurement has plenty. Worth adding to
the PL-013 convention as *"state the setup, not just the method"* the next time
that convention is touched.

## ⟲ Previous-session review

The previous session withdrew the Field Guide finding and proposed the helper
above. The withdrawal was right and the proposal was the wrong size — it would
have added an uncalled abstraction to guard a mistake that a paragraph prevents.

**Workflow improvement:** a session idea is a *proposal*, and the session that
picks it up should re-price it rather than implement it on sight. Two of this
run's ideas were worth building (`tools/course_audit.gd` had immediate callers
and found six things); this one was worth writing down instead. **Ask what will
call it before building it** — if the answer is "a future session that remembers
this exists", write the sentence, not the code.

- **📊 Model:** opus-5 · high · docs-only — headless layout trap recorded

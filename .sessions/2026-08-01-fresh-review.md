# Fresh-eye review of the simulator/search/replay series

> **Status:** `complete`

## Goal

The owner switched the session's model and asked for a thorough fresh-look
review of everything built today — explicitly to see whether a different model
and effort level finds anything the previous pass missed. So: treat the
session's own output as someone else's work, re-test the headline claims
empirically instead of re-reading them, and hunt for holes.

## Scope guard

Review findings plus the small fixes they license. No physics values, no zone
content, no tuning. One latent replay bug fixed; no behaviour of the game
itself changes.

## Previous-session review

**previous-session review:** four slices landed today — owner-play calibration
(#84), bot model v3 (#85), the policy search (#88), and the replay review loop
(#89, in flight). Each carries its own verification. This card is the
adversarial pass over all of them.

## What survived review — tested, not re-read

**The +138% search gain is real, and was an *underestimate*.** The reported
number was the best of ~192 noisy evaluations with no held-out re-test —
textbook winner's-curse conditions, and the review's top suspicion. Re-run on
**completely unseen bot seeds and unseen course seeds** (seed 4242, courses
9000–9007, 40 runs):

| | defaults | search optimum |
| --- | ---: | ---: |
| Mean travelled | 766.0 m | **1 978.1 m** (+158%) |
| Deaths per km | 2.61 | **1.01** |
| Taps per second | 4.91 | 3.50 |
| Dives per web | 0.66 | 0.99 |

The gain generalises across both seed axes. Selection-on-noise was the right
thing to test and the wrong thing to fear.

**The replay loop's determinism holds** — both bundled traces reproduce to
three decimals, and the 1-metre session contract passes on the current tree.
PR #87 (zones 3–4 art) merged under the open #89 and was checked for geometry
impact: presentation-only, so the committed trace is unaffected.

## What did not survive review

1. **A latent replay bug: traces that end at the batch cap did not
   reproduce.** Every trace verified before today ended in a death. A trace
   captured from a run that ended at `--max-seconds` (cause `timeout`)
   diverged on `--replay`, because the verifier replayed under a hardcoded
   600 s cap — the run kept going, inputless, past its own recording. Found by
   probing the `--skill=all` fix below; fixed by recording `max_seconds` in
   the trace setup and replaying under the same wall. Old traces fall back to
   600 s, which death-ended traces never reach. Verified both ways: a
   timeout-ended probe now reproduces exactly, and both committed traces still
   pass through the fallback path.
2. **`--trace-top` with `--skill=all` or `--spider=all` wrote unverifiable
   traces.** Setup recorded the literal option strings ("all"), not the row's
   actual tier and spider, so such a trace could neither be verified nor
   replayed. Now records per-row values; probed before and after.
3. **"No anomaly flags" was threshold-fragile and the narrative leaned on
   it.** The optimum's Burst use is **2.450×** the default against a flag
   threshold of 2.5 — the headline silence survived by 2%. `fit_bot.py` now
   reports near-misses (≥80% of a threshold) so a silence that fragile is
   visible in the artifact rather than discovered by a reviewer.
4. **The trace format constant was defined twice** while
   `replay-review-loop.md` claimed a single definition — and the doc even
   said "bump it in both places", contradicting its own headline sentence.
   `tools/simulate.gd` now references `TraceCatalog.INPUT_TRACE_FORMAT`; one
   definition exists, in domain, and the doc says what is true.
5. **The trace-stepping contract was vacuous.** With one bundled trace, the
   "+1 then −1 returns to start" assertion is satisfied by a picker that
   never moves. A second verified trace (2 969 m) is now bundled and the
   contract requires stepping to actually change the selection — falsified by
   making `select_debug_trace` a no-op: red, then green on restore.
6. **The four new lab flags were missing from `simulate.gd`'s own usage
   header.** `--bot`, `--trace-top`, `--trace-dir`, `--replay` are now
   documented where every other option is.

## Noted, deliberately not changed

- **`TraceCatalog` is the only domain file doing engine IO** (FileAccess /
  DirAccess / JSON). The architecture checker enforces layer *references* and
  passes, but the stated principle is "domain contains engine-independent
  value objects". A cleaner home is application (its two consumers are
  application and a tool script). Recorded as a smell; moving a class across
  layers deserves its own slice, not a review side-effect.
- **"Past the owner's best recorded 3 535 m" over-reads a lower bound.** Every
  owner recording ended while the run was still alive, so his true best is
  unknown and larger. The search's 4 295 m shows such runs are reachable; it
  does not show the bot out-ran him.
- **Reported knob vs effective value:** `decision_period_ticks: 5.83` in the
  search artifact rounds to 6 in effect. Cosmetic, but a reader diffing knobs
  against behaviour should know the tick knobs quantise.
- The front-end re-reads all trace files on every `changed` emit. Two small
  files today; worth a cache only if the list grows.

## Verification

`python3 tools/verify.py --require-godot` → **exit 0**, 176 contracts.
`python3 bootstrap.py check --strict` → exit 0, findings read in full.

Replay checks, each run and read: both committed traces REPRODUCE; the
regenerated timeout-ended probe REPRODUCES under its recorded cap; the
strengthened stepping contract reddens on a no-op picker and restores green.

## Owner questions

None new. OQ-9 and OQ-10 remain open.

## 💡 Idea

The review's biggest suspicion — winner's curse on the +138% — was reasonable,
testable, and wrong, and the test that disproved it made the original claim
*stronger* than its author left it. Meanwhile the real defect was somewhere no
suspicion pointed: a cap nobody recorded because every example at hand happened
to die before reaching it. Generalisable: **review effort spent confirming a
plausible doubt is capped at restoring confidence; effort spent probing inputs
the tests never saw can find new truth.** Probe the input space, not the
narrative.

## Next slice

Unchanged from the replay-loop card: **per-upgrade fingerprints** — run the
search at L0/L10/L20, diff how each optimum *plays*, bundle each best run as a
trace so the differences can be watched. The held-out protocol from this
review (fresh bot seeds AND fresh course seeds) should become the standard
final step of every search before its number is quoted.
- **📊 Model:** fable-5 · high · review/verify — fresh-eye audit of today's series

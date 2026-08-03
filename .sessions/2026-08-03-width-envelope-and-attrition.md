# Corridor width becomes a distribution, and the first play data lands

> **Status:** `complete`

## Goal

Turn a long owner conversation into records before it evaporates: what a passable
gap actually is, the first death data the repository has ever had, and the Bramble
opening plan. Then **hunt every existing document for claims this session
contradicts**, on the owner's instruction that this session leads and older
entries are stale where they disagree.

## Scope guard

Docs, the decision ledger, and two comments. **No code, no contract, no generator
change, no build bump.** The `leaderboards_eligible` flag and the "Standard alone"
contract are deliberately left enforcing the shipped rule — they change in the
slice that builds the boards.

## Previous-session review

**previous-session review:** the pressure-curve slice pinned a course digest so
behaviour could not move unnoticed. That paid off here in an unexpected way — with
behaviour provably frozen, every measurement taken this session is directly
comparable to the baseline, so three contradictions surfaced as arithmetic rather
than as argument.

## What was decided

**[D-0056] — width is a distribution with two classes, not a floor.** A floor
alone is worse than useless: written as "the minimum is X", a scheduler may drive
every chunk to X and pass. The four terms come from Ancient Forest, which the
owner has played and endorsed — **minimum 7.39 diameters, median ≈ 12.3, ~6% of
chunks near the minimum, never two in a row.** Swing obstacles (`lane`
`high`/`low`/`weave`) may never go below 7.39; threading gates (`lane = centre`)
may, **as their constriction shortens toward one spider width**, because a narrow
gap costs width × length. Absolute backstop 3.0 diameters — R8's constant K, at
last supplied.

## Three claims that did not survive measurement

Each had been reasoned from. Each is corrected in place rather than deleted.

1. **The doctrine's § 2.2 corridor table is not reproducible.** Re-run on its own
   seed: Silk Hollow's tightest is **244.5 px, not 93**. Likely cause is the
   contact-inset decision that landed the same day and shrank every lethal
   polygon. **Consequence: the 10 km wall is a timing wall, not a width wall** —
   spacing collapses 4.2× while the corridor barely moves.
2. **N1's "tightest content in the game" is a spacing finding, not a width one.**
   `hollow_spindle_gate` has a 7.85-diameter corridor and an **8 ms**
   constriction — the most generous tight pattern in Silk Hollow. R13 was framed
   against it as though it were a width claim.
3. **Bramble's open recovery chunks are not what made it passable.** The owner's
   own `0.22.0` recording shows the disease was two almost-touching walls *inside*
   a pattern. The geometry fix succeeded alone: Bramble now has the **widest
   minimum corridor in the game**. The 50% cadence is guarding a failure two other
   things already prevent, so it can be spent on variety.

**All three are the same error: a rule built against a number that measured a
different quantity.** That is now three instances — the weave in O3, § 2.2's
93 px, and N1. **Guard recipe:** before building a rule on a measured figure,
check which *quantity* it measures — spacing, corridor width, or obstacle extent
— because all three are reported in pixels and none is interchangeable. Anchors:
`corridor_width_across` versus `classify_pairs` in `tools/course_audit_probe.gd`.

## The first play data in the repository

35 recorded attempts and one success, one sitting. **Hazard peaks at
2 000–2 500 m at 41%, double the surrounding bands** — landing independently on
the cliff R3 was written to forbid from geometry alone. Only 17% of attempts
reached 5 km.

**It is not a content difficulty**, and the document says so: the owner rushed the
first 2 km, reeling to skip it, and arrived at the cliff at the speed cap and
inattentive. The number is content × player state, and the player state was
manufactured by the preceding two kilometres being dull. Tuning obstacles at
2–2.5 km would treat a symptom whose cause is a kilometre upstream.

## Verification — run, not claimed

- **`python3 tools/verify.py --require-godot` — PASS** on the pinned
  `4.7.1.stable.official.a13da4feb`; `bootstrap.py check --strict` exit 0.
- **The stamp guard caught two citation collisions** I had introduced (D-0052 and
  D-0056 each cited from three docs) and both were resolved to one home. Worth
  recording as a case where the kit's own gate did the review.
- Every figure in the new documents was measured this session with
  `course_audit_probe.gd`, most at 2 px horizontal resolution rather than the
  default 24 px — which itself revealed that the default **overestimates the
  minimum by ~1.5%**, always optimistically.

## Owner questions

None new. Both arguable defaults inside [D-0056] — that Harsh spends on timing
rather than width, and the 2/3/4 continuation counts — were already recorded as
vetoable in the previous entry. The one genuinely open item is device-only and
named in Phase 4: **how small an obstacle can be drawn before it looks wrong.**

## 💡 Idea

**Numbers in this repository need a unit that names the quantity, not just the
scale.** Three separate rules have now been built against a figure in pixels that
measured something other than what the rule assumed — spacing read as width, width
read as spacing. Every one looked correct and none was catchable by review,
because "180 px" and "266 px" are indistinguishable as text. A convention as
cheap as suffixing the quantity in the reported field names — `gap_px` versus
`spacing_px` versus `extent_px` — would have made all three visible at the point
of use. The probe already separates them internally; only the prose collapses
them. Deduped: no existing guard covers it. Worth proposing if a fourth appears.

## Next slice

**Two instrument measurements, then the fix.** Constriction length within a chunk
and consecutive chunks near the minimum are both width × duration terms and
**nothing watches either** — an obstacle could become a 400 px tube at an
unchanged minimum and the suite would stay green. They land first, pinning the
measurement rather than the difficulty, as Phase 0 did. Then
`hollow_lattice_high` and `hollow_lattice_low` are widened with the enforcing
contract in the same commit, because an enforcing contract added today would fail
on `main` — the shipped game genuinely violates the rule.

- **📊 Model:** opus-5 · high · docs-only

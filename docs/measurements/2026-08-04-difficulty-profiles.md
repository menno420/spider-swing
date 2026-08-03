# Difficulty-profile structure — 2026-08-04

> **Status:** `audit`
>
> **Scope:** deterministic course structure from 0–15 km. This document is not
> a survival result and does not claim that any mode feels correctly tuned.

## Question

Does the difficulty-profile implementation make Relaxed and Harsh structurally
different derivatives of Standard's pressure envelope while preserving
Standard exactly and keeping the width/fairness boundaries intact?

## Method

Pinned engine: `4.7.1.stable.official.a13da4feb`.

The audit walked chunks 0–156 for seeds 1000, 1001 and 1002 in each mode:

```sh
godot --headless --path . --script res://tools/course_audit.gd -- \
  --mode=relaxed --to-metres=15000 --seeds=3 --seed-base=1000 --quiet \
  --json=/tmp/course-relaxed.json
godot --headless --path . --script res://tools/course_audit.gd -- \
  --mode=standard --to-metres=15000 --seeds=3 --seed-base=1000 --quiet \
  --json=/tmp/course-standard.json
godot --headless --path . --script res://tools/course_audit.gd -- \
  --mode=harsh --to-metres=15000 --seeds=3 --seed-base=1000 --quiet \
  --json=/tmp/course-harsh.json
```

Warm-up chunks, which carry no scheduled pattern, are excluded from density.
Reaction spacing is the audit's edge-to-edge gap between sequential
opposite-side commitments, divided by the speed cap at that distance. Gates
whose obstacles overlap in X remain width challenges and are not timed.

## Inputs — `assumed`

These are product defaults pending device review, not empirical truths:

| axis | Relaxed | Standard | Harsh |
| --- | ---: | ---: | ---: |
| legal continuations | 2 | 3 | 4 |
| reaction-spacing scale | 1.25× | 1.00× | 0.90× |
| recovery-interval delta | −1 | identity | +1 |
| repetition memory | 1 chunk | 2 chunks | 3 chunks |
| admission-pressure transform | 0.82p | p | 1.10p + 0.035 |

The transforms compose with `CoursePressure`; none introduces another distance
curve. Standard's row is the identity path.

## Output — `measured`

Across 453 scheduled chunks per mode:

| axis | Relaxed | Standard | Harsh |
| --- | ---: | ---: | ---: |
| challenge chunks | 300 | 342 | 357 |
| recovery chunks | 153 | 111 | 96 |
| challenge density | 66.23% | 75.50% | 78.81% |
| longest challenge run, per-seed maximum | 4 | 6 | 6 |
| mean authored label on challenges | 3.627 | 3.675 | 3.745 |
| timed opposite pairs | 64 | 58 | 65 |
| mean edge reaction gap at speed cap | 0.339 s | 0.294 s | 0.216 s |
| minimum edge reaction gap at speed cap | 0.085 s | 0.073 s | 0.019 s |
| swing-class minimum corridor | 7.75 d | 7.75 d | 7.57 d |
| absolute minimum corridor | 7.25 d | 7.39 d | 7.57 d |

`d` is player diameter. Every swing-class minimum remains above the 7.39 d
class floor (within the contract's 0.005 tolerance), and every absolute minimum
remains far above the 3.0 d fairness backstop. Relaxed's relative near-minimum
run reaches four chunks in Bramble, but that mode's absolute minimum there is
9.66 d; the profile contract pins four as the maximum rather than mislabelling
the wider distribution as a Standard-width failure.

Course digests over patterns plus polygons, chunks 0–156 and all three seeds:

| mode | digest |
| --- | --- |
| Relaxed | `782cd3e34c96585ef848e9eed63cfa8f3ab1b1f0713a4654bdb8446af6c3ee59` |
| Standard | `497b6bc658e49ea280aed0cb17c3b41aef62a669bfe41b5b62352c6a89e79311` |
| Harsh | `2a48dd0db5e5357d4ab8bc42772d78a5dfc505372b53df8cad8c368d027d219e` |

All three diverge. Repeating an audit with the same mode, seed and range returns
the same digest.

## Standard preservation — `measured`

The pre-change and post-change Standard audit over seeds 1000–1001 is exactly:

`087252417d164e4d2521b917084c63a39fb9f5d100e7826001a5241dcf75704b`

The extracted pattern sequence also stayed byte-identical before and after
(`d79f1db019e8f4d885f433bcaa10116bfdcd8f0ef836a73e6126025d734b71d7`).
The suite additionally owns a canonical sequence-only digest
(`c40f126d894dc7739fd1af1325066a0e84a7a78990724cc95b6b41c696d110f4`)
so later geometry and selection changes cannot mask one another.

## Interpretation — `inferred`

- Relaxed is structurally more legible and supplies more time: fewer legal
  continuations, lower challenge density, more recovery, shorter challenge runs
  and wider measured sequential gaps than Standard.
- Harsh spends its extra structural difficulty on more legal continuations,
  denser challenge cadence, fewer recovery pockets, higher admitted rungs and
  tighter measured gaps. Its former corridor-width tightening overrides are
  absent; width is not its main lever.
- Standard is a reference, not a midpoint reconstructed from the other modes.
  Its override set and profile transforms are identities, and the unchanged
  digest proves the implementation did not retune it incidentally.

Those statements describe generated structure only. They do **not** prove that
Relaxed feels easy enough, that Harsh feels fair, or that the assumed 1.25× and
0.90× spacing factors are correct for the owner's hands and phone.

## Device questions

Use the same seed/start band for Relaxed, Standard and Harsh, preferably first
at 5–10 km and then at 10–15 km:

1. Can the player predict Relaxed's next route earlier without it becoming
   monotonous?
2. Does Standard feel identical to build `0.41.0-tutorial-practice`?
3. Does Harsh read as denser and less predictable before it reads as noisy?
4. Are Relaxed's extra reaction time and Harsh's tighter timing noticeable,
   and does either spacing factor need to move?
5. Does Harsh retain enough corridor room that deaths read as timing/choice
   failures rather than width traps?

Only that device comparison can provide the feel verdict.

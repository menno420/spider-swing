# Every measurement now carries its instrument — and the checker that enforces it was wrong first

> **Status:** `complete`

## Goal

Adopt the claim-provenance convention the owner asked for, and put it in
substrate-kit so it outlives this repo. His framing was a test of the kit:
*"you should be able to determine the correct place to add it, if not then the
substrate kit itself is failing."*

## Scope guard

Documentation only in this repo. No physics values, no zone ids, no code.
The kit half is a separate repository and a separate PR (substrate-kit #565).

## Previous-session review

**previous-session review:** the recovery-gap measurement landed and correctly
superseded its own earlier "route choice" diagnosis. What it did well and this
session copied: it measured the thing directly instead of arguing from the
symptom. What it did not do — and this session is the fix — is mark *which* of
its sentences were measurements and which were inferences. That is exactly the
distinction the owner has been correcting all day, roughly fourteen times.

## Where the rule belongs (the owner's actual question)

The kit answered it, and the answer was more constraining than "write it down":

- `provenance` is **already a required field** in the `[PL-NNN]` ledger grammar,
  and **PL-008** already demands a provenance header on every adopted tool. The
  doctrine existed; measurement *output* simply was not covered.
- **PL-007 — "enforce, don't exhort"** — decided the shape. It puts written
  rules *last*, behind checker / CI / test. A prose-only convention would have
  violated the kit's own law. So it ships as **`[PL-013]` plus an advisory
  checker**, not a paragraph asking future sessions to remember.
- **PL-006 — "source wins"** — supplied the argument. A number with **no stated
  instrument has no source to lose to**: nothing can ever show it wrong.

So the kit routed it correctly, and did so in a way that changed the deliverable.

## What the retrofit says

Seven measurement documents now carry a labelled provenance statement. The
marks are not uniform, and the non-uniformity is the useful part:

- **`2026-08-01-owner-play-calibration.md`** — a per-instrument table with the
  **rate** of each: HUD text at 1–10 fps, taps at 60 fps, reel ring at 30 fps.
  The 73% reel minimum is now stated as an *upper bound on the true minimum*,
  because 30 fps against a 60 fps source leaves half the frames unread.
- **`2026-08-01-upgrade-audit.md`** — every number in it is exact, and the
  conclusions stay retracted. *A null result needs its instrument stated at
  least as loudly as a positive one*: "we measured no effect" and "our
  instrument cannot register this effect" produce identical tables.
- **The acceptance targets** — two rows are now honestly not measurements.
  ">5 000 m at max upgrades" is the owner's recall with no recording behind it,
  and "upgrades must improve the result" is an **assumption**, a design intent
  this project would act on even if a measurement disagreed.

## The checker was wrong, and only the real corpus caught it

This is the part worth reading.

The first checker tested for the **vocabulary alone** — does `measured`,
`inferred` or `assumed` appear anywhere. It passed 23 tests, survived three
mutants, and worked end-to-end through the built dist. Then it was run against
**these seven documents**, the ones the rule was extracted from, and fired on
**zero of seven**. Every one already used "measured" in ordinary prose — *"the
exploit is now measured"*, *"measured per track in isolation"*. Bolding failed
too: two of the seven carry bolded incidental uses.

Requiring a **labelled** statement (the literal word "provenance") *and* the
vocabulary measures **7/7 before the retrofit, 0/7 after**.

**A rule about stating your instrument was nearly shipped on an unmeasured
claim about its own checker.** "The checker guards this class" went into a PR
body and a session card before it had been run against real data, and it was
false. Recorded in PL-013's `form` field rather than quietly fixed.

## Verification

`python3 tools/verify.py --require-godot` → exit 0, **181 contracts**.
`python3 bootstrap.py check --strict` → exit 0.
Documentation only; `sha256sum -c bootstrap.py.sha256` → OK, pin untouched.

**Falsified against both states of this repo's own docs** using the kit's built
dist: 7 findings before the retrofit, 0 after.

## The vendored kit is deliberately not bumped

`bootstrap.py` here is pinned to **release tag v1.20.2** with a committed
checksum, and the provenance doc says explicitly that it was taken from release
assets — *"not copied from `main`"*. Dropping the rebuilt dist in would have
broken that contract for a convenience. The checker arrives with the next kit
release; the convention does not wait for it.

## Owner questions

None new. **OQ-12** (which anti-hauling mechanic to adopt) remains the live one.

## 💡 Idea

**The corpus is the test, and I keep learning it late.** Every error today had
the same shape: a claim that was internally consistent and never checked against
the thing it described. The tap rate was consistent at 30 fps. `dives_per_attach`
was consistent without its denominator. The provenance checker was consistent
across 23 tests. In all three cases the check that would have caught it was
cheap and available — the owner's word "verifiable but didn't verify" is exact.

The generalisable move: **when building a checker for a known failure class, run
it against the known failures before writing anything about what it catches.**
Not the synthetic fixtures — the actual documents. That should probably be a
kit ruling of its own; deduped against `docs/ideas/` here, but the right home is
substrate-kit's rulings ledger, so it is parked rather than filed.

## Next slice

Unchanged and owner-gated: **OQ-12**. The no-drive world is measured and the
regression test for it exists (arc-per-web on every batch), so whichever
mechanic he picks can be tested the hard way — apply it, re-run the search, see
whether hauling still wins.

- **📊 Model:** opus-5 · high · docs-only — provenance retrofit + kit rule PL-013

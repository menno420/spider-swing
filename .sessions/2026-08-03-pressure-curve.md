# The difficulty doctrine is approved, and the curve is computed

> **Status:** `complete`

## Goal

Phase 1 and Phase 2 of the difficulty doctrine, in one PR: land a decision-ledger
entry approving the doctrine with three named rulings, then compute
`pressure(d)` and prove the generated course did not move. **Stop before Phase 3**
— the owner wants to see the numbers before behaviour changes.

## Scope guard

No gameplay value changed. No build bump: nothing is player-visible, and the five
pinned build files are untouched. The generator is byte-identical, and that is
not a claim — it is a pinned digest over patterns and polygons, measured at two
commits on this branch. Phase 3, Phase 4 and the region swap were deliberately
not started.

## Previous-session review

**previous-session review:** the Phase 0 instrumentation session put its
measurement in `tools/course_audit_probe.gd` so the CLI and the contracts could
never measure differently. That paid off immediately here — the digest, the
per-chunk pressure column and the contracts all read one probe, so the
before/after proof and the report cannot disagree. The same instinct applied
once more: the digest deliberately reads generator output and **never** a derived
pressure value, because hashing pressure would have made the digest move the
moment the curve landed, destroying the one thing it exists to rule out.

## What landed

**Phase 1 — [D-0054].** The doctrine had sat at `status: plan` for five days with
zero ledger entries, which blocked every later phase behind a decision nobody had
recorded. It is now `binding` for 0–15 km, with three rulings folded into the
document itself:

- **R6 is reworded, not the generator.** Its old wording — "0–500 m carries no
  lethal obstacle" — described a game that has never shipped. The owner's ask was
  that the first 500 m stay as it is, so the rule moved rather than the content.
- **The axis budget became an axis envelope.** Pressure is very unlikely to be
  additive and no validated conserved difficulty budget exists.
- **R13's spacing floor T is a function of local predictability**, not a
  constant.

**Phase 2 — the curve.** `CoursePressure` (`game/domain/course_pressure.gd`):
zero through 500 m, smoothstep over a front-loaded input, 1.0 at the top of the
owner-scoped range, clamped above. **Nothing reads it.**

**The top is a clamp, not a plateau, and the constant is named for that.** O1 is
deferred; the longest verified run is 10 605 m. Clamping and plateauing produce
identical numbers today and mean opposite things, so `SCOPE_TOP_PIXELS` says
*this is where our authority ends* rather than *this is where the game stops
getting harder*.

## The finding worth keeping

The audit now prints pressure beside the axes it will eventually schedule, and
one row states the whole problem:

| region | pressure band | band width | label delivered |
| --- | ---: | ---: | ---: |
| Ancient Forest | 0.000 → 0.412 | 0.412 | 0.00 → **3.48** |
| Bramble Canopy | 0.412 → 0.837 | **0.425** | **2.00, flat** |
| Silk Hollow | 0.837 → 1.000 | 0.163 | 3.20, flat |

**Bramble is handed the widest pressure band in the scoped range and delivers a
flat line across all of it.** That is S4 restated as a number, and it is the
arithmetic behind why the swap cannot land before the curve.

## The contract that was worthless, and how it was caught

**The warm-up contract passed its own falsification.** It derived its sample
distances *from* `WARM_UP_END_PIXELS` — the constant it was checking — so setting
that constant to zero shrank every sample to 0 m, where pressure is legitimately
zero, and a deleted warm-up sailed through green.

It now restates 500 m as a literal and asserts the constant against it, the same
discipline `AUTHORED_WEAVE_SPACING_PX` already uses next door. *"The first 500 m"
is a fact about the game the owner asked for, not a fact about whatever the
constant currently says.*

This is the second time in this repository a contract has been "falsified" with a
failure it could not actually detect. The rule that caught it is worth stating
plainly: **falsify by breaking the thing the contract protects, not by breaking
the contract's own inputs.**

**Guard recipe** for a later session: the pattern to grep for is a test whose
loop bounds, sample spacing or expected value are read from the same constant it
asserts on. Anchors: `_test_warm_up_carries_no_pressure` in
`tests/unit/course_pressure_tests.gd`, and
`_test_probe_reproduces_authored_weave_spacing` in
`tests/unit/course_audit_tests.gd` as the reference shape.

**A second process failure, recorded because it silently corrupted results.** The
first falsification harness reverted with `git checkout -- <file>`, which is a
no-op on an untracked file. `course_pressure.gd` was new, so falsifications F2–F5
accumulated on top of each other and every result after F1 was contaminated.
Re-run with a real backup/restore, with a green baseline before and after.

## Godot is preinstalled now, and the seeded instruction was stale

This session downloaded 211 MB of Godot before running `which godot`. It was
already there: the owner created `scripts/env-setup.sh` earlier the same day, and
it installs `4.7.1.stable.official.a13da4feb` to `/opt/godot/godot` and symlinks
`/usr/local/bin/godot`. `tools/verify.py` finds it from PATH with no
configuration and no environment variable.

The prompt this session inherited said Godot was not preinstalled. **That was
true when it was written and had been overtaken by an hour.** THE DISCOVERY RULE
step 2 — check the environment — would have caught it in one command. Appended to
`docs/CAPABILITIES.md`, superseding the 2026-08-02 entry for this environment.

**Latent, not fired:** that script exports `GODOT_BIN` and the three `XDG_*`
roots only into `~/.bashrc`, which non-interactive agent shells never source.
`verify.py` is unaffected because its lookup ends at `godot` on PATH, but the
script's own comment records headless Godot aborting with exit 134 and no useful
message when the XDG roots are not writable — and that protection is not reaching
the shells that run Godot. It did not bite here because `/root/.cache/godot` and
its siblings exist and are writable as root. **Guard recipe:** the fix is to have
`scripts/env-setup.sh` write the four exports somewhere a non-interactive shell
reads, rather than `~/.bashrc` alone. Left alone deliberately — it is unrelated to
a doctrine PR.

## Verification — run, not claimed

- **`python3 tools/verify.py --require-godot` — PASS**, against the exactly
  pinned `4.7.1.stable.official.a13da4feb`, using the preinstalled engine from
  PATH. `bootstrap.py check --strict` passes.
- **Every new contract falsified with the real failure**, each in isolation, with
  a green baseline before and after: the warm-up deleted; a region lowering the
  curve for a breather; the upper clamp dropped so the curve extrapolates past
  scope; the 1750–2000 m cliff reintroduced; the slope bound raised to fit a
  steeper retune; and the generator starting to read the curve. All six failed as
  intended — the last with exactly the message written for it.
- **Byte-identity proved across two commits.** At `49367d1` (no
  `course_pressure.gd` in the tree) and at the finished branch, the digest over
  patterns and polygons for chunks 0–156 across three seeds is
  `abd839ea…f281d3e7` both times.
- **`tools/course_audit.gd` re-run and diffed against the baseline.** Every axis
  column — label, density, corridor, spacing, gates, novelty — reproduces the
  2026-08-02 table exactly.
- `EXPECTED_CHECK_COUNT` raised to the executed total, in one step, after the
  suite reported it.

## Owner questions

**OQ-17 added** — how fast difficulty should rise over the first 15 km. Exactly
one number in the curve is a judgement call (`ONSET_SHAPE`, defaulting to a
front-loaded 0.70), and it cannot be answered without a build that puts it on a
Test Lab dial. Nothing is blocked meanwhile. The three spacing-floor constants
are parked inside the same entry rather than raised separately, because asking
before content uses them would gather a weak verdict.

The three [D-0054] rulings are **agent defaults recorded for review**; any can be
vetoed on the PR without disturbing the rest.

## 💡 Idea

**A contract that reads the constant it asserts on is a specific, greppable bug
class, and this repository has now shipped two of them.** Both looked correct,
both produced green, and both were found only because someone falsified them
properly. The shape is mechanical: a test whose loop bounds, sample spacing or
expected value come from the same symbol it is checking. That is detectable
without understanding any particular contract — a lint over `tests/` for a
constant appearing in both the assertion and the sampling of the same function
would find them. Deduped: no existing guard covers it, and
`tools/check_no_false_walls.py` is about documentation claims, not test
vacuity. Worth proposing only if a third one appears; two is a pattern, not yet
a budget.

## Next slice

**Phase 3 — move selection onto the curve, Ancient Forest first.** The
before-picture is now pinned, so the diff is meaningful. Expect the digest
contract to fail: that is the deliverable, and re-pinning it in the same commit
is the record that behaviour moved. Targets from the baseline, with recovery
share landing inside (2%, 50%) — 20% is the natural first try, and Silk Hollow
already ships 21%.

- **📊 Model:** opus-5 · high · feature build

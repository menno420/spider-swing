# Restore the speed ceiling and bound the bird beneath it

> **Status:** `complete`

## Close-out

**Evidence:**

- source: `swing_config.gd` (schema 11 → 12; `overspeed_correction_acceleration`,
  `bird_ceiling_share`, `spider_speed_cap_at`, bounded `bird_speed_at`,
  `speed_curve_distance` 50 000 → 100 000 px), `spider_motor.gd` (ceiling branch
  no longer scaled by the drive), `difficulty_catalog.gd` (both new values added
  to `PHYSICS_FIELDS`), `tuning_catalog.gd` (two new Test Lab knobs).
- contracts: two added, one retargeted. **`python3 tools/verify.py
  --require-godot` — PASS, 206/206** against the exactly-pinned
  `4.7.1.stable.official.a13da4feb`. `bootstrap.py check --strict` passes.
- docs: `decisions.md` [D-0048]; `earned-speed-and-the-bird.md` corrected in two
  places.

**Two faults, both found from owner device feedback.**

**1. The speed ceiling had been switched off by accident.**
`SpiderMotor.apply_forces` has always had two branches — a floor pushing a slow
spider up to the reference, and a ceiling pulling a fast one back toward
`reference + maximum_horizontal_overspeed` — and **both were scaled by
`horizontal_drive_acceleration`**. PR #102 zeroed the drive to remove the free
forward push and silently removed the speed limit with it. Afterwards only air
drag acted on overspeed, at ~5.4%/s: proportional, so never a ceiling at all.
The owner felt this directly as speed that "increases to an amount that is
nearly impossible to correct yourself from". The ceiling now has its own
coefficient defaulting to the exact pre-#102 effective value (the old drive of
470 × the branch's own 0.25 = 117.5), so this is a repair rather than a new
tuning claim.

**2. The bird would eventually win by arithmetic.** The owner spotted the
structure before I did: a pursuer rising linearly against a pace curve that
flattens must overtake. With the shipped values it passed the spider's ceiling
at roughly **68 km** and reached 150 m/s against a 112 m/s cap by 100 km. It is
now hard-bounded at a share of the spider's own ceiling. **The bound is
expressed as a share rather than an absolute** so the invariant survives any
future retune of either curve instead of resting on a coincidence between two
independently authored constants, and a contract sweeps to 200 km on every
preset plus a deliberately absurd pursuer configuration.

**Purpose correction, from the owner.** The bird is an **anti-degeneracy
enforcer, not the difficulty ramp** — it exists to make dangling and
ceiling-hauling non-viable and must never end a well-swung run. That supersedes
the earned-speed spec's "the ramp moves into the bird", which is now annotated.

**Measured after the change:** permanent headroom of **+42 to +70 m/s** at every
distance; bot distance and death rate essentially unchanged (1 931 → 1 936 m,
1.04 → 1.03 deaths/km); arc per web 43.7°, so the hauling exploit stays dead
(its fingerprint was 21.4°).

**Decisions made:** [D-0048], owner-directed. This changes the approved
`balanced_baseline`, which no session should do on its own initiative — it was
explicitly requested, and every new value is `assumed` and exposed on the Test
Lab for his verdict.

**Next session should know:** all three values await a device verdict —
`overspeed_pullback` (117.5), `bird_ceiling_share` (0.62), and the 10 km curve.
The owner said he will test extensively. Note `speed_curve_distance` also feeds
the rescue grant, so the mid-run rescue is now slower than before at the same
distance; that is a side effect worth watching for on device rather than a
deliberate choice.

## 💡 Session idea

**The bug class here is worth naming, because it will happen again.** Both
faults were *one constant serving two purposes that later diverged*:
`horizontal_drive_acceleration` was simultaneously "how hard we push a slow
spider" and "how hard we brake a fast one", so a decision about the first
silently settled the second. The bird's linear law and the spider's flattening
curve were two constants that had to stay ordered and nothing enforced the
ordering.

The general fix is the one used here: **when an invariant matters, express it
relationally rather than numerically.** `bird_ceiling_share` cannot break the
ordering no matter how either curve is retuned, because it is defined in terms
of the thing it must stay below. A sweep contract over a range far past the
authored content then makes the guarantee visible. Worth auditing the remaining
config for the same shape — any two constants whose *relative* order is
load-bearing but only *absolutely* specified. `maximum_target_speed` versus the
release award cap looks like the next candidate.

## ⟲ Previous-session review

The previous session's own idea — that the speed-for-deaths trade was worth
testing rather than arguing about — is what made this session quick. The bot
work had already established that more speed at fixed reading ability costs more
than it buys, so when the owner described uncorrectable speed the mechanism was
already half-identified and only needed locating in source.

**Workflow improvement:** this is the second consecutive session where the owner
caught something the documents asserted confidently and wrongly — first
"reeling adds no speed", now an enumerated list of six couplings that was
missing a seventh. Both were *lists and claims in binding docs that had never
been re-derived from source*. The fix applied here is to annotate the original
document at the point of the error rather than only recording the correction
elsewhere, so the next reader of the six-coupling table sees the seventh
immediately instead of trusting the table.

- **📊 Model:** opus-5 · high · feature build

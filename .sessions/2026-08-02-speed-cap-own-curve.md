# Give the speed cap its own curve

> **Status:** `complete`

## Close-out

**Evidence:**

- source: `swing_config.gd` (schema 12 → 13; `maximum_speed_cap`,
  `spider_speed_cap_at` rewritten as its own smoothstep, validation),
  `simulation_world.gd` (release award reads the shared cap),
  `tuning_catalog.gd` (`Top speed cap` knob; `bird_ceiling_share` moved to RUN
  to free a PACING slot).
- contracts: cap-shape and cap-inversion assertions added to the bird-bound
  contract; the release-award cap contract rewritten to assert against the cap
  *function* rather than a literal, so a retune cannot make it vacuous.
- verify: **`python3 tools/verify.py --require-godot` — PASS, 207/207** against
  the exactly-pinned `4.7.1.stable.official.a13da4feb`. `bootstrap.py check
  --strict` passes.
- docs: `decisions.md` [D-0050]; `current-state.md` release-cap line corrected.

**The report.** The owner, from device play on `0.33.0`: *"I think the speed cap
is still missing or too high."*

**It was neither missing nor uniformly too high, and the distinction is the
finding.** The cap was `target_speed_at + maximum_horizontal_overspeed` — a
**fixed** 360 px/s offset on a reference that itself climbs 360 → 760. So the
ceiling ran:

| distance | cap | vs his measured 73–78 m/s |
| --- | ---: | --- |
| 0 km | 72 m/s | engages |
| 3 km | 81 m/s | marginal |
| 5 km | 92 m/s | never engages |
| 10 km+ | **112 m/s** | never engages |

Past roughly 3 km the limiter could not fire, and the warp bands are exactly
where he tests — so a present, working limiter read as absent.

**No value of the single offset could have fixed it.** Low enough to bite at
10 km (~140 px/s) would have throttled the opening to 50 m/s. The offset was
inherited from the drive era, when the reference described where the spider
actually *was*. With speed earned, the reference is a number the spider passes
in its first few swings and never returns to, so anchoring a ceiling to it gives
a ceiling that is tight early and inert late.

The cap now has its own start and top: 720 px/s (unchanged opening) rising to an
`assumed` 900 px/s at 10 km. New curve: 72 · 74 · 76 · 81 · 86 · **90** m/s —
engaging across the whole range instead of only the first 3 km.

**A second fault fixed in passing.** The release award was bounded by a flat
`maximum_target_speed + maximum_horizontal_overspeed` (1120 px/s) while the
motor corrected toward the distance-local ceiling. A good release near the start
could push to 112 m/s against a limiter aiming at 73, then be dragged back for
seconds. Both now read `spider_speed_cap_at`, so the game has **one** cap.

**My own omission, and it is the reason the report came back the way it did.**
The Test Lab exposed the pull-back *strength* but never the cap's *height*. The
owner could not have tuned his way out of this, or even confirmed the cap
existed, from the device. `Top speed cap` is now a knob.

**Decisions made:** [D-0050], superseding D-0048's cap definition. This changes
the approved `balanced_baseline` again — owner-reported fault, and the new value
is `assumed` and exposed.

**Next session should know:** `maximum_speed_cap` (900) is the number to move if
the ceiling still feels wrong; the opening cap is deliberately untouched at 720
and moves only via `starting_target_speed` or `maximum_horizontal_overspeed`,
neither of which is exposed. Bot play is unchanged within noise (1 936 → 1 870 m,
1.03 → 1.07 deaths/km) because the bot never approaches the cap — it is 25 m/s
below the reference in the warp band. **The bot cannot verify this change**; only
device play can.

## 💡 Session idea

**Three sessions running, the fault has been the same shape: a constant that
described the world when it was written and quietly stopped.**
`horizontal_drive_acceleration` meant "how hard we push" and also silently meant
"how hard we brake". `maximum_horizontal_overspeed` meant "headroom above where
you actually are" and became "headroom above a number you left behind in the
first four seconds". The bird's linear law meant "rising pressure" and became
"eventually unbeatable".

Each was found only when the owner played. None would have been found by
reading, because each constant still *looked* correct in isolation — the meaning
drifted, not the value.

The cheap defence is a **units-and-meaning audit**: for each tuning constant,
write the sentence it is supposed to make true, then check that sentence against
current source. `maximum_horizontal_overspeed`'s sentence was "the spider may
exceed its target pace by this much" — and there is no target pace any more.
That audit would have caught all three before a device session did, and it is an
afternoon's work against ~60 exported values.

## ⟲ Previous-session review

The previous session shipped the cap and declared permanent headroom of
"+42 to +70 m/s" — which was true, and irrelevant, because it measured the gap
between the cap and the *bird* rather than between the cap and *the player*.
Nobody checked the cap against the owner's own measured 73–78 m/s band, which
would have shown immediately that it never engages past 3 km. The verification
was real but pointed at the wrong comparison.

**Workflow improvement:** when a limiter ships, assert it against **measured
player behaviour**, not only against other constants. The owner's speed band is
recorded in `docs/measurements/2026-08-01-owner-play-calibration.md` and was
available the whole time. A single line — "at what distance does this cap stop
touching 73–78 m/s?" — was the entire missing check, and it is now the shape of
the cap-curve contract.

- **📊 Model:** opus-5 · high · runtime bugfix

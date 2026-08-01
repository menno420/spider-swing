# Earned speed and pursuing bird

> **Status:** `in-progress`

## Goal

Remove the free horizontal drive and turn the invisible left kill boundary into a deterministic, visually legible pursuing bird with owner-tunable speed, acceleration, and start offset.

## Scope guard

One combined, device-testable package: drive to zero, the six explicit
`target_speed_at` decisions, bird simulation state, finished bird presentation,
Test Run isolation controls, replay compatibility, exploit regression, build
identity, contracts, and living handoff. Preserve course replay purity,
progression/economy, difficulty, persisted identity, collision geometry, and all
owner-approved traversal values except the explicitly chosen drive config.

## Previous-session review

**previous-session review:** PR #97 correctly implemented release quality and
versioned its replay boundary, but the owner could not judge it while the drive
refunded missed timing. The follow-up planning card correctly withdrew the
one-slice rule: drive removal without a visible bird would expose a live,
unexplained failure line. This session therefore keeps both in PR #102 and uses
bird speed zero—rather than a separate build—to isolate the mechanics.

## Implemented

- All three presets set `horizontal_drive_acceleration = 0`; `target_speed_at`
  remains. Opening, rescue, guided opening, camera and profile scaling keep the
  named reference. Quick Feet is deliberately inert pending OQ-13. The release
  ceiling is the run-wide maximum reference plus overspeed, currently 1120 px/s
  / 112 m/s (`inferred`), so it bounds manufacture without clipping the owner's
  measured 73–78 m/s opening band.
- `SimulationWorld` owns the bird. X follows an independent analytic world rate
  rising with distance; Y is damped height-follow. Speed zero disables state,
  presentation and contact. Rescue restores the configured gap. Contact keeps
  the existing `camera_boundary` cause and death lifecycle.
- Bird defaults are explicitly `assumed`: 300 px/s, +12 px/s per 1,000 m, and
  760 px gap. Test Run exposes direct `−`/`+` controls plus OFF 0/12/760, SLOW
  240/8/900, BASE 300/12/760 and FAST 380/20/600. They are session-only and do
  not serialize into settings, progress or ownership.
- Four original 280×280 transparent robin poses render on a 300 px canvas. The
  visible silhouette is measured at one source-pixel resolution to read 2–3×
  the nominal spider canvas. Fixed-tick phase crossfades without a wrap snap;
  bob shares flap phase; banking reads vertical velocity; closing raises cadence
  and a safe lead eases into glide. Reduced Motion removes bob and softens bank.
  Each normal run introduces the off-screen pursuit immediately—"wings are
  already behind you"—and the bird enters from the left as the buffer closes.
- Trace identity is `@3`. `earned-speed-bird-technical.json` records bird-off
  input and reproduces exactly through both the lab driver and real session:
  measured 2,894.978 m at 49.733 s.
- Build identity is `0.26.0-earned-speed-bird-playtest`, Android code 45.

## Exploit regression

**Measured** with `tools/simulate.gd`, 12 intermediate L20 runs, bot seeds
4242–4253, course seeds 9000–9005, 120 s cap, bird off, one-tick / 60 Hz
instrument resolution. The previously flagged hauling policy travels a mean
73.5 m (median 65.3, p10–p90 60.4–75.4, max 148.2) and all 12 runs time out
dangling. The endorsed wide policy retains 63.9° arc per web. These are bot
behavior measurements and exploit evidence only; the bot cannot pump, so none
of them tuned the bird.

## Adversarial verification

Each production mutation turned its intended contract red before restoration:
nonzero Weighty drive; local release ceiling; player-speed-matched bird X;
missing distance acceleration; hard Y tracking; a new death cause; enabled
zero-speed contact; half rescue gap; fixed-clock drift; incomplete preset
application; a missing FAST control; undersized bird; uncoupled bob; and ignored
trace overrides. The flap-clock mutation exposed a real blind spot, so the
contract now pins the exact 90-tick wrapped phase rather than only comparing two
identical worlds.

## Local verification

- Focused drive/bird gate: 72/72.
- Focused presentation/replay gate: 61/61.
- `python3 tools/verify.py --require-godot`: exact Godot
  `4.7.1.stable.official.a13da4feb`, 197/197 contracts.
- `python3 bootstrap.py check --strict`: pending the deliberate final lifecycle
  flip; before that flip its expected blocker is this `in-progress` card.

## Owner questions

No new question. OQ-13 remains the Quick Feet identity decision; this build
keeps it visibly inert. OQ-14 ships its contact-kill default. OQ-15 and OQ-16
are now ready for one device session using the four bird presets.

## 💡 Idea

Timeout traces exposed a review-loop seam: the lab stops at its artificial cap,
while an input-only in-game replay correctly continues after the last command.
The chosen technical trace ends on real obstacle death and therefore proves both
paths exactly. A future replay-format slice should make an authored lab cap an
explicit terminal playback event if timeout traces are ever meant to be watched;
until then, only naturally terminal traces should be bundled as exact evidence.

## Final lifecycle

The claim withdrawal, `complete` badge, final strict gate, remote CI, merge and
Android artifact are deliberately deferred to the final repository edit.

- **📊 Model:** gpt-5 · high · feature build

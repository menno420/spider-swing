# Earned speed and the bird — design spec

> **Status:** `binding`
>
> **The two mechanics the owner has chosen to build next, specified against the
> live source.** Speed stops being handed to the player and starts being earned;
> a pursuing bird makes the escalating pressure visible and gives Burst and Dive
> a second kind of thing to escape from.
>
> **Provenance (PL-013):** the design argument is `measured` — see
> [`../measurements/2026-08-01-hauling-loophole.md`](../measurements/2026-08-01-hauling-loophole.md)
> § "The owner's proposal, tested". Every seam and line number below is
> `measured` by reading the live source on 2026-08-01. Every *number proposed
> for tuning* is `assumed` and marked as such — see § "What cannot be tuned from
> the lab", which is the most important section in this document.
>
> **Implementation status (2026-08-02):** the complete package is implemented
> in build `0.26.0-earned-speed-bird-playtest`. Release quality remains
> `assumed` at 100 px/s maximum and 90° full arc; continuous drive is zero; the
> left kill line is visible deterministic bird state; and Test Run exposes all
> three assumed bird axes. The contracts establish simulation, presentation,
> replay, isolation and reset behavior. OQ-13 … OQ-16 remain device/product
> verdicts, not implementation blockers.

## The owner's brief, verbatim

> *"The important thing right now is that the speed at which the spider travels
> also increases over time, which should probably happen in a player controlled
> way by upgrades, swing control, reel and burst timing etc. So the game still
> increases in difficulty through speed just in a different way."*

> *"One visual thing that does need to be done properly right now is the
> creation of the bird, and one that actually moves in a bird like way, follows
> the spiders position and moves at a slightly increasing speed."*

Earlier, on the same package:

> *"Add the bird at a speed rate slightly slower than the current speed the game
> forces you to go, and stop the forward motion that the game gives you, so only
> swinging itself makes you go forward."*

> *"Because how I play and how I intend this game to be played, I am mostly
> going faster than the forced speed, even just slightly, so the forced speed is
> basically useless."*

## Why this is one change, not two

Measured, and the reason evaluating the halves separately produced two wrong
verdicts before:

- **A speed-based chaser cannot discriminate playstyles today**, because
  `SpiderMotor` drives everyone's horizontal velocity toward the same pace
  curve. Remove the drive and speed becomes a real signal of skill.
- **Arc-scaled release momentum is decoration today**, because the drive
  refunds it within a second. Remove the drive and there is nothing to refund
  it, so it becomes the game's actual propulsion reward.
- **Removing the drive alone leaves no pressure at all.** The bird supplies it.

Ablation, held-out seeds (`measured`):

| policy | full drive | no drive | change |
| --- | ---: | ---: | ---: |
| hauling (the exploit) | 4 179 m | **78 m** | **−98%** |
| default (swings) | 1 720 m | 1 147 m | −33% |

And in a world searched *inside* the no-drive rules, wide swinging is not merely
permitted — it **wins outright** (2 717 m at 61.2° arc, beating the policy
searched specifically for that world). The intended style becomes optimal by
physics rather than by prohibition. No rule saying "you must swing" is needed.

### Re-verified against current `main`

**Measured** — `tools/simulate.gd`, 12 runs, intermediate, L20, 6 course seeds,
120 s cap, via `--sweep=horizontal_drive_acceleration:<v>:<v>:1`, run on the
merged tree on 2026-08-01. Resolution: in-run counters at 1 tick; n=12, so the
means carry real spread (the p10–p90 band is quoted for that reason).

| drive | mean | median | p10–p90 | arc/web | near-vertical |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 470 (shipped) | 1 859 m | 1 672 m | 1 385 – 2 257 | 43.2° | 63% |
| **0** | **1 171 m** | 1 011 m | 470 – 2 054 | 39.9° | 77% |

The −37% here matches the −33% measured earlier for the same unadapted policy.
More usefully, **the game runs cleanly at drive 0** — no crash, no stall, no
degenerate state — so the central experiment is safe for a session to run on
day one.

**What this run does NOT show, and a session should not claim it does:** arc per
web went *down* (43.2° → 39.9°) and near-vertical hang went *up*. That is the
**default policy**, which is adapted to a world that has a drive; stripped of
its engine it dangles rather than swings. The "wide swinging wins" result comes
from a policy *endorsed or searched inside* the no-drive world. Reading this
table as evidence against the design would be the exact error this project keeps
making — measuring an adapted behaviour in an unadapted policy.

---

# Part 1 — Speed becomes earned

## What creates speed today

`SpiderMotor.apply_forces` (`game/simulation/spider_motor.gd:6`) is the free
engine, and it has exactly **one caller**: `SimulationWorld.step`
(`game/simulation/simulation_world.gd:417`), in the `else` branch — during a
Burst/Dive pull the motor is bypassed entirely.

```gdscript
# spider_motor.gd:16-21 — the line this design removes
if velocity.x < target_speed:
    velocity.x = move_toward(velocity.x, target_speed,
        config.horizontal_drive_acceleration * delta)
```

Speed sources that already exist and are **kept**:

| Source | Where | Status |
| --- | --- | --- |
| Pendulum conversion | `WebConstraint.solve_moving_anchor` `web_constraint.gd:170-177` — kills only *outward* radial velocity, preserves tangential | real, and the whole point |
| Reel | `advance_resource` `web_constraint.gd:86-90` shortens rope 320 px/s; speed gain is emergent from the constraint doing work | real, `measured` at **+6.2% speed / +52% distance** |
| Burst / Dive exit | `_advance_pull` completion `simulation_world.gd:1173-1178`: `velocity = _pull_tangential_velocity + _pull_direction * _pull_exit_speed` | real; note it is an **absolute assignment, not an add** |
| Moving highway anchor | `_web_anchor_motion` `simulation_world.gd:296-306`, `HIGHWAY_ANCHOR_SPEED = 410` | real, injects speed via the anchor frame |

## What did not exist when this spec was written

At the spec baseline, `WebConstraint.release()` cleared four fields and
preserved velocity exactly: there was no angle test, timing window, or
release-quality score anywhere in `game/`. Slice 1 now keeps wrap-safe covered
arc history on `WebConstraint`; `SimulationWorld._release_web()` alone converts
the arc/rise score into bounded forward momentum. Forced detach still calls the
plain release path and earns nothing.

The game already *promises* this mechanic to the player. Tutorial copy at
`game/application/front_end_state.gd:68,72` reads **"RELEASE WITH MOMENTUM"** and
*"Release while rising to carry momentum forward."* That is a design debt, not a
new idea: the tutorial teaches a skill the simulation does not implement.

This is the single highest-value addition in Part 1, because it is what makes
"swing control" a speed source rather than a phrase.

## The couplings that break if the drive is simply deleted

> **⚠ This list was incomplete, and the omission shipped. Corrected 2026-08-02
> under [D-0048].** A **seventh** coupling was missed: the motor's *own*
> overspeed branch. `SpiderMotor.apply_forces` has always had two branches — a
> floor that pushed a slow spider up to the reference, and a ceiling that pulled
> a fast one back toward `reference + maximum_horizontal_overspeed` — and
> **both were scaled by `horizontal_drive_acceleration`**. Zeroing the drive to
> remove the free forward push therefore removed the speed limit as well, after
> which only air drag acted on overspeed: proportional, so never a ceiling at
> all. The owner found it on device as speed that "increases to an amount that
> is nearly impossible to correct yourself from". The ceiling now has its own
> coefficient, `overspeed_correction_acceleration`, defaulting to the exact
> pre-#102 effective value.
>
> The lesson is the one this table was written to teach, turned on the table
> itself: the couplings that break are not only the ones that *read*
> `target_speed_at` from elsewhere. The function being modified had a second
> caller inside itself.

**Do not delete `target_speed_at` — it is load-bearing in five other places.**
Each needs an explicit decision, and this list is the main reason a session
should not start by editing `spider_motor.gd`:

| Site | Line | What it uses `target_speed` for | Decision needed |
| --- | --- | --- | --- |
| `SimulationWorld.reset` | `simulation_world.gd:99` | seeds opening `velocity.x` | what is a standing start worth now? |
| Rescue | `simulation_world.gd:1339` | `velocity = Vector2(max(300, target*0.88), -110)` | the anti-death-spiral valve — see below |
| Guided opening | `simulation_world.gd:1379` | `velocity = target_speed_at(distance)` | tutorial hand-hold |
| Camera look-ahead | `swing_lab.gd:222` | `max(0, velocity.x − target_speed)` | needs a new reference speed or the camera stops leading |
| Profile / upgrade scaling | `spider_catalog.gd:347-349` | `speed_scale` multiplies start/max target speed | spider identity partly expressed through the curve |
| **Release award cap** *(added by slice 1)* | `simulation_world.gd` `_release_web` | `forward_cap = target_speed_at + maximum_horizontal_overspeed` | **the sharpest one** — see below |

**The sixth site did not exist when this spec was written.** Slice 1 bounds the
release award with an `inferred` reuse of `target_speed_at + maximum_horizontal_
overspeed`. As a limiter on a bonus sitting *on top of a drive*, that is a sound
safety rail. With the drive gone it becomes a **throttle on the primary speed
source**, and the numbers are uncomfortable: the ceiling is **72.0 m/s at 0 m**
and **76.2 m/s at 1 km**, while the owner's standing-start L0 runs sustain
~73–78 m/s. A cap meant to stop repeated releases manufacturing speed would
instead stand between a good player and the speed this design exists to let them
earn. Decide it explicitly in slice 2.

**One upgrade track is invalidated outright.** `skitter_drive` — *Quick Feet*,
`QUICK_FEET` — multiplies `horizontal_drive_acceleration`
(`spider_catalog.gd:393-394`). With no drive it buys **nothing**. It must be
repurposed, not left as a dead purchase. That is an owner-facing product
decision (it is a named, priced identity track on a shipped spider), so it goes
to the queue rather than being decided in-session.

### Implemented decisions at the six reference-speed sites

`target_speed_at` remains intact as the named reference. The six sites were not
allowed to inherit the drive removal accidentally:

1. Opening launch keeps the one-time reference grant.
2. Rescue keeps its anti-death-spiral reference grant and additionally restores
   the full configured bird gap.
3. Guided opening keeps the reference launch.
4. Camera look-ahead keeps comparing earned velocity against the reference.
5. Profile scaling keeps shaping the reference curve; Quick Feet is
   deliberately inert pending OQ-13, with an explicit audit exception.
6. Release quality now caps at `maximum_target_speed +
   maximum_horizontal_overspeed`, not the local distance curve. Current values
   make that **1120 px/s / 112 m/s** (`inferred` safety ceiling), above the
   owner's measured 73–78 m/s opening band while still bounding repeated awards.

**Recommended shape rather than deletion:** keep `target_speed_at` as a *named
reference speed* — the number the camera, the rescue, and the bird are all
expressed against — and reduce `horizontal_drive_acceleration` to zero (or near
zero) as the actual behaviour change. That keeps five call sites working, keeps
the tuning-lab keys meaningful, and makes the change a **one-value experiment**
that can be reverted instantly. `tools/simulate.gd` already supports the
no-drive ablation this way, which is how the measurements above were produced.

## Where the difficulty ramp goes

Today the ramp is `target_speed_at`: 360 → 760 px/s smoothstepped over 50 000 px
(`swing_config.gd:220-229`). Under this design the ramp moves into **the bird**,
and the player's own speed becomes the variable they control against it.

That is the owner's sentence — *"the game still increases in difficulty through
speed just in a different way"* — expressed mechanically.

> **Superseded 2026-08-02 by the owner, under [D-0048].** *"The main purpose of
> the bird is to prevent the players from using strategies that don't involve
> actually swinging."* The bird is an **anti-degeneracy enforcer, not the
> difficulty ramp** — its job is to make dangling and ceiling-hauling
> non-viable, and it must never end a run that is being swung well. It is
> therefore hard-bounded below the spider's own ceiling, and difficulty
> escalation past that point has to come from the course rather than from the
> chase. The curve above also changed: the reference now reaches full pace at
> **10 km**, not 5 km.

---

# Part 2 — The bird

## The bird existed invisibly; it is now visible state

At the spec baseline `SimulationWorld.left_kill_boundary()` was
`furthest_x − config.camera_left_kill_distance` (520 px). It was enforced in
`step()`, killed with `DEATH_REQUESTED` cause `camera_boundary`, and was already
published as `snapshot.left_kill_boundary`. The implementation now derives that
same seam from `bird_position.x + BIRD_CONTACT_LEAD_X`, preserving the death
cause while changing the message to *"Caught by the pursuing bird"*.

**The bird is that line: made visible, given its own position state, and
advanced by its own law instead of ratcheting off `furthest_x`.** Building it
this way reuses a proven kill path and a snapshot field that already exists,
rather than inventing a hazard type.

It also delivers the design argument that survived measurement: *the pressure is
already there and nothing on screen says so.* A pursuer does not create the
pressure — it **reveals** it.

## Do not build it with `CourseMotion`

`game/simulation/course_motion.gd` is deliberately **stateless and pure** over
`(base_polygon, motion_spec, tick, fixed_delta)`. It cannot read player
position, by design, because that purity is what makes the course
deterministic and replayable. A pursuer needs per-tick state.

**The correct seam is state on `SimulationWorld`:** a field initialised in
`reset()` (`:89`) and advanced in `step()` (`:384`), exactly as
`left_kill_boundary` is derived today. Then new `SimulationSnapshot` fields for
presentation to draw.

## The movement law

Two axes, and they should obey **different rules** — this is what produces
"follows the spider" without producing a speed-matcher:

- **X — the bird's own law.** Position-based, not speed-matching. It advances at
  its own world rate, which increases slowly with distance. Banked distance is
  the player's buffer: get far ahead and you have slack to spend on a careful
  section. This is the form the hauling measurement concluded was right *"if a
  chaser ships"* — a speed-matched chaser was ruled out on measurement.
- **Y — follows the spider, with lag.** A damped follow of the player's height
  (a first-order lag, not a hard track), so it reads as a creature tracking prey
  rather than a slider on a rail. This is what makes it feel alive and is what
  the owner asked for by "follows the spiders position".

**Bird-like motion** (the owner's explicit visual requirement, "one that
actually moves in a bird like way"):

- a wing-flap cycle driven off `tick` so it stays deterministic;
- gentle vertical bobbing **coupled to the flap phase** — a bird gains a little
  height on the downstroke, so the bob should not be an independent sine;
- **banking** — tilt into vertical velocity, which is the single cue that most
  reads as "bird" rather than "sprite moving";
- flap rate rising when it is closing and easing to a glide when it is not,
  which turns the bird into a readable difficulty gauge.

Determinism requirement: the bird's state must be a pure function of
`(tick, course seed, the player's own history)` with no float accumulation that
could drift, and it must be captured in the trace format so replays reproduce.
`docs/technical/replay-review-loop.md` holds the existing contract; the
cross-path replay contract in `tests/unit/simulation_lab_tests.gd` is what will
catch a mistake here.

## The death spiral, and the valve that already exists

Earned speed plus an accelerating pursuer compounds: fall behind → less speed →
bird closer → panic → less speed. Left unmanaged this is the design's main
failure mode.

The valve already exists and is well-placed. Rescue sets
`velocity = Vector2(max(300, target_speed*0.88), −110)`
(`simulation_world.gd:1339`) — an absolute speed grant on the one event that
follows a mistake. Under this design the rescue's job grows: it is what buys a
player back into a survivable gap. **That number is now load-bearing and should
be treated as a tuning knob, not a constant.**

---

## What cannot be tuned from the lab

**Read this before proposing any bird speed.**

The limitation is **no longer that the bot cannot pump** — model v4 closed that
blind spot on 2026-08-02 (`pump_window_deg`, `RunDriver._in_pump_window`). The
conclusion is unchanged, but the reason is now pace. All `measured`:

- The **48.4 m/s** no-drive figure was produced by **v3, with pumping off**, and
  does **not** reproduce under the v4 default. `--bot=pump_window_deg:0`
  restores it exactly.
- Pumping buys a replicated **≈ +3.3 m/s** — real, and nowhere near the gap.
- In the warp band where the owner sustains **78.6 m/s**, v4 runs **26 m/s below
  the reference curve** and fails every pace acceptance target in
  [`../measurements/2026-08-01-owner-play-calibration.md`](../measurements/2026-08-01-owner-play-calibration.md).
- The physics allow far more still: a 380 px web swung from horizontal reaches
  `sqrt(2gL)` ≈ **92 m/s** at the bottom.
- Today's play sits at **55–76 m/s** with the drive helping.

**So every bot number in the no-drive world is a floor, not a target**, and a
bird speed derived from bot runs would be tuned against a player 26 m/s slower
than the one this design is about. A human should beat the bot here by more than
in any configuration measured so far.

The owner has stated he cannot supply new recordings for this work. Therefore:

1. **The bird's speed, acceleration and start offset must be exposed as debug
   tunables** on the Test Run / Course Lab screen, so the owner can find the
   number by playing rather than a session guessing it.
2. **No bird speed constant may be justified by a bot run.** Ship a placeholder
   that is explicitly labelled `assumed`, and say so in the doc.
3. The bot lab remains useful for the thing it *can* answer: whether the
   hauling exploit stays dead. `arc per web` is reported for every batch, so
   re-running the search is a genuine regression test on the exploit.

### Combined-tree exploit regression

**Measured** on the implementation tree with `tools/simulate.gd`, 12 runs,
intermediate, L20, bot seeds 4242–4253, course seeds 9000–9005, 120 s cap,
bird speed zero. Resolution is one 60 Hz tick. Produced by **bot v3, before
pumping existed** — reproduce with `--bot=pump_window_deg:0`. No number here
tuned the bird.

- The previously flagged hauling policy travels a mean **73.5 m** (median
  65.3 m, p10–p90 60.4–75.4 m, max 148.2 m) and all 12 runs time out dangling.
  Its 111.6° recorded arc is not a travelling swing and is deliberately not
  used as a target — the regression result is that the exploit no longer moves.
- The endorsed wide-swing policy still produces a **63.9° arc per web** on the
  same held-out setup. This is style evidence only, not a bird-speed target.

## Build order

**Corrected 2026-08-01.** The original five-slice split shipped release quality
first and spaced the rest behind device verdicts. That was wrong: it imported a
cadence from the superseded recording-led handoff, and it delivered a mechanic
that cannot be judged while the drive is on, instead of the two things actually
requested.

1. **Release quality — implemented** (PR #97). Not judgeable until the drive is
   gone; see OQ-16's timing banner.
2. **Drive → 0 and the bird — implemented together.** Removing the drive without the bird
   produces a game that is only harder: the drive is what makes stalling
   impossible today, and `left_kill_boundary()` becomes a live failure mode with
   nothing on screen explaining it (`measured`: 4 of 10 bot runs time out at
   drive zero). The bird is what makes that world legible rather than punishing.
   Ship them in one PR, built in the order drive → bird simulation → bird visual
   → exploit regression, and keep them separable with **debug tunables** rather
   than separate PRs.

The rule that replaces "one slice, one PR": **ship a testable whole.** A slice
boundary that hands someone a build they cannot form an opinion about is not a
slice boundary, it is a delay.

## Open forks for the owner

Tracked in [`../owner-questions.md`](../owner-questions.md):

- **OQ-12** — adopt this package (answered: yes, this document is the spec).
- **OQ-13** — what does *Quick Feet* become when the drive is gone?
- **OQ-14** — does the bird kill on contact, or push/stagger first?
- **OQ-15** — how fast does the bird start, and how fast does it accelerate?
  **Only a device playtest can answer this**, for the pumping reason above.

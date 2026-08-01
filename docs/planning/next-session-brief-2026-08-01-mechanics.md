# Next session brief — earned speed and the bird (mechanics, not visuals)

> **Status:** `plan`
>
> **This supersedes
> [`fresh-session-handoff-2026-08-01.md`](fresh-session-handoff-2026-08-01.md)
> as the next-session entry point.** That handoff is recording-led and
> visuals-led; the owner has redirected. It stays as an accurate record of what
> merged — read it for repository state, not for what to do next.
>
> **No new recordings will be supplied.** Everything the next session needs is
> in the repository. That constraint shapes the whole brief.
>
> **Progress:** ordered slice 1 (release quality) is implemented in
> `0.25.0-earned-release-playtest`; the next session starts at slice 2, drive → 0.

## What changed, in the owner's words

> *"I think right now the visuals are not the most important part anymore
> especially since the first 10K visuals are essentially done. One visual thing
> that does need to be done properly right now is the creation of the bird, and
> one that actually moves in a bird like way, follows the spiders position and
> moves at a slightly increasing speed."*

> *"For the game mechanics: the important thing right now is that the speed at
> which the spider travels also increases overtime, which should probably happen
> in a player controlled way by upgrades, swing control, reel and burst timing
> etc. So the game still increases in difficulty through speed just in a
> different way."*

So: **one visual job (the bird, done properly) and one mechanical job (speed
becomes earned).** Everything else is out of scope.

## The one document to read

[`../game-design/earned-speed-and-the-bird.md`](../game-design/earned-speed-and-the-bird.md)
is the spec. It carries the measured argument, every seam with a file:line, the
five call sites that break if the drive is naively deleted, the invalidated
upgrade track, and the build order. **It is written to be actionable without
re-deriving anything.**

## The three things a session will get wrong if it does not read them

**1. Do not build the bird with `CourseMotion`.** That module
(`game/simulation/course_motion.gd`) is deliberately stateless and pure over
`(base_polygon, motion_spec, tick, fixed_delta)`. It cannot read player
position, and that purity is what makes courses replayable. A pursuer needs
per-tick state on `SimulationWorld` — initialised in `reset()` (`:89`), advanced
in `step()` (`:384`) — plus new `SimulationSnapshot` fields.

**The bird already exists, invisibly.** `left_kill_boundary()`
(`simulation_world.gd:554`) is a player-following kill line with a working death
path and a published snapshot field. The bird is that line made visible and
given its own advance law. Build it there.

**2. Do not delete `target_speed_at`.** It is load-bearing in five other
places — opening velocity, the rescue grant, the guided opening, the camera
look-ahead, and profile speed scaling. The spec tables all five. The recommended
change is `horizontal_drive_acceleration → 0` as a **config value**, which is a
one-value experiment that reverts instantly and which `tools/simulate.gd`
already knows how to ablate.

**3. Do not tune the bird's speed from a bot run.** Measured: the bot **cannot
pump** (its reel policy is height-based, not swing-phase-based), so it reaches
48.4 m/s in the no-drive world while the physics allow ~92 m/s. Bot numbers are
a **floor, not a target**. Ship a placeholder marked `assumed` and expose bird
speed / acceleration / start offset as debug tunables so the owner finds the
number by playing. This is OQ-15.

## What is already settled and should not be reopened

`measured`, on the live source, 2026-08-01:

- **Removing the drive kills hauling and keeps swinging.** −98% for the exploit,
  −33% for the intended style; and in a no-drive search, wide swinging **wins
  outright** (2 717 m at 61.2° arc).
- **Reel already buys speed** — +6.2% speed, +52% distance. The repo phrase
  "speed-neutral Reel" is narrower than it reads.
- **Burst and Dive already have an escape job.** `_find_dive_tap` screens every
  candidate with a swept clearance test. The bird gives them a *second kind of
  thing* to escape from, not a new role.
- **Release quality was the first design debt and now exists.** The spec
  baseline had no angle or timing test even though the tutorial promised one.
  Slice 1 now scores wrap-safe covered arc and upward motion only on deliberate
  release, with bounded forward momentum and no forced-detach award.
- **`skitter_drive` / Quick Feet is invalidated** by removing the drive. That is
  OQ-13 and is owner-facing.

## Working rules that still stand

- **Do not change physics values casually.** `balanced_baseline` was
  owner-approved. This work necessarily changes one (`horizontal_drive_accel`),
  which is exactly why it should be a single revertible config value.
- **Zones 1–3 are frozen.** Their ids key persisted checkpoints.
- **Verify with `python3 tools/verify.py --require-godot`.** Without the flag
  the engine checks are skipped and green proves almost nothing. 184 contracts
  after the release-quality slice.
- **Falsify every new contract before trusting it:** break the code it guards,
  confirm the suite fails, restore, confirm it passes.
- **Mark every published number** `measured` (with method *and* the instrument's
  resolution), `inferred`, or `assumed` — PL-013, and `docs/README.md`
  § Measurements says why.
- **Never record a wall.** A refused call is transient venue state.
- **~~One slice, one green PR. Do not combine the mechanic and the visual.~~**
  **Withdrawn 2026-08-01** — it imported the superseded handoff's
  device-verdict-between-slices rhythm into headless work where that premise no
  longer held, and it cost the owner a day. Combine whatever ships a testable
  whole; keep them separable by **debug tunables**, not by separate PRs.

## Slice order

1. **Release quality — implemented** (PR #97). Deterministic speed reward on a
   deliberate wide, rising release. **Not yet judgeable** — see below.
2. **Drive → 0 and the bird — the current work, shipping together.** Detailed
   under "The current work"; the paste-ready prompt is there.

**The original five-slice split was wrong and is withdrawn.** It sequenced the
work for building and spaced it for a device verdict that headless work does not
need, and it delivered the owner a mechanic he could not test instead of the two
things he actually asked for. What replaces it: ship a **testable whole**, and
keep the parts separable with debug tunables so one build still isolates them.

### Correction — the build order was right, the verification order was not

**Slice 1's feel verdict cannot be gathered while the drive is on, and OQ-16
asks for exactly that.** This was an error in the original brief, found on
2026-08-01 after slice 1 merged. Two mechanisms, and they compound:

- **The drive erases the penalty.** `SpiderMotor` only fires *below*
  `target_speed`; the overspeed bleed only fires *above* `target + 360`. A good
  release lands in the untouched band and survives on drag alone — **4.4 s of
  airtime at 0 m, 4.0 s at 1 km, 2.2 s at 5 km** (`measured` — motor arithmetic
  at 60 Hz, `air_drag` 0.055; exact, not sampled). So the award is *not*
  decoration, and the spec's earlier "the drive refunds it within a second" was
  wrong on the arithmetic. But **a bad release costs nothing**: the floor
  rebuilds at 470 px/s, ~0.2 s per 100 px/s. The good-vs-bad contrast is a
  fraction of what it becomes without the drive.
- **The award's own ceiling sits inside the owner's playing band.**
  `forward_cap = target_speed_at(distance) + maximum_horizontal_overspeed` is
  **72.0 m/s at 0 m, 73.1 at 500 m, 76.2 at 1 km**, reaching 112 only past
  5 km. His standing-start L0 runs sustain **~73–78 m/s** (`inferred` — HUD
  distance deltas, average ground speed, not instantaneous `velocity.x` at a
  rising release). So for the first kilometre the award may be near zero.

Asking for the OQ-16 verdict now would test the mechanic in the one
configuration engineered to make it feel weak — and a weak verdict would send
someone tuning the 100 px/s value when neither the value nor the formula is at
fault. **Do slice 2, then gather slice 1 and slice 2 in one device session.**

---

## The current work: remove the drive AND build the bird, in one session

### Why these ship together — corrected 2026-08-01

The original brief said *"one slice, one green PR — do not combine."* **That was
wrong here, and it cost the owner a day.** It imported the rhythm of the
superseded recording-led handoff, which spaced slices out because each visual
change needed a device verdict between them. That premise died the moment the
owner said no more recordings would be supplied and the work went headless.

There is also a **design** reason, and it is the stronger one:

**Removing the drive without the bird produces a game that is only harder.**
The drive is what currently makes stalling impossible. Take it away and
`left_kill_boundary()` — `furthest_x − 520 px`, ratcheting — becomes a live
failure mode with nothing on screen explaining it. `measured`: 4 of 10 bot runs
time out with the drive at zero, and `camera_boundary` appears as a death cause.

The bird is not decoration on top of that. **The bird is the thing that makes
the no-drive world legible**: it turns an invisible ratcheting line into a
visible pursuer whose distance tells you how much slack you have. Handing the
owner a no-drive build without it would produce a misleading feel verdict for
exactly the same reason slice 1's verdict is unavailable today — testing a
mechanic in a configuration built to make it feel bad.

**Attribution is still available without separate PRs.** The bird's speed,
acceleration and start offset are debug tunables (OQ-15). Setting its speed to
zero isolates the drive change; the drive is a single config value. Two knobs,
four combinations, one build.

### Internal order within the session

Ship it as one PR, but build it in this order so each step is verifiable before
the next:

1. **Drive → 0**, with the six coupling sites decided (table below).
2. **The bird as simulation state** — position, advance law, kill reusing the
   existing `camera_boundary` path, snapshot fields, contract tests.
3. **The bird as a visual** — flap, bank, bob, and the closing/gliding tell.
4. **Exploit regression** — re-run the search, check `arc per web` climbed.

Steps 1–2 and 4 are fully headless-verifiable. Step 3 is the one needing an eye.

### The six coupling sites — each needs an explicit decision

`target_speed_at` stays. It is a **named reference speed**, not a drive. Six
things read it, and every one needs a stated decision in the PR body:

| # | Site | What it uses `target_speed` for | The question |
| ---: | --- | --- | --- |
| 1 | `SimulationWorld.reset` `:99` | seeds opening `velocity.x` | a standing start currently gets ~36 m/s free. Keep, reduce, or zero? |
| 2 | Rescue `:1339` | `velocity = max(300, target*0.88)` | **the anti-death-spiral valve.** Now load-bearing, not a constant |
| 3 | Guided opening `:1379` | opening tutorial web | same question as 1 |
| 4 | Camera look-ahead `swing_lab.gd:222` | `max(0, velocity.x − target_speed)` | still meaningful as a reference, or does the camera need a new one? |
| 5 | Profile scaling `spider_catalog.gd:347-349` | `speed_scale` on start/max target | spider identity partly lives in the curve |
| 6 | **Release award cap** `simulation_world.gd` `_release_web` | `target_speed_at + maximum_horizontal_overspeed` | **the sharpest.** `inferred`, sound as a limiter *on top of a drive*; with no drive it throttles the **primary** speed source |

Site 6 matters most. The ceiling is **72.0 m/s at 0 m** and **76.2 m/s at 1 km**;
the owner's standing-start L0 runs sustain **~73–78 m/s**. A cap meant to stop
repeated releases manufacturing speed would instead stand between a good player
and the speed this design exists to let them earn.

### The bird — what the code already gives you

**`left_kill_boundary()` (`simulation_world.gd:554`) is already a
player-following kill line** with a working death path (`:471-477`, cause
`camera_boundary`) and a snapshot field presentation already receives
(`swing_lab_session.gd:684`). The bird is that line made visible and given its
own advance law. Do not invent a hazard type.

**Do NOT use `CourseMotion`.** It is stateless and pure over
`(base_polygon, motion_spec, tick, fixed_delta)` by design, and cannot read
player position — that purity is what makes courses replayable. A pursuer needs
per-tick state on `SimulationWorld`: initialised in `reset()` (`:89`), advanced
in `step()` (`:384`), published through new `SimulationSnapshot` fields.

**Movement law — two axes, deliberately different rules:**

- **X is the bird's own law.** Position-based, not speed-matching, advancing at
  a world rate that increases slowly with distance. Banked distance is the
  player's buffer. A speed-matched chaser was ruled out on measurement.
- **Y follows the spider, with lag.** A damped follow of player height, not a
  hard track. This is what "follows the spiders position" means without turning
  it into a speed-matcher.

**Bird-like motion** (the owner's explicit requirement): a wing-flap cycle
driven off `tick` so it stays deterministic; vertical bob **coupled to the flap
phase**, not an independent sine; **banking** into vertical velocity, which is
the single cue that most reads as "bird"; and flap rate rising when closing,
easing to a glide when not — which makes the bird a readable difficulty gauge.

Determinism: bird state must be a pure function of `(tick, course seed, player
history)` and must be captured in the trace format so replays reproduce. The
cross-path replay contract in `tests/unit/simulation_lab_tests.gd` catches
mistakes here.

### What to measure, and the trap in reading it

Reproduce the ablation with `--sweep=horizontal_drive_acceleration:0:0:1`.

**Do not read arc-per-web from an unadapted policy.** The default policy is
tuned for a world with a drive; stripped of its engine it dangles rather than
swings, and arc per web goes *down* (43.2° → 39.9°). The "wide swinging wins"
result comes from a policy searched or endorsed *inside* the no-drive world.
Reading the naive table as evidence against the design would reproduce this
project's most repeated error.

### Do not tune the bird from a bot run

`measured`: the bot **cannot pump** — its reel policy is height-based, not
swing-phase-based — so it reaches 48.4 m/s in the no-drive world while the
physics allow ~92 m/s from a 380 px web. Every bot number is a **floor**. Ship
placeholders marked `assumed` and expose bird speed, acceleration and start
offset as debug tunables on the Test Run screen. That is OQ-15, and it is also
what makes attribution possible in a combined PR.

---

## Paste-ready prompt — the current work

```
Continue Spider Swing in menno420/spider-swing from live `main`. Read, in
order: .claude/CLAUDE.md, docs/current-state.md, then
docs/planning/next-session-brief-2026-08-01-mechanics.md — especially "The
current work" — and the spec it points at,
docs/game-design/earned-speed-and-the-bird.md. Read both fully before
writing code.

Build BOTH of these in one PR: remove the free forward drive so that only
swinging propels the spider, and add the bird. They ship together on
purpose. Removing the drive without the bird produces a game that is only
harder: the drive is what currently makes stalling impossible, and without
it the invisible left kill line becomes a live failure mode with nothing on
screen explaining it. Measured, 4 of 10 bot runs time out at drive zero. The
bird is what makes that world legible rather than just punishing. I have one
device session to spend and I want to feel the finished shape, not half of
it.

Build it in this internal order, verifying each before the next: drive to 0
with the six coupling sites decided; the bird as simulation state; the bird
as a visual; then re-run the exploit regression.

Do NOT delete target_speed_at. Keep it as a named reference speed and set
horizontal_drive_acceleration to 0 as a config value. Six things read that
reference and each needs an explicit decision stated in your PR body — the
brief tables all six. Site 6 is the sharpest: slice 1's release award is
capped at target_speed_at + maximum_horizontal_overspeed, a sensible limiter
on a bonus sitting on top of a drive, which becomes a throttle on the primary
speed source once the drive is gone. That ceiling is 72 m/s at the start and
I already play at 73-78, so think hard about it.

Do NOT build the bird with CourseMotion — it is stateless by design and
cannot read player position, which is what makes courses replayable. The
correct seam is state on SimulationWorld, and left_kill_boundary() is
already an invisible player-following kill line with a working death path
and a published snapshot field. The bird is that line, made visible and
given its own advance law.

The bird's two axes obey different rules. X is its own law: position-based,
not speed-matching, advancing at a world rate that rises slowly with
distance, so banked distance is my buffer. Y follows my height with lag, a
damped follow rather than a hard track. It must actually move like a bird —
a flap cycle driven off tick so it stays deterministic, vertical bob coupled
to the flap phase rather than an independent sine, banking into vertical
velocity, and a flap rate that rises when it is closing and eases to a glide
when it is not, so I can read my danger from how it moves.

Do NOT tune the bird's speed from a bot run. The bot cannot pump, so every
simulated no-drive number is a floor, not a target. Ship placeholders marked
`assumed` and expose bird speed, acceleration and start offset as debug
tunables on the Test Run screen. That also lets me isolate the two changes
while testing: bird speed zero gives me the drive change alone.

When you measure the ablation, do not read arc-per-web from the default
policy — it is adapted to a world with a drive and dangles without one. The
"wide swinging wins" result comes from a policy searched inside the no-drive
world.

Verify with `python3 tools/verify.py --require-godot` (the count lives in
EXPECTED_CHECK_COUNT in tests/test_runner.gd — do not trust a number written
in prose) and `python3 bootstrap.py check --strict`. Falsify every new
contract before trusting it: break the code it guards, confirm the suite
fails, restore, confirm it passes. Mark every number you publish `measured`
(with method AND the instrument's resolution), `inferred`, or `assumed` —
PL-013.

I cannot supply new recordings, so do not plan around getting one. When this
lands I will test the release award, the no-drive world and the bird in one
session, so tell me plainly what to look for in each and which debug values
to change to isolate them. Anything that genuinely needs my decision goes to
docs/owner-questions.md — OQ-13 through OQ-16 are already open.

Do not rush this, and do not cut the bird short to finish sooner — I would
rather test it tomorrow than test a hurried version tonight. The one thing
that must not be dropped is the debug tunables: without them I cannot
isolate the two changes, and that isolation is the whole reason they are
allowed to ship together.

Land one green PR and tell me plainly what you did, what you verified, and
what you are unsure about. End with the one line I actually need: which
Actions run holds the APK, and exactly what to change on the Test Run screen
to try bird-off, bird-slow and bird-fast.
```

---

## Completed slice-1 prompt — historical

This is the exact prompt that produced the implemented release-quality slice.
Do not paste it into the next session; continue at ordered slice 2.

```
Continue Spider Swing from live `main`. Read, in order:
.claude/CLAUDE.md, docs/current-state.md, and then
docs/planning/next-session-brief-2026-08-01-mechanics.md and the spec it
points at, docs/game-design/earned-speed-and-the-bird.md. Read the spec
fully before writing any code — it carries the measured argument and every
seam with a file:line, and it names three specific mistakes that look
correct from the outside.

The work: the free forward drive goes away, and forward speed becomes
something the player earns through swing control, reel, burst timing and
upgrades. A pursuing bird then supplies the escalating pressure the pace
curve used to supply invisibly. The design is already decided and measured —
your job is to build it, not to re-litigate it.

Three constraints that will not be obvious from the code:

1. The bird must NOT be built with CourseMotion. That module is stateless by
   design and cannot read player position. The correct seam is state on
   SimulationWorld, and left_kill_boundary() is already an invisible
   player-following kill line with a working death path — the bird is that
   line, made visible and given its own advance law.

2. Do not delete target_speed_at. It is load-bearing in five other places
   that the spec tables. Change horizontal_drive_acceleration as a config
   value instead, so the whole experiment reverts in one number.

3. Do not tune the bird's speed from a bot run. The bot cannot pump, so every
   simulated no-drive number is a floor, not a target. Ship a placeholder
   marked `assumed` and expose bird speed, acceleration and start offset as
   debug tunables on the Test Run screen.

Take ONE slice from the spec's build order, in order. Release quality first —
it is pure simulation, headless-verifiable, and the tutorial already promises
the player a mechanic the simulation does not implement. Do not combine the
mechanic and the visual in one PR.

Verify with `python3 tools/verify.py --require-godot` (181 contracts; without
the flag the engine checks are skipped and green proves almost nothing) and
`python3 bootstrap.py check --strict`. Falsify every new contract before
trusting it: break the code it guards, confirm the suite fails, restore,
confirm it passes. Mark every number you publish `measured` (with method AND
the instrument's resolution), `inferred`, or `assumed` — PL-013.

I cannot supply new recordings for this work, so do not plan around getting
one. I can playtest a build and give you a verdict. Anything that genuinely
needs my eye goes to docs/owner-questions.md — OQ-13, OQ-14 and OQ-15 are
already open and are the parts measurement could not settle.

Land one green PR and tell me plainly what you did, what you verified, and
what you are unsure about.
```

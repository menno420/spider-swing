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
- **One slice, one green PR.** Do not combine the mechanic and the visual.

## Slice order

Each is independently shippable and independently revertible:

1. **Release quality — implemented.** Pure simulation, headless-testable, no
   new gameplay visual. Swing control now has a deterministic speed reward.
2. **Drive → 0** — **the current slice**, with the six coupling sites decided.
3. **The bird as simulation state** — position, advance law, kill reusing the
   `camera_boundary` path, snapshot fields, contract tests.
4. **The bird as a visual** — flap, bank, bob, and the closing/gliding tell.
5. **Exploit regression** — re-run the search, check `arc per web` climbed.

Slices 1–3 are fully verifiable headless. Slice 4 is the one that needs the
owner's eye.

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

## Slice 2 — the current work: remove the free drive

### Why this slice, and why now

Three reasons, in order of force:

1. **It is the change the owner asked for.** *"Stop the forward motion that the
   game gives you, so only swinging itself makes you go forward."* Everything
   else in this programme exists to make that survivable.
2. **It unblocks OQ-16.** Slice 1 shipped a mechanic whose feel cannot be
   judged while the drive is on — see the correction above. Until this lands,
   the owner cannot answer the one question slice 1 left open, and the device
   session it would cost him would produce a misleading answer.
3. **It is the whole anti-hauling fix.** `measured`: ablating the drive costs
   the intended style a third and destroys hauling outright (−98%), and in a
   world searched inside the no-drive rules wide swinging **wins outright**.
   The intended style becomes optimal by physics, with no rule written.

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
| 6 | **Release award cap** `simulation_world.gd` (slice 1) | `target_speed_at + maximum_horizontal_overspeed` | **new, and the sharpest.** `inferred` and reasonable as a bonus-limiter *on top of a drive*. With no drive it throttles the **primary** speed source |

Site 6 is the one to think hardest about. Today the ceiling is 72 m/s at the
start; the owner already plays at 73–78 there. A cap that was a safety rail
becomes the thing standing between the player and the speed the design is
supposed to let them earn.

### The failure mode this creates, which does not exist today

**Stalling becomes reachable.** `left_kill_boundary()` is
`furthest_x − 520 px` and `furthest_x` only ratchets forward, so falling 52 m
behind your own best point kills you. Today the drive makes that nearly
impossible. Without it, it is live.

`measured` — `tools/simulate.gd`, 10 runs, intermediate, L20, 5 course seeds,
100 s cap, in-run counters at 1 tick:

| | drive 470 | **drive 0** |
| --- | ---: | ---: |
| mean distance | 2 031 m | **1 206 m** |
| timeout runs | **0 / 10** | **4 / 10** |
| death causes | boundary ×2, obstacle ×8 | **camera_boundary ×2**, obstacle ×4, **timeout ×4** |

**Forty per cent of runs stall out.** Read that correctly: the bot **cannot
pump** — its reel policy is height-based, not swing-phase-based — so it cannot
add energy at the bottom of an arc, which is the single skill this design makes
central. These numbers are a **floor, not a prediction about a human**. What
they prove is that stalling is now mechanically reachable, and slice 2 must
decide what happens when it does. The rescue (site 2) is the existing valve.

### What to measure, and the trap in reading it

Reproduce with `--sweep=horizontal_drive_acceleration:0:0:1`.

**Do not read arc-per-web from an unadapted policy.** The default policy is
tuned for a world with a drive; stripped of its engine it dangles rather than
swings, and arc per web goes *down* (43.2° → 39.9°). The "wide swinging wins"
result comes from a policy searched or endorsed *inside* the no-drive world.
Reading the naive table as evidence against the design would reproduce this
project's most repeated error.

### Not in this slice

The bird. Slice 2 removes the drive; slice 3 adds the pursuer. Shipping them
together would make it impossible to tell which one caused a change in feel,
and the owner has exactly one device session to spend.

---

## Paste-ready prompt for slice 2

```
Continue Spider Swing in menno420/spider-swing from live `main`. Read, in
order: .claude/CLAUDE.md, docs/current-state.md, then
docs/planning/next-session-brief-2026-08-01-mechanics.md — especially the
"Slice 2" section — and the spec it points at,
docs/game-design/earned-speed-and-the-bird.md. Read both fully before
writing code.

The work is ordered slice 2: remove the free forward drive, so that only
swinging propels the spider. This is the change the whole programme is
built around, and it is now also blocking me: slice 1 shipped a
release-momentum reward whose feel I cannot judge while the drive is on,
because the drive erases the penalty for a bad release and the award's own
ceiling sits inside the speed band I already play in. Until this lands I
cannot answer OQ-16, and a playtest now would give us a misleading answer.

Do NOT delete target_speed_at. Keep it as a named reference speed and set
horizontal_drive_acceleration to 0 as a config value, so the whole
experiment reverts in one number. Six things read that reference and each
needs an explicit decision, stated in your PR body — the brief tables all
six. Site 6 is the sharpest: slice 1's release award is capped at
target_speed_at + maximum_horizontal_overspeed, which was a sensible
limiter on a bonus sitting on top of a drive, and with no drive becomes a
throttle on the primary speed source. At the standing start that ceiling is
72 m/s and I already play at 73-78, so think hard about it.

Expect a failure mode that does not exist today: stalling. left_kill_boundary
is furthest_x - 520px and furthest_x only ratchets forward, so falling 52 m
behind your own best point kills you. Measured with the drive at zero, 4 of
10 bot runs time out and camera_boundary appears as a death cause. Read that
as a floor, not a prediction — the bot cannot pump, so it cannot generate
speed the way a person does. But it proves stalling is now reachable, and you
must decide what happens when it does. The rescue grant is the existing valve
and its numbers become load-bearing.

Do NOT add the bird in this slice. Slice 3 does that. If both land together
I cannot tell which one changed the feel, and I have one device session to
spend.

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

I cannot supply new recordings, so do not plan around getting one. I can
playtest a build and give you a verdict. When this lands I will test slice 1
and slice 2 together in one session, so tell me plainly what to look for in
both. Anything that genuinely needs my decision goes to
docs/owner-questions.md — OQ-13 through OQ-16 are already open.

Land one green PR and tell me plainly what you did, what you verified, and
what you are unsure about.
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

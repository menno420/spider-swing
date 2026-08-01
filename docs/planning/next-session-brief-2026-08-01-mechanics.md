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

## Suggested slice order

Each is independently shippable and independently revertible:

1. **Release quality — implemented.** Pure simulation, headless-testable, no
   new gameplay visual. Swing control now has a deterministic speed reward.
2. **Drive → 0**, with the five coupling sites explicitly decided.
3. **The bird as simulation state** — position, advance law, kill reusing the
   `camera_boundary` path, snapshot fields, contract tests.
4. **The bird as a visual** — flap, bank, bob, and the closing/gliding tell.
5. **Exploit regression** — re-run the search, check `arc per web` climbed.

Slices 1–3 are fully verifiable headless. Slice 4 is the one that needs the
owner's eye.

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

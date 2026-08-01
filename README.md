# Spider Swing

An Android-first 2D physics game. You control a small, agile spider moving through
oversized environments — fire silk, turn forward speed into pendulum momentum, skim
past hazards, catch flies, and survive as long as you can. Distance travelled is the
score.

The product *is* the swinging. Everything else exists to support it.

> ### "Spider Swing" is a codename
>
> **Not approved release branding.** Other games already use this name and similar
> spider-swinging concepts. Naming, trademark, domain, and store-conflict review are
> all still open — see [`docs/product/name-status.md`](docs/product/name-status.md).
> The repository name, the Godot project name, and the package identifier
> `com.menno420.spiderswing.dev` are all development identifiers and are all
> expected to change.

## Current phase: integrated pre-alpha playtesting

**The traversal core and an integrated content test build are implemented.** The
project opens on a player-facing Home screen with Play, Garage, Shop, a six-step
Tutorial, three-level Campaign, Course Lab, Region Practice, Field Guide, and
readable scrolling Settings. Play begins on a real ceiling web that provides a
safe first swing before the player must react. The deterministic endless course
now spans eight authored zones while retaining forgiving solid-object attachment,
momentum-preserving release, speed-neutral Reel shortening, interruptible Anchor
Burst and Dive Pull, collectible fly routes, and one temporary Burst boost.

### What exists

- A responsive starting screen with Play, Garage, Shop, Tutorial, Campaign,
  Course Lab, Region Practice, Field Guide, and Settings. One forest-web skin
  supplies the bark/moss/silk palette, natural web backdrop, controls, panels,
  focus states, and silk-like scrollbars across every screen; settings persist
  swing feel, control hints, reduced motion, effects, haptics, and debug-tool
  visibility.
- A data-defined Garage with five comparison spiders—balanced, small/agile,
  heavy, gliding, and one-charge rail recovery—plus three web treatments and
  palette selection. Every
  profile modifies the same authoritative `SwingConfig`, and its trade-off is
  visible before Play.
- A touch-scrollable prototype Shop with one fly-balance badge, themed upgrade
  cards, and visible silk-knot progress. Every spider has the same five core
  tracks and two identity tracks. Each track has 20 small levels and a visible
  breakthrough at levels 5, 10, 15, and 20; each milestone purchase applies the
  track's listed increase twice by granting one bonus tuning step. Previous
  five-level saves migrate proportionally. Buttons, panels, labels, and empty
  card regions all bubble drag gestures to one native inertial scroll owner,
  while taps remain owned by their original control. This is a local fly-funded
  balance lab, not an in-app-purchase implementation.
- A six-slot Course Lab that cycles deterministic EMPTY/LEAF/POD/VINE/GATE
  pieces, saves the pattern locally, and can playtest it immediately.
- A data-driven six-step animated tutorial plus an in-game Menu return path.
- A deterministic 60 Hz point-mass spider motor with the owner-approved
  Balanced baseline's 1120 gravity, a smooth 5000 m default speed-learning curve, forward drive, drag,
  world boundaries, and a capped maximum-length web constraint.
- A deterministic opening trajectory that uses the ordinary web constraint and
  remains interruptible from the first tick, plus one optional rescue charge per
  run with a short collision shield and clear HUD state.
- Polygonal ceilings and obstacles with off-by-default web-target guides, a
  1000-pixel shared
  web range, a 220-pixel aim-forgiveness band, manual release, Reel-In
  drain/regeneration/lockout, and multi-touch input that keeps UI touches out of
  the web path. Rails, walls and ceiling-grown hazards are valid web targets;
  floor-grown hazards are lethal but do not answer taps, so a release tap aimed
  at the usual spot cannot be captured as a Dive Pull. Diving to the floor
  itself is unchanged.
- One approved baseline preset, `balanced_baseline` (owner-approved 2026-07-31),
  plus two untuned forks kept for future work: `weighty_candidate` and
  `agile_candidate`. Only balanced has been played and tuned, so the two
  candidates are stale relative to the baseline and were never evaluated against
  it — they are not vetted alternatives.
- A deterministic bounded course stream with a 1000 m learning runway before
  detached middle hazards and a separate 2000 m default protection period in
  which the lethal ceiling/floor rails never move inward. One shared route plan
  shapes the rails and fly trail around each challenge. A curated,
  distance-banded pattern catalog prevents immediate repeats, introduces
  paired/staggered compositions only after 2000 m, and reserves predictable
  later tight gaps for rail-only challenges. Authored weave chunks cue and
  clear a full Classic-sized route from high to low or low to high, with 420 px
  between shorter alternating growths and a tested central transition band;
  compact
  silk-suspended seed burrs add a small middle decision without creating a large
  floating wall. Leaf clusters, vine forks, hanging seed pods, broken root
  stumps, broad rail-grown root passages, fly route arcs, and lower anchors
  appear in distinct rhythms. Base Burst crosses 40% of the
  selected web distance; downward taps make a one-shot 40% Dive Pull. Both are
  collision-checked, but only Burst uses a timer. Dive rearms after the next
  successful upper/obstacle web attachment. Either pull can be cancelled
  immediately by a recovery-web tap.
- Eight structurally distinct endless regions: Ancient Forest, Bramble Canopy,
  Silk Hollow, Ruined Arboretum, Storm Ridge, Web City, Ashen Hollow, and Deep
  Mist. Their authored mechanics include deterministic moving anchors, wind and
  lightning, safe and sticky silk highways, expiring anchors, embers, and
  audio-first fog warnings without changing the approved swing physics.
- Relaxed, Standard, and Harsh modes vary obstacle presentation and recovery
  policy while preserving every physics field. Three Campaign lessons require
  Reel, Burst, and Dive respectively and award one non-repeatable star each.
- Small post-runway hazards gain only 8–16% size across later distance bands,
  with independent DEBUG controls for edge obstacle size, floating obstacle
  size, and gate opening size. The broad passage is not narrowed. Collision and
  presentation always consume the same scaled polygons.
- Four generated 384×384 environment packs—Ancient Forest, Mossy Ravine,
  Overgrown Greenhouse, and Reclaimed Attic—plus the original Graybox. Ancient
  Forest is the default and now adds a cohesive finished-art candidate:
  world-continuous mossy branch rails, rooted brambles, hanging thorn vines,
  broken root stumps, a broad root passage, three layered forest depths, the
  bright Classic Garden Spider, the broad charcoal-and-bronze Anchorite, and
  golden forest flies. Its transparent obstacle
  sprites replace the prototype polygon backing instead of layering over it;
  root-and-moss growth sockets join every wall-grown hazard behind the rail.
  Broad growth uses aspect-preserving crops; tall narrow growth uses the full
  vertical vine silhouette with conservative overscan, avoiding the rectangular
  cut edges exposed by the 1040×480 device recording.
  The broad passage uses the same natural upper/lower growth instead of
  stretched circular halves. Background layers scroll at restrained independent
  rates and stay lower contrast than gameplay.
  Custom presentation interpolation now blends the spider and attached web
  between authoritative 60 Hz snapshots. Mipmapped minification keeps the
  high-resolution Garden, Anchorite, and fly art readable at their small
  gameplay size,
  while restrained Reel, pull, glide, and speed poses add motion without
  changing collision or simulation.
  DEBUG → LOOK swaps visual treatment without changing a course polygon or
  collision. DEBUG → OVERLAYS
  independently enables exact collision outlines or web-target guides; both
  load off.
- Base Reel-In is an isolated comparison at 320 px/s with 2.0 seconds of full
  energy: enough to shorten about 640 px while remaining a finite resource.
  Maxing Silk Winder reaches 416 px/s inside the owner-tested 400–450 px/s
  response band; maxing Silk Reserve as well extends the meter to 2.48 seconds.
  Reel still adds no acceleration or forward-speed correction. Burst remains
  40% with 80 px minimum useful
  travel. Shared fly upgrades can improve Reel rate, Burst share, minimum Burst
  travel, Reel capacity, and Reel recovery; two identity tracks per spider
  reinforce its existing trade-off.
- Automatic rope take-up retains 85% of natural inward slack by default without
  adding speed. DEBUG can compare it off/on, alter the retained percentage, hide
  the course rails, or make visible rails lethal.
- Flies are swept deterministically at high speed. A Burst Frenzy pickup removes
  Burst cooldown for a tunable duration. One idempotent run settlement persists
  fly totals and distance milestones; the first two alternate graybox spider
  palettes unlock at 25 flies and 1000 m.
- Buckler can survive one moderate free-flight rail hit, then must attach an
  upper web to recharge. Obstacles, high-speed impacts, pull collisions, and a
  second rail contact remain lethal.
- With Debug Tools enabled, Home exposes a pre-run `DEBUG TEST RUN`: stage an
  exact typed distance, use large `−`/`+` controls for distance and the
  temporary all-track upgrade level, then start once through the existing
  no-awards Region Practice path. `OWNED`/L0/L10/`MAX` remain shortcuts; Garage
  and Shop mark overlays `NOT OWNED`, real purchases remain unchanged, and
  normal Play clears the overlay. DEBUG → RUN retains the same live controls;
  both surfaces disappear when Debug Tools is off.
- A presentation view with camera follow, 228-pixel thumb targets,
  action flashes, independently optional haptics, and 25 original generated
  sound-effect samples for traversal, pickups, failure, and later-zone warnings.
  It also provides pause/frame-step/slow-motion and an eleven-section,
  touch-first DEBUG panel with direct values for Burst/Dive percentages and
  durations, Burst cooldown, Reel shortening speed and full-meter hold time,
  natural take-up mode/percentage, rail presence/lethality, obstacle sizes,
  pace endpoints and full-speed distance, shaped-route clearance, the
  inward-rail start distance, and tight gaps,
  opening web, rescue, and impact-shell controls, middle-hazard start, boost duration, attach
  catch, aim forgiveness, range, RELEASE/RETARGET behavior,
  deterministic input recording/replay, visual-theme comparison, independent
  opt-in overlays, and diagnostic export.
- A 175-contract Godot suite covering bootstrap/build identity, deterministic
  physics, all eight zones, spider biology, Campaign, difficulty, upgrades,
  economy, generated audio, mobile layout, settings, and progression. It includes
  interruptible recovery webs, double-tap fallback, explicit
  release/retarget modes, opening-runway pacing, lower anchor coverage, exact
  pull-distance shares, speed-neutral Reel/take-up shortening, rail policy,
  swept pickups, idempotent progression, polygon anchors/collisions, and
  creator-pattern bounds, a three-lane Classic-sized steering-envelope sweep
  through every root passage, full-route clearance for both authored height
  weaves, bounded middle-burr geometry,
  the guided opening trajectory, seven-track spider progression and
  breakthroughs, level-zero preservation, spider profiles/glide,
  rescue consumption, presentation interpolation, custom cosmetic rails,
  touch-scroll stability, proportional save migration,
  and identical results from simulated 30/60/90/120 Hz render loops. Adapter tests
  prove that raw Android touch owns world intent while its emulated mouse copy
  is ignored, so one physical tap cannot attach and immediately release.
- The existing headless, architecture, CI, and Android debug build substrate.

### What is deliberately not implemented

Missions, longer Campaign tiers, a star-funded cosmetic sink, ambience, music,
production monetization, cloud saves, leaderboards, analytics, ads, and store
publishing remain absent. The generated environment art, fly-funded upgrades,
temporary boost, one-run rescue, spider profiles, local Course Lab, difficulty
modes, and three Campaign lessons are integrated pre-alpha slices—not approved
production balance or a finished economy. There is no Google Play Billing SDK,
real-money catalogue, purchase verification, server entitlement, course sharing,
or moderation. Those require explicit later product and infrastructure work.

The implementation order and the ideas deliberately rejected or deferred are in
[the deep progression direction](docs/product/deep-progression-direction.md).

Phase 0 is tracked in [issue #2](../../issues/2). Balanced is the approved
physics baseline; the issue remains open for the broader owner-judged feel and
long-distance device gates.
See the [Swing Laboratory playtest guide](docs/technical/phase-0-swing-laboratory.md).

## Requirements

- **Godot 4.7.1 Standard** — not the .NET/Mono build. GDScript only, no C#.
  [Download archive](https://godotengine.org/download/archive/).
- **Python 3.10+** for the verification tooling. Nothing to install; it is
  stdlib-only.

The engine version is pinned in [`.godot-version`](.godot-version) and locked by
[ADR 0001](docs/technical/adr/0001-engine-and-runtime.md). `tools/verify.py`
refuses to run against a different version, and refuses a Mono build outright.

## Opening the project

1. Install Godot 4.7.1 Standard.
2. Clone this repository.
3. In the Godot project manager choose **Import**, select `project.godot` in the
   repository root, and open it.
4. Press F5. You should see the Spider Swing Home screen. Choose **Tutorial** or
   **Campaign** for guided mechanics, **Settings** for feedback/accessibility
   options, or **Play** to enter the endless course.

The engine will create `.godot/` on first open — that is regenerated import data
and is git-ignored.

## Verifying

Two commands. Both must pass before work lands, and they never call each other.

```bash
python3 tools/verify.py             # host + game code
python3 bootstrap.py check --strict  # Substrate doc/session hygiene
```

`tools/verify.py` locates Godot via `GODOT_BIN`, `GODOT`, `GODOT4`, or PATH; asserts
the version; runs the architecture checker and its 14 self-test fixtures; imports the
project headlessly; runs the boot smoke test; then runs the headless test runner. It
never downloads anything — a missing Godot is reported, not fetched.

```bash
export GODOT_BIN=/path/to/Godot_v4.7.1-stable_linux.x86_64
python3 tools/verify.py
```

Details in [`docs/technical/testing.md`](docs/technical/testing.md).

## Getting an Android debug build

Every push to `main` builds an installable debug APK.

1. Open the [**android-debug** workflow runs](../../actions/workflows/android-debug.yml).
2. Click the most recent successful run.
3. Download the **`spider-swing-android-debug`** artifact from the Artifacts
   section (kept 14 days).
4. If the device has never installed build `0.19.0-depth-testing` or a later
   stable-key build, uninstall the older Spider Swing development app one final
   time. Then unzip the artifact and install `spider-swing-debug.apk`. Do not
   uninstall afterward: every later artifact uses the same stable debug
   identity and should update in place while preserving saves.

Debug build only, signed by the conventional public key committed under
`.github/android/`. The key and its credentials are public and must **NEVER** be
reused for Google Play, a release build, production signing, or any signed
distribution. No release signing exists. The development app installs alongside
any future production build because the package identifiers differ. See
[ADR 0003](docs/technical/adr/0003-android-build-strategy.md).

You can also trigger a build manually from the workflow page via **Run workflow**.

## Architecture in one table

Dependencies point strictly inward. `adapters` and `presentation` are equal-rank
peers and may not depend on each other.

| Layer | Contains | May depend on |
| --- | --- | --- |
| `game/domain/` | Value objects, commands, events, identifiers, config contracts | nothing |
| `game/content/` | Versioned data definitions | nothing |
| `game/simulation/` | Fixed-step spider motor, web constraint, collision policy | `domain` |
| `game/application/` | Front-end state, run state machine, difficulty director, world stream, score, settlement | `domain`, `simulation` |
| `game/adapters/` | Godot input, scenes, persistence, telemetry, platform | inward layers |
| `game/presentation/` | UI, camera, audio, VFX, rendering | inward layers |
| `game/bootstrap/` | The composition root | anything |

The flow is one-way:

```
input → buffered command → fixed-step simulation → domain events
      → presentation/telemetry → run settlement → persistence
```

Presentation never mutates simulation truth and cannot grant rewards. Enforced by
`tools/check_architecture.py` and `tests/test_runner.gd`, both run by CI. See
[ADR 0002](docs/technical/adr/0002-simulation-and-event-boundaries.md) and
[`docs/technical/repository-layout.md`](docs/technical/repository-layout.md).

## Roadmap

Phases are gated: each one has an exit gate that must pass before the next starts.
Full criteria in the GDD § 23.

| Phase | Scope | Exit gate |
| --- | --- | --- |
| **0 — Swing Laboratory** | Spider body and forward drive, solid-object targets, attach/swing/manual release, Reel-In energy, percentage Anchor Burst and Dive Pull, camera and world boundaries, streamed prototype course, runtime tuning and diagnostics | Attach/release predictable across frame rates; release preserves momentum; Reel-In useful but not mandatory; test players can attribute their deaths; one named physics preset approved as baseline |
| **1 — Fair Endless Slice** | Seeded chunk selection, three static chunks + one moving-hazard family, small flies, Shield and Tension flies, distance score, death/results/sub-2s restart, local best, basic audio and haptics | No unavoidable deaths in fixed-seed testing; special-fly hits readable; performance target met on the lowest supported device |
| **2 — MVP Progression** | Run settlement and Silk, atomic versioned save, Magnet Fly, Classic customization, small capped upgrades, three mission templates, settings and accessibility, analytics adapter, release-quality first biome | Economy grants cannot duplicate; progress survives suspension and migration; upgrades do not affect standard records |
| **3 — Content Expansion** | Alternate spiders with trade-offs, more biomes and chunk packs, cosmetics, daily fixed-seed challenge, platform services, tested rewarded ads, Rush Fly | — |

Twin-Web stays blocked until it has a dedicated, tested control specification.

## Documentation

| Document | What it is |
| --- | --- |
| [Game Design Document v2.0](docs/game-design/Spider-Swing-GDD-v2.0.md) | **The product and gameplay source of truth.** Fairness rules, system boundaries, release gates. |
| [ADR 0001 — Engine and runtime](docs/technical/adr/0001-engine-and-runtime.md) | Godot 4.7.1 Standard, GDScript, Compatibility renderer, 60 Hz fixed step. |
| [ADR 0002 — Simulation and event boundaries](docs/technical/adr/0002-simulation-and-event-boundaries.md) | Inward layering and deterministic event flow. |
| [ADR 0003 — Android build strategy](docs/technical/adr/0003-android-build-strategy.md) | Debug-only CI now; production signing later, owner-controlled. |
| [Repository layout](docs/technical/repository-layout.md) | What lives where. |
| [Testing and verification](docs/technical/testing.md) | How to verify locally; what CI enforces. |
| [Phase 0 Swing Laboratory](docs/technical/phase-0-swing-laboratory.md) | Controls, tuning candidates, diagnostics, and the real-device approval gate. |
| [Front-end flow](docs/technical/front-end-flow.md) | Home, animated tutorial, persistent settings, lifecycle ownership, and tests. |
| [Name status](docs/product/name-status.md) | Why the title is a codename and what review remains. |
| [Substrate Kit provenance](docs/technical/substrate-kit-provenance.md) | How the vendored kit got here; how to re-verify the pin. |

The GDD's own change rules apply: **locked rules** must not change during
implementation without updating the document, **tunable values** live in
configuration rather than code, and **deferred features** keep an extension point
but are not built before their phase.

## How this repository is worked

The owner directs product vision and playtests; autonomous Claude and Codex agents
implement and maintain the repository. The working contract lives in
[`CONSTITUTION.md`](CONSTITUTION.md) and the Substrate-generated ledgers under
`docs/` — start with `docs/AGENT_ORIENTATION.md` and `docs/current-state.md`.

Reversible implementation decisions are decide-and-flag. The owner reviews playable
feel, branding, monetization, production signing, and external publication rather
than routine code. When documentation disagrees with verified source, the source
wins and the documentation is corrected in the same PR.

# Spider Swing

## Game Design Document v2.0

**Status:** Greenfield pre-production specification  
**Current codename:** Spider Swing  
**Initial platform:** Android  
**Later platform:** iOS  
**Genre:** Endless physics-action game  
**Primary orientation:** Landscape  
**Primary score:** Distance travelled  

> “Spider Swing” is a codename, not an approved release name. Existing games already use the name and similar spider-swinging concepts. Complete a naming and store-conflict review before public branding.

---

## 1. Document Authority and Change Rules

This document is the product and gameplay source of truth. It defines intended player behaviour, system boundaries, fairness rules, and release gates.

Three kinds of values are used:

- **Locked rule:** Do not change during implementation without updating this document.
- **Tunable value:** Expose through data/configuration so it can be changed without rewriting gameplay code.
- **Deferred feature:** Preserve an extension point, but do not implement it before its stated phase.

The core physics prototype must be approved before progression, monetization, missions, multiple spiders, or large content sets are built. A coding agent must not silently decide an unresolved product rule.

---

## 2. Product Definition

### 2.1 Player fantasy

The player controls a small, agile spider moving through oversized environments. They fire silk, turn forward speed into pendulum momentum, skim past hazards, catch flies, and survive for as long as possible.

The visual identity should focus on an actual or stylized spider in a miniature world—not a human superhero, city-swinging fantasy, or red-and-blue comic-book imitation.

### 2.2 Core promise

Every run should produce three feelings:

1. **Control:** The spider responds immediately and predictably.
2. **Flow:** Good timing chains swings into faster, cleaner movement.
3. **Ownership:** A death is understandable and feels caused by a player decision.

### 2.3 Design pillars

- Swinging is the product; all other systems support it.
- Controls are understandable within one run and expressive after many runs.
- Sessions are short, restarts are nearly instant, and improvement is visible.
- Random generation never overrides fairness.
- Progression adds variety and goals without selling competitive power.
- Visuals remain readable on small screens and at maximum speed.

### 2.4 Non-goals for the first release

- Combat
- Story campaign
- Multiplayer
- User-generated levels
- Live-service events
- Global competitive leaderboards
- Procedurally generated individual obstacle placement
- More than one simultaneously simulated player web

### 2.5 Market differentiation

The broad “swing, avoid obstacles, catch flies” premise already exists in small web and mobile games. This game must be recognizable through the combination of:

- Reel-In as an energy-managed arc-shaping skill;
- special flies caught by aiming the same web used for movement;
- a miniature natural/household world built around an actual spider;
- readable, seeded obstacle chunks rather than ragdoll chaos;
- spiders that provide balanced movement trade-offs.

If playtesting shows that Reel-In and direct-hit flies do not materially change how the game feels, the concept needs another differentiation pass before content production.

---

## 3. Core Run Loop

1. Start a run with the selected loadout.
2. Enter a short, safe opening segment.
3. Automatically move forward while the target pace gradually increases.
4. Attach and release webs to convert forward speed into safe swing arcs.
5. Use Reel-In energy to shorten an active web and adjust the arc.
6. Avoid lethal hazards and the camera boundary.
7. Collect small flies through proximity and special flies through accurate web shots.
8. Travel through increasingly difficult, prevalidated obstacle chunks.
9. Die when a lethal collision or world-boundary condition resolves.
10. Show the cause of death, distance, flies caught, Silk earned, and any mission progress.
11. Restart immediately or return to the meta screens.

The time from death to a restarted controllable run should be **under two seconds** when the player chooses instant restart.

Provisional session targets:

- a new player understands the basic action within 30 seconds;
- early runs commonly last 20–60 seconds;
- improving players commonly reach 60–180 seconds;
- there is no artificial run-length cap.

---

## 4. Screen, Camera, and World Model

### 4.1 Orientation

The game uses landscape orientation. The extended horizontal view provides the reaction distance required by a speed-based endless game.

### 4.2 World model

- Obstacles, flies, anchors, and the spider exist in world space.
- The spider uses real velocity; the game must not fake the swing by moving only the background.
- A forward-drive force moves horizontal velocity toward a target pace. It must not overwrite velocity every physics step.
- The camera follows forward progress with the spider normally held in the left third of the screen.
- The camera has speed-dependent look-ahead so upcoming hazards remain visible.
- Falling below the lower world boundary or lagging behind the camera’s left kill boundary causes death.
- The top of the screen is not itself lethal; authored geometry determines whether the upper route is safe.

### 4.3 Readability contract

- At normal maximum difficulty, a new lethal decision must be visible for at least the configured minimum reaction time.
- UI respects notches, rounded corners, and device safe areas.
- Player, web, collectible, safe attachment surface, and lethal hazard must be distinguishable by shape as well as color.
- The player hitbox is slightly smaller than the visible body and is exposed as a tunable debug overlay.

---

## 5. Controls

### 5.1 Locked default control scheme

**Web**

- When detached, tapping a valid target fires and attaches a web.
- When attached, tapping the play area releases the current web.
- Attach and release commands trigger on touch-down, not after the finger lifts.
- An invalid attachment tap gives immediate visual and audio feedback but does not alter velocity.
- The player may attach only within the configured forward/upward attachment cone and maximum range.
- Validity feedback appears with the shot; the default mobile control does not wait for a drag or targeting preview.

**Reel-In**

- Holding the dedicated Reel-In button retracts an active web while energy remains.
- Releasing the button stops retraction immediately.
- Pressing Reel-In while detached does nothing except give subtle unavailable feedback.
- Button placement can be mirrored for left-handed play.

### 5.2 Release policy

Manual release is the default and authoritative rule. The web does **not** automatically release at the swing apex.

An optional accessibility assist may release the web when the player would otherwise rotate backward past a configurable angle. This is a later feature and must be clearly disclosed in settings.

### 5.3 Input guarantees

- Input is sampled during rendering and buffered for the next physics step.
- A valid tap must never be lost solely because it occurred between physics ticks.
- Pause, app suspension, focus loss, or an interrupted touch cancels held Reel-In input safely.
- Gameplay supports simultaneous touch input for the play area and Reel-In button.
- UI touches must never fire a web through the UI.

---

## 6. Web and Swing Physics

### 6.1 Simulation model

The spider is a dynamic body. An attached web behaves primarily as a maximum-length rope constraint with a small, tunable elastic allowance for visual snap and feel.

The web should not behave as a loose spring by default; excessive spring behaviour makes the swing floaty and injects unpredictable energy.

### 6.2 Attach contract

On a successful attachment:

- The selected target is converted from screen space to a stable world-space anchor.
- The anchor remains fixed unless it belongs to an explicitly moving obstacle.
- Existing velocity is preserved.
- Constraint correction is capped so attachment cannot teleport the spider or create an extreme impulse.
- The initial rope length equals the spider-to-anchor distance, clamped to the valid range.
- Attach feedback begins immediately even if the rendered web extends over several frames.

### 6.3 Swing contract

- Gravity continuously affects the spider.
- A taut web removes only the velocity component that would extend the rope beyond its allowed length, subject to elasticity and correction limits.
- Tangential velocity is preserved except for configured drag.
- The simulation must not add unbounded energy through repeated attach/release actions.
- Reel-In shortens the allowed rope length over time; it never teleports the spider.
- Releasing the web preserves the spider’s current velocity.

### 6.4 Web break and invalid states

The web releases when:

- The player manually releases it.
- Its anchor is destroyed.
- A spider or power-up rule explicitly breaks it.
- The simulation detects an unrecoverable invalid constraint.

Ordinary tension does not break the default web in the MVP.

### 6.5 Reel-In resource

Reel-In uses a continuous energy meter rather than discrete charges.

- A run starts with full Reel energy.
- Holding Reel-In drains energy.
- Energy regenerates when Reel-In is not being used.
- Emptying the meter triggers a short recovery lockout before regeneration resumes.
- Drain, regeneration, lockout, and retraction rates are tunable.

This creates a readable resource decision without requiring the player to count hidden uses.

### 6.6 Required tunable parameters

Expose the following through one versioned gameplay configuration:

- Gravity
- Spider mass
- Horizontal drive acceleration
- Target forward-speed curve
- Maximum horizontal overspeed
- Air drag
- Web minimum and maximum length
- Attachment cone
- Attachment correction cap
- Rope elasticity allowance
- Rope damping
- Reel retraction rate
- Reel energy capacity
- Reel drain rate
- Reel regeneration rate
- Reel empty lockout
- Camera follow strength
- Camera look-ahead
- Player collision radius
- Input buffer duration

The debug build must support named parameter presets and runtime adjustment without editing source code.

---

## 7. Web Targets and Special-Fly Aiming

### 7.1 Valid anchors

Webs attach only to surfaces or anchor volumes marked as web-compatible. Level chunks must provide enough valid anchors for every intended route.

An attachment indicator distinguishes:

- valid in range;
- valid but out of range;
- invalid surface;
- special fly intercept.

### 7.2 Direct-hit special flies

A special fly is caught only when the fired web ray intersects its direct-hit target before reaching the selected anchor.

- Mild aim assistance expands only the fly’s web-ray hit area, not the spider’s body-collection area.
- The fly must be close to a valid web line so catching it never requires an impossible shot.
- After catching the fly, the web continues to the valid anchor behind it.
- Catching a fly therefore rewards aim without replacing or cancelling the swing action.

This rule prevents ambiguity over whether a fly is an anchor and keeps one input responsible for one predictable movement action.

---

## 8. Movement States and Resolution Order

The simulation separates independent state axes instead of combining every condition into one large state enumeration:

- run lifecycle: `Active`, `Dying`, or `Dead`;
- web state: `Detached` or `Attached`;
- Reel-In input: active or inactive;
- effect set: zero or more timed/consumable effects such as Shield or Tension.

Only valid combinations are processed. For example, Reel-In input has no simulation effect while detached, and no active input is processed while dying or dead.

Within each fixed simulation tick, resolve in this order:

1. Consume buffered player commands.
2. Update target pace and forward drive.
3. Apply gravity and movement forces.
4. Apply web constraint and Reel-In.
5. Advance physics.
6. Resolve collectible contacts.
7. Resolve hazard contacts through the central collision policy.
8. Emit domain events.
9. Update presentation from the resulting state.

Only the collision policy decides whether a contact kills, consumes a shield, phases, or breaks an obstacle.

---

## 9. Obstacles and Fair Generation

### 9.1 Chunk-based generation

The MVP uses curated obstacle chunks selected by a seeded director. It does not place individual lethal obstacles randomly.

Every chunk declares:

- stable content identifier and version;
- physical length;
- supported speed range;
- difficulty cost;
- allowed entry height and velocity envelope;
- expected exit height and velocity envelope;
- valid anchor positions;
- safe route envelope;
- minimum preview distance;
- collectible sockets;
- whether mirroring is supported;
- obstacle tags and required player capabilities.

### 9.2 Selection rules

The Difficulty Director:

- selects only chunks compatible with current speed and entry state;
- prevents incompatible chunk combinations;
- respects a recovery budget after demanding chunks;
- avoids repeating the same pattern too frequently;
- spawns content far enough ahead to meet reaction-time rules;
- records the seed and chosen chunk sequence for reproduction.

If no valid challenging chunk is available, the director chooses a safe recovery chunk. It must never improvise an unvalidated lethal layout.

### 9.3 Obstacle categories

- **Solid lethal:** kills on resolved contact.
- **Light breakable:** normally lethal; specific spider or protection rules may destroy it.
- **Moving lethal:** has authored, deterministic movement.
- **Web-compatible moving object:** can be used as an anchor and must expose its velocity to the constraint.
- **Scenery:** no gameplay collision.

Initial obstacle families should be visually simple: static columns, spikes, rotating bars, and one predictable moving gate. Introduce one new rule at a time.

### 9.4 Fairness rules

- No lethal obstacle spawns inside the active simulation or camera safety margin.
- No required route depends on a power-up or non-default spider.
- Every chunk is completable by the Classic spider without permanent upgrades.
- Visual decoration cannot conceal hazard bounds or anchor validity.
- Moving hazards telegraph direction and timing before they enter the decision zone.

---

## 10. Difficulty and Pace

Difficulty is driven by authored tiers and a continuous target-speed curve, not by unbounded random scaling.

### 10.1 Provisional distance bands

| Distance | Purpose | Content |
| --- | --- | --- |
| 0–150 m | Learn | Wide routes, static hazards, obvious anchors |
| 150–500 m | Establish rhythm | Mixed heights, simple fly lines, first moving hazard |
| 500–1,200 m | Test control | Tighter transitions, route choices, recovery chunks |
| 1,200 m+ | Mastery | Higher pace, advanced authored combinations, capped minimum gaps |

These thresholds are tunable. Difficulty metrics must never shrink a required reaction window below the tested device and speed limits.

### 10.2 Speed rules

- Target pace rises smoothly with distance and approaches a tested cap.
- Temporary speed effects modify the target pace, not the score formula.
- When a speed effect ends, the target transitions back gradually.
- The game never abruptly clamps the spider’s actual velocity downward.
- Distance uses actual forward world displacement.

---

## 11. Collectibles and Run Economy

### 11.1 Small flies

- Small flies are collected when the spider enters a base proximity radius.
- A mild default attraction may curve nearby flies toward the spider, but does not pull the player.
- They are placed on readable route lines, including safe and risky variants.
- The HUD displays flies caught during the current run.
- At run settlement, caught flies convert to Silk using a configurable conversion rule.

Separating in-run flies from persistent Silk makes the theme and economy easier to understand.

### 11.2 Initial special flies

| Fly | Effect | Initial duration | Notes |
| --- | --- | ---: | --- |
| Shield Fly | Absorbs one otherwise-lethal contact | 6 s or until consumed | Expiry and consumption are distinct events |
| Tension Fly | Faster Reel-In and lower Reel energy drain | 5 s | Does not change base gravity |
| Magnet Fly | Strong attraction to nearby small flies | 5 s | Does not collect other special flies |
| Rush Fly | Raises target pace and phases through hazards | 3 s | Post-MVP until transitions and readability are proven |
| Twin-Web Fly | Allows a second simultaneous web | Deferred | Requires a separate control and physics design; not part of MVP |

Only Shield and Tension are required in the first vertical slice. Magnet is the preferred third MVP power-up.

### 11.3 Power-up rules

- Effects have stable identifiers and data-defined durations.
- Recollecting the same timed effect refreshes it up to a configured cap; it does not stack strength unless explicitly specified.
- Visual and audio language clearly shows activation, final-second warning, expiration, and shield consumption.
- Collision invulnerability, shield absorption, and phasing all resolve through the central collision policy.

---

## 12. Scoring, Records, and Style

### 12.1 Primary score

Distance travelled is the authoritative run score. Special flies and style actions do not add fake metres.

### 12.2 Secondary run statistics

- Small flies caught
- Special flies caught
- Longest uninterrupted swing chain
- Number of successful near-hazard passes
- Reel energy used
- Cause of death

### 12.3 Records

The MVP stores:

- best Classic-standard distance;
- best distance for each spider/loadout;
- lifetime flies caught;
- lifetime Silk earned.

If global or daily leaderboards are added later, their standard mode uses fixed Classic stats, a versioned physics configuration, and a known seed or validated generation version. Gameplay purchases and nonstandard spider abilities do not affect that leaderboard.

### 12.4 Style system

Perfect releases and near misses may provide feedback, mission progress, and a temporary Silk multiplier. They do not directly change distance in the MVP. Add momentum rewards only after testing proves they cannot create runaway speed or obscure cause and effect.

---

## 13. Death and Restart

### 13.1 Death causes

- lethal obstacle contact;
- lower world-boundary exit;
- camera left-boundary exit;
- an explicitly authored future hazard.

### 13.2 Collision priority

On an otherwise-lethal contact:

1. Active phasing ignores the hit.
2. A valid shield consumes itself and prevents death.
3. A spider-specific rule may destroy a compatible light obstacle.
4. Otherwise the player dies.

Only one outcome is committed for a contact. Repeated collision callbacks in the same tick cannot consume multiple shields or settle the run twice.

### 13.3 Death presentation

- Freeze or slow the final moment briefly.
- Show the cause of death without hiding the collision.
- Emit one haptic pulse when supported.
- Allow instant restart after the short confirmation window.
- Commit rewards exactly once before the results screen becomes actionable.

---

## 14. Spiders and Loadouts

Spiders are data-defined movement profiles with trade-offs. None may be a strict upgrade over Classic.

| Spider | Strength | Trade-off | Phase |
| --- | --- | --- | --- |
| Classic | Balanced reference profile | None | MVP |
| Heavy | Retains momentum; breaks light obstacles | Slower Reel-In; shorter attachment range | Post-core |
| Long-Silk | Longer attachment range | More elasticity and slower correction | Post-core |
| Quick-Reel | Faster Reel-In | Lower Reel capacity | Post-core |
| Phantom | Periodic obstacle phasing | Weaker fly magnet and visible cooldown | Post-core |

Each spider requires:

- stable identifier;
- presentation assets;
- physics modifier profile;
- collision capabilities;
- explicit disadvantages;
- unlock rule;
- balance-test record;
- separate local record.

Spider abilities are earned through play and are never sold directly for real money.

---

## 15. Permanent Progression

### 15.1 Silk

Silk is granted only through idempotent run settlement, missions, achievements, or explicitly claimed rewards.

Do not add an upgrade that grants “starting Silk per run”; it creates a repeatable currency faucet unrelated to performance.

### 15.2 Upgrade philosophy

Permanent upgrades are for the noncompetitive adventure experience. They must use small capped changes and be grouped by function:

- Reel capacity or regeneration
- Small-fly attraction radius
- Power-up duration
- Mission or loadout convenience
- Cosmetic unlock tracks

Starting speed is not a generic permanent upgrade. It changes difficulty, scoring opportunity, and reaction time simultaneously.

### 15.3 Fairness boundary

- Real money buys cosmetics and optional convenience only.
- Gameplay modifiers are earned through play.
- Standard competitive records ignore permanent upgrades.
- Every required route remains possible with the unupgraded Classic spider.
- Economy tuning may affect unlock pace, never core collision or score calculation.

---

## 16. Missions and Challenges

Missions are data-defined and consume domain events rather than reading gameplay objects directly.

Examples:

- Reach 800 m without using Reel-In.
- Catch 50 small flies across any number of runs.
- Catch three special flies in one run.
- Survive 200 m after a shield expires.
- Complete five consecutive swings without touching the lower route.

Mission definitions include:

- stable identifier and version;
- event and filter conditions;
- target value;
- run-scoped or lifetime scope;
- reward;
- expiry policy, if any;
- progress-migration rule.

No mission required for basic progression may depend on a rare random event.

---

## 17. Visual, Audio, Haptics, and Accessibility

### 17.1 Art direction

Use high-contrast 2D silhouettes and oversized natural or household environments. Candidate biomes include attic, greenhouse, tree canopy, kitchen, and storm drain. The first release needs one coherent biome; later biomes are content packs, not separate gameplay systems.

Avoid visual similarities to Spider-Man or other superhero properties.

### 17.2 Web presentation

The web communicates state through:

- launch streak;
- attach spark or silk burst;
- visible tension;
- modest stretch;
- Reel-In pulse travelling toward the anchor;
- release snap;
- color or pattern overrides for accessibility and cosmetics.

The visual web follows the authoritative physics endpoints but does not drive physics.

### 17.3 Audio

Core sounds:

- valid and invalid web shot;
- attach;
- tension;
- release;
- Reel-In start, loop, empty, and stop;
- small and special fly catch;
- shield activation and break;
- near miss;
- death;
- results settlement.

High-frequency actions require variation and cooldown rules to avoid repetitive audio fatigue.

### 17.4 Accessibility

- Left- and right-handed Reel-In layouts
- Separate music, effects, and haptic controls
- Reduced screen shake
- Reduced flashes
- High-contrast web option
- Color-independent collectible and hazard shapes
- Optional apex-release assist
- Tutorial reset

---

## 18. Monetization

Monetization is not implemented before core retention and fairness are validated.

Allowed directions:

- cosmetic spider skins;
- web colors and patterns;
- trails and death effects;
- cosmetic environment variants;
- extra cosmetic loadout slots;
- optional rewarded ad after a run for a capped Silk bonus;
- at most one rewarded continue per run, tested in a separate score category.

Disallowed directions:

- selling spider abilities or upgrade levels;
- paid random loot;
- interruptive ads during a run;
- energy systems that prevent play;
- paid score multipliers;
- manipulating death or difficulty to drive ad views.

Any continued run is marked and does not overwrite an unassisted standard record.

---

## 19. Technical Architecture

Avoid a collection of global `Manager` singletons. Use a deterministic simulation core, explicit orchestration, data-defined content, and presentation adapters.

### 19.1 System boundaries

| System | Responsibility |
| --- | --- |
| Run State Machine | Owns countdown, active run, dying, settlement, results, and restart transitions |
| Input Router | Converts touch/UI input into buffered simulation commands |
| Spider Motor | Applies gravity, forward drive, velocity limits, and body configuration |
| Web Controller | Validates targets and owns attach/release commands |
| Web Constraint | Applies rope and Reel-In physics during fixed updates |
| Difficulty Director | Selects valid chunks from speed, state envelope, history, and seed |
| World Stream | Spawns, pools, positions, and retires selected chunks |
| Collision Policy | Produces one authoritative outcome for contacts |
| Collectible System | Resolves small-fly proximity and special-fly web hits |
| Effect State | Applies, refreshes, expires, and reports power-ups |
| Score and Settlement | Tracks distance/run stats and creates one reward settlement |
| Progression Service | Applies idempotent rewards, purchases, unlocks, and mission progress |
| Save Repository | Owns atomic persistence, schema versions, and migrations |
| Presentation Layer | Consumes events for visuals, UI, audio, and haptics |
| Telemetry Adapter | Records privacy-conscious balance and technical events |

### 19.2 Deterministic event flow

`Input -> buffered command -> fixed-step simulation -> domain events -> presentation/telemetry -> run settlement -> persistence`

Presentation code cannot mutate simulation truth. Persistence cannot grant currency from raw collision callbacks.

### 19.3 Content definitions

Spiders, effects, difficulty tiers, chunks, obstacles, missions, upgrades, economy values, and cosmetics are versioned data definitions. Runtime logic refers to stable IDs rather than scene names or display text.

### 19.4 Extension rules

- New spiders implement data profiles and capabilities; they do not fork the player controller.
- New power-ups use effect definitions and policy hooks; they do not patch collision callbacks.
- New obstacle chunks use validated metadata and sockets; they do not modify the director.
- New presentation themes subscribe to events; they do not alter physics.

---

## 20. Save and Economy Integrity

The save model includes:

- schema version;
- install/player-local identifier;
- settings;
- Silk balance;
- unlocks and purchases;
- upgrade levels;
- spider/loadout selection;
- high scores by ruleset;
- mission progress;
- tutorial state;
- last accepted settlement identifier.

Requirements:

- atomic local writes;
- backup or recovery path for interrupted writes;
- forward migrations between supported schema versions;
- unknown future fields preserved where practical;
- every run settlement has a unique ID;
- applying the same settlement twice has no effect;
- economy values use integers;
- app suspension during death/results cannot duplicate rewards.

Cloud sync is deferred, but stable IDs and idempotent settlement must make it possible later.

---

## 21. Performance and Device Requirements

Provisional targets for supported devices:

- 60 frames per second during normal gameplay
- fixed physics timestep independent of render rate
- consistent behaviour at 30, 60, 90, and 120 Hz rendering
- no routine garbage-collection spikes during active play
- pooled chunks, obstacles, flies, effects, and common particles
- bounded active-world object counts
- graceful pause/resume after app suspension
- no simulation advance from a large unbounded resume delta

Measure frame time, physics time, active object counts, pool misses, input-to-feedback time, and save duration in development builds.

---

## 22. Testing and Observability

### 22.1 Required developer tools

- physics parameter panel;
- visible velocity, speed target, rope length, tension, Reel energy, and player state;
- collision and attachment hitbox overlays;
- chunk ID, difficulty tier, seed, and entry-state display;
- slow motion and frame-step;
- fixed-seed run mode;
- input recording and replay for physics regressions;
- one-button export of a compact run diagnostic.

### 22.2 Automated checks

- release preserves velocity within tolerance;
- Reel-In shortens length at the configured rate and never teleports;
- invalid targets do not create a constraint;
- settlement is idempotent;
- a collision produces only one outcome;
- power-up refresh and expiry rules are stable;
- a seed produces the same chunk sequence for the same content version;
- save migrations preserve balances and unlocks;
- pooled objects reset all gameplay state;
- standard mode ignores permanent upgrades;
- every released chunk passes metadata and route-validation checks.

### 22.3 Playtest signals

Track:

- run duration and distance;
- restart choice and restart latency;
- death cause and active chunk;
- distance at first use of each mechanic;
- special-fly attempts and hit rate;
- Reel energy usage;
- frame-time percentiles and device class.

Do not collect unnecessary personal information. Telemetry must be optional where required and resilient when offline.

---

## 23. Delivery Plan and Quality Gates

### Phase 0 — Swing laboratory

Build only:

- spider body and forward drive;
- valid anchor targets;
- attach, swing, manual release;
- Reel-In energy;
- camera and world boundaries;
- graybox debug course;
- runtime tuning and diagnostics.

Do not build currency, shops, missions, multiple spiders, ads, or procedural content.

**Exit gate**

- Attach/release behaviour is predictable across supported frame rates.
- Release preserves momentum.
- Reel-In is useful without being mandatory.
- Test players understand attach, release, and Reel-In after a short tutorial.
- Most test deaths can be correctly attributed by the player.
- The team approves one named physics preset as the baseline.

### Phase 1 — Fair endless vertical slice

Add:

- seeded chunk selection;
- three static obstacle chunks and one moving-hazard family;
- small flies;
- Shield and Tension special flies;
- distance score;
- death, results, and sub-two-second restart;
- local best score;
- basic audio, particles, and haptics.

**Exit gate**

- All selected chunks are valid for their declared speed/state ranges.
- No observed unavoidable deaths in fixed-seed testing.
- Special-fly direct hits are readable and reliable.
- Performance target is met on the lowest supported test device.
- Playtesters voluntarily choose “one more run” at a promising rate.

### Phase 2 — MVP progression

Add:

- run settlement and Silk;
- atomic versioned save;
- Magnet Fly;
- Classic spider customization;
- a small capped upgrade set;
- three mission templates;
- settings and accessibility essentials;
- analytics adapter;
- release-quality first biome.

**Exit gate**

- Economy grants cannot duplicate.
- Progress survives app suspension and migration tests.
- The basic Classic profile remains capable of every chunk.
- Upgrades do not affect standard records.
- Retention and session data justify additional content investment.

### Phase 3 — Content expansion

Candidate additions:

- alternate spiders with trade-offs;
- additional biomes and chunk packs;
- cosmetics;
- daily fixed-seed challenge;
- platform services;
- carefully tested rewarded ads;
- Rush Fly.

Twin-Web remains blocked until it has a dedicated, tested control specification.

---

## 24. MVP Acceptance Checklist

The MVP is ready for external testing when:

- Swinging is satisfying without progression rewards.
- A valid input produces immediate feedback.
- The same input and state produce explainable results.
- Manual release is the primary mastery skill.
- Reel-In has a visible resource and no hidden charge rules.
- All obstacle generation is chunk-based, seeded, and speed-aware.
- Every required route is possible with the baseline Classic profile.
- The player sees lethal information with adequate reaction time.
- Directly webbing a special fly feels deliberate.
- Death settles rewards once and explains the cause.
- Restart is fast enough to preserve flow.
- Game state survives app suspension and normal save migration.
- The game maintains its performance target on the supported device floor.
- Monetization does not alter standard competitive performance.

---

## 25. Decisions Required Before Repository Scaffolding

These choices belong in short architecture decision records and must be made before feature implementation:

1. **Engine and language:** Choose based on 2D physics workflow, Android/iOS export, testing, profiling, store SDK needs, and AI maintainability.
2. **Physics units and fixed timestep:** Lock world scale, timestep, and maximum catch-up policy.
3. **Minimum supported Android device/API:** Required for performance budgets and test hardware.
4. **Art pipeline:** Vector, raster, skeletal animation, or a deliberate combination.
5. **Save ownership:** Local-only MVP and the intended future cloud-sync provider boundary.
6. **Telemetry and crash reporting:** Provider or local abstraction, consent behaviour, and offline queue limits.
7. **Release name and brand identity:** Replace the current codename after store, domain, trademark, and visual-conflict checks.

Once these are decided, create the repository with Phase 0 only. Later phases should be milestones with acceptance gates, not one undifferentiated implementation request.

---

## Appendix A — Major Corrections from v1.0

- Replaced ambiguous “tap again or auto-release” behaviour with manual release.
- Replaced unclear limited Reel-In uses/cooldown with a visible energy model.
- Defined actual world movement, camera behaviour, and death boundaries.
- Defined valid web anchors and special-fly ray interception.
- Deferred Twin-Web because it requires separate controls and complex rope physics.
- Replaced unrestricted random obstacles with seeded, validated chunks.
- Centralized collision resolution for shields, phasing, and breakable obstacles.
- Separated caught flies from persistent Silk.
- Removed the exploitable “starting Silk per run” upgrade.
- Separated standard records from permanent gameplay modifiers.
- Added data contracts, deterministic event flow, save integrity, diagnostics, tests, and staged delivery gates.
- Marked the current title as an internal codename due to existing naming and concept overlap.

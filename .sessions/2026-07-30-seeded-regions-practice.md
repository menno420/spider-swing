# Seeded regions and checkpoint practice session

> **Status:** `complete`

## Goal

Turn the endless course into reproducible but varied 5,000 m regions, then
make every reached region start available as an explicitly non-record practice
checkpoint.

## Scope guard

This session may add one centralized region catalogue; seed the existing
curated pattern director; differentiate regions through validated pattern
pools, recovery cadence, presentation-owned forest ambience, and transition
feedback; persist reached checkpoints through an explicit save migration; add
a touch-first practice route; mark practice settlements as ineligible for
flies, records, checkpoint unlocks, and future leaderboards; extend diagnostics
and Claude's simulation lab only where the new production contracts require;
add regression coverage; refresh the development build; and update living
documentation.

It must not change swing physics, Reel/Burst/Dive values, aim forgiveness,
web reach, maximum course speed, collision sizes, the first 2,000 m inward-rail
protection, spider upgrades, monetization, production publishing, or the
byte-frozen GDD. Every required pattern remains clearable by the unupgraded
Garden Spider.

## About to happen

Implement the region definition and seeded selection seams first, prove
determinism, variation, recovery spacing, and route envelopes, then layer
checkpoint lifecycle and presentation over those authoritative contracts.
Practice mode will be impossible to mistake for a standard run and will not
write competitive or economy progress.

## Previous-session review

**previous-session review:** PR #45 upgraded Claude's simulation lab to adaptive
bot v2 with late-course starts, parameter sweeps, and expanded resource/economy
metrics without changing gameplay. This session preserves those improvements,
uses the new late-start seam for region verification, and will not duplicate
its completed sweep work.

## Shipped

- `game/domain/course_region_catalog.gd` establishes one authoritative
  5,000 m region vocabulary shared by generation, saves, UI, and tools:
  Ancient Forest teaches mixed fundamentals, Bramble Canopy emphasizes rapid
  high↔low decisions, and Silk Hollow emphasizes suspended hazards and precise
  rail openings.
- `game/application/course_pattern_catalog.gd` and `course_stream.gd` turn the
  existing curated chunks into a reproducible seeded director. Seeds vary
  validated pattern order rather than individual geometry, the final two
  resolved challenge chunks cannot repeat, each new region opens safely, and
  fixed Canopy/Hollow recovery pockets bound hard-pattern streaks.
- `game/domain/player_progress.gd`, `progression_service.gd`, and the
  save/front-end flow add schema-5 checkpoint persistence. Existing schema-4
  saves infer already-reached 5,000 m and 10,000 m checkpoints from best
  distance without reapplying the schema-4 twenty-level upgrade migration.
- Home now exposes Region Practice cards. An unlocked practice run starts at
  the exact checkpoint distance and distance-paced speed through the ordinary
  safe guided-web reset, while its authoritative settlement disables flies,
  best-distance records, later checkpoint unlocks, and future leaderboard
  eligibility. A persistent HUD notice prevents practice from masquerading as
  a standard run.
- `game/presentation/scripts/swing_lab.gd` gives each region a restrained
  presentation identity and a transition banner: Canopy uses a greener veil,
  hanging silk, and motes; Hollow uses cooler darkness, web arcs, and dew.
  These decorations do not alter collision or targeting and freeze under
  reduced motion.
- Run snapshots and diagnostics carry run mode, start distance, course seed,
  active region, and active pattern. The headless simulator now accepts
  `--course-seed`/`--course-seeds`, reports death region/pattern, starts
  late-course runs through the production checkpoint reset, separates course
  order from bot-imperfection randomness, and deduplicates delayed web/Burst
  intents.
- The regression suite grows from 93 to 97 contracts. It proves seeded
  determinism and variation, region pools, non-repetition, recovery spacing,
  route clearance, checkpoint migration, noncompetitive settlement, safe
  checkpoint starts, practice UI/HUD state, visual ownership, and packaged
  build identity.
- Build identity advances to `0.15.0-seeded-regions-test`, Android version
  code 31, and display name `Spider Swing Seeded Regions (dev)`. Decision
  D-0025 and the application/domain/front-end/simulator/testing documentation
  record the new contracts without editing the frozen GDD.

## Decisions flagged

- Vary curated pattern order with a saved/reported course seed; never place
  individual hazards randomly. Reproducibility is required for debugging,
  simulation, and fair comparison.
- Change course identity every 5,000 m. A region owns a content focus, quirk,
  recovery cadence, and presentation treatment, but never physics, targeting,
  collision truth, maximum speed, or the protected opening.
- A checkpoint is earned only by crossing its distance during a standard run.
  Practice reproduces the reached late-game start with the player's current
  spider and upgrades, but cannot write economy, records, later unlocks, or
  future leaderboard eligibility.
- Recovery chunks are authoritative rhythm boundaries. Silk Hollow's
  tight-gap schedule cannot override one, and the challenge cooldown evaluates
  the final resolved patterns rather than only the seed's first candidate.
- Keep the initial region set deliberately small. Device evidence should decide
  whether each identity is readable and fun before adding more regions,
  obstacles, or visual density.

## 💡 Idea

Let a future daily challenge publish one course seed and one standard-only
ruleset. Because the director is now reproducible and practice eligibility is
explicit, players could compare a shared course without weakening ordinary
endless variety or letting checkpoint attempts enter its board.

- **📊 Model:** gpt-5.6-sol · high · feature build

## Capability delta

None. The established repository connector, exact-tree publishing fallback,
pinned Godot CI, and Android artifact-inspection path covered the work. The
local container still lacks Godot, so engine authority remains the mandatory
CI job rather than a weakened local substitute.

## Verification evidence

- The implementation tree is byte-identical locally and remotely at PR
  [#48](https://github.com/menno420/spider-swing/pull/48) source
  `a2124776f6d494d6872eb1c59524202114d78769`, tree
  `885883b57243c09ef7f85b5e0f7929cd3923cf0c`.
- Pinned Godot `4.7.1.stable.official.a13da4feb` `game-quality`
  [run 30575710624](https://github.com/menno420/spider-swing/actions/runs/30575710624)
  passes clean import, clean front-end boot, and all 97/97 contracts:
  49 physics, 22 mobile HUD, 16 front-end, and 10 bootstrap.
- Android
  [run 30575710564](https://github.com/menno420/spider-swing/actions/runs/30575710564)
  produced verified
  [artifact 8772613930](https://github.com/menno420/spider-swing/actions/runs/30575710564/artifacts/8772613930).
  Its 61,544,120-byte ZIP matches GitHub digest
  `sha256:7fdd732ab93884fb6e9f80a3f3678d9db2d1e124291d221e1c223d1970dbdd3b`
  and passes archive validation. The 61,947,599-byte APK passes archive
  validation with SHA-256
  `c78612c90a2094aa0a78d86887189a5645b7bd17af419e6ac01d9f42d5cf76c3`;
  `build-info.txt` proves the exact source, version, dev package, and display
  name, and the packaged Godot payload contains both course catalogs.
- The in-progress Substrate gate reports only this session's designed
  `HOLD (by design)`. The checksum-pinned GDD remains byte-identical at
  `a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53`.
- Final `python3 bootstrap.py check --strict --require-session-log
  --session-log .sessions/2026-07-30-seeded-regions-practice.md` reports the
  session complete and all checks passed.

## Documentation audit

Decision D-0025, the current-state ledger, front-end flow, phase-0 laboratory,
simulation lab, testing inventory, layer READMEs, build identity, regression
suite, and this session agree. The frozen GDD and all swing physics, Reel,
Burst, Dive, aim, reach, speed, collision, upgrade, and monetization sources
remain unchanged.

## Remaining owner review

On device, confirm that the 5,000 m and 10,000 m transitions are readable
without interrupting play; Canopy's high↔low rhythm and Hollow's precise
suspended-hazard rhythm feel distinct but fair; recovery pockets arrive before
fatigue becomes frustration; visual treatments preserve hazard contrast; and
an unlocked practice run starts safely, remains unmistakably
`NON-COMPETITIVE`, and never changes flies or best distance.

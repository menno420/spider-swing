# Headless simulation lab session

> **Status:** `complete`

## Goal

Answer Menno's automated-testing request with a working tool: a headless
batch-run simulation lab that drives the authoritative simulation with an
imperfect scripted player and reports distance, death-cause, and resource
metrics — so balance changes can be compared in seconds before spending an
owner device playtest.

## Scope guard

This session may add `tools/simulate.gd`, its documentation, and living-doc
pointers. It must not change any gameplay value, simulation rule, test
contract, build identity, save schema, or CI gate. The declared suite remains
91 contracts; the lab is diagnostic instrumentation, never a third gate.

## Previous-session review

**previous-session review:** PR #40 (Reel speed playtest correction) merged
cleanly: level-zero Balanced Reel now 320 px/s over the 2.0-second meter, max
Garden Silk Winder 416 px/s inside the owner-tested band, all 91 contracts
green and the Android artifact verified. Its remaining owner review — whether
320/416 px/s reads as arc control on device — is untouched by this session.

## Shipped

- `tools/simulate.gd` — the simulation lab. Drives `SimulationWorld` +
  `CourseStream` unpaced and headless with a seeded imperfect player model
  (aim error, reaction delay, decision cadence; novice/intermediate/expert),
  mirrors the session's per-tick orchestration (Burst Frenzy, streaming,
  one-rescue-then-death), and reports per-run rows plus summary statistics
  (mean/median/p10/p90 distance, death causes, death distance bands, flies,
  Reel-empty count, Bursts, webs), with optional JSON export. The bot reads
  only player-visible information: its own motion, the fly-trail route
  language, and the same `nearest_solid_point` tap forgiveness real input
  receives.
- `docs/technical/simulation-lab.md` — usage, the player model, the questions
  the lab can and cannot answer, the unadapting-bot interpretation caveat,
  and first dated observations.
- `docs/technical/testing.md` — a pointer section making explicit the lab is
  not a third gate.
- `docs/current-state.md` In-flight refresh and a `docs/CAPABILITIES.md`
  append recording the in-container proof.

## Decisions flagged

- The lab asserts nothing and never runs in CI: the two gates remain
  `tools/verify.py` and `bootstrap.py check --strict`. A statistical tool
  that could red a merge would invite tuning-to-the-bot.
- `RunDriver.run()` deliberately mirrors the small `_step_once()`
  orchestration rather than restructuring `SwingLabSession`; extraction of a
  shared driver is deferred until the duplication grows past a handful of
  lines.
- Bot findings are labeled as bot-model findings, never human truth; the doc
  carries the caveat prominently.

## 💡 Idea

Give `CourseStream` an optional generation seed and rotate a "daily course"
from it — one shared fair course per day for score comparison, and a
`--course-seed` sweep flag in the lab so balance conclusions can be tested
for generalization beyond the single fixed course.

- **📊 Model:** fable-5 · high · feature build

## Capability delta

Re-verified in-container Godot: a fresh official
`Godot_v4.7.1-stable_linux.x86_64` download ran the complete verify surface
twice this session. New verified capability appended to
`docs/CAPABILITIES.md`: the simulation lab completes a 20-run batch in about
one second in this container, and its metrics discriminate skill tiers,
spider profiles, and upgrade levels.

## Verification evidence

- `python3 tools/verify.py --require-godot` on pinned
  `4.7.1.stable.official.a13da4feb`: all steps PASS, 91/91 contracts, both
  before and after adding `tools/simulate.gd` (the import step parses the new
  script; the architecture scan stays green).
- Lab discrimination evidence (balanced preset, level 0 unless noted):
  Garden means over 20 runs — novice ≈560 m, intermediate ≈1 264 m, expert
  ≈1 829 m; Springtail's batch died to obstacles only (impact shell removed
  rail deaths); the 2.0 s Reel meter never emptied under corrective reeling;
  maxed-everything Garden scored slightly below level 0 for the unadapting
  bot (caveat documented).
- Pre-flip `bootstrap.py check --strict`: the designed born-red HOLD for this
  card plus known non-blocking staleness advisories; the post-flip strict
  check runs green as the last step before the final push (its guard-fire
  telemetry delta is committed with this session).
- PR [#41](https://github.com/menno420/spider-swing/pull/41) is open with the
  full template; `game-quality` and `substrate-gate` run on the PR head and
  the session remains subscribed to drive it to green.

## Documentation audit

`simulation-lab.md`, the `testing.md` pointer, the current-state In-flight
note, this card, and the CAPABILITIES append all agree: diagnostic tool, two
gates unchanged, 91 contracts unchanged, no gameplay values touched.

## Remaining owner review

Nothing playable changed, so no device pass is required. When planning the
next Reel device comparison, the lab's "corrective reeling never empties the
2.0 s meter" observation is worth one targeted on-device look: if real thumbs
also rarely empty it, Silk Reserve's value case weakens and the meter could
be tightened instead.

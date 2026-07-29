# Deep progression foundation session

> **Status:** `complete`

## Goal

Turn the current three-track, five-level prototype into one coherent
progression foundation: every comparison spider receives the same five
small-step core tracks plus two identity tracks, existing upgraded saves retain
their completion proportion, milestone levels read clearly, and the shop remains
usable on the owner's 1040×480 device. In the same contained update, remove the
Classic spider's visible fixed-tick shimmer and add restrained state-based pose
motion without changing authoritative simulation.

## Scope guard

This session may change data-defined upgrade tracks and curves, progression save
migration, Shop presentation, custom-render interpolation, character texture
import settings, regression contracts, documentation, and development build
identity. It must not change level-zero swing physics, web reach, aim
forgiveness, input rules, collision geometry, route generation, required-route
fairness, standard scoring, or the GDD. It must not add paid power, production
IAP, spider locks, a campaign, temporary style modes, extra Burst charges, or
new obstacle difficulty.

## Previous-session review

**previous-session review:** PR #27 shipped a continuous, varied Ancient Forest
course and a verified Android artifact. Menno approved the environment direction
and then identified progression depth and the spider's blurry/vibrating motion
as the more valuable next systems work. The current source confirms that the
course already balances high, low, and centre route plans, while upgrades remain
three profile-specific five-level tracks and the custom-drawn spider consumes
fixed snapshots directly.

## Decisions flagged

- Use 20 levels for every track: enough room for small increments and four
  visible breakthroughs without stretching the prototype to an arbitrary 25.
- Define five shared track kinds once and instantiate them for every spider;
  give each profile exactly two separately named identity tracks.
- Make levels 5, 10, 15, and 20 grant one extra tuning step rather than a new
  input rule. Active breakthroughs such as chained Bursts need their own control
  and fairness specification.
- Preserve old save completion by mapping each legacy level to four new levels;
  keep all five spiders open during the comparison phase.
- Interpolate only presentation coordinates and orientation. Simulation,
  collision, input, and deterministic replay remain fixed at 60 Hz.
- Keep unlock enforcement, temporary ability loans, fixed-stat Challenge mode,
  and any monetization implementation outside this update.

## 💡 Idea

Treat a breakthrough as a conspicuous double tuning step in the foundation, then
reserve mechanic-changing breakthroughs for separately replay-tested ability
modules. That makes milestones meaningful now without quietly changing the
control grammar.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

- `python3 tools/verify.py --require-godot` passed architecture self-tests
  (14/14), the repository architecture scan, Godot 4.7.1 discovery, clean
  headless import, front-end boot, and 86/86 contracts: 42 deterministic
  physics, 21 mobile/presentation, 13 front-end/progression, and 10 bootstrap.
- Ready PR
  [#28](https://github.com/menno420/spider-swing/pull/28) publishes the exact
  locally verified tree `21c1925d7b418fb5d8d4e8c2af708e48cf4775b8` at source
  `c8d093109860d4a0716aa2e3ddd7b6d163c82a70`.
- `game-quality` run
  [30489461720](https://github.com/menno420/spider-swing/actions/runs/30489461720)
  passed the complete 86-contract suite on Godot 4.7.1.
- `android-debug` run
  [30489461754](https://github.com/menno420/spider-swing/actions/runs/30489461754)
  passed and produced
  [`spider-swing-android-debug` artifact 8739088355](https://github.com/menno420/spider-swing/actions/runs/30489461754/artifacts/8739088355),
  61,370,244 bytes, expiring 2026-08-12, with GitHub digest
  `sha256:4e466ec3453c51dc2e2f0d9a2828916fe258bb2be0e76256e4b3895a69982eac`.
  The downloaded ZIP matched that digest and passed archive validation. Its
  61,770,490-byte APK passed archive validation with SHA-256
  `310ea5419e0bd0df5ee78c7a1626a5a5ef560b272229ef2f79c40a4c186e14b5`;
  `build-info.txt` proves version `0.10.0-deep-progression-test`, exact source,
  dev package, and display name `Spider Swing Deep Progression (dev)`.

## Documentation audit

README, current-state and capability ledgers, product direction, front-end and
Swing Laboratory references, testing contract, project context index, and
domain/application/presentation/asset folios now match verified source. The GDD
remains byte-identical at
`a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53`;
no ADR or frozen design file changed. No live document retains an unrendered
template slot or drafting marker.

## Remaining owner review

Install the source-identified development APK and compare a migrated near-max
Garden Spider against the previous build. Confirm that the spider no longer
vibrates or separates visually from its web; the subtle Reel/Burst/glide poses
remain readable; seven Shop rows are comfortable at 1040×480; and levels 4→5
make the breakthrough obvious. The reversible balance decision needing the most
attention is the shared +30% maximum Reel track, which is below the former
maxed Garden track because faster radius shortening already feels powerful.

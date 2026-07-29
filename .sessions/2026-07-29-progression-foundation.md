# Deep progression foundation session

> **Status:** `in-progress`

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

`[[fill: exact local gates, PR checks, Android artifact, and source identity]]`

## Documentation audit

`[[fill: updated living docs and confirmation that binding design files stayed unchanged]]`

## Remaining owner review

`[[fill: focused device checks and any decide-and-flag follow-up]]`

# Debug depth-testing access session

> **Status:** `complete`

## Goal

Make consecutive Android test builds preserve local saves, let DEBUG start the
deterministic course at an arbitrary distance, and let the owner compare real
saved upgrades against a session-only resolved-level overlay without changing
physics, tuning, economy, or persistent progression.

## Scope guard

Android debug signing, debug-only run/progression orchestration, Garage/Shop/HUD
disclosure, deterministic and persistence contracts, layout measurement, build
identity, and living documentation. No release signing, store publishing,
economy change, upgrade purchase bypass, physics change, or second settlement
path.

## Shipped

- `.github/android/` and `android-debug.yml` now use one conventional public
  debug signer. The workflow pins the key file and certificate digests, verifies
  the exported APK signer, and contains no release-signing or publishing path.
  A contract fails if per-run key generation returns.
- DEBUG → RUN accepts an exact typed metre value and restarts through
  `RUN_PRACTICE` on the active seed. It therefore awards no flies, record,
  checkpoint, or future leaderboard eligibility; the HUD says so plainly.
- `ProgressionService` resolves a selectable 0–20 upgrade overlay without
  changing `PlayerProgress`. Garage and Shop disclose `NOT OWNED`, purchases
  pause, overlay runs are noncompetitive, and `OWNED` restores the exact saved
  level dictionary.
- The real `SwingLabView` is measured in a 1280×720 headless `SubViewport`.
  Every debug category/card and the typed field stay inside the panel; all debug
  access disappears when `show_debug_tools` is off.
- Build identity is `0.19.0-depth-testing`, Android version code 35. The
  technical reference, current-state ledger, README, ADR, tests, and decisions
  describe the same contract.

## Previous-session review

**previous-session review:** The newest completed session established the
real-name-first spider identity rule and added a discoverable Field Guide. It
also left the owner device playtest as the decisive gate. This session does not
revisit that identity work; it removes the installation and traversal barriers
that currently prevent deep, repeatable device testing of the shipped game.

## Moving-main reconciliation

PR #55 landed while this branch was active. Its owner-direction session,
owner-question answers, and D-0033 are preserved exactly. This session's
decisions moved to D-0034/D-0035, and the binary guard ledger preserves main as
a byte-for-byte prefix before this session's later records. The merged tree was
then re-verified in full.

## Verification

- Official Godot `4.7.1.stable.official.a13da4feb` Standard executed import,
  front-end boot, the 14-fixture architecture self-test, live architecture scan,
  and **116/116** headless contracts: 51 physics, 11 biology, 23 mobile/layout,
  20 front-end/progression, and 11 bootstrap/build.
- The new contracts prove no-award/no-record settlement, off-grid seeded
  geometry equality with traversal from zero, overlay non-persistence, exact
  owned-level restoration, debug gating/disclosure, stable signing, and measured
  1280×720 fit.
- `game-quality` run
  [30646172533](https://github.com/menno420/spider-swing/actions/runs/30646172533)
  passed on exact source `6bb902273d2341e52a0a17678b32cab72527e500`.
- `android-debug` run
  [30646174062](https://github.com/menno420/spider-swing/actions/runs/30646174062)
  passed every signing/export assertion and produced
  [artifact 8799510029](https://github.com/menno420/spider-swing/actions/runs/30646174062/artifacts/8799510029).
  The downloaded 61,782,748-byte ZIP matched GitHub's SHA-256 `8be96ccd…`;
  its intact 62,186,268-byte APK has SHA-256 `5835c002…`, source-identifying
  build info, and certificate SHA-256 `83ff0bc2…`, exactly the pinned signer.
- `python3 bootstrap.py check --strict` reports only the designed hold while
  this card remains `in-progress`; the final flip removes it before merge.

## Decide-and-flag

The stable signer is committed rather than secret-backed because it is
deliberately public debug material, makes every clone reproducible, and cannot
silently depend on repository-secret continuity. It must **NEVER** be used for
Google Play, release signing, production, or any signed distribution. Rotating
it is possible but forces another uninstall boundary. No owner decision remains
open for this slice.

## Owner device gate

The next APK install needs one final uninstall because all older builds used
unrelated throwaway certificates. Install this stable-key artifact after that;
every later stable-key build can update in place and preserve saves. Issue #2's
open device playtest should now cover save survival across two builds, arbitrary
far-distance geometry/regions, and `OWNED` versus upgraded A/B feel.

## 💡 Idea

After this slice is device-proven, consider named debug scenarios that bundle a
seed, distance, spider, and overlay level into a single reproducible test case.
Keep them as session-only orchestration over the same authoritative paths rather
than introducing saved cheat profiles.

- **📊 Model:** gpt-5 · high · feature build

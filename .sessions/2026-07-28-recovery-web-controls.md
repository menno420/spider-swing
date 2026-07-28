# Phase 0.8 recovery web controls session

> **Status:** `complete`

## Goal

Turn the latest Android recordings into a safer, more deliberate control
contract: a Burst or Dive Pull can always be interrupted by a normal recovery
web, rapid double-taps cannot swallow that recovery input, forward right-hand
taps have practical reach, and lower anchor windows exist before the hazards
that need downward redirection.

## Previous-session review

**previous-session review:** PR #13 made pull distance predictable and Reel
speed-neutral, but the next device recordings show that the short pull state
still monopolizes rapid double-taps. The percentage controls and solid-edge
resolver remain valid; input handoff and course-authored lower opportunities need
this follow-up.

## Shipped

- `SimulationWorld` now hands an active percentage pull into a normal upper-solid
  recovery web in the same fixed step. A downward tap can cancel the pull, and
  cooldown remains active without owning ordinary web input.
- `SwingLabSession` converts a platform-classified double-tap into web intent
  while a pull is active or while the detached spider is still cooling down.
  A ready detached double-tap still starts the configured targeted Burst.
- The candidate range is 1000 px and DEBUG can explore 500–1400 px. DEBUG also
  exposes shared pull cooldown and the explicit default `RELEASE` versus optional
  atomic `RETARGET` attached-tap contract.
- Every challenge pattern now authors one short cyan lower-root anchor window
  before its key hazard, with gaps between windows preserved.
- Build `0.3.1-recovery-web-test` and 50 runtime contracts cover the new control,
  course, tuning, tutorial, documentation, and Android identity behavior.

## Decisions flagged

- Recovery attachment uses the pull's configured fixed exit velocity plus its
  retained tangential velocity. It does not finish the remaining percentage
  displacement after the player interrupts it.
- `RELEASE` remains the default because it preserves the owner's and GDD's manual
  release model. `RETARGET` is a reversible debug comparison, not an approved
  replacement.
- Lower roots are targetable nonlethal structural surfaces. They are deliberately
  short and pattern-authored rather than a continuous floor safety net.

## 💡 Idea

Treat Burst and Dive Pull as interruptible movement transitions rather than
temporary input modes: their cooldown limits repeated power use, but never owns
or disables the spider's ordinary web.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

- Local
  `GODOT_BIN=/tmp/spider-swing-godot-4.7.1/Godot_v4.7.1-stable_linux.x86_64 python3 tools/verify.py`
  passed all six stages: 14 architecture fixtures, live inward scan, Godot
  4.7.1 discovery, clean import, boot smoke, and **50/50** runtime contracts
  (23 physics, 10 mobile HUD, 8 front-end, 9 bootstrap/build).
- PR #14 `game-quality` run
  [30393908882](https://github.com/menno420/spider-swing/actions/runs/30393908882)
  passed the same contracts from published implementation commit
  `1d4e3269c317a4b1323ccfe9e7c57eaea137d7d4`.
- PR #14 `android-debug` run
  [30393906389](https://github.com/menno420/spider-swing/actions/runs/30393906389)
  passed and produced
  [`spider-swing-android-debug`](https://github.com/menno420/spider-swing/actions/runs/30393906389/artifacts/8702034654)
  artifact `8702034654`. The downloaded 56,747,428-byte ZIP matched
  `sha256:b23c0f462339b017c2a564873522db0357fb4937e1ee70b88913eaa179597339`;
  its 57,128,524-byte APK passed archive verification and had SHA-256
  `4633b9b84b16cf52c29436ad355aec223cb201267be7a1b2eecd80f2705c6b4b`.
  `build-info.txt` proves version `0.3.1-recovery-web-test`, source
  `1d4e3269c317a4b1323ccfe9e7c57eaea137d7d4`, package
  `com.menno420.spiderswing.dev`, and display name
  `Spider Swing Recovery Web (dev)`.
- The exact locally verified implementation tree
  `52b62f3256a4cad51e44a6acd36799c6d8081fb4` matched the GitHub-published tree.
  The pre-close strict gate reported only this card's intentional `in-progress`
  hold as exit-affecting; its guard-fire telemetry is retained.

## Documentation audit

README, tutorial, Phase 0 playtest guide, front-end/testing guides, current-state,
decision and capability ledgers, build workflow/preset, diagnostics, and tests
describe the same recovery, reach, tap-mode, lower-window, and build contracts as
source. The checksum-pinned GDD was not modified. Render reports zero unfilled
placeholders.

## Remaining owner review

Install the PR #14 APK and verify immediate post-Burst recovery at several
timings; compare DEBUG `TAP RELEASE` with `TAP RETARGET`; judge the 1000-pixel
right-hand reach; and confirm the cyan lower anchor windows are useful without
making downward recovery automatic. Automated evidence cannot approve feel.

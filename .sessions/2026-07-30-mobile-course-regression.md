# Mobile course regression session

> **Status:** `complete`

## Goal

Repair the device-observed touch scrolling dead zones in Shop and Settings, then make the deterministic post-2000 m high↔low weave readable and visually complete without changing baseline swing physics, full-screen aim reach, attachment forgiveness, progression, save data, or the protected opening.

## Scope guard

This session may change reusable front-end input propagation, the two new weave patterns, presentation-owned obstacle asset fitting, regression contracts, living documentation, and development build identity. It must not change spider physics, input grammar, currency, upgrades, save schema, the 0–2000 m route policy, the frozen GDD, or any deferred monetization/Campaign/Challenge system.

## Previous-session review

**previous-session review:** PR #30 merged a coherent forest-web theme, custom body/Silk selectors, touch-scroll configuration, and four post-2000 m route patterns. Menno's 1040×480 recordings now prove that drag gestures still fail when they start on several card regions, while deterministic chunk 30's low→high weave is too abrupt and its tall stump art is visibly cropped at rectangular edges.

## Shipped

- `SpiderUiTheme` gives every descendant control in the Shop and Settings
  scroll trees `MOUSE_FILTER_PASS`. Their existing `ScrollContainer` remains the
  one inertial gesture owner, its 12-pixel deadzone still distinguishes a drag
  from a tap, and `follow_focus` remains disabled.
- Both authored weave directions retain the same post-2000 m placement and
  high↔low intent, but use 235-pixel growth, 420 pixels between cue centres, and
  a separately asserted central transition band.
- Tall narrow rail growth uses the complete hanging-vine texture at its natural
  aspect ratio with conservative horizontal overscan. Broad obstacles keep
  their existing aspect-preserving cover crop, and collision geometry remains
  authoritative.
- The existing 88-contract suite now rejects nested scroll dead zones, abrupt
  weave spacing, an undersized central transition band, excessive weave height,
  and cropped-stump rendering for tall narrow growth.
- Build identity is `0.11.1-mobile-route-polish-test`, Android version code 24,
  display name `Spider Swing Mobile Route Polish (dev)`.

## Decisions flagged

- Preserve the existing `ScrollContainer` as the one scroll owner and make its descendant controls bubble touch gestures instead of adding a second gesture system.
- Relax only the newly added weave pair using wider cue spacing and shorter growth; leave all established patterns and physics untouched.
- Fit tall rail growth with a vertically appropriate forest asset and conservative visual overscan so finished art no longer ends on a cropped rectangle.

## 💡 Idea

Add a presentation-debug course jump that starts immediately before a named authored pattern, so device reviews can compare one route repeatedly without playing several kilometres first.

- **📊 Model:** gpt-5 · high · runtime bugfix

## Verification evidence

- `git diff --check`, the 14-fixture architecture self-test, and the inward
  dependency scan pass on the exact implementation tree.
- Pinned Godot `4.7.1.stable.official.a13da4feb` completed a clean import,
  front-end boot, and all 88/88 contracts locally.
- The pre-flip
  `python3 bootstrap.py check --strict --require-session-log --session-log
  .sessions/2026-07-30-mobile-course-regression.md` reported only this card's
  designed in-progress hold.
- Ready PR
  [#32](https://github.com/menno420/spider-swing/pull/32) contains the exact
  implementation source `e4788245d7618238404e5058023dcde8433e265a`.
- PR `game-quality` run
  [30531249630](https://github.com/menno420/spider-swing/actions/runs/30531249630)
  passed on that source. PR `android-debug` run
  [30531250200](https://github.com/menno420/spider-swing/actions/runs/30531250200)
  produced
  [artifact 8754781683](https://github.com/menno420/spider-swing/actions/runs/30531250200/artifacts/8754781683),
  61,390,731 bytes with GitHub digest
  `sha256:c4186c880efa9267dd8f4072e3df2d67914ffeaa0f577e63a6aab0963a986b1b`.
  The downloaded ZIP matched that digest and passed archive validation. Its
  61,791,366-byte APK passed archive validation with SHA-256
  `4c870f628d8de16f1802fad60d06d00d5864982dd552752991ddabd57b374f3d`;
  `build-info.txt` proves the new version, exact source, dev package, and display
  name.
- The checksum-pinned GDD remains byte-identical at
  `a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53`.

## Documentation audit

README, current-state and capability ledgers, front-end and Swing Laboratory
contracts, testing reference, project index, and application/presentation
folios match the verified implementation. The previously stale Phase 0.23
in-flight claim and Android workflow display label are corrected. No ADR or
frozen game-design file changed.

## Remaining owner review

Install artifact 8754781683 after uninstalling the previous ephemerally signed
development app. Confirm that Shop and Settings drag smoothly when the gesture
starts on purchase buttons, descriptions, milestone rows, panel edges, toggles,
and empty card space while short taps still activate exactly once. Compare
Classic, Dew, and Ember in the live Silk preview. After 2000 m, pass both weave
directions and confirm the shorter growth, wider cue spacing, central transition
band, and complete vine silhouettes are readable rather than unfair.

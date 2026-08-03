# Rebuild the tutorial around the live game

> **Status:** `complete`

## Goal

Replace the six-step debug-diagram tutorial with stable, focused lessons that
look recognizably like the current Spider Swing game, remain readable on short
landscape phones, and describe only mechanics verified in live source.

## Scope guard

This PR changes the tutorial catalogue, presentation, front-end contracts,
documentation, and Android build identity. It does **not** add lesson practice,
change simulation or progression, alter course generation, or implement the
difficulty-mode profiles planned for the following PRs.

## Previous-session review

**previous-session review:** PR #155 corrected a documentation grounding block
while this session was starting. It was docs-only and changed no tutorial seam;
the claim branch was rebased onto its merged commit before implementation. PR
#148's pressure-curve work also remained intact and is the prerequisite for the
third PR in this owner-requested sequence.

## Shipped

- Eight stable lesson ids with one declared goal and an exhaustive, single-owner
  mechanic list: opening pressure, Attach, swing/release, Reel, Anchor Burst,
  Dive/recovery, course reading, and survival/restart.
- `TutorialPreview` now stages the selected production spider, body tint and
  Silk treatment over Bramble Canopy art with real rails, obstacles, pursuing
  bird, fly, target/route cues, and gameplay-shaped HUD controls. It remains a
  presentation-only deterministic snapshot and exposes explicit asset fallback
  evidence instead of retaining the primitive cyan-grid renderer.
- Reduced Motion freezes each preview at a useful pose. Copy, preview, and four
  80 px actions remain enclosed at 1280×720, 1280×600, and strict 1040×480,
  with no nested scroller or competing gesture owner.
- The ordinary launch is now truthfully labeled `START RUN`; direct lesson
  practice remains the next PR rather than being implied here.
- Build `0.40.0-live-tutorial`, Android version code 60, display name
  `Spider Swing Live Tutorial (dev)`.

## Verification

- `python3 tools/verify.py --require-godot` with pinned Godot
  `4.7.1.stable.official.a13da4feb`: all stages passed and **234/234** contracts
  passed, including **36** front-end contracts.
- `game-quality` run
  [30858311330](https://github.com/menno420/spider-swing/actions/runs/30858311330)
  passed at implementation source `7e91bf6fa610b0707f911a66226ad9342984d2d9`.
- Falsification: changed the preview contract's `primitive_only` result to true.
  The runner exited 1 with `tutorial lesson opening_pressure does not resolve
  the live game art contract`; restoring the exact line returned **234/234**.
- `git diff --check` passed; stale six-page, fake-practice, old-build, and old
  Android-identity strings are absent from the changed live surfaces.

## Android artifact

- `android-debug` run
  [30858311721](https://github.com/menno420/spider-swing/actions/runs/30858311721)
  passed and produced artifact
  [8873340090](https://github.com/menno420/spider-swing/actions/runs/30858311721/artifacts/8873340090),
  77,897,776 bytes, expiring 2026-08-17.
- Downloaded ZIP SHA-256:
  `6ca24bc3a9e8ae0739928c6135c00ac749bfd8a12dc4f9a06610e3fd2f181d73`;
  APK SHA-256:
  `441f2fc89150d08093f812a464d4a2db4517e652536c507ea7ac9b2c89fce8c6`.
  The APK is a valid Android package with `classes.dex`, passed full ZIP
  integrity, and its build info matches version, source, package, display name,
  and stable debug signing-key digest.

## Device questions

1. Does every lesson immediately look like the run you enter, including the
   selected spider and Silk treatment?
2. At 1040×480, is each page readable without clipped copy or blocked controls?
3. With Reduced Motion on, does every frozen pose still teach the intended idea?
4. Are Burst and Dive now distinct and understandable without dense copy?
5. Does `START RUN` clearly communicate an ordinary endless launch?

## Pull request

- PR [#156](https://github.com/menno420/spider-swing/pull/156) — Rebuild the
  tutorial around the live Spider Swing experience.
- Owner action needed before merge: **None**. Device feel review follows from
  the installable artifact; issue #2 remains open.

## 💡 Session idea

The stable lesson ids and mechanic-owner metadata are already the right seam for
short practice runs: PR 2 can add objective and seed fields to the same model,
without teaching by step index or turning this presentation control into a
second simulator.

- **📊 Model:** gpt-5.6 · high · feature build

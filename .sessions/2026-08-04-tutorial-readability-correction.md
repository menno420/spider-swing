# Correct tutorial orientation and teaching clarity

> **Status:** `complete`

## Goal

Use the owner's 1040×480 device recording to correct upside-down Bramble
obstacles and make every tutorial page readable and understandable without
requiring the player to decode small prose or ambiguous scene badges.

## Scope guard

This PR may change tutorial lesson presentation data, the shared canopy-art
orientation seam, front-end tutorial layout, focused contracts, live
documentation, and Android build identity. It does not change simulation,
input, lesson-practice objectives, course generation, difficulty profiles,
progression, rewards, saves, or gameplay balance.

## Previous-session review

**previous-session review:** PRs #156 and #159 established eight stable lessons
and real noncompetitive practice, but the owner's first device review found
that their screenshot-style presentation still relied on small paragraph copy
and that ceiling-mounted hook-vine art ignored the production renderer's
vertical orientation rule. PR #160's difficulty-profile work is unrelated and
must remain unchanged.

## Shipped

- Reviewed the owner's complete 1040×480 recording lesson by lesson. The
  hook-vine source art grows upward from a floor socket, so all four
  ceiling-mounted tutorial uses now consume the same mount-aware orientation
  helper as gameplay and flip vertically; floor hooks remain upright.
- Replaced each dense paragraph/tiny preview-badge pairing with three concise,
  numbered teaching points. The right-hand cards and the preview callouts both
  consume those exact point labels, use stronger contrast and larger type, and
  cannot silently drift into competing explanations.
- Rewrote the eight lesson titles and points around current authoritative
  mechanics: legal surfaces and range, rising release, Reel energy/radius,
  separate Burst and Dive behavior, route pickups and lethal hazards, Rescue,
  Buckler, restart, and Menu.
- Made legal attach targets visually distinct from guide-only cues, drew the
  production lightning pickup beside the fly in the course lesson, and showed
  Buckler separately from Rescue in the survival lesson.
- Added contracts for three-point readability, copy/scene label identity,
  short-landscape text size, mount-driven obstacle orientation, and shared
  production/tutorial asset mapping. Simulation, practice objectives,
  difficulty profiles, rewards, and persistence are unchanged.
- Assigned Android build `0.43.0-tutorial-clarity`, version code 63, and display
  name `Spider Swing Tutorial Clarity (dev)`.

## Verification

- Pinned Godot 4.7.1 Standard full verification passed generated assets,
  14/14 architecture fixtures, inward-dependency scan, clean import, boot, and
  **251/251** runtime contracts:
  `python3 tools/verify.py --require-godot` with `GODOT_BIN` and isolated XDG
  directories pointing to the verified temporary engine.
- A 1040×480 runtime layout probe checked all 24 teaching-point cards after
  layout settled: every card remained inside its copy panel and every wrapped
  line was visible. The headless renderer cannot provide trustworthy pixels, so
  final visual judgment remains an Android-device check.
- Deliberately reversing the shared mount rule failed the focused suite with
  `tutorial obstacle orientation disagrees with its mount` (**35/36**). Removing
  the opening bird explanation failed the three-point, live-art, and mobile
  readability contracts (**33/36**). Both mutations were restored byte-for-byte
  and the focused suite returned to **36/36**.
- PR #161 implementation CI passed `game-quality` run 30886968294 and
  `android-debug` run 30886968449. The expected born-red `substrate-gate` run
  30886968217 reported only the intentional in-progress-card hold.
- Android artifact
  [8883480317](https://github.com/menno420/spider-swing/actions/runs/30886968449/artifacts/8883480317)
  is a 77,941,310-byte, integrity-clean ZIP with SHA-256
  `2bc32ca476bcc9668b79b2c565535f8470e87d229ab04d51cd65945e4f8cc18d`.
  Its 78,393,031-byte APK contains the manifest, `classes.dex`, and Android debug
  signer, passes ZIP verification, and has SHA-256
  `d8ce13a1c4bf598cfb808238eb2851dcd345de101f5b2010c09c330515e8d879`.
  Embedded build info binds it to version `0.43.0-tutorial-clarity`, source
  `cf7aa2c9740ed789885f6b62020bc5d9b9ef34d0`, run 30886968449, and package
  `com.menno420.spiderswing.dev`.
- `python3 bootstrap.py check --strict`: **PASS** after completion and claim
  cleanup.

## Pull request

- [PR #161](https://github.com/menno420/spider-swing/pull/161). Owner action
  needed before merge: **None**.

## Remaining owner review

Install the PR #161 Android artifact and first confirm that the four ceiling
hooks grow downward from the ceiling. Then judge whether each lesson can be
understood from its three numbered scene/copy pairs without deciphering small
prose; whether legal targets differ clearly from guide-only cues; and whether
the fly/lightning and Rescue/Buckler distinctions read immediately. Automated
checks prove orientation and enclosure, not human readability on a physical
screen.

## 💡 Session idea

Make each tutorial scene and its copy use the same three numbered teaching
points, so visual meaning and text cannot drift into two competing explanations.

- **📊 Model:** gpt-5.6-sol · high · feature build

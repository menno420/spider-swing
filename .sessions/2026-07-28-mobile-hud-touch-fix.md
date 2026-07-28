# Mobile HUD touch-coordinate fix session

> **Status:** `complete`

## Goal

Use Menno's 1040×480 Android recording to reproduce and fix the inert Reel and
DEBUG controls, preserve correct web taps, add clear detached-Reel feedback, and
ship a verified replacement phone build.

## Scope guard

This remained a contained Phase 0 input/readability correction. No swing physics
constant or preset changed; no Phase 1 content was added; the frozen GDD remains
untouched.

## Previous-session review

**previous-session review:** PR #6, its completed session evidence, the 16 passing
runtime contracts, the merged composition root, and Menno's first real-device
feedback were reviewed. The owner reports that the core swing already feels fun;
this session protected that movement while correcting the HUD input seam.

## Evidence and resolution

Frame review of the 1040×480 recording showed direct presses on both right-edge
controls with no response. Godot had already stretch-adjusted touch positions into
the logical canvas, and the Node2D HUD was drawn there, while `InputRouter` sized
its hit rectangles from the physical visible surface. With `canvas_items` and
`expand`, that phone's 1040×480 surface is a 1560×720 logical canvas, so the manual
hit targets were displaced up and left.

`InputRouter` now converts only the physical visible size through the inverse
stretch basis. Shared rectangles remain owned by `LabLayout`. Four regression
checks lock the recorded phone size, the recorded Reel and DEBUG positions, and
the reference identity layout.

The Reel behavior remains attached-only. A detached press now emits yellow
`Attach a web before Reel-In` feedback without consuming energy. While attached,
the control becomes `PULL`, brightens, drains its energy ring, shortens the rope,
and retains the existing rope pulse.

## Verification

- `game-quality` run #40: PASS — Godot 4.7.1 import, boot, 21/21 runner checks,
  nine deterministic physics contracts, four mobile HUD coordinate checks, and
  14/14 architecture fixtures.
  https://github.com/menno420/spider-swing/actions/runs/30354700917
- The earlier functional head also passed independently in run #39.
  https://github.com/menno420/spider-swing/actions/runs/30354624244
- `substrate-gate`: the only pre-close failure was this card's designed
  `in-progress` hold. This deliberate final status change triggers the post-close
  strict verification; merge remains forbidden until it passes.
- PR: https://github.com/menno420/spider-swing/pull/7

## Docs audit

**docs audit result:** `docs/technical/phase-0-swing-laboratory.md`,
`docs/current-state.md`, and `control/status.md` now record the logical-canvas
input contract, detached/attached Reel feedback, 21-check suite, owner phone
feedback, and replacement-device test. No ADR, project-index boundary, or GDD
change was required.

## Owner follow-up

Install the replacement `spider-swing-android-debug` artifact produced after merge.
Confirm DEBUG opens; detached Reel gives the yellow message; attached Reel changes
to PULL, drains energy, and shortens the rope. Then approve or reject a tuning
candidate for the Phase 0 exit gate.

## 💡 Idea

Keep rectangle ownership in `LabLayout`, but convert the adapter's physical visible
size through the inverse stretch basis exactly once. Future HUD controls inherit
one coordinate contract instead of accumulating device-specific patches.

- **📊 Model:** gpt-5 · high · bug fix

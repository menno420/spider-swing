# Mobile HUD touch-coordinate fix session

> **Status:** `in-progress`

## Goal

Use Menno's 1040×480 Android recording to reproduce and fix the inert REEL and
DEBUG controls, preserve correct web taps, add clear detached-Reel feedback, and
ship a verified replacement phone build.

## Scope guard

This is a contained Phase 0 input/readability correction. It does not retune swing
physics, choose a baseline preset, add Phase 1 content, or change the frozen GDD.

## Previous-session review

**previous-session review:** PR #6, its completed session card, the 16 passing
runtime contracts, the merged composition root, and Menno's first real-device
feedback were reviewed. The owner reports that the core swing already feels fun;
this session protects that movement while correcting the HUD input seam.

## Working hypothesis

The Node-based input adapter sizes hit rectangles with
`Viewport.get_visible_rect()` (physical screen space), while touch events and
the Node2D HUD use the stretched canvas space. On the recorded 13:6 viewport this
moves the logical hit regions up and left of the buttons.

## 💡 Idea

Keep rectangle ownership in `LabLayout`, but make the adapter convert the physical
visible size through the inverse stretch basis exactly once. Future HUD controls
then inherit one coordinate contract instead of accumulating device-specific fixes.

- **📊 Model:** gpt-5 · high · bug fix

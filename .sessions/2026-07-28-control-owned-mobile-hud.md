# Control-owned mobile HUD correction session

> **Status:** `in-progress`

## Goal

Use Menno's second real-device failure to eliminate manual touch-coordinate
assumptions, make Reel and DEBUG true Godot GUI controls that consume input before
world taps, and produce an unmistakably versioned replacement APK.

## Scope guard

This session changes the mobile input adapter, presentation build marker, debug
package version, tests, and truthful ledgers. It does not retune swing physics,
select a baseline, add Phase 1 content, or modify the frozen GDD.

## Previous-session review

**previous-session review:** merged PR #7, its 21 runtime checks, the owner's second
phone result, and the unchanged on-device behavior were reviewed. Automated
coordinate proofs did not establish actual Android event routing or artifact
identity, so both assumptions are removed from this follow-up.

## 💡 Idea

Let Godot's GUI pipeline own HUD geometry and event consumption, while world taps
move to `_unhandled_input`. Add an always-visible build identifier and incrementing
Android version so a future device report is tied to an exact binary rather than an
ambiguous artifact name.

- **📊 Model:** gpt-5 · high · runtime bugfix

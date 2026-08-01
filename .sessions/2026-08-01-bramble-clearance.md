# Bramble Canopy clearance correction

> **Status:** `in-progress`

## Goal

Correct the owner-reported device failure in which Bramble Canopy's new hook
and leaf-shutter obstacles are too large and too closely sequenced to make the
opening course physically playable.

## Scope guard

Bramble-only obstacle geometry, pair spacing/recovery cadence, a player-path
passability regression, development build identity, and living verification
records. Preserve the approved physics, speed curve, Reel/Burst/Dive values,
upgrades, input, economy, settlement, saves, and every other zone.

## Previous-session review

**previous-session review:** PR #69 correctly replaced Ancient Forest obstacle
roles with a distinct Bramble vocabulary, but its static guide-and-radius sweep
was weaker evidence than the owner's five device recordings. Those recordings
show the new silhouettes occupying too much of the corridor and recurring too
quickly for the actual swinging trajectory, so the prior passability claim is
superseded rather than defended.

## Owner evidence

Five 1040×480 Android recordings from build `0.22.0-audio-playtest` show
immediate or near-immediate deaths around Bramble's large hooks and diagonal
leaf shutters. The correction must retain their distinct silhouettes while
making both individual openings and the time between commitments achievable at
the unchanged full-speed traversal values.

## What is about to happen

Measure the recorded failure against current seeded geometry, reduce Bramble's
collision occupancy, lengthen its commitment/recovery spacing, and replace the
point-guide clearance proof with a trajectory-aware opening contract that can
fail on the shipped configuration.

## Planned verification

Falsify the new regression against the current Bramble values, prove direct
5000 m starts retain a safe entry and physically achievable early sequence,
run exact Godot 4.7.1 plus strict Substrate verification, then inspect a
source-identified stable-signed Android artifact before the final lifecycle
flip and merge.

## 💡 Idea

Treat each authored obstacle sequence as a timed traversal envelope: validate
clearance, minimum reaction time, and a recoverable exit state together rather
than certifying isolated polygons against an ideal centreline.

- **📊 Model:** gpt-5.6-sol · high · feature build

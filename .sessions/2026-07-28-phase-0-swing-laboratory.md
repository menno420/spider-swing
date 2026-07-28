# Phase 0 — Swing Laboratory implementation session

> **Status:** `in-progress`

## Goal

Implement GitHub issue #2 end-to-end: the deterministic world-space spider motor,
validated web attachment, manual momentum-preserving release, continuous Reel-In
energy, camera/world boundaries, touch-safe buffered input, graybox presentation,
runtime tuning, diagnostics, replay hooks, and trajectory tests.

## Scope guard

This session implements GDD Phase 0 only. It does not add procedural chunks,
collectibles, economy, progression, multiple spiders, monetization, or production
art. The owner-facing exit gate remains real-device feel approval.

## Previous-session review

**previous-session review:** the founding bootstrap session was reviewed against
main, PRs #1/#5, live CI logs, the exact GDD checksum, and the downloaded APK.
Its architecture and Android build substrate are the baseline for this session.

## Working hypothesis

Use one deterministic point-mass simulation at 60 Hz, with a capped
maximum-length rope constraint and presentation rendered from immutable snapshots.
Input is captured during render events and buffered until the next simulation tick.

## 💡 Idea

The same recorded command trace should drive both automated trajectory regression
tests and a runtime replay button. That makes a failed feel report reproducible
without creating a second diagnostic format.

- **📊 Model:** gpt-5 · high · feature build

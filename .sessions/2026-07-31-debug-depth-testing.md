# Debug depth-testing access session

> **Status:** `in-progress`

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

## About to happen

A stable repository-owned debug keystore will replace per-run generation; one
RUN debug control will select any start distance; one session-only upgrade
overlay will resolve selected levels without writing ownership; both debug
paths will make runs non-competitive through the existing practice settlement.

## Previous-session review

**previous-session review:** The newest completed session established the
real-name-first spider identity rule and added a discoverable Field Guide. It
also left the owner device playtest as the decisive gate. This session does not
revisit that identity work; it removes the installation and traversal barriers
that currently prevent deep, repeatable device testing of the shipped game.

## 💡 Idea

After this slice is device-proven, consider named debug scenarios that bundle a
seed, distance, spider, and overlay level into a single reproducible test case.
Keep them as session-only orchestration over the same authoritative paths rather
than introducing saved cheat profiles.

- **📊 Model:** gpt-5 · high · feature build

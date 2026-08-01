# `game/content/` — versioned data definitions

**Rank 0. Depends on nothing.**

Spiders, effects, difficulty tiers, obstacle chunks, missions, upgrades, economy
values, and cosmetics as *data*, not code (GDD § 19.3).

## Why data, not code

The GDD's extension rules (§ 19.4) depend on it:

- new spiders implement data profiles and capabilities — they do not fork the
  player controller;
- new power-ups use effect definitions and policy hooks — they do not patch
  collision callbacks;
- new obstacle chunks use validated metadata and sockets — they do not modify the
  director;
- new presentation themes subscribe to events — they do not alter physics.

## Every definition carries

A stable identifier and a version. Runtime logic refers to IDs, never to scene
names or display text.

Chunks additionally declare the full envelope from GDD § 9.1: physical length,
supported speed range, difficulty cost, allowed entry and expected exit
height/velocity envelopes, valid anchor positions, safe route envelope, minimum
preview distance, collectible sockets, mirroring support, and obstacle tags with
required player capabilities.

This rank-0 directory remains deliberately empty. Current authored catalogs live
at the inward layer that owns their behavior (`domain` or `application`) while
the project proves the right schema boundaries; moving them here requires an
explicit migration rather than a second source of truth. See ADR 0002.

# Deep progression direction

> **Status:** `plan`
>
> This document orders the owner-supplied progression ideas without overriding
> the byte-frozen GDD. Verified source and tests remain the authority for what
> the current build actually does.

## Product rules

- Preserve the level-zero Garden Spider and the current targeting policy.
- Permanent upgrades are Adventure/prototype progression, not a competitive
  substitute for skill.
- Release always retains full velocity. “Momentum retention after release” is
  therefore already complete at level zero and must not become an upgrade that
  makes an unupgraded spider artificially worse.
- No gameplay ability, upgrade level, or stronger spider is sold for money.
- Required routes remain valid for the unupgraded Garden Spider.
- Change progression, course difficulty, and base swing tuning in separate
  playtests so a feel regression has one plausible cause.

## Implemented first: the low-disruption foundation

Build `0.10.0-deep-progression-test` gives every comparison spider the same five
core tracks and exactly two identity tracks. Each track has 20 small levels.
Levels 5, 10, 15, and 20 grant one additional tuning step, making the milestone
real without introducing another button, charge, or hidden control rule.

| Shared core track | What it changes |
| --- | --- |
| Silk Winder | Reel shortening rate |
| Anchor Drive | Burst distance share |
| Reliable Launch | Minimum useful Burst travel |
| Silk Reserve | Reel energy capacity |
| Rapid Recovery | Reel regeneration and empty-lockout recovery |

| Spider | Identity tracks |
| --- | --- |
| Garden Spider | Balanced Flow; Garden Rhythm |
| Magnolia Green Jumper | Compact Stance; Quick Feet |
| Anchorite | Momentum Core; Pendulum Mass |
| Ballooner | Long Silk Sail; Featherline |
| Buckler | Impact Carapace; Elastic Guard |

The previous five-level save format migrates proportionally: old level 1 becomes
new level 4, and old level 5 becomes new level 20. Unknown track IDs are ignored.
The total fly cost of a full track remains close to the previous prototype while
individual purchases become much smaller.

The shared Reel duration remains deliberately bounded below the former
3.33-second base meter. Reel does not inject velocity, but faster radius
shortening can still feel like a large speed gain around the arc. The isolated
0.12.0 device comparison proved that 260 px/s was too weak; the corrected
comparison raises Garden from 320 px/s at level zero to 416 px/s with maxed
Silk Winder while preserving the finite 2.0–2.48-second duration range.

## Extended next: forty smaller levels

Build `0.27.0-forty-level-progression-playtest` extends every one of the 35
tracks to level 40. The original twenty-level implementation above remains
historical evidence; it is no longer the current cap.

- Each numerical tuning step is an `assumed` 70% of its former size.
- Breakthroughs remain every fifth level, yielding 48 effective tuning steps at
  L40. `48 × 0.70 / 24 = 1.40`, so the new maximum is 40% stronger than the old
  L20 maximum even though each purchase is smaller.
- Schema-7 ownership doubles exactly once under schema 8: old L1 becomes L2,
  old L10 becomes L20, and old L20 becomes L40. The older five-level migration
  still runs first, preserving proportional ownership across both expansions.
- Each track costs 490 flies in total. One seven-track spider costs 3,430 and
  all five cost 17,150. Using the prior **measured** ~46 flies/min income as an
  instrument gives an **inferred** ~74.6 minutes per spider and ~6.2 hours for
  the roster; current-device income remains unmeasured.
- Anchor Drive's second stored Burst moves from L10 to L20, the same midpoint
  position. Reel remains speed-neutral rope shortening; max Garden Reel rises
  from 416 to 454.4 px/s and its max meter from 2.48 to 2.672 seconds without
  directly adding spider velocity.

## Structured order after this build

1. **Device-balance the foundation.** Build
   `0.12.1-reel-speed-correction-test` applies the first comparison's evidence:
   level-zero Reel uses 320 px/s for 2.0 seconds, while maxed Garden Silk Winder
   reaches 416 px/s and maxed Silk Reserve extends the meter to 2.48 seconds.
   Every preset/profile/upgrade combination still resolves from a fresh base so
   repeated mount paths cannot compound capacity or recovery. Compare level 0,
   migrated mid-level, and migrated max Garden Spider before adding a mechanic-
   changing breakthrough.
2. **Finish spider motion readability.** The current build interpolates the
   custom-drawn spider/web between fixed snapshots, enables mipmapped minification
   for the moving spider and fly, and adds restrained action poses. A later art
   pass may add two or three deliberate state animations per spider, but only
   after device footage proves the vibration is gone.
3. **Recheck route readability and lower-route viability.** Use the existing
   high/centre/low route catalog and diagnostic overlays. Adjust contrast or
   route placement before increasing hazard density; do not loosen targeting.
4. **Prototype one temporary style mode.** Start with a naturally readable,
   earned in-run pickup such as Ballooner glide. One mode may be active at a
   time, with explicit duration and expiry. Validate that it creates a new line
   through a difficult section without invalidating the selected spider.
5. **Add skill/collection unlock goals after comparison testing.** Keep all five
   spiders available until their identities are approved. Later unlocks may use
   distance, missions, baby-spider collection, or flies. Real money may unlock
   cosmetics or convenience only, never ability-bearing profiles or levels.
6. **Prototype fixed-stat Challenge runs.** Use a fixed seed and base stats with
   separate records so pure skill remains comparable. This is smaller and more
   coherent than starting a campaign now.
7. **Increase course variety and difficulty independently.** Once readability
   and lower routes are proven, add a small number of validated patterns or
   slightly larger hazards. Every required lane still needs a deterministic
   unupgraded-Garden clearance test.

## Explicitly deferred

- ~~Anchor Drive's proposed level-10 reserve Burst~~ — **implemented** as the
  first active breakthrough (D-0024) after the owner approved the corrected
  Reel build on device (D-0023): capacity rises from one to two at level 10,
  successful Bursts alone spend a pip, and one serial timer refills one pip
  at a time without resetting when the reserve is used, preserving the
  long-run one-Burst-per-cooldown rate. Its own device evaluation is the
  next feel gate.
- Generic “web stability”: settling changes can fight player intent and need a
  precise measurable design before becoming progression.
- Multiple simultaneous temporary modes or stacking strength.
- Spider locks during the current feel-comparison phase.
- Paid gameplay power, paid upgrade levels, or paid spider abilities.
- Campaign production, story content, and a large mission backlog.
- More aim forgiveness; accidental attachment is already a known concern.

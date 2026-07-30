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
| Skitter | Compact Stance; Quick Feet |
| Anchorite | Momentum Core; Pendulum Mass |
| Ballooner | Long Silk Sail; Featherline |
| Springtail | Impact Carapace; Elastic Guard |

The previous five-level save format migrates proportionally: old level 1 becomes
new level 4, and old level 5 becomes new level 20. Unknown track IDs are ignored.
The total fly cost of a full track remains close to the previous prototype while
individual purchases become much smaller.

The shared Reel cap is deliberately bounded below the former maximized Garden
Spider track. Reel does not inject velocity, but faster radius shortening can
still feel like a large speed gain around the arc. This is a reversible balance
decision that needs an owner device comparison with a migrated near-max save.

## Structured order after this build

1. **Device-balance the foundation.** Build
   `0.12.0-reel-resource-test` isolates the first comparison: level-zero Reel
   falls from 400 px/s and 3.33 seconds to 260 px/s and 2.0 seconds, while maxed
   Silk Winder + Silk Reserve reaches about 338 px/s and 2.48 seconds. It also
   resolves every preset/profile/upgrade combination from a fresh base so
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

- Anchor Drive's proposed level-10 reserve Burst remains the next isolated
  active-breakthrough prototype after Reel approval: capacity rises from one to
  two, successful Bursts alone spend a pip, and one serial timer begins after
  the first spend without resetting when the reserve is used. This preserves
  the long-run one-Burst-per-cooldown rate. It is specified here, not yet
  implemented.
- Generic “web stability”: settling changes can fight player intent and need a
  precise measurable design before becoming progression.
- Multiple simultaneous temporary modes or stacking strength.
- Spider locks during the current feel-comparison phase.
- Paid gameplay power, paid upgrade levels, or paid spider abilities.
- Campaign production, story content, and a large mission backlog.
- More aim forgiveness; accidental attachment is already a known concern.

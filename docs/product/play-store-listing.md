# Play store listing — draft copy

> **Status:** `owner-guidance`
>
> Draft copy for the Play Console store listing, written from the GDD's own
> product definition (§ 2.1–2.5) rather than invented. **Character counts below
> are measured, not estimated.** Limits verified 2026-08-05 from
> [answer/9859152](https://support.google.com/googleplay/android-developer/answer/9859152).
>
> The store listing is a **prerequisite for rolling out a closed-test release**,
> so this is on the critical path, not after it.

## App name — limit 30

# **`Slingy Spider`** — 13 characters. **DECIDED 2026-08-05 (owner).**

The live Play Console app and signed release workflow now use the permanent
application ID **`com.menno420.slingyspider`**. Do not create a replacement app
or change this package name.

Exact-phrase search on Google Play returns **no app with this name**. Play's
search parses "slingy" as swing/momentum and surfaces **Stickman Hook (100M+)**
at position 2 — the store already understands the word. Full evidence, and the
three retracted objections, in [`name-status.md`](name-status.md).

**Still open:** trademark only — BOIP (Benelux) and EUIPO, Nice Class 9 and 41.

---

The historical name research, including why **Swingy Spider** was rejected, is
kept in [`name-status.md`](name-status.md). It is background, not an open naming
decision for this release. The only remaining owner judgment is whether to do a
formal Benelux/EU trademark clearance before production publication.

## Short description — limit 80

Pick one. All measured.

| # | Text | Chars |
|---|---|---|
| **A** | `Fire silk, ride the pendulum, and see how far one small spider can go.` | **70** |
| B | `Swing on silk, catch flies, and turn every good arc into more speed.` | 68 |
| C | `A spider, a silk line, and one clean arc after another. How far?` | 64 |

**A is the recommended default** — it names the mechanic (silk, pendulum) and
the goal (distance) without promising a feature the build does not have.

## Full description — limit 4,000

Measured: **1,488 characters**. Well inside the limit, with room to add a
"what's new" paragraph later.

```
You are a small spider in an oversized world. Fire a line of silk, swing, and
turn your speed into momentum — then let go at the right moment and fly.

Swinging is the whole game. Everything else exists to make it feel good.

CONTROL THAT ANSWERS YOU
Attach, swing, and release with immediate, predictable response. When a run
ends, you should know exactly which decision ended it — deaths are meant to be
understandable, never arbitrary.

FIND THE FLOW
Good timing chains swings into faster, cleaner movement. Accelerate through the
low point, ease toward the apex, release, and arc. Reel in your line to tighten
a curve and shape the path you are already on — it costs energy, so spend it
where it counts.

A MINIATURE WORLD
Swing through natural and household spaces built at spider scale, past hazards
that stay readable even at full speed. Obstacle layouts are seeded and fair, not
random chaos — the same course rewards the same skill.

CATCH FLIES, EARN UPGRADES
Aim the same silk you move with to snag flies mid-arc. Spend what you earn on
spiders and upgrades that trade one strength for another. Nothing in the game
sells you power over other players.

BUILT FOR SHORT SESSIONS
Runs are quick and restarts are near-instant. Pick it up for one more attempt,
and watch your distance climb as your timing sharpens.

Practice each skill on its own in the Guide, then take it to a full run.

No ads. No accounts. No internet connection needed — the game runs entirely on
your device.
```

### Why the copy says what it says

- Leads on silk, pendulum and momentum — the GDD's § 2.5 differentiators
  (Reel-In as an energy-managed arc-shaping skill, flies caught with the
  movement web, a miniature natural world, seeded readable chunks, spiders as
  trade-offs) rather than the generic "swing and avoid obstacles" premise it
  shares with existing small games.
- "Deaths are meant to be understandable" is GDD § 2.2's Ownership pillar, which
  is the actual product promise.
- **No superhero framing anywhere.** GDD § 17.1 requires avoiding Spider-Man and
  comic-book similarity in naming and visual identity; the copy stays on "small
  spider in an oversized world".
- The closing three lines are literal and verifiable — no ads, no accounts, no
  network — which matches the Data safety declaration exactly. Listing copy that
  contradicts the declaration is a policy problem.
- **Does not mention leaderboards.** GDD § 2.4 lists global competitive
  leaderboards as a non-goal for the first release. Copy must not promise them.

## Graphics — prepared for owner review

| Asset | Spec | State |
|---|---|---|
| App icon | 512×512, 32-bit PNG **with** alpha, ≤1024 KB | **candidate ready** |
| Feature graphic | 1024×500, JPEG or 24-bit PNG, **no** alpha | **candidate ready** |
| Phone screenshots | ≥2 to publish; ≤8 per device type | **3 genuine candidates ready** |
| Games recommendation eligibility | ≥3 landscape 16:9 at ≥1920×1080 | **minimum set ready** |

The upload-sized files, original masters, genuine captures and provenance are
in [`../../assets/source/play-store/README.md`](../../assets/source/play-store/README.md).
They have not been uploaded. The icon, feature graphic and screenshot order all
remain owner-review decisions.

**The graphics are the differentiator here, not a formality.** Owner review of
the category (2026-08-05) found store art across competing swinging games to be
uniformly cheap. The closest name-neighbour, *Spider Swing* (10K+ installs, ad-
supported), ships screenshots of a **flat solid-blue background with thin
magenta lines**, and its live build carries a **"trial version" watermark**.

Against that baseline, a set of real 1920×1080 captures of an actual art-directed
game is a large, cheap advantage — and it is on the critical path anyway, since
the listing gates the closed-test rollout. Treat these assets as a priority, not
as paperwork.

**Screenshots must be real capture.** The game renders 16:9 landscape natively
at a 1280×720 reference viewport, so 1920×1080 captures need no cropping — but
they do need a real device or a real windowed build. This repository's own
tooling notes that the headless renderer cannot provide trustworthy pixels, so
these cannot be produced from a session without a verified capture path.

Generated imagery invents interface and physics — a generated clip in this
estate produced three ATTACH buttons in a single frame. It is acceptable for the
feature graphic; it must never be used for a screenshot implying "this is how it
plays".

The current candidates were captured from the actual headed game at its native
1280×720 viewport and resized without retouching to 1920×1080. Before production,
replace them with signed-build device captures if the release presentation
differs — most visibly, if its small debug build label is absent.

# Fresh-session handoff — recording-led fine-tuning

> **Status:** `owner-guidance`
>
> ## ⚠️ Superseded as a plan — 2026-08-01 evening
>
> **Do not take the next slice from this document.** The owner redirected the
> same evening: the first 10 km of visuals are essentially done, so the work is
> now **mechanics** — forward speed becomes earned, and a bird supplies the
> pressure. The current entry point is
> [`next-session-brief-2026-08-01-mechanics.md`](next-session-brief-2026-08-01-mechanics.md)
> and the spec it points at,
> [`../game-design/earned-speed-and-the-bird.md`](../game-design/earned-speed-and-the-bird.md).
>
> Two of this document's premises no longer hold: it is built around choosing a
> **recording-led** slice, and the owner has stated **no new recordings will be
> supplied**; and its "Paste-ready first prompt" asks for a recording upload.
>
> **This file remains accurate as a record** — what merged, what Menno accepted
> versus what is only technically verified, the corrected 181/181 test count,
> and the device-verification queue. Read it for repository state.
>
> Dated handoff for the next Spider Swing session. Source, executable tests,
> merged commits, and Android artifacts outrank this document if the repository
> advances. Read `.claude/CLAUDE.md` and `docs/current-state.md` first, then use
> this file to choose **one** recording-led correction slice.

## Authoritative starting point

- **Live source:** `2787314b4d46ccbcc03c0e50e38a8c96629d8056`, merged
  through PR #92 after PRs #90 and #89. PR #92 adds measurement/replay tooling,
  one review trace, and documentation; it does not tune physics, zones, or
  balance. The handoff-only PR #91 changes no gameplay or Android setting.
- **Build:** `0.24.0-environment-finish-playtest`, Android version code 43,
  development package `com.menno420.spiderswing.dev`.
- **Verification:** exact Godot `4.7.1.stable.official.a13da4feb` import, boot,
  architecture scan, deterministic audio regeneration, and **181/181** contracts
  pass. `python3 bootstrap.py check --strict` passes.
- **Repository state at final reconciliation:** no open implementation PRs;
  Phase 0 issue #2 remains open deliberately for owner-judged feel and device
  gates. PR #91 is this documentation-only handoff.
- **Coordination:** open PRs plus `control/claims/` determine active work.
  Historical merged branch refs may remain visible and are not work in flight.
- **Android artifact:** [download the verified current playtest build](https://github.com/menno420/spider-swing/actions/runs/30703610645/artifacts/8819609662)
  (GitHub retains the download until 2026-08-15; an already-downloaded APK does
  not expire). Its PR #92 head contains the same gameplay/content as merged
  `main` and includes the flagged review trace; the only tree difference is the
  temporary PR #91 coordination claim, which this handoff removes. The ZIP digest is `2a8b3774…`,
  the APK digest is `4efb36dc…`, and the
  certificate fingerprint remains the pinned `83ff0bc2…`. Install over any
  stable-key `0.19.0` or later build without uninstalling.

### Contract-count correction

PR #89's body and its first closeout summary said 176 contracts. That was an
intermediate count. The final merged runner sets `EXPECTED_CHECK_COUNT` to 181:
the replay work added five simulation-lab contracts and one front-end contract
to the prior 175-contract environment tree. A clean exact-engine rerun on this
handoff confirmed all 181. Historical session evidence remains intact; this is
the corrected current snapshot. PR #92 also moved evergreen prose to
`EXPECTED_CHECK_COUNT` so future contract additions do not silently stale the
living summaries again.

## What actually happened

1. **Later content landed.** PR #73 implemented mechanically distinct Zones
   4–8; PRs #75 and #76 added three Campaign teaching levels and three difficulty
   modes without changing the approved Balanced physics.
2. **The simulator produced a wrong product conclusion.** PRs #77/#78 called
   upgrade tracks inert or harmful and temporarily withdrew two from sale.
   Menno's device play contradicted that result; PR #80 reverted the withdrawal
   completely, with no save migration or lost ownership. The lab is now
   explicitly barred from judging upgrades or high-distance difficulty until it
   meets its owner-calibration targets.
3. **Audio became a real test slice.** PR #83 reconciled living docs and added
   25 original deterministic mono SFX plus independent Effects and Haptics
   settings. Music and ambience were not added.
4. **Bramble was corrected from device evidence.** PR #86 reduced the oversized
   hook/shutter commitments, inserted open preparation and recovery, and added a
   timed full-speed clearance contract. Physics and action values stayed fixed.
5. **The visible obstacle pass was corrected twice.** PR #87 replaced Silk
   Hollow and Ruined Arboretum polygon fallbacks with finished objects. PR #90
   then used six recordings to add the missing near-depth planes, continuous
   corridor materials, outline-free normal rendering, resolved Storm/City
   surfaces, and narrow collision-honest ceiling supports across 10–30 km.
6. **Lab runs became watchable.** PRs #88/#89 added policy search, held-out
   verification, two bundled input-only traces, headless replay, and a debug Test
   Run route.
7. **The first replay judgement and fair upgrade comparison arrived.** Menno
   watched both original traces and judged them genuine, close to his playstyle,
   and only a little excessive on Burst and Dive. PR #92 then cross-applied the
   same policies at L0 and L20: upgrades measurably reduce deaths and effort,
   while the route-limited bot does not reliably convert that relief into more
   distance. It also bundled a separate 10,773 m web-spam trace that abandons
   Dive for roughly 130 attaches per run. That trace is technically reproducible
   but deliberately has no fairness verdict yet.

## Evidence boundary

### Owner-accepted or directly established

- `balanced_baseline` is the approved physics baseline. It was not chosen from
  a tuned three-way comparison; Weighty and Agile remain stale forks.
- Ancient Forest and Bramble Canopy establish the **visual scene standard**:
  layered depth, continuous materials, and obstacles that belong to the same
  physical space. This does not silently approve every Bramble seed's clearance.
- Menno likes the later-zone backplates and reports the integrated result looks
  genuinely better. That is not blanket acceptance of their walls, obstacles,
  readability, spacing, or mechanics.
- Device play establishes that max upgrades are substantially better than level
  zero and that the overall difficulty curve is much healthier than the old bot
  measurements claimed.
- Menno accepted the two original bundled replay traces as fair representations
  of his style, with slightly excessive but still acceptable Burst and Dive use.
- At high speed, Reel is predictive arc shaping and Burst is the fast late
  height correction. The recent visual work did not retune either role.

### Repository-proven, but not owner-accepted

- The four recorded 10–30 km zones have two scrolling background planes,
  zone-specific walls and surfaces, resolved obstacle routes, no normal-play
  collision ghosts/rims, and measured ceiling joins.
- Zones 4–8 have deterministic mechanics, typed anchors, swept moving collision,
  energy-safe moving pivots, and seeded passability/silhouette contracts.
- Audio generation, event wiring, cooldown/variant policy, headroom, and Effects
  versus Haptics persistence are correct in source.
- Save migrations, noncompetitive debug/practice settlement, upgrade overlays,
  and stable debug signing are contract-covered.
- The held-policy upgrade sweep proves lower deaths, longer survival, lower input
  rate, and less Reel pressure at L20. It does not prove that every player gains
  the same distance.
- All three bundled lab traces reproduce through the headless driver and the real
  run state machine. The first two are owner-accepted; the flagged web-spam trace
  is not.

None of those proofs can approve phone-scale composition, touch comfort,
readability at 76–77 m/s, sound quality, perceived fairness, or fun.

## Device-verification queue

Do not run this as one large task. Pick the highest-value visible problem, gather
one focused recording, and finish one correction before selecting the next row.

| Priority | Slice | What still needs a real-device verdict |
| ---: | --- | --- |
| 1 | One recorded 10–30 km zone | Whether parallax reads as depth; ceiling/floor form one structure; faint outlines are truly gone; obstacles attach honestly, belong to the scene, remain readable at speed, and leave fair scale/spacing. Start with whichever failure is most noticeable—not automatically Silk Hollow. |
| 2 | Ashen Hollow (30–35 km) or Deep Mist (35 km+) | First integrated device review of failing anchors, embers, restricted visibility, advance cues, and the frozen success sentences. These zones were not part of the six-recording PR #90 benchmark pass. Review one zone at a time. |
| 3 | Bramble clearance | Whether PR #86's first sequence is genuinely traversable across several seeds at `MAX`, while still forcing readable high↔low play. Its visual identity is the benchmark; clearance still needs an explicit verdict. |
| 4 | Mobile front end | Home, Garage, Shop, Silk selection, Tutorial, Campaign, Settings, and debug setup: smooth inertial scrolling, readable text, thumb comfort, selection clarity, and consistent forest-web presentation. |
| 5 | Audio and haptics | Phone-speaker clarity, Reel-loop fatigue, Burst versus Dive distinction, later-zone warning timing, and independent Effects/Haptics switches. |
| 6 | Save continuity | After installing the *next* stable-key APK over this one, confirm settings, flies, owned upgrades, bests, Campaign clears, and checkpoints survive. Do not uninstall. |
| 7 | Profiles, upgrades, and modes | Garden `OWNED` versus L0/MAX at distance; then one non-Garden profile at a time; then Relaxed/Standard/Harsh. No simulator-derived retuning. |
| 8 | Flagged replay fairness | Watch `lab-flagged-webspam-standing-l20.json` in Debug Test Run. Decide whether abandoning Dive for roughly 130 attaches per run is legitimate high-frequency play or an exploit. Do not reopen the two already accepted traces without new evidence. |
| 9 | Android performance | Frame pacing, heat, memory pressure, audio stutter, and touch latency after the new parallax/art layers, especially at 20–35 km. Automated headless rendering does not cover this. |

The two parked product forks in `docs/owner-questions.md`—a Harsh fly premium
and whether a roughly 21-minute seven-track economy is long enough—do not block
this fine-tuning pass.

## Required next-session rhythm

1. **Analyse only first.** Read the uploaded recording frame by frame, state the
   exact visible/feel defect, distance band, reproduction conditions, and likely
   owning source path. Do not implement during the diagnosis pass.
2. **Choose one bounded slice.** If a shared renderer problem is suspected,
   prove it in one zone before generalising it.
3. **One zone or system per PR and APK.** Preserve approved backgrounds,
   physics, routes, saves, and unrelated content unless the evidence directly
   implicates them.
4. **Run exact gates and inspect the Android artifact.** Technical green means
   ready for Menno's phone; it does not mean visually accepted.
5. **Wait for the device verdict.** Only then continue to another zone or
   system. Do not absorb several new recordings into one implementation batch.

## Paste-ready first prompt for the fresh session

> Continue Spider Swing from the live `main` branch. Read
> `.claude/CLAUDE.md`, `docs/current-state.md`, and
> `docs/planning/fresh-session-handoff-2026-08-01.md` before acting. I will upload
> recordings of the areas that still feel unfinished. Analyse the first
> recording thoroughly and diagnose it before implementing anything. Separate
> what the repository proves from what I have actually approved on-device. Then
> choose one bounded, highest-value correction—one zone or one system—publish one
> green PR and APK, and wait for my device verdict before continuing. Do not
> retune physics or balance from simulator output, do not combine several zones
> into one task, and do not overwrite backgrounds or mechanics that the
> recording does not implicate.

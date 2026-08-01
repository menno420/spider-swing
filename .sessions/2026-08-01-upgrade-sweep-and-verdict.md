# Upgrade playstyle sweep, the first fair-play verdict, and a review verified

> **Status:** `complete`

## Goal

Answer the owner's standing question — how much does each upgrade change the
*way* the game is played — by searching each configuration separately and
diffing behaviour rather than distance. Record his verdict on the first lab
runs he watched. Verify an external repo review against the source.

## Scope guard

Measurement, one small tool addition (`--start-from`), and documentation. No
physics values, no zone content, no tuning. One comment cross-reference in
`swing_config.gd`; no behaviour changes.

## Previous-session review

**previous-session review:** #89 merged, closing the replay loop. The four-leg
sweep was the named next slice, and the L0 device recordings arrived in time
to serve as its validation set.

## The verdict — the loop paid off

The owner watched both bundled warp-L20 traces in game:

> *"They are genuinely good and match my own playstyle, a little excessive on
> the burst and dives, but that's not bad."*

**First fair-play verdict on lab output that exists.** It also did something
unplanned: it **calibrated the anomaly detector**. Those runs measure 2.45×
Burst against a 2.5× threshold I had guessed. A human reading "slightly
excessive, still fair" lands one near-miss below the alarm — the eye and the
detector agreed on the same axis, independently. The thresholds in
`fit_bot.py` now carry that anchor in a comment instead of being a guess.

## The sweep, and the trap in it

Comparing each configuration's best result says **upgrades cost 12%** — the
audit's old wrong sign, now apparently better evidenced because each level had
its own policy fitted. That reading is wrong. Cross-applying each optimum to
the other configuration (held-out seeds throughout):

| policy | @L0 | @L20 | upgrade effect |
| --- | ---: | ---: | ---: |
| L0 optimum | 3 491 m | 3 434 m | **−1.6%** |
| L20 optimum (cold) | 2 739 m | 3 072 m | +12.2% |
| L20 optimum (warm) | **5 378 m** | 5 124 m | −4.7% |
| default | 2 040 m | 1 796 m | −12.0% |

The L0 policy beats the L20 search's own answer *at L20*. **The L20 search
under-converged**; comparing best-per-configuration silently compares search
luck. `--start-from` warm-starts from a neighbouring optimum — its first
generation beat the cold search's twelfth, and it finished 65% higher.

## What upgrades actually change

One policy, both levels, held-out — so every difference is the upgrades:
deaths/km **0.55 → 0.51**, runs surviving to the cap **1 → 3**, run duration
**+21%**, input **−20%**, reel time **−45%**, at **flat distance**.

**Upgrades buy survival and economy of effort, not distance.** Whether that
converts into distance depends on what was limiting you — the bot is limited
by route choice, so it cannot convert; a player limited by survival converts
it straight into kilometres, which is what the owner reports. The gradient
says the same: −12.0% (weak policy), −1.6% (searched), strongly positive (the
owner). **The better the play, the better upgrades pay.** First measurement
that reconciles the lab's negative findings with his experience rather than
one overruling the other.

## An exploit candidate, awaiting judgement

The warm L20 search reached **5 879 m mean, 9 945 m furthest** — and did it by
**abandoning Dive** (0.28 per web against the endorsed 0.96) in favour of
**130 web attaches per run** against the endorsed 13.6. It also scores
*better without upgrades*. Two flags fired.

Against the now-calibrated reference this is not marginally out, it is
qualitatively different play. A verified trace of the most extreme run —
**10 773 m, 640 commands** — is bundled as
`lab-flagged-webspam-standing-l20.json`. **No conclusion in the measurement
document rests on it** until it is watched.

## External review, verified

An external (Grok) repo review was checked claim by claim against source.

| Claim | Verdict |
| --- | --- |
| `input_buffer_duration` 0.25 s | correct |
| `surface_snap_distance` 220 px | correct |
| `DEVICE_ID_EMULATION` ignored | correct |
| downward tap during a pull only interrupts it | correct |
| command expiry is silent | correct — `_discard_expired_commands` emits nothing |
| `front_end.gd` / `swing_lab.gd` are heavy | correct — 1 933 / 2 325 lines |
| bot diverges on route choice, not verbs | correct, and now measured |
| repo created ~28 July | 29 July |
| "175 contracts" | was true this morning; 181 now |
| **stale presets should be hidden behind a debug flag** | **already mitigated** — Settings labels them "WEIGHTY UNTUNED" / "AGILE UNTUNED" with copy saying they are "kept for future work, not offered as tested alternatives" |

No structural errors found by it, and none by this verification. The one
actionable recommendation was already implemented in a layer the review did
not read.

**Cleanliness fixes it prompted:** two living docs quoted a hard contract
total (175) that had already gone stale twice today; they now point at
`EXPECTED_CHECK_COUNT` instead. `swing_config.gd` now cross-references the UI
disclosure so the next reviewer does not re-raise a solved problem.

## Verification

`python3 tools/verify.py --require-godot` → exit 0, **181 contracts**.
`python3 bootstrap.py check --strict` → exit 0.
All three bundled traces REPRODUCE, including the newly captured 10 773 m one.
Every comparison number quoted is from held-out seeds (4242 / 9000–9007).

## Owner questions

None new. OQ-9 unchanged. **OQ-10 gains its decisive evidence:** upgrades
measurably buy survival and effort-economy, and the reel tracks relieve a
constraint that binds at L0 — so extending them is defensible, and the earlier
"inert tracks" reading is retired.

## 💡 Idea

The sweep's headline was wrong twice before it was right, and both times the
error was *comparing the best of two searches*. Search quality is a confound
that looks exactly like an effect: the L20 leg under-converged by 12%, and the
first reading attributed that entirely to upgrades. **Whenever two optimised
configurations are compared, cross-apply each policy to the other** — if
policy A beats configuration B's own optimum, the difference is search luck,
not the axis being studied. That test costs two batches and would have caught
this an hour earlier.

## Next slice

The owner's judgement on `lab-flagged-webspam-standing-l20.json`. If it is an
exploit, 130 web attaches per run is a balance bug found before a player found
it; if it is legitimate, the anomaly thresholds need widening on the web axis
and the bot has found a real high-frequency style. Either answer is worth more
than another search.
- **📊 Model:** opus-5 · high · research — upgrade sweep, verdict, review audit

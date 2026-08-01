# What upgrades change about how the game is played — 2026-08-01

> **Status:** `reference`
>
> The policy search run once per configuration, so each upgrade level is
> compared at *its own best play* rather than at a policy tuned for a different
> build. Answers the owner's standing question — how much does each upgrade
> change the way the game is played — with behaviour rather than distance.
>
> **Headline: upgrades do not buy this bot distance. They buy survival and
> economy of effort.** Deaths per kilometre fall, runs last a fifth longer,
> and input and reel use both drop sharply — at flat distance. That is not
> "upgrades are inert"; it is a different constraint binding first.

## The trap this document exists to avoid

The obvious way to read a per-configuration sweep is to compare each
configuration's best result. Done that way the answer is that **upgrades cost
12%** — the same wrong sign the 2026-08-01 upgrade audit reported, now
apparently much better evidenced, because each level had its own policy fitted
and "the bot can't adapt" is no longer an available excuse.

That reading is wrong, and one test shows why. Apply each optimum to the
*other* configuration, all on held-out seeds (bot seed 4242, courses
9000–9007, 24 runs, standing start, intermediate):

| policy | @ L0 | @ L20 | upgrade effect |
| --- | ---: | ---: | ---: |
| **L0 optimum** | 3 491 m | 3 434 m | **−1.6%** |
| L20 optimum (cold search) | 2 739 m | 3 072 m | +12.2% |
| **L20 optimum (warm-started)** | **5 378 m** | 5 124 m | **−4.7%** |
| default, unsearched | 2 040 m | 1 796 m | −12.0% |

**The L0 policy scores better at L20 (3 434 m) than the L20 search's own
answer did (3 072 m).** The L20 search under-converged by 12%, and most of the
apparent "upgrades hurt" was that search failure rather than anything about
the game. Comparing best-per-configuration silently compares search luck.

`tools/fit_bot.py --start-from=<artifact>` now warm-starts a search from a
neighbouring configuration's optimum for exactly this reason. Its **first
generation beat the cold search's twelfth**, and it finished at 5 879 m
against the cold search's 3 554 m — the cold run had left 65% on the table.

The warm optimum then scores **better without upgrades than with them**
(5 378 m at L0 against 5 124 m at L20): the best policy found does not need
the upgrades at all. Three independent policies now agree on the sign, and the
size shrinks as the policy improves — **−12.0%**, **−4.7%**, **−1.6%**.

## What upgrades actually change

One policy, both upgrade levels, held-out seeds — so every difference below is
the upgrades and nothing else.

| | L0 | L20 | change |
| --- | ---: | ---: | ---: |
| Distance travelled (mean) | 3 491 m | 3 434 m | −1.6% |
| **Deaths per km** | 0.55 | **0.51** | **−7%** |
| Deaths per run | 1.92 | 1.75 | −9% |
| Runs surviving to the time cap | 1 | **3** | **3×** |
| **Run duration** | 64.6 s | **78.2 s** | **+21%** |
| **Input rate** | 3.68 /s | **2.94 /s** | **−20%** |
| **Reel time held** | 4.14 s | **2.27 s** | **−45%** |
| Reel energy spent | 118.8 | 65.4 | −45% |
| Bursts per run | 20.5 | 26.0 | +27% |
| Dives per run | 30.1 | 32.4 | +8% |
| Dives per web | 0.40 | 0.45 | +12% |
| Webs per run | 75.5 | 72.0 | −5% |
| Flies per km | 23.6 | 20.5 | −13% |

Read as a sentence: **with upgrades the same player survives longer, works
less, and reels far less, while covering the same ground.** The pull verbs get
used more because they are stronger; the reel gets used half as much because
the same correction costs less of it; the hands do 20% less.

That is a coherent product story, not a null result. **Upgrades relieve
effort and risk. Whether that converts into distance depends on what was
limiting you.** The bot's distance is limited by route choice — which anchor
it picks, and whether the swing that follows clears what is coming — and no
amount of relieved effort moves that ceiling. A player whose distance *is*
limited by survival converts the same relief straight into kilometres, which
is exactly what the owner reports: ~2 km unupgraded, well above 5 km upgraded.

The three-policy gradient says the same thing from another angle:

| policy quality | upgrade effect on distance |
| --- | ---: |
| hand-written default | **−12.0%** |
| searched optimum | **−1.6%** |
| the owner | strongly positive |

**The better the play, the better upgrades pay.** A weak policy handed a
longer Burst mostly reaches more lethal geometry with it. This is the first
measurement that reconciles the lab's negative findings with the owner's lived
experience instead of one simply overruling the other.

## The four corners

Each configuration searched independently, 12 generations, population 16.
`tools/search/*.json` are the committed artifacts.

| configuration | baseline | optimum | gain | furthest run | flags |
| --- | ---: | ---: | ---: | ---: | ---: |
| warp 5 000 m, L0 | 929 m | 2 087 m | +125% | 4 881 m | 1 |
| warp 5 000 m, L20 | 720 m | 1 715 m | +138% | 4 296 m | **0 — owner-endorsed** |
| standing, L0 | 2 200 m | 4 203 m | +91% | 6 278 m | 2 |
| standing, L20 *(warm)* | 1 871 m | **5 879 m** | **+214%** | **9 945 m** | 2 |

Read these as *ceilings per configuration*, never as an upgrade comparison —
that is the trap above.

## The anomaly detector fired for the first time

Three of the four legs raised flags, all on Burst or web volume, and the
standing legs raised the loudest: **Burst use 3.4× the default at L0, 6.6× at
L20**, plus web use 2.7× at L0. The warm-started L20 re-search went further
still, reaching 136 web attaches per run at 7.07 taps/s with dives almost
abandoned (0.05 per web).

None of that is a verdict — but the owner's endorsement of the warp-L20 runs
now gives the flags a **calibrated reference**, which they did not have when
they were guessed thresholds. He watched runs measuring 2.45× Burst, 1.16×
web and **0.96 dives per web** and called them fair, *"a little excessive on
the burst and dives"*.

Against that reference the standing optima are not marginally out, they are
qualitatively different:

| | endorsed warp-L20 | warm standing-L20 |
| --- | ---: | ---: |
| Burst vs default | 2.45× | **3.9×** |
| Web vs default | 1.16× | **4.6×** |
| Dives per web | **0.96** | **0.28** |
| Webs per run | 13.6 | **130.1** |

**Correction — it did not abandon Dive.** The falling *ratio* invited that
reading and an earlier draft of this document made it; the absolute counts say
otherwise:

| | endorsed | flagged |
| --- | ---: | ---: |
| Dives per run | 13.1 | **36.2** |
| Dives per second | 0.60 | 0.37 |
| Webs per second | 0.63 | **1.34** |

It dives nearly **three times as often per run** and only a little less often
per second. `dives_per_attach` collapsed because **web attaches doubled per
second**, not because diving stopped — a denominator effect. What is genuinely
unusual is the web rate: better than one attach per second, sustained for a
minute and a half.

A ratio flag needs its denominator read before it is described.

A verified trace of the most extreme run — **10 773 m, 640 commands** — is
bundled as `lab-flagged-webspam-standing-l20.json` for exactly this judgement.
Until it is watched, **no conclusion in this document rests on the standing-L20
optimum**, and the upgrade findings above are stated from the L0 optimum and
the default policy, both of which stay inside ordinary play.

## Two things the review conversation surfaced

**Obstacle awareness exists, with an exact shape.** Watching the traces, the
owner read them as recognising and avoiding obstacles, and separately noticed
dives that "narrowly avoided" hazards. Both observations are right and they
have different causes: route-following for the first, and a **swept clearance
test along each candidate pull** (`preview_pull` → `_first_obstacle_contact`)
for the second. The model cannot see an obstacle it is swinging toward, but it
will not *pull into* one, and it picks among candidate dives by clear path.
Full distinction in `docs/technical/simulation-lab.md` § "What the model can
actually see".

**Reeling buys speed — the design phrase "speed-neutral" is narrower than it
reads.** The owner said he reels partly to gain speed. Tested by ablation on
the endorsed policy, held-out seeds:

| | reel allowed | reel ablated |
| --- | ---: | ---: |
| Mean speed | **79.2 m/s** | 74.5 m/s |
| Distance | **1 908 m** | 1 252 m |
| Run duration | 24.1 s | 16.8 s |

**Reel is worth +6.2% speed and +52% distance.** "Speed-neutral" is true only
of the shortening step itself — `WebConstraint` adds no velocity when it
retracts the rope. The speed arrives through the pendulum, and it is not
small. The phrase should not be read as "reeling does not make you faster".

**Reel usage is configuration-dependent, not uniformly absent.** An earlier
note said the model "effectively does not use the reel", from 9 reel presses
in the 97-second flagged trace. That holds for *that* run (1.5% of its
duration) and not in general: the endorsed warp-L20 runs hold reel **21.5% of
the time** — which is why the owner saw it reeling. The real gap is that he
reels harder still, and empties the meter at L0 where the model never does.

## A fidelity gap, now measured at both ends

`reel empties` is **0.00 in every leg, at every upgrade level**, while the
owner empties the meter in *every* recorded L0 run — four separate empty
episodes in one of them. The bot reels far more lightly than he does, at half
the rate again once upgraded.

So the reel tracks remain unmeasurable by bot, and this is now a measured
fidelity gap rather than a suspicion. Any claim about Silk Reserve or Rapid
Recovery has to come from device play until the model reels like a person.

## Method

- `tools/fit_bot.py`, bot model v3, `balanced_baseline`, `classic`, Standard.
- Every number quoted for comparison is from **held-out** seeds — bot seed
  4242, courses 9000–9007, unseen by any search. The searches themselves used
  seeds 7 and 11 with courses 1337–1344.
- Cross-application (each policy at the other configuration) is what separates
  a game fact from a search artifact, and is now the standard final step.

Reproduce:

```bash
python3 tools/fit_bot.py --config=standing-l20 --generations=12 \
  --start-from=tools/search/standing-l0.json

godot --headless --path . --script res://tools/simulate.gd -- \
  --runs=24 --seed=4242 --course-seed=9000 --course-seeds=8 \
  --skill=intermediate --upgrades=20 --max-seconds=180 \
  "$(python3 -c "import json;print(json.load(open('tools/search/standing-l0.json'))['replay'])")"
```

#!/usr/bin/env python3
"""Search for the best play the simulation lab's model can find, and report how
it played — not just how far it got.

Black-box search (cross-entropy method) over `tools/simulate.gd`'s *policy*
knobs. It answers three questions the lab could not answer before:

1. **Is the run genuinely possible?** The search establishes a ceiling for a
   given configuration. A ceiling is only meaningful if it was reached by
   decisions a person could have made, which is what the frozen perception
   limits below are for.
2. **How does each upgrade change the way the game is played?** Run the search
   once per upgrade level and compare the *behavioural fingerprint* of each
   optimum — dives per web, reel time, burst use, anchor choice, input rate —
   not merely the distance. Two configurations reaching the same distance by
   different play is a finding; distance alone hides it.
3. **Did it find a loophole?** A search rewarded for distance will exploit
   whatever the physics allows. That is a feature here: an exploit found in the
   lab is a balance bug found before a player finds it. Candidates whose
   fingerprint departs sharply from ordinary play are flagged.

THE FAIRNESS FLOOR
------------------
Decision cadence, reaction delay and aim error are bounded by what a human has
been *observed to do* — not by what one averages. The distinction matters and
an earlier version of this file got it wrong: the owner averages 6.60 taps/s
across a run but sustains 18/s for a full second, so a model frozen at his
average is capped below the player and cannot perform the recoveries his long
runs depend on. Cadence and reaction delay are searchable down to a 2-tick
(30/s) floor. Aim error stays frozen — it is precision, not speed, and nothing
in the tap stream licenses moving it.

THE FAIRNESS CEILING IS A HUMAN
-------------------------------
No statistic here certifies that a run was played fairly. The intended use is
that the best runs are watched and judged by the owner. This script's job is to
surface a short list worth watching and to say what was unusual about it.

Usage:

    python3 tools/fit_bot.py --config=warp5000-l20 --generations=12
    python3 tools/fit_bot.py --config=standing-l0 --evaluate-only
    python3 tools/fit_bot.py --config=standing-l20 --generations=8 --workers=4

Writes `tools/search/<config>.json` — the best knobs, the fingerprint, and the
generation history. A table of numbers, reviewable in a diff, replayable with
`--bot=`.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import random
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent

# --- knobs -----------------------------------------------------------------
# name -> (low, high, default). Every one is a *policy* choice: what to do with
# what was perceived. `simulate.gd` owns the authoritative list and rejects
# anything outside it, including this script's mistakes.
KNOBS = {
    "band_px": (18.0, 90.0, 36.0),
    "reel_band_px": (24.0, 120.0, 52.0),
    "panic_fall_speed": (200.0, 560.0, 330.0),
    "release_rise_speed": (90.0, 320.0, 200.0),
    "burst_chance": (0.0, 1.0, 0.30),
    "dive_chance": (0.0, 1.0, 0.65),
    "care": (0.30, 1.0, 0.95),
    "class_read": (0.0, 1.0, 0.95),
    "attach_fan_top_deg": (-88.0, -40.0, -70.0),
    "attach_fan_bottom_deg": (-38.0, 6.0, -20.0),
    "attach_reach_frac": (0.30, 0.95, 0.62),
    "dive_fan_top_deg": (6.0, 40.0, 20.0),
    "dive_fan_bottom_deg": (30.0, 85.0, 56.0),
    "dive_reach_frac": (0.25, 0.95, 0.55),
    "dive_floor_y": (380.0, 640.0, 520.0),
    "reel_reserve_scale": (0.10, 3.0, 1.0),
    "reel_floor_scale": (0.10, 3.0, 1.0),
    # Rate knobs. Floored at 2 ticks (30/s) by simulate.gd, against the 18/s
    # the owner has been recorded sustaining -- headroom over him, but not an
    # unbounded amount. Searchable because a model capped at his *average*
    # rate cannot perform the recoveries his long runs depend on.
    "decision_period_ticks": (2.0, 10.0, 4.0),
    "reaction_delay_ticks": (2.0, 12.0, 3.0),
}

# --- what to search --------------------------------------------------------
# Warp runs end ~10x sooner than standing ones, so they carry more runs for the
# same wall-clock. `runs` is chosen per config rather than shared.
CONFIGS = {
    "warp5000-l20": {
        "args": ["--skill=expert", "--start-m=5000", "--upgrades=20"],
        "runs": 24,
        "note": "the owner's own recording condition",
    },
    "warp5000-l0": {
        "args": ["--skill=expert", "--start-m=5000", "--upgrades=0"],
        "runs": 24,
        "note": "same course regime, no upgrades — the upgrade comparison",
    },
    "standing-l0": {
        "args": ["--skill=intermediate", "--upgrades=0"],
        "runs": 12,
        "note": "a full run from zero, unupgraded",
    },
    "standing-l20": {
        "args": ["--skill=intermediate", "--upgrades=20"],
        "runs": 12,
        "note": "a full run from zero, fully upgraded",
    },
}

# Summary fields that describe *how* it played. Distance says what happened;
# these say what it did to get there, and are how two optima are compared.
FINGERPRINT = [
    "taps_per_second", "dives_per_attach", "mean_attaches", "mean_bursts",
    "mean_save_bursts", "mean_reel_time_s", "mean_reel_empties",
    "mean_highway_attaches", "mean_sticky_attaches",
    "mean_timed_anchor_attaches", "class_choice_rate", "flies_per_km",
    "deaths_per_km", "mean_seconds",
]

# Owner ground truth, for context and for the anomaly flags — never optimised
# toward. Measured from run 726dcc65 decoded at its native 60 fps; an earlier
# 30 fps pass undercounted these by 40%.
OWNER_TAPS_PER_SECOND = 6.60          # averaged across a whole run
OWNER_TAPS_PER_SECOND_PEAK = 18.0     # sustained across one full second


def godot_binary() -> str:
    for candidate in (os.environ.get("GODOT_BIN"), "godot", "godot4"):
        if candidate and (os.path.isfile(candidate) or shutil.which(candidate)):
            return candidate
    sys.exit(
        "no Godot executable found. Set GODOT_BIN or put 'godot' on PATH. "
        "This script never downloads tools -- see docs/technical/testing.md."
    )


def run_batch(binary: str, extra: list[str], runs: int, seed: int,
              knobs: dict[str, float] | None) -> dict | None:
    """One simulate.gd batch. Returns its summary, or None if it failed."""
    handle, path = tempfile.mkstemp(suffix=".json")
    os.close(handle)
    argv = [
        binary, "--headless", "--path", str(REPO),
        "--script", "res://tools/simulate.gd", "--",
        f"--runs={runs}", f"--seed={seed}", "--course-seeds=8",
        "--max-seconds=180", f"--json={path}",
    ] + extra
    if knobs:
        argv.append("--bot=" + ",".join(f"{k}:{v:.5f}" for k, v in knobs.items()))
    try:
        result = subprocess.run(argv, capture_output=True, text=True, timeout=900)
        if result.returncode != 0:
            return None
        with open(path) as stream:
            return json.load(stream)["summaries"][0]
    except (subprocess.TimeoutExpired, OSError, ValueError, KeyError, IndexError):
        return None
    finally:
        try:
            os.unlink(path)
        except OSError:
            pass


def objective(summary: dict | None) -> float:
    """Higher is better: mean distance actually travelled.

    Mean rather than max, because the search needs a signal it can follow and a
    single lucky run is noise. The maximum is reported separately — that is the
    number that speaks to "is this possible at all", and it is an observation,
    not a target.
    """
    if summary is None:
        return -math.inf
    return float(summary["travelled_mean_m"])


def fingerprint(summary: dict) -> dict:
    return {key: round(float(summary[key]), 4)
            for key in FINGERPRINT if key in summary}


def reach(summary: dict) -> dict:
    return {
        "mean_m": round(float(summary["travelled_mean_m"]), 1),
        "median_m": round(float(summary["travelled_median_m"]), 1),
        "p90_m": round(float(summary["travelled_p90_m"]), 1),
        "furthest_single_run_m": round(float(summary["travelled_max_m"]), 1),
        "timeout_runs": int(summary.get("timeout_runs", 0)),
    }


def anomalies(best: dict, baseline: dict) -> list[str]:
    """Signatures worth a human's attention.

    Deliberately blunt. The point is not to decide whether something is an
    exploit — that is the owner's call from the replay — it is to make sure a
    run that plays nothing like ordinary play never passes unremarked.
    """
    flags: list[str] = []

    def ratio(key: str) -> float | None:
        base = float(baseline.get(key, 0.0))
        if base <= 1e-9:
            return None
        return float(best.get(key, 0.0)) / base

    taps = float(best.get("taps_per_second", 0.0))
    # Compared against the owner's PEAK, not his average: a run-long average
    # above what he sustains for one second is input no hand produced.
    if taps > OWNER_TAPS_PER_SECOND_PEAK:
        flags.append(
            f"sustained input {taps:.2f}/s exceeds the owner's one-second peak "
            f"of {OWNER_TAPS_PER_SECOND_PEAK:.0f}/s for a whole run — that is "
            "not a rate a hand holds, check the replay")
    elif taps > OWNER_TAPS_PER_SECOND * 1.6:
        flags.append(
            f"input rate {taps:.2f}/s is {taps / OWNER_TAPS_PER_SECOND:.1f}x the "
            f"owner's run average of {OWNER_TAPS_PER_SECOND}/s — inside his "
            "demonstrated peak, but worth seeing on the replay")
    if taps < OWNER_TAPS_PER_SECOND * 0.35:
        flags.append(
            f"input rate {taps:.2f}/s is far below ordinary play — it may be "
            "riding one long swing rather than playing the course")

    dives = float(best.get("dives_per_attach", 0.0))
    if dives > 1.05:
        flags.append(
            f"{dives:.2f} dives per web attach — Dive re-arms once per attach, "
            "so anything above 1.0 wants explaining")
    if dives < 0.02 and float(baseline.get("dives_per_attach", 0.0)) > 0.2:
        flags.append("stopped diving entirely — one verb abandoned")

    for key, label in (("mean_bursts", "Burst"), ("mean_attaches", "web")):
        value = ratio(key)
        if value is not None and value > 2.5:
            flags.append(
                f"{label} use {value:.1f}x the default — verb spam is the "
                "commonest shape of an exploit")
        if value is not None and value < 0.25:
            flags.append(f"{label} use fell to {value:.1f}x the default")

    # Near-misses are reported too. The first search's burst ratio was 2.45
    # against the 2.5 threshold, and "no anomaly flags" was quietly two
    # percent away from being false — a silence that fragile must be visible.
    for key, label, threshold in (
            ("mean_bursts", "Burst", 2.5), ("mean_attaches", "web", 2.5)):
        value = ratio(key)
        if value is not None and 0.8 * threshold < value <= threshold:
            flags.append(
                f"NEAR MISS: {label} use {value:.2f}x the default, threshold "
                f"{threshold} — the flag stayed silent by "
                f"{(threshold - value) / threshold:.0%}")

    sticky = float(best.get("mean_sticky_attaches", 0.0))
    if sticky > 0.0 and float(baseline.get("mean_sticky_attaches", 0.0)) <= 0.0:
        flags.append(
            "started attaching to sticky silk, which bleeds velocity — either "
            "the penalty is too weak or it found a use for it")
    return flags


def clamp(name: str, value: float) -> float:
    low, high, _ = KNOBS[name]
    return min(high, max(low, value))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", default="warp5000-l20", choices=list(CONFIGS))
    parser.add_argument("--generations", type=int, default=12)
    parser.add_argument("--population", type=int, default=16)
    parser.add_argument("--elite-fraction", type=float, default=0.25)
    parser.add_argument("--runs", type=int, default=0,
                        help="override the per-config run count")
    parser.add_argument("--workers", type=int, default=4)
    parser.add_argument("--seed", type=int, default=7)
    parser.add_argument("--evaluate-only", action="store_true")
    parser.add_argument("--out", default="")
    args = parser.parse_args()

    binary = godot_binary()
    random.seed(args.seed)
    spec = CONFIGS[args.config]
    runs = args.runs or spec["runs"]
    extra = spec["args"]

    base_summary = run_batch(binary, extra, runs, args.seed, None)
    if base_summary is None:
        sys.exit("[fit] the baseline batch failed to run")
    base_score = objective(base_summary)
    base_print = fingerprint(base_summary)
    print(f"[fit] config {args.config} — {spec['note']}")
    print(f"[fit] defaults reach {json.dumps(reach(base_summary))}")
    print(f"[fit] defaults play  {json.dumps(base_print)}")
    if args.evaluate_only:
        return 0

    names = list(KNOBS)
    mean = {n: KNOBS[n][2] for n in names}
    # Start wide. The hand-written defaults are a guess and a narrow prior
    # around them would only rediscover them.
    sigma = {n: (KNOBS[n][1] - KNOBS[n][0]) * 0.30 for n in names}
    elite_count = max(2, int(args.population * args.elite_fraction))

    best_score = base_score
    best_knobs: dict[str, float] = {}
    best_summary = base_summary
    history = [{"generation": 0, "best_m": round(base_score, 1),
                "fingerprint": base_print}]

    for generation in range(1, args.generations + 1):
        population = [
            {n: clamp(n, random.gauss(mean[n], sigma[n])) for n in names}
            for _ in range(args.population)
        ]
        # Every candidate in a generation shares one seed so they face the
        # same courses and the same modelled imperfection; the seed moves
        # between generations so the search cannot win by fitting one course.
        generation_seed = args.seed + generation
        with ThreadPoolExecutor(max_workers=args.workers) as pool:
            summaries = list(pool.map(
                lambda c: run_batch(binary, extra, runs, generation_seed, c),
                population))
        scored = sorted(
            zip(population, summaries),
            key=lambda pair: objective(pair[1]),
            reverse=True)
        elite = [candidate for candidate, summary in scored
                 if summary is not None][:elite_count]
        if not elite:
            print(f"[fit] gen {generation:2d}  every candidate failed; stopping")
            break

        for n in names:
            values = [candidate[n] for candidate in elite]
            mean[n] = sum(values) / len(values)
            spread = (sum((v - mean[n]) ** 2 for v in values) / len(values)) ** 0.5
            # Floor the spread so the search cannot collapse onto one point in
            # three generations and then report its own noise as convergence.
            sigma[n] = max(spread, (KNOBS[n][1] - KNOBS[n][0]) * 0.05)

        top_knobs, top_summary = scored[0]
        top_score = objective(top_summary)
        if top_score > best_score:
            best_score, best_knobs, best_summary = top_score, top_knobs, top_summary
        print(f"[fit] gen {generation:2d}  best {top_score:8.1f} m  "
              f"overall {best_score:8.1f} m  "
              f"{json.dumps(fingerprint(top_summary)) if top_summary else '{}'}")
        history.append({
            "generation": generation,
            "best_m": round(top_score, 1),
            "fingerprint": fingerprint(top_summary) if top_summary else {},
        })

    best_print = fingerprint(best_summary)
    flags = anomalies(best_print, base_print) if best_knobs else []
    gain = (best_score / base_score - 1.0) * 100.0 if base_score > 0 else 0.0

    out = REPO / (args.out or f"tools/search/{args.config}.json")
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps({
        "format": "spider-swing/bot-policy-search@1",
        "config": args.config,
        "note": spec["note"],
        "fairness": ("Perception limits (decision cadence, reaction delay, aim "
                     "error) are frozen at measured human values and are not "
                     "searchable. No statistic here certifies fair play — the "
                     "best runs are meant to be watched and judged."),
        "runs_per_candidate": runs,
        "generations": args.generations,
        "population": args.population,
        "baseline": {"reach": reach(base_summary), "fingerprint": base_print},
        "best": {"reach": reach(best_summary), "fingerprint": best_print},
        "gain_percent": round(gain, 1),
        "anomaly_flags": flags,
        "best_knobs": {k: round(v, 5) for k, v in best_knobs.items()},
        "replay": ("--bot=" + ",".join(f"{k}:{v:.5f}" for k, v in best_knobs.items())
                   if best_knobs else ""),
        "history": history,
    }, indent=2) + "\n")

    print(f"[fit] wrote {out}")
    print(f"[fit] {base_score:.1f} m -> {best_score:.1f} m ({gain:+.1f}%)")
    for flag in flags:
        print(f"[fit] FLAG {flag}")
    if not flags and best_knobs:
        print("[fit] no anomaly flags — the optimum plays like ordinary play, "
              "only better")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

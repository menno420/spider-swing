#!/usr/bin/env python3
"""Measure the difficulty curve across distance bands and skill tiers.

Drives `tools/simulate.gd` once per distance band with `--start-m`, over every
skill tier and a fixed seed set, then renders the deaths-per-kilometre and
death-cause tables that difficulty modes, the upgrade audit and the economy are
judged against.

    python3 tools/difficulty_curve.py --out docs/measurements/...md

The point of committing the runner rather than the numbers alone is that a
later slice can re-measure the same grid and diff it. Every knob that moves a
number is a flag here, and the flags are echoed into the rendered document.

Nothing here asserts: this is instrumentation, not a gate. It reads Godot from
GODOT_BIN / GODOT / GODOT4 / PATH, the same order `tools/verify.py` uses.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SIMULATE_SCRIPT = "res://tools/simulate.gd"
GODOT_ENV_VARS = ("GODOT_BIN", "GODOT", "GODOT4")
GODOT_PATH_NAMES = ("godot", "godot4", "Godot")

DEFAULT_BANDS = (0, 5000, 10000, 15000, 20000)
SKILL_ORDER = ("novice", "intermediate", "expert")


def locate_godot() -> str:
    for var in GODOT_ENV_VARS:
        value = os.environ.get(var, "").strip()
        if value:
            resolved = shutil.which(value) or value
            if Path(resolved).exists():
                return resolved
    for name in GODOT_PATH_NAMES:
        resolved = shutil.which(name)
        if resolved:
            return resolved
    sys.exit(
        "no Godot executable found. Set GODOT_BIN to the pinned binary or put "
        "it on PATH as 'godot'."
    )


def run_band(godot: str, band_m: int, options: argparse.Namespace) -> list[dict]:
    """Run every skill tier at one start distance; return its summaries."""
    with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as handle:
        json_path = handle.name
    command = [
        godot, "--headless", "--path", str(REPO_ROOT),
        "--script", SIMULATE_SCRIPT, "--",
        f"--runs={options.runs}",
        "--skill=all",
        f"--spider={options.spider}",
        f"--preset={options.preset}",
        f"--upgrades={options.upgrades}",
        f"--seed={options.seed}",
        f"--course-seed={options.course_seed}",
        f"--course-seeds={options.course_seeds}",
        f"--max-seconds={options.max_seconds}",
        f"--start-m={band_m}",
        f"--json={json_path}",
    ]
    print(f"[curve] band {band_m} m ...", flush=True)
    completed = subprocess.run(command, capture_output=True, text=True)
    if completed.returncode != 0:
        sys.stderr.write(completed.stdout)
        sys.stderr.write(completed.stderr)
        sys.exit(f"simulate.gd failed at --start-m={band_m}")
    payload = json.loads(Path(json_path).read_text(encoding="utf-8"))
    Path(json_path).unlink(missing_ok=True)
    summaries = payload["summaries"]
    for summary in summaries:
        summary["start_m"] = band_m
    return summaries


def histogram_text(histogram: dict) -> str:
    if not histogram:
        return "—"
    ordered = sorted(histogram.items(), key=lambda item: (-item[1], item[0]))
    return " · ".join(f"{name} ×{count}" for name, count in ordered)


def cause_share(histogram: dict) -> dict[str, float]:
    total = sum(histogram.values())
    if total == 0:
        return {}
    return {name: count / total for name, count in histogram.items()}


def render(summaries: list[dict], options: argparse.Namespace) -> str:
    by_key = {(s["start_m"], s["skill"]): s for s in summaries}
    bands = sorted({s["start_m"] for s in summaries})
    skills = [s for s in SKILL_ORDER if any(k[1] == s for k in by_key)]

    lines: list[str] = []
    add = lines.append

    add("## Deaths per kilometre")
    add("")
    add("Rate normalizes on ground **travelled**, not course position, and")
    add("counts the rescued death as well as the terminal one. `±` is the")
    add("Poisson standard error — band-to-band wobble inside it is sample")
    add("size, not difficulty.")
    add("")
    add("| Start | " + " | ".join(s.capitalize() for s in skills) + " |")
    add("| --- | " + " | ".join("---:" for _ in skills) + " |")
    for band in bands:
        cells = []
        for skill in skills:
            summary = by_key.get((band, skill))
            cells.append("—" if summary is None else
                         f"{summary['deaths_per_km']:.2f} ±"
                         f"{summary['deaths_per_km_se']:.2f}")
        add(f"| {band:,} m | " + " | ".join(cells) + " |")
    add("")

    add("## Distance survived from the start line")
    add("")
    add("| Start | Skill | Mean | Median | p10 | p90 | Timeouts |")
    add("| --- | --- | ---: | ---: | ---: | ---: | ---: |")
    for band in bands:
        for skill in skills:
            summary = by_key.get((band, skill))
            if summary is None:
                continue
            add(
                f"| {band:,} m | {skill} | "
                f"{summary['travelled_mean_m']:,.0f} m | "
                f"{summary['travelled_median_m']:,.0f} m | "
                f"{summary['travelled_p10_m']:,.0f} m | "
                f"{summary['travelled_p90_m']:,.0f} m | "
                f"{summary['timeout_runs']} |"
            )
    add("")

    add("## Death causes")
    add("")
    add("| Start | Skill | Causes | Mid-pull | Patterns at death |")
    add("| --- | --- | --- | ---: | --- |")
    for band in bands:
        for skill in skills:
            summary = by_key.get((band, skill))
            if summary is None:
                continue
            add(
                f"| {band:,} m | {skill} | "
                f"{histogram_text(summary['death_causes'])} | "
                f"{summary['pull_death_runs']} | "
                f"{histogram_text(summary['death_patterns'])} |"
            )
    add("")

    add("## Resource pressure")
    add("")
    add("| Start | Skill | Flies/km | Webs/run | Bursts/run | Reel held | At empty |")
    add("| --- | --- | ---: | ---: | ---: | ---: | ---: |")
    for band in bands:
        for skill in skills:
            summary = by_key.get((band, skill))
            if summary is None:
                continue
            add(
                f"| {band:,} m | {skill} | "
                f"{summary['flies_per_km']:.1f} | "
                f"{summary['mean_attaches']:.1f} | "
                f"{summary['mean_bursts']:.1f} | "
                f"{summary['mean_reel_time_s']:.2f} s | "
                f"{summary['mean_time_empty_s']:.2f} s |"
            )
    add("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runs", type=int, default=40)
    parser.add_argument("--spider", default="classic")
    parser.add_argument("--preset", default="balanced_baseline")
    parser.add_argument("--upgrades", type=int, default=0)
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument("--course-seed", type=int, default=1337)
    parser.add_argument("--course-seeds", type=int, default=8)
    parser.add_argument("--max-seconds", type=int, default=240)
    parser.add_argument(
        "--bands", default=",".join(str(b) for b in DEFAULT_BANDS),
        help="comma-separated --start-m values")
    parser.add_argument("--out", default="", help="write markdown here")
    parser.add_argument("--json-out", default="", help="write raw summaries here")
    options = parser.parse_args()

    godot = locate_godot()
    bands = [int(value) for value in options.bands.split(",") if value.strip()]
    summaries: list[dict] = []
    for band in bands:
        summaries.extend(run_band(godot, band, options))

    body = render(summaries, options)
    if options.json_out:
        Path(options.json_out).write_text(
            json.dumps(summaries, indent="\t"), encoding="utf-8")
    if options.out:
        Path(options.out).write_text(body, encoding="utf-8")
        print(f"[curve] wrote {options.out}")
    else:
        print(body)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

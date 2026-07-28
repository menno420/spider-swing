#!/usr/bin/env python3
"""The single host verification entry point for Spider Swing.

    python3 tools/verify.py

Runs, in order:

  1. locate the Godot executable (GODOT_BIN, GODOT, GODOT4, then PATH)
  2. assert it reports the version pinned in .godot-version
  3. tools/check_architecture.py --self-test, then the repository scan
  4. a headless project import / editor smoke validation
  5. tests/test_runner.gd, headlessly

Contract:

  * any failure propagates as a nonzero exit code
  * failure messages are concise and say what to do next
  * nothing is ever downloaded: a missing Godot is reported, not fetched
  * the Substrate checker is NEVER invoked from here -- the Substrate workflow
    runs `bootstrap.py check` itself and calling it from this script would
    recurse (see the substrate-gate workflow's verify step)

This validates host/game code only. Keep it stdlib-only so it runs on a clean
Python 3.10+ with no install step.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
GODOT_ENV_VARS = ("GODOT_BIN", "GODOT", "GODOT4")
GODOT_PATH_NAMES = ("godot", "godot4", "Godot")
VERSION_FILE = REPO_ROOT / ".godot-version"
TEST_RUNNER = "res://tests/test_runner.gd"

#: Generous but bounded: a cold import on a CI runner is slow, a hang is a bug.
IMPORT_TIMEOUT_SECONDS = 600
RUN_TIMEOUT_SECONDS = 300


class VerifyError(Exception):
    """A verification step failed with an actionable message."""


@dataclass
class Report:
    """Accumulated step results, rendered as one summary at the end."""

    steps: list[tuple[str, bool, float]] = field(default_factory=list)

    def record(self, name: str, ok: bool, seconds: float) -> None:
        self.steps.append((name, ok, seconds))

    def render(self) -> str:
        lines = ["", "verify.py summary:"]
        for name, ok, seconds in self.steps:
            mark = "PASS" if ok else "FAIL"
            lines.append(f"  [{mark}] {name} ({seconds:.1f}s)")
        return "\n".join(lines)


def log(message: str) -> None:
    print(f"[verify] {message}", flush=True)


def fail(message: str) -> None:
    print(f"[verify] FAIL: {message}", file=sys.stderr, flush=True)


def pinned_version() -> str:
    if not VERSION_FILE.is_file():
        raise VerifyError(
            ".godot-version is missing. It pins the engine version this project "
            "is verified against; recreate it containing a single line, e.g. 4.7.1"
        )
    version = VERSION_FILE.read_text(encoding="utf-8").strip()
    if not version:
        raise VerifyError(".godot-version is empty; it must contain e.g. 4.7.1")
    return version


def locate_godot() -> Path:
    """Find a Godot executable. Never downloads one."""
    for var in GODOT_ENV_VARS:
        value = os.environ.get(var)
        if not value:
            continue
        candidate = Path(value).expanduser()
        if candidate.is_file() and os.access(candidate, os.X_OK):
            log(f"using Godot from ${var}: {candidate}")
            return candidate
        resolved = shutil.which(value)
        if resolved:
            log(f"using Godot from ${var} (resolved on PATH): {resolved}")
            return Path(resolved)
        raise VerifyError(
            f"${var} is set to '{value}' but that is not an executable file. "
            f"Point it at the Godot {pinned_version()} binary, or unset it to "
            "fall back to PATH."
        )

    for name in GODOT_PATH_NAMES:
        resolved = shutil.which(name)
        if resolved:
            log(f"using Godot from PATH: {resolved}")
            return Path(resolved)

    raise VerifyError(
        f"no Godot executable found. Install Godot {pinned_version()} Standard "
        "(not .NET) and either put it on PATH as 'godot' or set GODOT_BIN to it. "
        "This script never downloads tools -- see docs/technical/testing.md."
    )


def godot_version(binary: Path) -> str:
    """Return the raw --version string, e.g. '4.7.1.stable.official.a13da4feb'."""
    try:
        completed = subprocess.run(
            [str(binary), "--version"],
            capture_output=True,
            text=True,
            timeout=120,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise VerifyError(f"could not run '{binary} --version': {exc}") from exc
    if completed.returncode != 0:
        raise VerifyError(
            f"'{binary} --version' exited {completed.returncode}: "
            f"{(completed.stderr or completed.stdout).strip()[:300]}"
        )
    # Godot prints the version last; earlier lines can be loader noise.
    lines = [line.strip() for line in completed.stdout.splitlines() if line.strip()]
    if not lines:
        raise VerifyError(f"'{binary} --version' printed nothing")
    return lines[-1]


def check_version(binary: Path, expected: str) -> None:
    raw = godot_version(binary)
    log(f"Godot reports: {raw}")
    if not raw.startswith(expected + "."):
        raise VerifyError(
            f"Godot version mismatch: the binary reports '{raw}' but "
            f".godot-version pins '{expected}'. Install Godot {expected} Standard, "
            "or update .godot-version in the same change that moves the engine "
            "(and update ADR 0001, which locks the engine version)."
        )
    if "mono" in raw.lower():
        raise VerifyError(
            f"this is the .NET/Mono build ('{raw}'). Spider Swing is GDScript-only "
            "and pins Godot Standard -- see ADR 0001."
        )
    log(f"Godot version matches the pinned {expected}")


def run_step(name: str, argv: list[str], timeout: int, cwd: Path) -> bool:
    """Run one subprocess step, streaming nothing but reporting clearly."""
    log(f"{name}: {' '.join(argv)}")
    try:
        completed = subprocess.run(
            argv, cwd=str(cwd), capture_output=True, text=True,
            timeout=timeout, check=False,
        )
    except subprocess.TimeoutExpired:
        fail(f"{name} timed out after {timeout}s")
        return False
    except OSError as exc:
        fail(f"{name} could not start: {exc}")
        return False

    if completed.returncode == 0:
        for line in _interesting(completed.stdout):
            print(f"    {line}")
        return True

    fail(f"{name} exited {completed.returncode}")
    tail = (completed.stdout + "\n" + completed.stderr).strip().splitlines()
    for line in tail[-40:]:
        print(f"    {line}", file=sys.stderr)
    return False


def _interesting(stdout: str) -> list[str]:
    """Keep engine progress spam out of a passing run's output."""
    keep = []
    for line in stdout.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("[") and "%" in stripped.split("]")[0]:
            continue
        keep.append(stripped)
    return keep[-25:]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Verify the Spider Swing host/game code.",
    )
    parser.add_argument(
        "--skip-godot",
        action="store_true",
        help="run only the engine-independent checks (architecture); useful for a "
             "fast local pass on a machine without Godot installed. CI never uses this.",
    )
    args = parser.parse_args(argv)

    report = Report()
    checker = REPO_ROOT / "tools" / "check_architecture.py"
    if not checker.is_file():
        fail(f"missing {checker.relative_to(REPO_ROOT)}")
        return 1

    # --- engine-independent checks -------------------------------------------
    start = time.monotonic()
    ok = run_step(
        "architecture checker self-test",
        [sys.executable, str(checker), "--self-test"],
        timeout=120,
        cwd=REPO_ROOT,
    )
    report.record("architecture checker self-test", ok, time.monotonic() - start)
    all_ok = ok

    start = time.monotonic()
    ok = run_step(
        "architecture scan",
        [sys.executable, str(checker)],
        timeout=120,
        cwd=REPO_ROOT,
    )
    report.record("architecture scan", ok, time.monotonic() - start)
    all_ok = all_ok and ok

    if args.skip_godot:
        log("--skip-godot: engine checks skipped (never used in CI)")
        print(report.render())
        return 0 if all_ok else 1

    # --- engine checks -------------------------------------------------------
    start = time.monotonic()
    try:
        expected = pinned_version()
        godot = locate_godot()
        check_version(godot, expected)
    except VerifyError as exc:
        fail(str(exc))
        report.record("Godot discovery and version", False, time.monotonic() - start)
        print(report.render())
        return 1
    report.record("Godot discovery and version", True, time.monotonic() - start)

    start = time.monotonic()
    ok = run_step(
        "headless project import",
        [str(godot), "--headless", "--path", str(REPO_ROOT), "--import"],
        timeout=IMPORT_TIMEOUT_SECONDS,
        cwd=REPO_ROOT,
    )
    report.record("headless project import", ok, time.monotonic() - start)
    all_ok = all_ok and ok

    start = time.monotonic()
    ok = run_step(
        "headless boot smoke test",
        [str(godot), "--headless", "--path", str(REPO_ROOT), "--quit-after", "3"],
        timeout=RUN_TIMEOUT_SECONDS,
        cwd=REPO_ROOT,
    )
    report.record("headless boot smoke test", ok, time.monotonic() - start)
    all_ok = all_ok and ok

    start = time.monotonic()
    ok = run_step(
        "headless test runner",
        [str(godot), "--headless", "--path", str(REPO_ROOT), "--script", TEST_RUNNER],
        timeout=RUN_TIMEOUT_SECONDS,
        cwd=REPO_ROOT,
    )
    report.record("headless test runner", ok, time.monotonic() - start)
    all_ok = all_ok and ok

    print(report.render())
    if all_ok:
        log("all checks passed")
        return 0
    fail("one or more checks failed (see above)")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())

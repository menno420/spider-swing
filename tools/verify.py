#!/usr/bin/env python3
"""The single host verification entry point for Spider Swing.

    python3 tools/verify.py

Runs, in order:

  1. regenerate the original gameplay SFX in a temporary directory and compare
     exact bytes
  2. tools/check_architecture.py --self-test, then the repository scan
  3. locate the Godot executable (GODOT_BIN, GODOT, GODOT4, then PATH)
  4. assert it reports the version pinned in .godot-version
  5. a headless project import / editor smoke validation
  6. tests/test_runner.gd, headlessly

Contract:

  * any failure propagates as a nonzero exit code
  * failure messages are concise and say what to do next
  * nothing is ever downloaded: a missing Godot is reported, not fetched
  * the Substrate checker is NEVER invoked from here -- the Substrate workflow
    runs `bootstrap.py check` itself and calling it from this script would
    recurse (see the substrate-gate workflow's verify step)

This validates host/game code only. Keep it stdlib-only so it runs on a clean
Python 3.10+ with no install step.

Two jobs run this script, and they have different toolchains:

  * `game-quality` installs Godot and runs `--require-godot`, so a missing or
    wrong-version engine is a HARD failure there. That is the gate that proves
    the engine.
  * `substrate-gate` is kit-owned and Python-only -- it runs this script because
    it is the repository's confirmed `verify_command` interview slot. With no
    engine present it runs the engine-independent checks strictly and reports the
    engine steps as SKIPPED rather than inventing a pass or a failure.

So the default is "run everything you can, and say loudly what you could not
run"; `--require-godot` turns a missing engine into a failure. A *wrong* engine
version is always a hard failure, in both modes -- that is never a skip.
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
GODOT_FATAL_OUTPUT_MARKERS = (
    "SCRIPT ERROR:",
    "Parse Error:",
    "Compile Error:",
    "ERROR: Failed to load script",
)


class VerifyError(Exception):
    """A verification step failed with an actionable message."""


class GodotMissing(VerifyError):
    """No Godot executable is installed anywhere this script can see."""


@dataclass
class Report:
    """Accumulated step results, rendered as one summary at the end."""

    steps: list[tuple[str, str, float]] = field(default_factory=list)

    def record(self, name: str, mark: str, seconds: float) -> None:
        self.steps.append((name, mark, seconds))

    def ok(self, name: str, seconds: float) -> None:
        self.record(name, "PASS", seconds)

    def failed(self, name: str, seconds: float) -> None:
        self.record(name, "FAIL", seconds)

    def skipped(self, name: str) -> None:
        self.record(name, "SKIP", 0.0)

    def render(self) -> str:
        lines = ["", "verify.py summary:"]
        for name, mark, seconds in self.steps:
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

    raise GodotMissing(
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

    combined_output = completed.stdout + "\n" + completed.stderr
    fatal_markers = [
        marker for marker in GODOT_FATAL_OUTPUT_MARKERS
        if marker in combined_output
    ]
    if completed.returncode == 0 and not fatal_markers:
        for line in _interesting(completed.stdout):
            print(f"    {line}")
        return True

    if completed.returncode == 0:
        fail(
            f"{name} printed fatal Godot diagnostics despite exit 0: "
            f"{', '.join(fatal_markers)}"
        )
    else:
        fail(f"{name} exited {completed.returncode}")
    tail = combined_output.strip().splitlines()
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
        "--require-godot",
        action="store_true",
        help="treat a missing Godot as a FAILURE instead of skipping the engine "
             "steps. game-quality installs Godot and passes this, so the gate that "
             "proves the engine can never silently skip it.",
    )
    parser.add_argument(
        "--skip-godot",
        action="store_true",
        help="skip the engine steps even if Godot is installed; runs only the "
             "engine-independent checks. For a fast local pass. CI never uses this.",
    )
    args = parser.parse_args(argv)

    if args.require_godot and args.skip_godot:
        fail("--require-godot and --skip-godot contradict each other; pick one.")
        return 2

    report = Report()
    checker = REPO_ROOT / "tools" / "check_architecture.py"
    audio_generator = REPO_ROOT / "tools" / "generate_audio_samples.py"
    if not checker.is_file():
        fail(f"missing {checker.relative_to(REPO_ROOT)}")
        return 1
    if not audio_generator.is_file():
        fail(f"missing {audio_generator.relative_to(REPO_ROOT)}")
        return 1

    # --- engine-independent checks -------------------------------------------
    start = time.monotonic()
    ok = run_step(
        "generated audio reproducibility",
        [sys.executable, str(audio_generator), "--check"],
        timeout=120,
        cwd=REPO_ROOT,
    )
    (report.ok if ok else report.failed)(
        "generated audio reproducibility", time.monotonic() - start
    )
    all_ok = ok

    start = time.monotonic()
    ok = run_step(
        "architecture checker self-test",
        [sys.executable, str(checker), "--self-test"],
        timeout=120,
        cwd=REPO_ROOT,
    )
    (report.ok if ok else report.failed)(
        "architecture checker self-test", time.monotonic() - start
    )
    all_ok = all_ok and ok

    start = time.monotonic()
    ok = run_step(
        "architecture scan",
        [sys.executable, str(checker)],
        timeout=120,
        cwd=REPO_ROOT,
    )
    (report.ok if ok else report.failed)("architecture scan", time.monotonic() - start)
    all_ok = all_ok and ok

    engine_steps = (
        "Godot discovery and version",
        "headless project import",
        "headless boot smoke test",
        "headless test runner",
    )

    if args.skip_godot:
        log("--skip-godot: engine steps skipped by request (CI never uses this)")
        for name in engine_steps:
            report.skipped(name)
        print(report.render())
        return 0 if all_ok else 1

    # --- engine checks -------------------------------------------------------
    start = time.monotonic()
    try:
        expected = pinned_version()
        godot = locate_godot()
        check_version(godot, expected)
    except GodotMissing as exc:
        # No engine installed. In the gate that installs Godot this is a hard
        # failure (--require-godot). In a Python-only job -- notably the kit-owned
        # substrate-gate, which runs this script because it is the confirmed
        # verify_command -- the honest result is SKIPPED, not a manufactured pass
        # or a red gate about a tool that job was never meant to have.
        if args.require_godot:
            fail(str(exc))
            report.failed("Godot discovery and version", time.monotonic() - start)
            print(report.render())
            return 1
        log("=" * 72)
        log(f"ENGINE STEPS SKIPPED -- {exc}")
        log("The engine-independent checks above ran strictly and their result")
        log("stands. Nothing about the Godot project has been verified by this")
        log("run. The `game-quality` workflow installs Godot and runs this script")
        log("with --require-godot, so the engine is always proven there.")
        log("=" * 72)
        for name in engine_steps:
            report.skipped(name)
        print(report.render())
        return 0 if all_ok else 1
    except VerifyError as exc:
        # A wrong version, a Mono build, or an unrunnable binary is ALWAYS a hard
        # failure -- never a skip. An engine that is present but wrong is a real
        # defect in both modes.
        fail(str(exc))
        report.failed("Godot discovery and version", time.monotonic() - start)
        print(report.render())
        return 1
    report.ok("Godot discovery and version", time.monotonic() - start)

    start = time.monotonic()
    ok = run_step(
        "headless project import",
        [str(godot), "--headless", "--path", str(REPO_ROOT), "--import"],
        timeout=IMPORT_TIMEOUT_SECONDS,
        cwd=REPO_ROOT,
    )
    (report.ok if ok else report.failed)(
        "headless project import", time.monotonic() - start
    )
    all_ok = all_ok and ok

    start = time.monotonic()
    ok = run_step(
        "headless boot smoke test",
        [str(godot), "--headless", "--path", str(REPO_ROOT), "--quit-after", "3"],
        timeout=RUN_TIMEOUT_SECONDS,
        cwd=REPO_ROOT,
    )
    (report.ok if ok else report.failed)(
        "headless boot smoke test", time.monotonic() - start
    )
    all_ok = all_ok and ok

    start = time.monotonic()
    ok = run_step(
        "headless test runner",
        [str(godot), "--headless", "--path", str(REPO_ROOT), "--script", TEST_RUNNER],
        timeout=RUN_TIMEOUT_SECONDS,
        cwd=REPO_ROOT,
    )
    (report.ok if ok else report.failed)(
        "headless test runner", time.monotonic() - start
    )
    all_ok = all_ok and ok

    print(report.render())
    if all_ok:
        log("all checks passed")
        return 0
    fail("one or more checks failed (see above)")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())

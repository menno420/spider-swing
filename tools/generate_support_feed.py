#!/usr/bin/env python3
"""Generate the Spider Bot support feed, and check that it is current.

    python3 tools/generate_support_feed.py            # write it
    python3 tools/generate_support_feed.py --check    # fail if it is stale

**Why this exists.** Spider Bot answers testers' questions about this game, and
until now it did so from a block of prose hand-copied out of these docs. That
had already drifted: `MEASURED` 2026-09-04, the bot's copy said the game was
*"currently in CLOSED ALPHA testing"* while `docs/technical/play-closed-test-runbook.md`
describes a closed track that has not started; its wait-time figures appear in
no document here; and it carried **no build version at all** — the fastest-
changing fact in the whole system.

This repository owns the game, so this repository publishes what the bot may
say about it. The bot consumes; it never becomes a second definition.

**The contract is `CONSTITUTION.md`'s own**, verbatim:

> *"Cross-repo feeds carry a pinned contract. When this repo commits a generated
> artifact another repo consumes over a raw URL, the seam carries a committed,
> versioned shape contract: the producer stamps the version into the artifact
> and enforces fail-closed parity in CI; the consumer pins the version it built
> against and verifies at render time, surfacing drift as an honest banner —
> never faking data."*

So the producer half is: stamp `schema_version`, validate the shape, and fail
CI when the committed artifact does not match its source. `--check` is wired
into `tools/verify.py`'s engine-independent section, which both required
checks on `main` run.

**Two files, on purpose.** `support/source.json` is the curated half — prose a
person writes, edited here by whoever changes the game. The build identity is
read MECHANICALLY from `project.godot`, so the one class of fact that drifts
fastest cannot. Pretending a regex could extract join steps from a runbook
would make this generator a second source of truth rather than a projection of
one.

**The artifact is byte-reproducible.** No timestamp: `source_sha` is the
SHA-256 of the curated source, which identifies exactly which content produced
this feed and, unlike a clock, is the same on every run. `--check` is therefore
a plain byte comparison with no exceptions carved out of it.

Stdlib only, like every other tool here, so it runs on a clean Python 3.10+.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parent.parent
SOURCE = REPO_ROOT / "support" / "source.json"
ARTIFACT = REPO_ROOT / "support" / "spider-bot-support-feed.json"
PROJECT_GODOT = REPO_ROOT / "project.godot"

#: Bumped when the SHAPE changes. Spider Bot pins the version it was built
#: against and refuses anything else, so this number is a promise: a consumer
#: reading schema 1 will find every field below and no field will change
#: meaning under it.
SCHEMA_VERSION = 1
FEED_FORMAT = "slingy-spider-support-feed"

#: Every key the artifact carries, in emitted order. A consumer may ignore
#: fields it does not know; it may not be surprised by a missing one.
REQUIRED_SOURCE_KEYS = (
    "testing_state",
    "join_steps",
    "known_issues",
    "troubleshooting",
    "facts",
    "feedback_wanted",
    "retention_rules",
    "links",
)

_VERSION = re.compile(r'^config/version="([^"]*)"', re.MULTILINE)
_VERSION_CODE = re.compile(r"^config/android_version_code=(\d+)", re.MULTILINE)


class GenerationError(Exception):
    """A refusal with a reason, printed and turned into a nonzero exit."""


def read_build_identity() -> tuple[str, int]:
    """The build version and Android version code, from `project.godot`.

    Mechanical on purpose. These are the facts a human copying prose gets wrong
    first, and they are the two this generator can read without interpreting
    anything.
    """
    if not PROJECT_GODOT.is_file():
        raise GenerationError(f"missing {PROJECT_GODOT.relative_to(REPO_ROOT)}")
    text = PROJECT_GODOT.read_text(encoding="utf-8")
    version = _VERSION.search(text)
    code = _VERSION_CODE.search(text)
    if version is None:
        raise GenerationError("project.godot has no config/version")
    if code is None:
        raise GenerationError("project.godot has no config/android_version_code")
    return version.group(1), int(code.group(1))


def _pairs(raw: Any, first: str, second: str, where: str) -> list[dict[str, str]]:
    if not isinstance(raw, list):
        raise GenerationError(f"{where} must be a list")
    out = []
    for index, item in enumerate(raw):
        if not isinstance(item, dict) or first not in item or second not in item:
            raise GenerationError(
                f"{where}[{index}] must be an object with {first!r} and {second!r}"
            )
        out.append({first: str(item[first]), second: str(item[second])})
    return out


def _strings(raw: Any, where: str) -> list[str]:
    if not isinstance(raw, list) or not all(isinstance(x, str) for x in raw):
        raise GenerationError(f"{where} must be a list of strings")
    return [x.strip() for x in raw if x.strip()]


def build_feed() -> dict[str, Any]:
    """The artifact. Raises `GenerationError` with a readable reason."""
    if not SOURCE.is_file():
        raise GenerationError(f"missing {SOURCE.relative_to(REPO_ROOT)}")
    raw_text = SOURCE.read_text(encoding="utf-8")
    try:
        source = json.loads(raw_text)
    except ValueError as exc:
        raise GenerationError(f"{SOURCE.name} is not valid JSON: {exc}") from exc
    if not isinstance(source, dict):
        raise GenerationError(f"{SOURCE.name} must be a JSON object")
    missing = [key for key in REQUIRED_SOURCE_KEYS if key not in source]
    if missing:
        raise GenerationError(f"{SOURCE.name} is missing {', '.join(missing)}")

    version, version_code = read_build_identity()
    return {
        "format": FEED_FORMAT,
        "schema_version": SCHEMA_VERSION,
        "build_version": version,
        "android_version_code": version_code,
        "testing_state": str(source["testing_state"]).strip(),
        "join_steps": _strings(source["join_steps"], "join_steps"),
        "known_issues": _strings(source["known_issues"], "known_issues"),
        "troubleshooting": _pairs(
            source["troubleshooting"], "symptom", "fix", "troubleshooting"
        ),
        "facts": _pairs(source["facts"], "name", "value", "facts"),
        "feedback_wanted": _strings(source["feedback_wanted"], "feedback_wanted"),
        "retention_rules": _strings(source["retention_rules"], "retention_rules"),
        "links": _pairs(source["links"], "label", "url", "links"),
        # Identifies exactly which curated content produced this feed. A hash
        # rather than a clock, so the artifact is byte-reproducible and --check
        # can be a plain comparison with nothing carved out of it.
        "source_sha": hashlib.sha256(raw_text.encode("utf-8")).hexdigest()[:12],
    }


def render(feed: dict[str, Any]) -> str:
    return json.dumps(feed, indent=2, ensure_ascii=False) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="fail if the committed artifact does not match its source",
    )
    args = parser.parse_args(argv)

    try:
        rendered = render(build_feed())
    except GenerationError as exc:
        print(f"support feed: {exc}", file=sys.stderr)
        return 1

    if args.check:
        if not ARTIFACT.is_file():
            print(
                f"support feed: {ARTIFACT.relative_to(REPO_ROOT)} is missing.\n"
                "Run: python3 tools/generate_support_feed.py",
                file=sys.stderr,
            )
            return 1
        current = ARTIFACT.read_text(encoding="utf-8")
        if current != rendered:
            print(
                f"support feed: {ARTIFACT.relative_to(REPO_ROOT)} is stale.\n"
                "Spider Bot reads this file over a raw URL, so a stale one means "
                "the bot tells testers something this repository no longer says.\n"
                "Run: python3 tools/generate_support_feed.py  (then commit both)",
                file=sys.stderr,
            )
            return 1
        print("support feed: current")
        return 0

    ARTIFACT.parent.mkdir(parents=True, exist_ok=True)
    ARTIFACT.write_text(rendered, encoding="utf-8")
    print(f"support feed: wrote {ARTIFACT.relative_to(REPO_ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Enforce Spider Swing's inward architectural dependency direction.

The declared layering (docs/architecture.md, ADR 0002) is inward-facing: an
outer layer may depend on inner layers, never the reverse, and the two
outermost peers -- adapters and presentation -- may not depend on each other.

    domain (0)        engine-independent value objects, commands, events,
                      identifiers, configuration contracts. Depends on nothing.
    content (0)       versioned data definitions. Depends on nothing.
    simulation (1)    fixed-step spider motor, web constraint, collision
                      policy, deterministic run model. Depends on domain.
    application (2)   run state machine, difficulty director, world stream,
                      effects, score, settlement.
    adapters (3)      Godot input, scenes, persistence, telemetry, platform.
    presentation (3)  UI, camera, audio, VFX, rendering.
    bootstrap (4)     the composition root; may wire anything.

What this checker inspects:

  * GDScript ``preload(...)`` and ``load(...)`` calls
  * GDScript ``extends "res://..."`` path form
  * GDScript ``extends SomeClass`` where SomeClass is a ``class_name``
    registered elsewhere in the tree (resolved through a class index, so the
    common Godot idiom is covered rather than skipped)
  * any bare ``res://game/<layer>/`` string in a script -- direct resource
    references are the usual way an outward dependency sneaks in
  * ``[ext_resource ...]`` paths in ``.tscn`` / ``.tres`` files under ``game/``,
    so a presentation scene wired into a simulation scene is caught too

It is deliberately textual and deterministic: no engine, no imports, no
network, stdlib only. It aims to catch *obvious* outward dependencies
reliably rather than to prove the absence of exotic ones -- a dynamic
``load(some_variable)`` is beyond a static text scan and is covered by review.

Usage:
    python3 tools/check_architecture.py            # check the repository
    python3 tools/check_architecture.py --self-test  # check the checker
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
GAME_ROOT = REPO_ROOT / "game"

#: Layer name -> rank. A layer may reference itself and any strictly lower
#: rank. Equal-rank-but-different-name pairs (adapters/presentation) are peers
#: and may not reference each other.
LAYER_RANKS: dict[str, int] = {
    "domain": 0,
    "content": 0,
    "simulation": 1,
    "application": 2,
    "adapters": 3,
    "presentation": 3,
    "bootstrap": 4,
}

SCRIPT_SUFFIXES = (".gd",)
SCENE_SUFFIXES = (".tscn", ".tres")

#: Any res:// path pointing into a game layer. Covers preload(), load(),
#: extends "res://...", ext_resource paths, and bare string references alike --
#: they are all "this file names that layer's code".
RES_PATH_RE = re.compile(r'res://game/(?P<layer>[a-z_]+)/(?P<rest>[^"\')\s]*)')

#: `class_name Foo` declarations, used to build the global class index.
CLASS_NAME_RE = re.compile(r"^\s*class_name\s+([A-Za-z_][A-Za-z0-9_]*)", re.MULTILINE)

#: `extends Foo` (identifier form, not the "res://" path form).
EXTENDS_IDENT_RE = re.compile(
    r"^\s*extends\s+([A-Za-z_][A-Za-z0-9_]*)\s*$", re.MULTILINE
)

#: Lines that are pure comments are stripped before scanning, so prose that
#: mentions another layer (as this file's own docstrings do) never trips the
#: checker. A `##`/`#` comment is documentation, not a dependency.
COMMENT_LINE_RE = re.compile(r"^\s*#.*$", re.MULTILINE)
TRAILING_COMMENT_RE = re.compile(r"(?<!\S)#(?!\{).*$", re.MULTILINE)


@dataclass(frozen=True)
class Violation:
    """One outward dependency, reported with enough context to fix it."""

    path: Path
    line: int
    from_layer: str
    to_layer: str
    detail: str

    def render(self, root: Path) -> str:
        try:
            shown = self.path.relative_to(root)
        except ValueError:
            shown = self.path
        return (
            f"{shown}:{self.line}: '{self.from_layer}' must not depend on "
            f"'{self.to_layer}' -- {self.detail}"
        )


def layer_of(path: Path, game_root: Path) -> str | None:
    """Return the layer a file belongs to, or None if it is outside game/."""
    try:
        relative = path.resolve().relative_to(game_root.resolve())
    except ValueError:
        return None
    parts = relative.parts
    if not parts:
        return None
    return parts[0] if parts[0] in LAYER_RANKS else None


def is_allowed(from_layer: str, to_layer: str) -> bool:
    """Inward rule: same layer, or strictly lower rank."""
    if from_layer == to_layer:
        return True
    if from_layer not in LAYER_RANKS or to_layer not in LAYER_RANKS:
        return True  # unknown layer: not this checker's business
    return LAYER_RANKS[to_layer] < LAYER_RANKS[from_layer]


def strip_comments(text: str) -> str:
    """Blank out comment content while preserving line numbering.

    Line count must be preserved so reported line numbers stay accurate.
    Strings containing '#' are rare in GDScript paths and a false positive here
    would only ever *hide* a violation inside a string literal that also holds a
    comment marker, so the conservative trade is acceptable and documented.
    """
    text = COMMENT_LINE_RE.sub("", text)
    return TRAILING_COMMENT_RE.sub("", text)


def build_class_index(game_root: Path) -> dict[str, str]:
    """Map each registered `class_name` to the layer that declares it."""
    index: dict[str, str] = {}
    for path in sorted(game_root.rglob("*")):
        if path.suffix not in SCRIPT_SUFFIXES or not path.is_file():
            continue
        layer = layer_of(path, game_root)
        if layer is None:
            continue
        text = strip_comments(path.read_text(encoding="utf-8", errors="replace"))
        for match in CLASS_NAME_RE.finditer(text):
            index[match.group(1)] = layer
    return index


def line_of(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def scan_file(
    path: Path, game_root: Path, class_index: dict[str, str]
) -> list[Violation]:
    from_layer = layer_of(path, game_root)
    if from_layer is None:
        return []

    raw = path.read_text(encoding="utf-8", errors="replace")
    text = strip_comments(raw) if path.suffix in SCRIPT_SUFFIXES else raw
    violations: list[Violation] = []

    for match in RES_PATH_RE.finditer(text):
        to_layer = match.group("layer")
        if is_allowed(from_layer, to_layer):
            continue
        violations.append(
            Violation(
                path=path,
                line=line_of(text, match.start()),
                from_layer=from_layer,
                to_layer=to_layer,
                detail=f"references res://game/{to_layer}/{match.group('rest')}",
            )
        )

    if path.suffix in SCRIPT_SUFFIXES:
        for match in EXTENDS_IDENT_RE.finditer(text):
            base = match.group(1)
            to_layer = class_index.get(base)
            if to_layer is None or is_allowed(from_layer, to_layer):
                continue
            violations.append(
                Violation(
                    path=path,
                    line=line_of(text, match.start()),
                    from_layer=from_layer,
                    to_layer=to_layer,
                    detail=f"extends '{base}', a class_name declared in '{to_layer}'",
                )
            )

    return violations


def check_tree(game_root: Path) -> list[Violation]:
    """Scan every script and scene under game/ and return all violations."""
    if not game_root.is_dir():
        return []
    class_index = build_class_index(game_root)
    violations: list[Violation] = []
    for path in sorted(game_root.rglob("*")):
        if not path.is_file():
            continue
        if path.suffix not in SCRIPT_SUFFIXES + SCENE_SUFFIXES:
            continue
        violations.extend(scan_file(path, game_root, class_index))
    return violations


# --------------------------------------------------------------------------
# Self-tests. These make the checker's own behaviour verifiable, so a future
# refactor cannot quietly turn it into a no-op that passes everything.
# --------------------------------------------------------------------------

_FIXTURES: list[tuple[str, str, str, bool]] = [
    # (case name, relative path under game/, file body, should_pass)
    (
        "simulation may reference domain",
        "simulation/motor.gd",
        'extends Node\nconst C := preload("res://game/domain/config.gd")\n',
        True,
    ),
    (
        "simulation must not reference presentation",
        "simulation/motor.gd",
        'extends Node\nconst C := preload("res://game/presentation/hud.gd")\n',
        False,
    ),
    (
        "domain must not reference simulation",
        "domain/value.gd",
        'extends RefCounted\nvar x = load("res://game/simulation/motor.gd")\n',
        False,
    ),
    (
        "application may reference simulation and domain",
        "application/run.gd",
        'extends Node\nconst A := preload("res://game/simulation/motor.gd")\n'
        'const B := preload("res://game/domain/value.gd")\n',
        True,
    ),
    (
        "application must not reference adapters",
        "application/run.gd",
        'extends Node\nconst A := preload("res://game/adapters/save.gd")\n',
        False,
    ),
    (
        "presentation may reference application",
        "presentation/hud.gd",
        'extends Control\nconst A := preload("res://game/application/run.gd")\n',
        True,
    ),
    (
        "adapters must not reference presentation (equal-rank peers)",
        "adapters/input.gd",
        'extends Node\nconst H := preload("res://game/presentation/hud.gd")\n',
        False,
    ),
    (
        "presentation must not reference adapters (equal-rank peers)",
        "presentation/hud.gd",
        'extends Control\nconst S := preload("res://game/adapters/save.gd")\n',
        False,
    ),
    (
        "bootstrap may wire anything",
        "bootstrap/main.gd",
        'extends Node\nconst H := preload("res://game/presentation/hud.gd")\n'
        'const S := preload("res://game/simulation/motor.gd")\n',
        True,
    ),
    (
        "bare resource reference is caught",
        "simulation/motor.gd",
        'extends Node\nvar path := "res://game/presentation/scenes/hud.tscn"\n',
        False,
    ),
    (
        "scene ext_resource is caught",
        "simulation/world.tscn",
        '[gd_scene format=3]\n\n'
        '[ext_resource type="Script" path="res://game/presentation/hud.gd" id="1"]\n',
        False,
    ),
    (
        "comment mentioning an outward layer is not a dependency",
        "domain/value.gd",
        "extends RefCounted\n"
        "## Consumed by res://game/presentation/hud.gd, which must not be imported here.\n"
        "# see res://game/simulation/motor.gd\n",
        True,
    ),
    (
        "extends a class_name from an outward layer is caught",
        "simulation/motor.gd",
        "extends HudBase\n",
        False,
    ),
    (
        "same-layer reference is fine",
        "simulation/motor.gd",
        'extends Node\nconst W := preload("res://game/simulation/web.gd")\n',
        True,
    ),
]

#: Declared in presentation so the `extends HudBase` fixture has something to
#: resolve against.
_FIXTURE_SUPPORT = {
    "presentation/hud_base.gd": "class_name HudBase\nextends Control\n",
}


def run_self_test() -> int:
    import shutil
    import tempfile

    failures: list[str] = []
    passed = 0

    for name, rel_path, body, should_pass in _FIXTURES:
        tmp = Path(tempfile.mkdtemp(prefix="spider-swing-arch-"))
        try:
            game = tmp / "game"
            for support_path, support_body in _FIXTURE_SUPPORT.items():
                target = game / support_path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(support_body, encoding="utf-8")
            target = game / rel_path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(body, encoding="utf-8")

            violations = check_tree(game)
            actually_passed = not violations
            if actually_passed == should_pass:
                passed += 1
                print(f"  ok   {name}")
            else:
                expectation = "no violation" if should_pass else "a violation"
                got = (
                    "none"
                    if actually_passed
                    else "; ".join(v.render(tmp) for v in violations)
                )
                failures.append(f"{name}: expected {expectation}, got {got}")
                print(f"  FAIL {name}")
        finally:
            shutil.rmtree(tmp, ignore_errors=True)

    print("")
    if failures:
        print(f"check_architecture self-test: {passed} passed, {len(failures)} FAILED")
        for failure in failures:
            print(f"  - {failure}")
        return 1
    print(f"check_architecture self-test: all {passed} fixture(s) passed")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Enforce Spider Swing's inward architectural dependency direction."
    )
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="run the checker's own fixtures instead of scanning the repository",
    )
    parser.add_argument(
        "--game-root",
        type=Path,
        default=GAME_ROOT,
        help="directory holding the layer folders (default: <repo>/game)",
    )
    args = parser.parse_args(argv)

    if args.self_test:
        return run_self_test()

    if not args.game_root.is_dir():
        print(f"check_architecture: no game/ directory at {args.game_root}", file=sys.stderr)
        return 1

    violations = check_tree(args.game_root)
    if not violations:
        layers = ", ".join(
            name
            for name in LAYER_RANKS
            if (args.game_root / name).is_dir()
        )
        print(f"check_architecture: OK -- inward dependencies hold ({layers})")
        return 0

    print(
        f"check_architecture: {len(violations)} outward dependency violation(s)",
        file=sys.stderr,
    )
    for violation in violations:
        print(f"  {violation.render(REPO_ROOT)}", file=sys.stderr)
    print(
        "\nFix: move the shared contract inward (usually into game/domain/), or "
        "invert the dependency with an event the inner layer emits. The layer "
        "order is documented in docs/technical/adr/0002-simulation-and-event-"
        "boundaries.md.",
        file=sys.stderr,
    )
    return 1


if __name__ == "__main__":
    raise SystemExit(main())

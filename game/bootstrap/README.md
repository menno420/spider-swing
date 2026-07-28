# `game/bootstrap/` — the composition root

**Rank 4. May wire anything.**

The single place allowed to know about every layer, because its whole job is
assembling the graph.

## Current contents

| File | Purpose |
| --- | --- |
| `main.tscn` | The main scene, set as `application/run/main_scene`. |
| `main.gd` | Boots the tree, mounts the Swing Laboratory placeholder, and exits cleanly under the headless smoke test. |

## The smoke-test contract

`main.gd` detects smoke-test mode when the headless display driver is active (CI)
or `--smoke-test` is passed as a user argument. In that mode it prints a boot
report — engine version, main scene, physics tick rate, display server — and quits
with 0 on success or 1 if the placeholder failed to mount.

CI depends on this contract, and `tools/verify.py` runs it as the boot smoke test.
**Phase 0 should keep it working unchanged** while replacing what gets mounted: the
report and the exit codes are what makes "the project boots" a checkable claim
rather than an assertion.

## Rules

Being allowed to reference every layer is not licence to hold logic. Wiring only —
no gameplay, no physics, no persistence decisions. If something here starts making
decisions, it belongs in `application/`.

See ADR 0002.

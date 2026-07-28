# ADR 0001 — Engine, language, and runtime configuration

> **Status:** `binding`
>
> Decided 2026-07-28, founding bootstrap session. Supersedes nothing.
> Answers GDD § 25 decisions 1 and 2.

## Context

The GDD (§ 25) requires an engine/language decision and a physics-units/fixed-timestep
decision *before* feature implementation, chosen on 2D physics workflow, Android
and iOS export, testing, profiling, store SDK needs, and AI maintainability.

Spider Swing is an Android-first 2D physics game whose product *is* the swing
feel. The owner does not code; autonomous agents implement and maintain the
repository. That makes two properties dominate the choice:

1. **Deterministic, inspectable 2D physics at a fixed timestep.** The GDD's
   swing contract (§ 6.3) requires that a taut web remove only the rope-extending
   velocity component and that repeated attach/release cannot inject unbounded
   energy. That is only testable if the simulation advances at a fixed rate
   independent of render rate.
2. **Text-native, diff-reviewable project files.** Agents implement and review
   through PRs. An engine whose scenes are opaque binaries makes review
   impossible and merge conflicts unresolvable.

## Decision

**Godot 4.7.1 Standard, GDScript, Compatibility renderer.**

| Choice | Value | Rationale |
| --- | --- | --- |
| Engine | Godot 4.7.1 Standard (no .NET) | Current stable maintenance release. Standard build has no .NET/Mono dependency to install or ship. |
| Language | GDScript only | First-class in-engine tooling, no build step, no IL/AOT concerns for Android, and the smallest toolchain surface for agents to maintain. C# is explicitly out: it would add a .NET SDK, an export-template variant, and AOT trimming questions for zero gameplay benefit here. |
| Renderer | Compatibility (`gl_compatibility`) | Widest Android GLES3 device baseline and the cheapest path for 2D silhouettes. The GDD's art direction (§ 17.1) is high-contrast 2D — it needs no Forward+ feature. |
| Orientation | Landscape (`SCREEN_LANDSCAPE`) | Locked GDD rule (§ 4.1): horizontal view provides the reaction distance a speed-based endless game requires. |
| Reference viewport | 1280×720, `canvas_items` stretch, `expand` aspect | Keeps the reference height authoritative while letting wider phone aspect ratios reveal *more horizontal world* rather than letterboxing. Directly serves the § 4.1 reaction-distance requirement. |
| Fixed simulation rate | 60 Hz (`physics_ticks_per_second=60`) | The GDD requires consistent behaviour at 30/60/90/120 Hz rendering (§ 21) with a fixed timestep independent of render rate. |
| Max catch-up steps | 4 (`max_physics_steps_per_frame=4`) | Bounds the resume spike. The GDD forbids advancing the simulation from a large unbounded resume delta (§ 21); this is the engine-level enforcement. |
| Physics interpolation | On | Decouples rendered smoothness from the 60 Hz tick so a 120 Hz device looks smooth without changing simulation truth. |
| World scale | 1 world unit = 1 pixel at the 1280×720 reference; default gravity 980 px/s² | Godot 2D's native convention. Distance in metres (the GDD's primary score, § 12.1) is a *presentation* conversion applied at the score boundary, not a change of physics units. |

### Version pinning

`.godot-version` holds `4.7.1` and is the single source of truth. `tools/verify.py`
refuses to run when the located binary disagrees, and refuses a Mono build
outright. CI installs the same version. Moving the engine means changing
`.godot-version`, this ADR, and the CI pin in one PR.

## Consequences

- No C#, no .NET SDK, no Mono export templates anywhere in the toolchain.
- Every project file that encodes a locked decision above is asserted by
  `tests/test_runner.gd`, so an accidental editor rewrite that drops the tick
  rate or the renderer fails CI instead of silently changing feel.
- iOS (a later GDD platform) is unaffected by this choice: the Compatibility
  renderer and GDScript both export to iOS. Adding it needs a signing identity
  and a macOS runner, not an engine change — see ADR 0003.
- Godot's own editor may rewrite `project.godot` when opened. That is expected;
  the asserted contracts turn any lossy rewrite into a red gate.

## Alternatives considered

- **Godot 4.7.1 with C#** — rejected: adds the .NET SDK and export-template
  variants to every CI job and every agent's mental model, for no gameplay gain
  in a GDScript-sized codebase.
- **Unity** — rejected: binary scenes/prefabs defeat PR review and produce
  unresolvable merge conflicts, which is disqualifying for an agent-maintained
  repository.
- **Forward+ / Mobile renderer** — rejected: narrows the Android device floor
  and buys 3D-oriented features this 2D game does not use.
- **Custom engine or a web stack** — rejected: no 2D physics workflow,
  profiling, or store export story worth the cost.

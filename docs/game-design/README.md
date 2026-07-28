# Game design

> **Status:** `reference`
>
> Index for the product and gameplay source of truth. This index is maintained;
> the document it points at is **frozen**.

## The GDD

**[`Spider-Swing-GDD-v2.0.md`](Spider-Swing-GDD-v2.0.md)** — Spider Swing Game
Design Document v2.0, authored by the owner.

| | |
| --- | --- |
| Status in its own words | Greenfield pre-production specification |
| SHA-256 | `a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53` |
| Vendored | 2026-07-28, founding bootstrap session |
| Modified since | **No.** Byte-exact as supplied. |

### It is vendored byte-exact, on purpose

This file is the owner's authored document, checksum-pinned. It was **not**
rewritten, summarized, reformatted, or reinterpreted when the repository was
bootstrapped, and it must not be edited incidentally. Verify it at any time:

```bash
sha256sum docs/game-design/Spider-Swing-GDD-v2.0.md
# a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53
```

Because it is frozen, it carries the author's own `**Status:**` line rather than a
Substrate badge token. That is expected: a vendored product document is not one of
this repository's living ledgers, and adding a badge to it would break the checksum
above. This index carries the badge on its behalf.

**Changing the GDD is a product decision, not an implementation detail.** A genuine
design change means a new version of this document from the owner, with a new
checksum recorded here — not an in-place edit.

## How to read it

Its own § 1 sets the rules. Three kinds of value appear throughout:

- **Locked rule** — do not change during implementation without updating the
  document.
- **Tunable value** — expose through data/configuration so it can change without
  rewriting gameplay code.
- **Deferred feature** — preserve an extension point, but do not implement it before
  its stated phase.

And one constraint that binds every agent working here:

> The core physics prototype must be approved before progression, monetization,
> missions, multiple spiders, or large content sets are built. A coding agent must
> not silently decide an unresolved product rule.

## Sections worth knowing by number

| § | Covers |
| --- | --- |
| 4 | Screen, camera, world model, readability contract |
| 5 | Controls — the locked default scheme and release policy |
| 6 | Web and swing physics, including the § 6.6 tunable-parameter list |
| 8 | Movement states and the fixed per-tick resolution order |
| 9 | Obstacles and fair generation — chunk metadata and fairness rules |
| 13 | Death, collision priority, restart |
| 19 | Technical architecture, system boundaries, deterministic event flow |
| 20 | Save and economy integrity |
| 22 | Testing and observability — the automated-check target list |
| 23 | Delivery plan and per-phase quality gates |
| 25 | Decisions required before scaffolding — answered by the ADRs |

## Related

- [`../technical/adr/0001-engine-and-runtime.md`](../technical/adr/0001-engine-and-runtime.md) — answers GDD § 25 decisions 1 and 2.
- [`../technical/adr/0002-simulation-and-event-boundaries.md`](../technical/adr/0002-simulation-and-event-boundaries.md) — implements GDD § 19 and § 8.
- [`../technical/adr/0003-android-build-strategy.md`](../technical/adr/0003-android-build-strategy.md) — answers GDD § 25 decision 3; defers § 25 decision 7.
- [`../product/name-status.md`](../product/name-status.md) — tracks the codename warning at the head of the GDD.

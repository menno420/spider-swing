# Name status — "Spider Swing" is a codename

> **Status:** `owner-guidance`
>
> Tracks GDD § 25 decision 7 (release name and brand identity) and the codename
> warning at the head of `docs/game-design/Spider-Swing-GDD-v2.0.md`.

## Current status: internal codename only

**"Spider Swing" is an internal codename. It is not approved for release
branding.** It appears in this repository's name, the Godot project name, and the
development package identifier purely so that development has something stable to
refer to.

The GDD states this directly in its own header:

> "Spider Swing" is a codename, not an approved release name. Existing games
> already use the name and similar spider-swinging concepts. Complete a naming and
> store-conflict review before public branding.

## What remains future product work

None of the following has been done, and none of it can be done by an agent —
each needs the owner, and several cost money or are irreversible:

| Item | Status | Why it is owner work |
| --- | --- | --- |
| Public release name | **Not chosen** | A product and brand decision. |
| Google Play store-conflict review | **Not done** | Requires searching the live store and judging confusability. |
| Apple App Store conflict review | **Not done** | Same, for the later iOS platform. |
| Trademark search and clearance | **Not done** | May need legal advice; jurisdiction-dependent. |
| Domain availability and registration | **Not done** | Costs money; registration is a commitment. |
| Social handle availability | **Not done** | First-come-first-served across platforms. |
| Production package identifier | **Not chosen** | Irreversible once published — see ADR 0003. |
| Visual identity / logo | **Not started** | Must avoid Spider-Man and superhero-property similarity (GDD § 17.1). |
| Store listing copy and screenshots | **Not started** | Depends on the final name and art. |

## Constraints the eventual name must satisfy

Carried from the GDD so the review has criteria rather than taste alone:

- **No superhero association.** The GDD requires avoiding visual and naming
  similarity to Spider-Man or other superhero properties (§ 17.1). The visual
  identity must read as an actual or stylized spider in a miniature world, not a
  city-swinging human hero.
- **Distinguishable from existing swing games.** The broad "swing, avoid obstacles,
  catch flies" premise already exists in small web and mobile games (§ 2.5). The
  name should not collide with them.
- **Store-searchable.** A name that returns established competitors on the first
  page of store search is a discovery problem regardless of legal clearance.

## What this means for the repository right now

- The repository name `spider-swing`, the Godot `config/name` ("Spider Swing"),
  and the package identifier `com.menno420.spiderswing.dev` are all **development
  identifiers** and are all expected to change.
- The `.dev` suffix on the package identifier is deliberate: it leaves the
  production identifier unclaimed. `tests/test_runner.gd` asserts the exact
  development value, so a production identifier cannot slip in without a failing
  check and a deliberate decision.
- Renaming later is a contained change (project name, package identifier, README,
  store assets) as long as no production build has shipped. **It stops being
  contained the moment a package identifier is published** — which is why ADR 0003
  keeps publishing behind an explicit owner step.

## Owner action

Tracked as an owner action in the founding session card. Nothing in Phase 0, 1, or
2 is blocked by it; the naming review must complete **before public branding or any
store submission**, not before implementation.

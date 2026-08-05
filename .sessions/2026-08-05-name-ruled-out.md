# Rule out "Swingy Spider" before anything ships under it

> **Status:** `complete`

## Goal

The working release name was carried into the privacy policy and the store
listing copy as though it were settled. It is taken, by two games in this
game's own genre. Remove it from every artefact that could reach a store, record
the evidence, and leave the replacement decision open — the owner is holding it.

## Scope guard

This PR may change product and legal documentation only. It does not change
simulation, input, gameplay, export presets, workflows, contracts, or the
application identifier.

## Previous-session review

**previous-session review:** PR #163 landed the closed-test kit with "Swingy
Spider" written into `docs/legal/privacy-policy.md` and
`docs/product/play-store-listing.md`, carrying `OQ-SWINGY-NAME`'s caveat that
the name was unconfirmed. The owner then asked for an actual availability check.
The name did not survive it.

## Shipped

- `docs/product/name-status.md` — "Swingy Spider" recorded as **ruled out** with
  fetched evidence; "Slingy Spider" rejected on SLINKY confusability and wrong
  mechanic; the whole `[swing|sling]+spider` construction rejected as
  structurally undiscoverable.
- `docs/legal/privacy-policy.md` — the name replaced with an explicit
  `[GAME NAME — NOT YET CHOSEN]` placeholder and a warning banner, so the draft
  cannot be published under a taken name by accident.
- `docs/product/play-store-listing.md` — app-name section rewritten around the
  evidence, the candidate table, and the "candidates are not clearances" caveat.
- Owner-supplied titling methodology recorded, along with the owner-only
  clearance steps it implies (USPTO TESS / EUIPO Class 009 + 041, common-law
  audit, WHOIS rather than a registrar search bar, handle reservation, blind
  scoring).

## Verification

- `python3 tools/verify.py --require-godot` → **exit 0**, 256/256 contracts.
  Documentation-only change; the run proves the tree is undisturbed.
- `python3 bootstrap.py check --strict` → **exit 0**, run **post-commit**.
- **Conflicts verified by fetching, not by search summary.**
  `goodwingames.itch.io/swingy-spider` returned **HTTP 200** with the title
  "Swingy Spider by Garrett Goodwin". A competing research pass asserted the URL
  `garrettgoodwin.itch.io/swingy-spider`, which returns **404** — right
  developer, invented handle. The fact was real; the citation was not.
- Candidate availability is **web-search only** and explicitly labelled as not
  cleared, since store search under the owner's account and a trademark check
  are owner-only.

**Honest nulls:** no trademark search was run — that needs USPTO/EUIPO and is
owner work. Domain and social-handle availability unchecked; the methodology
warns registrar search bars front-run queries, so WHOIS is the required route
and was not used here. The replacement name is undecided by owner choice.

## 💡 Session idea

**"Unconfirmed" and "wrong" had been sitting in the same slot.** The name was
carried in a repo doc with a caveat attached, and a caveat reads as a to-do
right up until someone runs the check — at which point it turns out to have been
load-bearing all along. Two products already use this exact name in this exact
genre, and one of them is *"eat flies and avoid enemy bugs"*.

The deeper finding is the one that outlives the name. Availability was the wrong
test. `[swing|sling] + spider` is not merely crowded — it is **mistrained**:
*Spider Swing*, *Spider Swinger* and their neighbours have taught store search
that the phrase means urban superhero brawler. A quiet physics game entering
that space loses to algorithmic mismatch even where the exact string is free. So
the fix was never to find a free variant of the same shape; every name of that
shape fails the GDD's own store-searchable requirement structurally.

- **📊 Model:** opus-5 · high · research

# Rule out "Swingy Spider" before anything ships under it

> **Status:** `in-progress`

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

[[fill: shipped]]

## Verification

[[fill: verification]]

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

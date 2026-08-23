# Google Play Store asset package

> **Status:** `owner-review`
>
> Prepared 2026-08-23. Nothing in this directory has been uploaded to Google
> Play. The files under `final/` have the exact upload dimensions; the owner
> still decides whether they represent the game well enough to publish.

## Ready-to-review files

| File | Purpose | Measured requirement |
|---|---|---|
| `final/app-icon-512.png` | Play Store app icon | 512x512 RGBA PNG, at most 1024 KB |
| `final/feature-graphic-1024x500.png` | Play Store feature graphic | 1024x500 RGB PNG, no alpha |
| `final/phone-screenshots/*.png` | Phone listing screenshots | three 1920x1080 landscape RGB PNGs |

Run the deterministic preparation step after replacing a master or capture:

```powershell
C:\tools\godot\godot.exe --headless --path . --script tools/prepare_play_store_assets.gd
```

`assets/source/.gdignore` keeps this entire package out of the Android export.

## Provenance

The screenshots are genuine pixels rendered by Godot 4.7.1 from build
`0.45.0-run-feedback` at the game's native 1280x720 viewport. The laboratory
debug controls were disabled. The final files are only a deterministic 1.5x
Lanczos resize to 1920x1080; no UI or gameplay was invented or retouched.

- `01-home-1280x720.png`: Home and current Garden Spider.
- `02-bramble-swing-1280x720.png`: attached swing in Bramble Canopy.
- `03-spider-hub-1280x720.png`: Garden Spider selection and traits.

The small build label is present because these were captured from a local debug
run. Release builds now hide that label, so a final capture from the next signed
Play build should replace these candidates before production. They are already
truthful and suitable for evaluating the closed-test listing.

The icon and feature graphic are AI-generated marketing art based on the
repository's `classic-garden-spider.png` character and the real moss/bramble
visual language. They are marketing graphics, never presented as gameplay.

### Icon prompt

> Google Play game icon for Slingy Spider. Preserve the exact Garden Spider
> identity from the existing character art: deep moss forest, pale silk,
> centered large face and upper body, orange markings, reflective eyes, safe
> margins, no text, no pre-rounded corners, no extra spider, no superhero or UI.

### Feature graphic prompt

> 1024x500 Google Play feature graphic. One Garden Spider swinging on silk at
> the right third through a layered bramble forest, golden flies forming an arc,
> dark clean negative space on the left, painterly game-art finish, no text,
> logo, UI, superhero or city imagery.

## What still needs owner judgment

- Approve or replace the icon and feature graphic.
- Choose the screenshot order and decide whether to capture more moments.
- Confirm the public developer/contact identity before any Console upload.

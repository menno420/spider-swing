# `assets/runtime/`

Engine-ready assets the game loads at runtime. Exported from `assets/source/`.

Keep these small and readable at phone size (GDD § 4.3). Godot imports everything
here, so a file added by mistake costs import time on every clean build.

Current contents include optimized zone/character PNGs and the reproducibly
generated mono WAV playtest pack. Asset-specific provenance and audits live in
the nearest subdirectory README and manifest.

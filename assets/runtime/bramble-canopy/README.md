# Bramble Canopy finished art

> **Status:** `candidate-production-runtime-art`

- `bramble-backdrop-far.webp` replaces the enclosed old-growth trunks with a
  bright, high-canopy clearing and open central sightline.
- `bramble-backdrop-mid.png` adds thorned edge trunks and reaching canopy limbs
  without putting decorative shapes across the playable centre.
- `canopy-vine-rail-tile.png` is the continuous ceiling/floor surface: younger
  braided vines, large leaves, and pale readable thorns.
- `canopy-growth-socket.png` roots wall-grown hazards into that rail.
- `canopy-thorn-bramble.png` visualizes floor, broad, and compact suspended
  canopy hazards.
- `canopy-seed-pod-vine.png` visualizes the region's long hanging hazards.

`SwingLabView` selects foreground art from each authoritative polygon's world
position. This lets Bramble geometry enter naturally from the right before the
player crosses 5000 m and leaves Ancient Forest art behind on the left. The
distant backdrop crossfades for 2.2 seconds at the region boundary; Reduced
Motion makes that replacement immediate. Manual DEBUG environment looks remain
visual-only alternatives and do not receive distance-owned finished art.

Every sprite is presentation-owned. Course polygons remain the complete
collision authority, missing assets fall back to geometry, and exact outlines
remain available only through DEBUG. The art never adds a thorn, pod, vine,
opening, pickup, or target surface to simulation.

Source specifications, processing, and hashes live in
`assets/source/bramble-canopy/README.md`.

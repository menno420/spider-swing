# Character runtime art

`classic-garden-spider.png` is the finished candidate sprite for the Classic
Garden Spider. `anchorite-burrowing-spider.png` is the finished Anchorite
candidate: a broad, low, tarantula-like burrowing spider with a compact eye
cluster, heavy chelicerae, thick legs, and an earthy charcoal/bronze palette.
The two assets keep the same right-facing 384×181 source contract so
presentation can apply one rotation and action-pose path.

Each sprite rotates with presentation velocity and scales around its profile's
authoritative collision radius. Both are imported with mipmaps because the
384-pixel sources are normally drawn at roughly one quarter of that size.
Presentation interpolates fixed-step positions and applies only restrained
action-state pose scaling; DEBUG still shows the exact collision circle. Skitter,
Ballooner, and Springtail retain their distinct procedural silhouettes until they
receive equally deliberate art.

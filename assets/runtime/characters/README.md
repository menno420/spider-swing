# Character runtime art

`classic-garden-spider.png` is the finished candidate sprite for the Classic
Garden Spider. It replaces only the Classic profile's code-drawn body; other
spider profiles retain their distinct procedural silhouettes until they receive
equally deliberate art.

The sprite rotates with presentation velocity and scales around the authoritative
collision radius. It is imported with mipmaps because the 384-pixel source is
normally drawn at roughly one quarter of that size. Presentation interpolates
fixed-step positions and applies only restrained action-state pose scaling;
DEBUG still shows the exact collision circle.

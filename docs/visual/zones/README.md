# Zone structure and alpha QA

> **Status:** `candidate-evidence`

These captures are reproducible review evidence for the endless-course zones.
`tools/export_zone_geometry.gd` exports the actual seeded `CourseStream`
polygons at tick 137; `tools/zone_art_audit.py` combines those polygons with the
runtime foreground art, writes the full-colour world captures, reduces the same
structure to pure black, and shrinks it to 25%.

Run:

```bash
godot --headless --path . --script res://tools/export_zone_geometry.gd -- \
  --out=/tmp/spider-zone-geometry.json
python3 tools/zone_art_audit.py \
  --geometry /tmp/spider-zone-geometry.json \
  --output-dir docs/visual/zones \
  --report docs/visual/zones/zone-art-audit.json
```

## Output dimensions and purpose

| Output | Dimensions | Why |
| --- | ---: | --- |
| Each `screenshots/*-screenshot.png` | 1280×720 | Exact landscape reference viewport; shows runtime art plus authoritative geometry without HUD noise. |
| Each `*-silhouette-25.png` | 320×180 | Pure-black 25% sort test required for structural identity. |
| `zone-screenshot-contact-sheet.png` | 1040×1304 | Two-column review sheet using 480×270 reductions while retaining colour and structure. |
| `zone-silhouette-contact-sheet-25.png` | 688×896 | Two-column labeled sheet containing every 320×180 silhouette at its audited size. |

The silhouettes deliberately exclude the flat sky/background colour: reducing
an opaque framebuffer would produce eight solid black rectangles. They include
foreground backdrop alpha, boundaries, safe surfaces, harmless phase markers,
and active hazards from the same captured tick.

## Result

The highest pair overlap is 0.518, between the two pre-existing forest zones.
Every owned zone remains below 0.488 against every other zone. Per-zone nearest
confusion, every asset's exact source/runtime dimensions and rationale, its
**ANCHORABLE**/**NOT** state, hashes, and source/runtime/25% fringe counts are
recorded in `assets/source/zone-art/README.md` and `zone-art-audit.json`.

These files demonstrate separable structure; they do not replace the required
small-screen Android readability and success-sentence playtests.

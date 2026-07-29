extends RefCounted
class_name EnvironmentThemeCatalog
## Presentation-owned visual themes for one authoritative course silhouette.
##
## A theme may change texture, palette, background, and edge treatment. It may
## never change simulation geometry, targeting, collision, or lethality.

const GRAYBOX := &"graybox"
const ANCIENT_FOREST := &"ancient_forest"
const MOSSY_RAVINE := &"mossy_ravine"
const OVERGROWN_GREENHOUSE := &"overgrown_greenhouse"
const RECLAIMED_ATTIC := &"reclaimed_attic"
const DEFAULT_INDEX := 1

const THEMES := [
	{
		"id": GRAYBOX,
		"label": "GRAYBOX",
		"description": "Exact collision silhouette in flat colors.",
		"texture_path": "",
		"background": Color("102531"),
		"background_deep": Color("08141d"),
		"far": Color(0.13, 0.34, 0.32, 0.55),
		"near": Color(0.08, 0.28, 0.25, 0.90),
		"material_tint": Color(0.20, 0.16, 0.09, 0.96),
		"obstacle_tint": Color("632e34"),
		"safe_edge": Color("73e0a4"),
		"lethal_edge": Color("ffd166"),
		"accent": Color("4de8ee"),
	},
	{
		"id": ANCIENT_FOREST,
		"label": "ANCIENT FOREST",
		"description": "Finished branches, roots, thorns, and forest life.",
		"texture_path":
			"res://assets/runtime/environment-themes/ancient-forest.webp",
		"background": Color("14251d"),
		"background_deep": Color("08130f"),
		"far": Color(0.17, 0.34, 0.20, 0.58),
		"near": Color(0.08, 0.23, 0.13, 0.94),
		"material_tint": Color(0.82, 0.78, 0.67, 1.0),
		"obstacle_tint": Color(0.70, 0.58, 0.44, 1.0),
		"safe_edge": Color("8ccf7a"),
		"lethal_edge": Color("efb45f"),
		"accent": Color("9fd37f"),
	},
	{
		"id": MOSSY_RAVINE,
		"label": "MOSSY RAVINE",
		"description": "Wet slate, lichen, and mineral glints.",
		"texture_path":
			"res://assets/runtime/environment-themes/mossy-ravine.webp",
		"background": Color("10252a"),
		"background_deep": Color("071217"),
		"far": Color(0.12, 0.29, 0.32, 0.62),
		"near": Color(0.06, 0.20, 0.24, 0.96),
		"material_tint": Color(0.78, 0.88, 0.92, 1.0),
		"obstacle_tint": Color(0.62, 0.76, 0.80, 1.0),
		"safe_edge": Color("72d6b5"),
		"lethal_edge": Color("f1c36f"),
		"accent": Color("73d8d6"),
	},
	{
		"id": OVERGROWN_GREENHOUSE,
		"label": "GREENHOUSE",
		"description": "Aged brick, stone, vines, and verdigris.",
		"texture_path":
			"res://assets/runtime/environment-themes/overgrown-greenhouse.webp",
		"background": Color("253326"),
		"background_deep": Color("111b15"),
		"far": Color(0.30, 0.42, 0.29, 0.52),
		"near": Color(0.17, 0.30, 0.20, 0.92),
		"material_tint": Color(0.88, 0.82, 0.68, 1.0),
		"obstacle_tint": Color(0.82, 0.68, 0.54, 1.0),
		"safe_edge": Color("86cf8f"),
		"lethal_edge": Color("f2c46f"),
		"accent": Color("7cc6ad"),
	},
	{
		"id": RECLAIMED_ATTIC,
		"label": "RECLAIMED ATTIC",
		"description": "Timber, ironwork, dust, and new growth.",
		"texture_path":
			"res://assets/runtime/environment-themes/reclaimed-attic.webp",
		"background": Color("241c1a"),
		"background_deep": Color("100c0c"),
		"far": Color(0.35, 0.25, 0.21, 0.56),
		"near": Color(0.20, 0.13, 0.12, 0.94),
		"material_tint": Color(0.84, 0.76, 0.66, 1.0),
		"obstacle_tint": Color(0.72, 0.60, 0.50, 1.0),
		"safe_edge": Color("84c4a2"),
		"lethal_edge": Color("e9ad5d"),
		"accent": Color("c38f52"),
	},
]


static func count() -> int:
	return THEMES.size()


static func default_index() -> int:
	return DEFAULT_INDEX


static func theme(index: int) -> Dictionary:
	return THEMES[clampi(index, 0, THEMES.size() - 1)].duplicate(true)


static func index_for(theme_id: StringName) -> int:
	for index in range(THEMES.size()):
		if StringName(THEMES[index]["id"]) == theme_id:
			return index
	return 0


static func texture_paths() -> PackedStringArray:
	var paths := PackedStringArray()
	for definition: Dictionary in THEMES:
		var path := str(definition["texture_path"])
		if not path.is_empty():
			paths.append(path)
	return paths

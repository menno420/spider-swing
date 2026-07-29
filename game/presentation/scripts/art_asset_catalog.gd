extends RefCounted
class_name ArtAssetCatalog
## Presentation-owned runtime art paths.
##
## These assets present authoritative simulation silhouettes. Finished obstacle
## art is drawn on transparent alpha without the prototype geometry fill behind
## it. The assets still do not own collision geometry, pickup radius, spider
## radius, or obstacle classification.

const FOREST_BRANCH := &"forest_branch"
const FOREST_BRAMBLE := &"forest_bramble"
const FOREST_HANGING_VINE := &"forest_hanging_vine"
const FOREST_ROOT_GATE := &"forest_root_gate"
const CLASSIC_SPIDER := &"classic_spider"
const GOLDEN_FLY := &"golden_fly"

const ASSETS := {
	FOREST_BRANCH:
		"res://assets/runtime/forest-biome/ancient-branch-ceiling.png",
	FOREST_BRAMBLE:
		"res://assets/runtime/forest-biome/thorn-bramble.png",
	FOREST_HANGING_VINE:
		"res://assets/runtime/forest-biome/hanging-thorn-vine.png",
	FOREST_ROOT_GATE:
		"res://assets/runtime/forest-biome/split-thorn-root-gate.png",
	CLASSIC_SPIDER:
		"res://assets/runtime/characters/classic-garden-spider.png",
	GOLDEN_FLY:
		"res://assets/runtime/collectibles/golden-forest-fly.png",
}


static func texture_path(asset_id: StringName) -> String:
	return str(ASSETS.get(asset_id, ""))


static func texture_paths() -> PackedStringArray:
	var paths := PackedStringArray()
	for asset_id: StringName in ASSETS:
		paths.append(str(ASSETS[asset_id]))
	return paths

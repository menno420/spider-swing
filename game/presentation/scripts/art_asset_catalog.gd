extends RefCounted
class_name ArtAssetCatalog
## Presentation-owned runtime art paths.
##
## These assets present authoritative simulation silhouettes. Finished obstacle
## art is drawn on transparent alpha without the prototype geometry fill behind
## it. The assets still do not own collision geometry, pickup radius, spider
## radius, or obstacle classification.

const FOREST_RAIL_TILE := &"forest_rail_tile"
const FOREST_GROWTH_SOCKET := &"forest_growth_socket"
const FOREST_BRAMBLE := &"forest_bramble"
const FOREST_HANGING_VINE := &"forest_hanging_vine"
const FOREST_ROOT_STUMP := &"forest_root_stump"
const FOREST_BACKDROP_FAR := &"forest_backdrop_far"
const FOREST_BACKDROP_MID := &"forest_backdrop_mid"
const FOREST_BACKDROP_NEAR := &"forest_backdrop_near"
const CLASSIC_SPIDER := &"classic_spider"
const SKITTER_SPIDER := &"skitter_spider"
const ANCHORITE_SPIDER := &"anchorite_spider"
const BALLOONER_SPIDER := &"ballooner_spider"
# Asset key and filename keep the "springtail" spelling: the manifest binds
# filename to SHA256, and no player sees either. The profile is Buckler.
const BUCKLER_SPIDER := &"springtail_spider"
const GOLDEN_FLY := &"golden_fly"

const ASSETS := {
	FOREST_RAIL_TILE:
		"res://assets/runtime/forest-biome/ancient-branch-rail-tile.png",
	FOREST_GROWTH_SOCKET:
		"res://assets/runtime/forest-biome/mossy-growth-socket.png",
	FOREST_BRAMBLE:
		"res://assets/runtime/forest-biome/thorn-bramble.png",
	FOREST_HANGING_VINE:
		"res://assets/runtime/forest-biome/hanging-thorn-vine.png",
	FOREST_ROOT_STUMP:
		"res://assets/runtime/forest-biome/fallen-root-stump.png",
	FOREST_BACKDROP_FAR:
		"res://assets/runtime/forest-biome/forest-backdrop-far.webp",
	FOREST_BACKDROP_MID:
		"res://assets/runtime/forest-biome/forest-backdrop-mid.png",
	FOREST_BACKDROP_NEAR:
		"res://assets/runtime/forest-biome/forest-backdrop-near.png",
	CLASSIC_SPIDER:
		"res://assets/runtime/characters/classic-garden-spider.png",
	SKITTER_SPIDER:
		"res://assets/runtime/characters/skitter-magnolia-jumper.png",
	ANCHORITE_SPIDER:
		"res://assets/runtime/characters/anchorite-burrowing-spider.png",
	BALLOONER_SPIDER:
		"res://assets/runtime/characters/ballooner-spider.png",
	BUCKLER_SPIDER:
		"res://assets/runtime/characters/springtail-trapdoor-spider.png",
	GOLDEN_FLY:
		"res://assets/runtime/collectibles/golden-forest-fly.png",
}

const SPIDER_ASSET_IDS := {
	SpiderCatalog.CLASSIC: CLASSIC_SPIDER,
	SpiderCatalog.SKITTER: SKITTER_SPIDER,
	SpiderCatalog.ANCHORITE: ANCHORITE_SPIDER,
	SpiderCatalog.BALLOONER: BALLOONER_SPIDER,
	SpiderCatalog.BUCKLER: BUCKLER_SPIDER,
}


static func texture_path(asset_id: StringName) -> String:
	return str(ASSETS.get(asset_id, ""))


static func spider_asset_id(profile_id: StringName) -> StringName:
	return StringName(SPIDER_ASSET_IDS.get(profile_id, &""))


static func spider_style_tint(style: StringName) -> Color:
	match style:
		PlayerProgress.STYLE_AMBER:
			return Color(1.0, 0.90, 0.72, 1.0)
		PlayerProgress.STYLE_COMET:
			return Color(0.73, 0.88, 1.0, 1.0)
	return Color.WHITE


static func texture_paths() -> PackedStringArray:
	var paths := PackedStringArray()
	for asset_id: StringName in ASSETS:
		paths.append(str(ASSETS[asset_id]))
	return paths

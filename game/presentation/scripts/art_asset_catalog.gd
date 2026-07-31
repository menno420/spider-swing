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
const CANOPY_RAIL_TILE := &"canopy_rail_tile"
const CANOPY_GROWTH_SOCKET := &"canopy_growth_socket"
const CANOPY_BRAMBLE := &"canopy_bramble"
const CANOPY_SEED_POD := &"canopy_seed_pod"
const CANOPY_HOOK_VINE := &"canopy_hook_vine"
const CANOPY_LEAF_SHUTTER := &"canopy_leaf_shutter"
const CANOPY_BACKDROP_FAR := &"canopy_backdrop_far"
const CANOPY_BACKDROP_MID := &"canopy_backdrop_mid"
const CLASSIC_SPIDER := &"classic_spider"
const SKITTER_SPIDER := &"skitter_spider"
const ANCHORITE_SPIDER := &"anchorite_spider"
const BALLOONER_SPIDER := &"ballooner_spider"
# Asset key and filename keep the "springtail" spelling: the manifest binds
# filename to SHA256, and no player sees either. The profile is Buckler.
const BUCKLER_SPIDER := &"springtail_spider"
const GOLDEN_FLY := &"golden_fly"
const HOLLOW_BACKDROP := &"hollow_backdrop"
const HOLLOW_COCOON := &"hollow_cocoon"
const ARBORETUM_BACKDROP := &"arboretum_backdrop"
const ARBORETUM_PANE := &"arboretum_pane"
const STORM_BACKDROP := &"storm_backdrop"
const STORM_SPIRE := &"storm_spire"
const WEB_CITY_BACKDROP := &"web_city_backdrop"
const WEB_CITY_RESIDENT := &"web_city_resident"
const ASHEN_BACKDROP := &"ashen_backdrop"
const ASHEN_ROTTEN := &"ashen_rotten"
const ASHEN_SOUND := &"ashen_sound"
const MIST_BACKDROP := &"mist_backdrop"
const MIST_LIT_BEAM := &"mist_lit_beam"

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
	CANOPY_RAIL_TILE:
		"res://assets/runtime/bramble-canopy/canopy-vine-rail-tile.png",
	CANOPY_GROWTH_SOCKET:
		"res://assets/runtime/bramble-canopy/canopy-growth-socket.png",
	CANOPY_BRAMBLE:
		"res://assets/runtime/bramble-canopy/canopy-thorn-bramble.png",
	CANOPY_SEED_POD:
		"res://assets/runtime/bramble-canopy/canopy-seed-pod-vine.png",
	CANOPY_HOOK_VINE:
		"res://assets/runtime/bramble-canopy/canopy-hook-vine.png",
	CANOPY_LEAF_SHUTTER:
		"res://assets/runtime/bramble-canopy/canopy-leaf-shutter.png",
	CANOPY_BACKDROP_FAR:
		"res://assets/runtime/bramble-canopy/bramble-backdrop-far.webp",
	CANOPY_BACKDROP_MID:
		"res://assets/runtime/bramble-canopy/bramble-backdrop-mid.png",
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
	HOLLOW_BACKDROP:
		"res://assets/runtime/zone-art/silk-hollow-backdrop.png",
	HOLLOW_COCOON:
		"res://assets/runtime/zone-art/silk-hollow-cocoon-cluster.png",
	ARBORETUM_BACKDROP:
		"res://assets/runtime/zone-art/ruined-arboretum-backdrop.png",
	ARBORETUM_PANE:
		"res://assets/runtime/zone-art/ruined-arboretum-pane.png",
	STORM_BACKDROP:
		"res://assets/runtime/zone-art/storm-ridge-backdrop.png",
	STORM_SPIRE:
		"res://assets/runtime/zone-art/storm-ridge-spire.png",
	WEB_CITY_BACKDROP:
		"res://assets/runtime/zone-art/web-city-backdrop.png",
	WEB_CITY_RESIDENT:
		"res://assets/runtime/zone-art/web-city-resident.png",
	ASHEN_BACKDROP:
		"res://assets/runtime/zone-art/ashen-hollow-backdrop.png",
	ASHEN_ROTTEN:
		"res://assets/runtime/zone-art/ashen-hollow-rotten-branch.png",
	ASHEN_SOUND:
		"res://assets/runtime/zone-art/ashen-hollow-sound-branch.png",
	MIST_BACKDROP:
		"res://assets/runtime/zone-art/deep-mist-backdrop.png",
	MIST_LIT_BEAM:
		"res://assets/runtime/zone-art/deep-mist-lit-beam.png",
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

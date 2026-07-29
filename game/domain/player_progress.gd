extends RefCounted
class_name PlayerProgress
## Versioned player progression value object.

const SCHEMA_VERSION := 4
const STYLE_GARDEN := &"garden"
const STYLE_AMBER := &"amber"
const STYLE_COMET := &"comet"
const ALL_STYLES := [STYLE_GARDEN, STYLE_AMBER, STYLE_COMET]
const WEB_CLASSIC := &"classic_silk"
const WEB_DEW := &"dew_silk"
const WEB_EMBER := &"ember_silk"
const ALL_WEB_VARIANTS := [WEB_CLASSIC, WEB_DEW, WEB_EMBER]
const CREATOR_PIECES := [&"empty", &"leaf", &"pod", &"vine", &"gate"]
const DEFAULT_CREATOR_PATTERN: Array[StringName] = [
	&"leaf", &"empty", &"pod", &"vine", &"empty", &"gate",
]

var total_flies: int = 0
var spendable_flies: int = 0
var best_distance_pixels: float = 0.0
var unlocked_spider_styles: Array[StringName] = [STYLE_GARDEN]
var selected_spider_style: StringName = STYLE_GARDEN
var unlocked_spider_ids: Array[StringName] = [
	SpiderCatalog.CLASSIC,
	SpiderCatalog.SKITTER,
	SpiderCatalog.ANCHORITE,
	SpiderCatalog.BALLOONER,
	SpiderCatalog.SPRINGTAIL,
]
var selected_spider_id: StringName = SpiderCatalog.CLASSIC
var upgrade_levels: Dictionary = {}
var unlocked_web_variants: Array[StringName] = [
	WEB_CLASSIC, WEB_DEW, WEB_EMBER,
]
var selected_web_variant: StringName = WEB_CLASSIC
var creator_pattern: Array[StringName] = [
	&"leaf", &"empty", &"pod", &"vine", &"empty", &"gate",
]
var applied_settlement_ids: PackedStringArray = PackedStringArray()


static func defaults() -> PlayerProgress:
	return PlayerProgress.new()


static func from_dictionary(data: Dictionary) -> PlayerProgress:
	var progress := PlayerProgress.new()
	var source_schema := maxi(1, int(data.get("schema_version", 1)))
	progress.total_flies = maxi(0, int(data.get("total_flies", 0)))
	progress.spendable_flies = maxi(
		0,
		int(data.get("spendable_flies", progress.total_flies)),
	)
	progress.best_distance_pixels = maxf(
		0.0, float(data.get("best_distance_pixels", 0.0)))
	progress.unlocked_spider_styles.clear()
	for raw_style: Variant in data.get("unlocked_spider_styles", [STYLE_GARDEN]):
		var style := StringName(str(raw_style))
		if style in ALL_STYLES and style not in progress.unlocked_spider_styles:
			progress.unlocked_spider_styles.append(style)
	if STYLE_GARDEN not in progress.unlocked_spider_styles:
		progress.unlocked_spider_styles.push_front(STYLE_GARDEN)
	var selected := StringName(str(
		data.get("selected_spider_style", STYLE_GARDEN)))
	progress.selected_spider_style = (
		selected if selected in progress.unlocked_spider_styles else STYLE_GARDEN)
	progress.unlocked_spider_ids.clear()
	for raw_id: Variant in data.get(
		"unlocked_spider_ids",
		SpiderCatalog.ALL_IDS,
	):
		var spider_id := StringName(str(raw_id))
		if spider_id in SpiderCatalog.ALL_IDS and \
				spider_id not in progress.unlocked_spider_ids:
			progress.unlocked_spider_ids.append(spider_id)
	# Phase 0 comparison access deliberately keeps every candidate available.
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		if spider_id not in progress.unlocked_spider_ids:
			progress.unlocked_spider_ids.append(spider_id)
	var selected_spider := StringName(str(
		data.get("selected_spider_id", SpiderCatalog.CLASSIC)))
	progress.selected_spider_id = (
		selected_spider
		if selected_spider in progress.unlocked_spider_ids
		else SpiderCatalog.CLASSIC
	)
	progress.upgrade_levels.clear()
	var raw_upgrades: Variant = data.get("upgrade_levels", {})
	if raw_upgrades is Dictionary:
		for raw_key: Variant in (raw_upgrades as Dictionary):
			var upgrade_id := StringName(str(raw_key))
			if SpiderCatalog.upgrade(upgrade_id).is_empty():
				continue
			var saved_level := int((raw_upgrades as Dictionary)[raw_key])
			if source_schema < SCHEMA_VERSION:
				saved_level *= SpiderCatalog.LEGACY_LEVEL_MULTIPLIER
			progress.upgrade_levels[str(upgrade_id)] = clampi(
				saved_level,
				0,
				SpiderCatalog.MAX_UPGRADE_LEVEL,
			)
	progress.unlocked_web_variants.clear()
	for raw_variant: Variant in data.get(
		"unlocked_web_variants",
		[WEB_CLASSIC, WEB_DEW, WEB_EMBER],
	):
		var variant := StringName(str(raw_variant))
		if variant in ALL_WEB_VARIANTS and \
				variant not in progress.unlocked_web_variants:
			progress.unlocked_web_variants.append(variant)
	if WEB_CLASSIC not in progress.unlocked_web_variants:
		progress.unlocked_web_variants.push_front(WEB_CLASSIC)
	var selected_web := StringName(str(
		data.get("selected_web_variant", WEB_CLASSIC)))
	progress.selected_web_variant = (
		selected_web
		if selected_web in progress.unlocked_web_variants
		else WEB_CLASSIC
	)
	progress.creator_pattern.clear()
	for raw_piece: Variant in data.get(
		"creator_pattern",
		DEFAULT_CREATOR_PATTERN,
	):
		var piece := StringName(str(raw_piece))
		progress.creator_pattern.append(
			piece if piece in CREATOR_PIECES else &"empty")
	while progress.creator_pattern.size() < DEFAULT_CREATOR_PATTERN.size():
		progress.creator_pattern.append(&"empty")
	if progress.creator_pattern.size() > DEFAULT_CREATOR_PATTERN.size():
		progress.creator_pattern.resize(DEFAULT_CREATOR_PATTERN.size())
	for raw_id: Variant in data.get("applied_settlement_ids", []):
		var settlement_id := str(raw_id)
		if not settlement_id.is_empty():
			progress.applied_settlement_ids.append(settlement_id)
	return progress


func copy() -> PlayerProgress:
	return PlayerProgress.from_dictionary(to_dictionary())


func to_dictionary() -> Dictionary:
	var styles: Array[String] = []
	for style: StringName in unlocked_spider_styles:
		styles.append(str(style))
	var spider_ids: Array[String] = []
	for spider_id: StringName in unlocked_spider_ids:
		spider_ids.append(str(spider_id))
	var web_variants: Array[String] = []
	for web_variant: StringName in unlocked_web_variants:
		web_variants.append(str(web_variant))
	var pattern: Array[String] = []
	for piece: StringName in creator_pattern:
		pattern.append(str(piece))
	return {
		"schema_version": SCHEMA_VERSION,
		"total_flies": total_flies,
		"spendable_flies": spendable_flies,
		"best_distance_pixels": best_distance_pixels,
		"unlocked_spider_styles": styles,
		"selected_spider_style": str(selected_spider_style),
		"unlocked_spider_ids": spider_ids,
		"selected_spider_id": str(selected_spider_id),
		"upgrade_levels": upgrade_levels.duplicate(true),
		"unlocked_web_variants": web_variants,
		"selected_web_variant": str(selected_web_variant),
		"creator_pattern": pattern,
		"applied_settlement_ids": Array(applied_settlement_ids),
	}


func upgrade_level(upgrade_id: StringName) -> int:
	return clampi(
		int(upgrade_levels.get(str(upgrade_id), 0)),
		0,
		SpiderCatalog.MAX_UPGRADE_LEVEL,
	)

extends RefCounted
class_name PlayerProgress
## Versioned player progression value object.

const SCHEMA_VERSION := 1
const STYLE_GARDEN := &"garden"
const STYLE_AMBER := &"amber"
const STYLE_COMET := &"comet"
const ALL_STYLES := [STYLE_GARDEN, STYLE_AMBER, STYLE_COMET]

var total_flies: int = 0
var best_distance_pixels: float = 0.0
var unlocked_spider_styles: Array[StringName] = [STYLE_GARDEN]
var selected_spider_style: StringName = STYLE_GARDEN
var applied_settlement_ids: PackedStringArray = PackedStringArray()


static func defaults() -> PlayerProgress:
	return PlayerProgress.new()


static func from_dictionary(data: Dictionary) -> PlayerProgress:
	var progress := PlayerProgress.new()
	progress.total_flies = maxi(0, int(data.get("total_flies", 0)))
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
	return {
		"schema_version": SCHEMA_VERSION,
		"total_flies": total_flies,
		"best_distance_pixels": best_distance_pixels,
		"unlocked_spider_styles": styles,
		"selected_spider_style": str(selected_spider_style),
		"applied_settlement_ids": Array(applied_settlement_ids),
	}

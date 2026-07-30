extends RefCounted
class_name ProgressionService
## Applies validated settlements and cosmetic selections to player progress.

const AMBER_FLY_REQUIREMENT := 25
const COMET_DISTANCE_REQUIREMENT := 10000.0
const SETTLEMENT_HISTORY_LIMIT := 64


func apply_settlement(
	progress: PlayerProgress,
	settlement: RunSettlement,
) -> Dictionary:
	if settlement.settlement_id.is_empty() or \
			settlement.settlement_id in progress.applied_settlement_ids:
		return {"applied": false, "unlocked": PackedStringArray()}
	progress.applied_settlement_ids.append(settlement.settlement_id)
	while progress.applied_settlement_ids.size() > SETTLEMENT_HISTORY_LIMIT:
		progress.applied_settlement_ids.remove_at(0)
	var collected := (
		maxi(0, settlement.flies_collected)
		if settlement.rewards_eligible
		else 0
	)
	progress.total_flies += collected
	progress.spendable_flies += collected
	if settlement.records_eligible:
		progress.best_distance_pixels = maxf(
			progress.best_distance_pixels,
			settlement.distance_pixels,
		)
	var unlocked := PackedStringArray()
	if progress.total_flies >= AMBER_FLY_REQUIREMENT:
		_unlock(progress, PlayerProgress.STYLE_AMBER, unlocked)
	if progress.best_distance_pixels >= COMET_DISTANCE_REQUIREMENT:
		_unlock(progress, PlayerProgress.STYLE_COMET, unlocked)
	return {
		"applied": true,
		"unlocked": unlocked,
		"flies_granted": collected,
		"records_eligible": settlement.records_eligible,
	}


func unlock_region_checkpoint(
	progress: PlayerProgress,
	region_id: StringName,
	reached_distance_pixels: float,
) -> bool:
	var required := CourseRegionCatalog.checkpoint_start(region_id)
	if required <= 0.0 or reached_distance_pixels + 0.001 < required or \
			region_id in progress.unlocked_region_checkpoints:
		return false
	progress.unlocked_region_checkpoints.append(region_id)
	return true


func select_spider(progress: PlayerProgress, style: StringName) -> bool:
	return select_spider_style(progress, style)


func select_spider_style(progress: PlayerProgress, style: StringName) -> bool:
	if style not in progress.unlocked_spider_styles:
		return false
	progress.selected_spider_style = style
	return true


func select_spider_profile(
	progress: PlayerProgress,
	spider_id: StringName,
) -> bool:
	if spider_id not in progress.unlocked_spider_ids or \
			spider_id not in SpiderCatalog.ALL_IDS:
		return false
	progress.selected_spider_id = spider_id
	return true


func select_web_variant(
	progress: PlayerProgress,
	web_variant: StringName,
) -> bool:
	if web_variant not in progress.unlocked_web_variants:
		return false
	progress.selected_web_variant = web_variant
	return true


func purchase_upgrade(
	progress: PlayerProgress,
	upgrade_id: StringName,
) -> Dictionary:
	var item := SpiderCatalog.upgrade(upgrade_id)
	if item.is_empty() or StringName(item["profile"]) != \
			progress.selected_spider_id:
		return {"purchased": false, "reason": "wrong_spider"}
	var level := progress.upgrade_level(upgrade_id)
	if level >= SpiderCatalog.MAX_UPGRADE_LEVEL:
		return {"purchased": false, "reason": "maximum"}
	var cost := SpiderCatalog.cost_for_level(level)
	if progress.spendable_flies < cost:
		return {"purchased": false, "reason": "flies", "cost": cost}
	progress.spendable_flies -= cost
	var next_level := level + 1
	progress.upgrade_levels[str(upgrade_id)] = next_level
	return {
		"purchased": true,
		"level": next_level,
		"cost": cost,
		"breakthrough": SpiderCatalog.is_breakthrough_level(next_level),
	}


func cycle_creator_piece(progress: PlayerProgress, slot: int) -> bool:
	if slot < 0 or slot >= progress.creator_pattern.size():
		return false
	var current := progress.creator_pattern[slot]
	var index := PlayerProgress.CREATOR_PIECES.find(current)
	progress.creator_pattern[slot] = PlayerProgress.CREATOR_PIECES[
		posmod(index + 1, PlayerProgress.CREATOR_PIECES.size())
	]
	return true


func clear_creator_pattern(progress: PlayerProgress) -> void:
	for index in range(progress.creator_pattern.size()):
		progress.creator_pattern[index] = &"empty"


func _unlock(
	progress: PlayerProgress,
	style: StringName,
	unlocked: PackedStringArray,
) -> void:
	if style in progress.unlocked_spider_styles:
		return
	progress.unlocked_spider_styles.append(style)
	progress.selected_spider_style = style
	unlocked.append(style)

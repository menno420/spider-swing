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
	progress.total_flies += maxi(0, settlement.flies_collected)
	progress.best_distance_pixels = maxf(
		progress.best_distance_pixels,
		settlement.distance_pixels,
	)
	var unlocked := PackedStringArray()
	if progress.total_flies >= AMBER_FLY_REQUIREMENT:
		_unlock(progress, PlayerProgress.STYLE_AMBER, unlocked)
	if progress.best_distance_pixels >= COMET_DISTANCE_REQUIREMENT:
		_unlock(progress, PlayerProgress.STYLE_COMET, unlocked)
	return {"applied": true, "unlocked": unlocked}


func select_spider(progress: PlayerProgress, style: StringName) -> bool:
	if style not in progress.unlocked_spider_styles:
		return false
	progress.selected_spider_style = style
	return true


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

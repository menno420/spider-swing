extends RefCounted
class_name EconomyTests
## Contracts for the currency and reward model.
##
## The separation rule is the whole design: **flies buy power, stars buy
## appearance, and nothing buys mastery.** These hold the parts of that rule
## the code can enforce today, plus the suspension of the two measurably inert
## upgrade tracks.
##
## Written against the lesson that cost a previous slice: asserting an
## *outcome* proves nothing when several mechanisms produce it. Where a rule is
## defended in more than one place, each contract names the mechanism it is
## checking and observes that one — refusal reasons, not just balances.


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_suspended_tracks_cannot_be_bought(failures)
	passed += _test_suspension_refuses_for_the_right_reason(failures)
	passed += _test_suspended_tracks_keep_owned_levels(failures)
	passed += _test_unsuspended_tracks_still_sell(failures)
	passed += _test_campaign_never_pays_flies(failures)
	passed += _test_only_records_eligible_modes_bank_flies(failures)
	return {"passed": passed, "failures": failures}


static func _suspended_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for upgrade: Dictionary in SpiderCatalog.upgrades_for(SpiderCatalog.CLASSIC):
		if not bool(upgrade.get("purchasable", true)):
			result.append(StringName(upgrade["id"]))
	return result


static func _test_suspended_tracks_cannot_be_bought(
	failures: PackedStringArray,
) -> int:
	var suspended := _suspended_ids()
	if suspended.is_empty():
		failures.append(
			"no track is suspended — the audit found two that measure zero")
		return 0
	for upgrade_id: StringName in suspended:
		var progress := PlayerProgress.defaults()
		progress.selected_spider_id = SpiderCatalog.CLASSIC
		progress.spendable_flies = 9999
		var service := ProgressionService.new()
		var result := service.purchase_upgrade(progress, upgrade_id)
		if bool(result["purchased"]):
			failures.append("suspended track %s was sold" % upgrade_id)
			return 0
		if progress.upgrade_level(upgrade_id) != 0:
			failures.append("suspended track %s gained a level" % upgrade_id)
			return 0
		if progress.spendable_flies != 9999:
			failures.append("suspended track %s took flies" % upgrade_id)
			return 0
	return 1


## Observe the mechanism, not the outcome. A player with no flies is also
## refused, so "not purchased" alone would pass even if suspension did nothing.
## The refusal must name suspension, with the wallet full.
static func _test_suspension_refuses_for_the_right_reason(
	failures: PackedStringArray,
) -> int:
	var suspended := _suspended_ids()
	if suspended.is_empty():
		failures.append("no suspended track to check the refusal reason on")
		return 0
	var progress := PlayerProgress.defaults()
	progress.selected_spider_id = SpiderCatalog.CLASSIC
	progress.spendable_flies = 9999
	var service := ProgressionService.new()
	var result := service.purchase_upgrade(progress, suspended[0])
	if str(result.get("reason", "")) != "suspended":
		failures.append(
			"suspended track refused for reason '%s', not 'suspended'" %
				str(result.get("reason", "")))
		return 0
	return 1


## Suspension withdraws a track from sale; it must never confiscate levels a
## save already holds, or an update would silently take value from a player.
static func _test_suspended_tracks_keep_owned_levels(
	failures: PackedStringArray,
) -> int:
	var suspended := _suspended_ids()
	if suspended.is_empty():
		failures.append("no suspended track to check ownership on")
		return 0
	var upgrade_id := suspended[0]
	var progress := PlayerProgress.defaults()
	progress.selected_spider_id = SpiderCatalog.CLASSIC
	progress.upgrade_levels[str(upgrade_id)] = 12
	var restored := PlayerProgress.from_dictionary(progress.to_dictionary())
	if restored.upgrade_level(upgrade_id) != 12:
		failures.append(
			"a suspended track lost its owned level across a save (%d)" %
				restored.upgrade_level(upgrade_id))
		return 0
	# And it must still reach the config — suspension is about the shop, not
	# about switching the effect off under a player who already paid.
	var baseline := SpiderCatalog.resolved_config(
		SwingConfig.PRESET_BALANCED, PlayerProgress.defaults())
	var owned := SpiderCatalog.resolved_config(
		SwingConfig.PRESET_BALANCED, restored)
	if is_equal_approx(
			owned.reel_energy_capacity, baseline.reel_energy_capacity) and \
			is_equal_approx(
				owned.reel_regeneration_rate,
				baseline.reel_regeneration_rate):
		failures.append(
			"a suspended track stopped applying to a save that owns it")
		return 0
	return 1


## The suspension must be surgical. If it disabled the shop wholesale the
## contracts above would still pass.
static func _test_unsuspended_tracks_still_sell(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	progress.selected_spider_id = SpiderCatalog.CLASSIC
	progress.spendable_flies = 9999
	var service := ProgressionService.new()
	var sold := 0
	for upgrade: Dictionary in SpiderCatalog.upgrades_for(SpiderCatalog.CLASSIC):
		if not bool(upgrade.get("purchasable", true)):
			continue
		var result := service.purchase_upgrade(
			progress, StringName(upgrade["id"]))
		if bool(result["purchased"]):
			sold += 1
	if sold < 3:
		failures.append(
			"only %d unsuspended track(s) could be bought — suspension is too broad"
				% sold)
		return 0
	return 1


## Flies buy power; the campaign pays mastery. A campaign clear must never
## bank a fly, however many the run collected.
static func _test_campaign_never_pays_flies(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	var service := ProgressionService.new()
	var settlement := RunSettlement.campaign(
		CampaignCatalog.settlement_id(CampaignCatalog.TEACH_REEL),
		3000.0,
		&"campaign_complete",
		CampaignCatalog.TEACH_REEL,
		4101,
	)
	# Force a fly payload onto it: the guarantee must come from eligibility,
	# not from the campaign constructor happening to zero the field.
	settlement.flies_collected = 500
	service.apply_settlement(progress, settlement)
	if progress.total_flies != 0 or progress.spendable_flies != 0:
		failures.append(
			"a campaign clear banked %d flies" % progress.spendable_flies)
		return 0
	if progress.campaign_stars_for(CampaignCatalog.TEACH_REEL) != 1:
		failures.append("the campaign clear paid no star")
		return 0
	return 1


static func _test_only_records_eligible_modes_bank_flies(
	failures: PackedStringArray,
) -> int:
	var index := 0
	for mode_id: StringName in DifficultyCatalog.mode_ids():
		index += 1
		var progress := PlayerProgress.defaults()
		var service := ProgressionService.new()
		var eligible := DifficultyCatalog.records_eligible(mode_id)
		service.apply_settlement(progress, RunSettlement.create(
			"bank-%d" % index,
			20000.0,
			120,
			&"obstacle",
			mode_id,
			0.0,
			eligible,
			1337,
		))
		var banked := progress.spendable_flies
		if eligible and banked != 120:
			failures.append("mode %s banked %d flies, expected 120" % [
				mode_id, banked])
			return 0
		if not eligible and banked != 0:
			failures.append("mode %s banked %d flies but sets no record" % [
				mode_id, banked])
			return 0
	return 1

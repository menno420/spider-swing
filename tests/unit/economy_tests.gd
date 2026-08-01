extends RefCounted
class_name EconomyTests
## Contracts for the currency and reward model.
##
## The separation rule is the whole design: **flies buy power, stars buy
## appearance, and nothing buys mastery.** These hold the parts of that rule
## the code can enforce today.
##
## Written against the lesson that cost a previous slice: asserting an
## *outcome* proves nothing when several mechanisms produce it. The campaign
## contract below forces a fly payload onto the settlement so the guarantee has
## to come from eligibility rather than from a constructor zeroing the field.


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_campaign_never_pays_flies(failures)
	passed += _test_only_records_eligible_modes_bank_flies(failures)
	return {"passed": passed, "failures": failures}



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

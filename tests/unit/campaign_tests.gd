extends RefCounted
class_name CampaignTests
## Contracts for the campaign teaching tier.
##
## The tier exists to close one gap: the tutorial explains Reel, Burst and
## Dive and then never asks the player to perform them. So the load-bearing
## guarantee is not "the level is hard" but "the level cannot be cleared
## without its verb", and that is what these hold. The economy rules matter
## just as much — a fixed-seed repeatable level that paid flies would be the
## optimal farm, so campaign settlement must pay stars and nothing else.


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_levels_are_well_formed(failures)
	passed += _test_goal_alone_does_not_complete(failures)
	passed += _test_verb_alone_does_not_complete(failures)
	passed += _test_goal_and_verb_complete(failures)
	passed += _test_wrong_verb_does_not_complete(failures)
	passed += _test_partial_verbs_do_not_complete_a_combination(failures)
	passed += _test_tiers_cover_every_level_in_order(failures)
	passed += _test_campaign_settlement_pays_no_flies_and_no_record(failures)
	passed += _test_campaign_clear_grants_exactly_one_star(failures)
	passed += _test_repeat_clear_grants_nothing(failures)
	passed += _test_stars_survive_a_save_round_trip(failures)
	passed += _test_schema_five_save_loads_with_no_stars(failures)
	return {"passed": passed, "failures": failures}


static func _test_levels_are_well_formed(
	failures: PackedStringArray,
) -> int:
	var levels := CampaignCatalog.all_levels()
	if levels.size() < 3:
		failures.append("campaign teaching tier has fewer than three levels")
		return 0
	var seen_ids: Array[StringName] = []
	var seen_seeds: Array[int] = []
	var taught_alone: Array[StringName] = []
	var known_verbs := [
		CampaignCatalog.VERB_REEL,
		CampaignCatalog.VERB_BURST,
		CampaignCatalog.VERB_DIVE,
	]
	for level: Dictionary in levels:
		var level_id := StringName(level["id"])
		if level_id in seen_ids:
			failures.append("duplicate campaign level id %s" % level_id)
			return 0
		seen_ids.append(level_id)
		var verbs := CampaignCatalog.verbs_for_level(level_id)
		if verbs.is_empty():
			failures.append("level %s requires no verb at all" % level_id)
			return 0
		var seen_here: Array[StringName] = []
		for verb: StringName in verbs:
			if not verb in known_verbs:
				failures.append("level %s requires unknown verb %s" % [
					level_id, verb])
				return 0
			if verb in seen_here:
				failures.append("level %s lists verb %s twice" % [
					level_id, verb])
				return 0
			seen_here.append(verb)
		if verbs.size() == 1:
			taught_alone.append(verbs[0])
		var seed := int(level["course_seed"])
		if seed in seen_seeds:
			failures.append("level %s reuses course seed %d" % [level_id, seed])
			return 0
		seen_seeds.append(seed)
		if float(level["goal_distance_pixels"]) <= 0.0:
			failures.append("level %s has no goal distance" % level_id)
			return 0
		if str(level["objective"]).strip_edges().is_empty():
			failures.append("level %s states no objective" % level_id)
			return 0
	# The teaching tier's whole purpose is one level per verb, in isolation.
	# A verb that only ever appears inside a combination has never been taught.
	for verb: StringName in known_verbs:
		if not verb in taught_alone:
			failures.append("no campaign level teaches %s on its own" % verb)
			return 0
	return 1


## The teaching guarantee, stated negatively: swinging past the goal without
## ever using the verb must NOT clear the level.
static func _test_goal_alone_does_not_complete(
	failures: PackedStringArray,
) -> int:
	for level: Dictionary in CampaignCatalog.all_levels():
		var level_id := StringName(level["id"])
		var goal := float(level["goal_distance_pixels"])
		if CampaignCatalog.is_complete(level_id, goal * 4.0, []):
			failures.append(
				"level %s completed at %.0f px with no verb performed" % [
					level_id, goal * 4.0])
			return 0
	return 1


static func _test_verb_alone_does_not_complete(
	failures: PackedStringArray,
) -> int:
	for level: Dictionary in CampaignCatalog.all_levels():
		var level_id := StringName(level["id"])
		var verbs := CampaignCatalog.verbs_for_level(level_id)
		var short_of_goal := float(level["goal_distance_pixels"]) - 1.0
		if CampaignCatalog.is_complete(level_id, short_of_goal, verbs):
			failures.append(
				"level %s completed short of its goal" % level_id)
			return 0
	return 1


static func _test_goal_and_verb_complete(
	failures: PackedStringArray,
) -> int:
	for level: Dictionary in CampaignCatalog.all_levels():
		var level_id := StringName(level["id"])
		var verbs := CampaignCatalog.verbs_for_level(level_id)
		var goal := float(level["goal_distance_pixels"])
		if not CampaignCatalog.is_complete(level_id, goal, verbs):
			failures.append(
				"level %s did not complete on goal plus every verb" % level_id)
			return 0
	return 1


## Performing a different verb must not stand in for the taught one, or the
## Dive level would clear on a Burst and teach nothing.
static func _test_wrong_verb_does_not_complete(
	failures: PackedStringArray,
) -> int:
	var all_verbs := [
		CampaignCatalog.VERB_REEL,
		CampaignCatalog.VERB_BURST,
		CampaignCatalog.VERB_DIVE,
	]
	for level: Dictionary in CampaignCatalog.all_levels():
		var level_id := StringName(level["id"])
		var verbs := CampaignCatalog.verbs_for_level(level_id)
		var others: Array[StringName] = []
		for candidate: StringName in all_verbs:
			if not candidate in verbs:
				others.append(candidate)
		# A level requiring every verb has no "wrong" set to offer it; the
		# goal-alone contract already covers that case, and asserting here
		# would pass vacuously.
		if others.is_empty():
			continue
		if CampaignCatalog.is_complete(
				level_id,
				float(level["goal_distance_pixels"]),
				others):
			failures.append(
				"level %s completed on the wrong verbs" % level_id)
			return 0
	return 1


## **The guarantee the combination tier exists for.** A level asking for two
## verbs must not clear on one of them. Without this it is a teaching level
## wearing a longer objective, and the tier adds nothing.
static func _test_partial_verbs_do_not_complete_a_combination(
	failures: PackedStringArray,
) -> int:
	var checked := 0
	for level: Dictionary in CampaignCatalog.all_levels():
		var level_id := StringName(level["id"])
		var verbs := CampaignCatalog.verbs_for_level(level_id)
		if verbs.size() < 2:
			continue
		var goal := float(level["goal_distance_pixels"])
		# Every strict subset that drops exactly one required verb.
		for omitted: StringName in verbs:
			var partial: Array[StringName] = []
			for verb: StringName in verbs:
				if verb != omitted:
					partial.append(verb)
			if CampaignCatalog.is_complete(level_id, goal, partial):
				failures.append(
					("level %s cleared without %s, so it requires ANY of its "
						+ "verbs rather than ALL of them")
					% [level_id, omitted])
				return 0
		checked += 1
	if checked == 0:
		failures.append(
			"no campaign level requires more than one verb — the combination "
			+ "tier this contract guards is gone")
		return 0
	return 1


## Tiers are presentation grouping, so they may not silently lose a level or
## invent an ordering that the screen then renders out of sequence.
static func _test_tiers_cover_every_level_in_order(
	failures: PackedStringArray,
) -> int:
	var tiers := CampaignCatalog.tiers()
	if tiers.size() < 2:
		failures.append("campaign declares fewer than two tiers")
		return 0
	var covered: Array[StringName] = []
	for tier: Dictionary in tiers:
		var tier_id := StringName(tier["id"])
		var levels := CampaignCatalog.levels_for_tier(tier_id)
		if levels.is_empty():
			failures.append("tier %s contains no levels" % tier_id)
			return 0
		if str(tier["name"]).strip_edges().is_empty():
			failures.append("tier %s has no display name" % tier_id)
			return 0
		for level: Dictionary in levels:
			covered.append(StringName(level["id"]))
	var all_ids := CampaignCatalog.level_ids()
	if covered.size() != all_ids.size():
		failures.append(
			"tiers cover %d levels but the catalog has %d — a level would "
			% [covered.size(), all_ids.size()] + "never be reachable")
		return 0
	for level_id: StringName in all_ids:
		if not level_id in covered:
			failures.append("level %s belongs to no tier" % level_id)
			return 0
	var previous := -1
	for level: Dictionary in CampaignCatalog.all_levels():
		var order := int(level["order"])
		if order <= previous:
			failures.append(
				"campaign level %s has order %d, not after %d"
				% [StringName(level["id"]), order, previous])
			return 0
		previous = order
	return 1


static func _test_campaign_settlement_pays_no_flies_and_no_record(
	failures: PackedStringArray,
) -> int:
	var level_id := CampaignCatalog.TEACH_REEL
	var settlement := RunSettlement.campaign(
		CampaignCatalog.settlement_id(level_id),
		9_000_000.0,
		&"campaign_complete",
		level_id,
		4101,
	)
	if settlement.rewards_eligible or settlement.records_eligible or \
			settlement.leaderboards_eligible:
		failures.append("campaign settlement claims eligibility it must not")
		return 0
	if settlement.flies_collected != 0:
		failures.append("campaign settlement carries flies")
		return 0
	var progress := PlayerProgress.defaults()
	var service := ProgressionService.new()
	var before_best := progress.best_distance_pixels
	var result := service.apply_settlement(progress, settlement)
	if not bool(result["applied"]):
		failures.append("campaign settlement was not applied")
		return 0
	if progress.total_flies != 0 or progress.spendable_flies != 0:
		failures.append("campaign clear paid flies")
		return 0
	if not is_equal_approx(progress.best_distance_pixels, before_best):
		failures.append("campaign clear moved the best distance record")
		return 0
	return 1


static func _test_campaign_clear_grants_exactly_one_star(
	failures: PackedStringArray,
) -> int:
	var level_id := CampaignCatalog.TEACH_BURST
	var progress := PlayerProgress.defaults()
	var service := ProgressionService.new()
	if progress.campaign_stars_for(level_id) != 0:
		failures.append("a fresh save already holds a campaign star")
		return 0
	var result := service.apply_settlement(progress, RunSettlement.campaign(
		CampaignCatalog.settlement_id(level_id),
		3000.0,
		&"campaign_complete",
		level_id,
		4102,
	))
	if not bool(result.get("star_granted", false)):
		failures.append("campaign clear did not report a star")
		return 0
	if progress.campaign_stars_for(level_id) != 1:
		failures.append("campaign clear did not grant exactly one star")
		return 0
	if progress.total_campaign_stars() != 1:
		failures.append("campaign star total is wrong after one clear")
		return 0
	return 1


## A fixed-seed level can be replayed forever. Settlement-id dedupe is what
## stops that being a star farm.
static func _test_repeat_clear_grants_nothing(
	failures: PackedStringArray,
) -> int:
	var level_id := CampaignCatalog.TEACH_DIVE
	var progress := PlayerProgress.defaults()
	var service := ProgressionService.new()
	var applied_count := 0
	var star_reports := 0
	for attempt in range(4):
		var result := service.apply_settlement(progress, RunSettlement.campaign(
			CampaignCatalog.settlement_id(level_id),
			3000.0,
			&"campaign_complete",
			level_id,
			4103,
		))
		if bool(result["applied"]):
			applied_count += 1
		if bool(result.get("star_granted", false)):
			star_reports += 1
	if progress.campaign_stars_for(level_id) != 1:
		failures.append("replaying a campaign level farmed %d stars" %
			progress.campaign_stars_for(level_id))
		return 0
	# Check the mechanism, not only the outcome. The settlement-id dedupe and
	# the star cap each independently hold the total at one, so asserting the
	# total alone passes even when one of them is removed — mutating either in
	# isolation left this contract green until it also counted the applications.
	if applied_count != 1:
		failures.append(
			"a repeated campaign settlement applied %d times, not once" %
				applied_count)
		return 0
	if star_reports != 1:
		failures.append(
			"a repeated campaign clear reported %d star grants, not one" %
				star_reports)
		return 0
	if progress.total_flies != 0:
		failures.append("replaying a campaign level farmed flies")
		return 0
	return 1


static func _test_stars_survive_a_save_round_trip(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	progress.campaign_stars[str(CampaignCatalog.TEACH_REEL)] = 1
	var restored := PlayerProgress.from_dictionary(progress.to_dictionary())
	if restored.campaign_stars_for(CampaignCatalog.TEACH_REEL) != 1:
		failures.append("campaign stars did not survive a save round trip")
		return 0
	if PlayerProgress.SCHEMA_VERSION < \
			PlayerProgress.CAMPAIGN_STAR_SCHEMA_VERSION:
		failures.append("campaign stars ship below their schema version")
		return 0
	return 1


## A schema-5 save predates the campaign entirely, so the truthful migration
## is an empty star ledger — not an inferred one.
static func _test_schema_five_save_loads_with_no_stars(
	failures: PackedStringArray,
) -> int:
	var legacy := {
		"schema_version": 5,
		"total_flies": 900,
		"spendable_flies": 120,
		"best_distance_pixels": 120000.0,
	}
	var progress := PlayerProgress.from_dictionary(legacy)
	if progress.total_campaign_stars() != 0:
		failures.append("a schema-5 save invented campaign stars")
		return 0
	if progress.total_flies != 900:
		failures.append("schema-5 migration lost fly balance")
		return 0
	# An unknown level id in a save must not become a star either.
	var forged := legacy.duplicate(true)
	forged["schema_version"] = 6
	forged["campaign_stars"] = {"not_a_real_level": 5}
	var forged_progress := PlayerProgress.from_dictionary(forged)
	# Assert on the stored ledger, not on `total_campaign_stars()`: that
	# helper only sums ids the catalog knows, so it can never observe a
	# forged key and an assertion against it would pass vacuously — which is
	# exactly what it did until the guard was mutated and the suite stayed
	# green.
	if forged_progress.campaign_stars.has("not_a_real_level"):
		failures.append("an unknown campaign level id was stored as a star")
		return 0
	if forged_progress.total_campaign_stars() != 0:
		failures.append("an unknown campaign level id was awarded a star")
		return 0
	# A real level id must never bank more than the single star it pays.
	var greedy := legacy.duplicate(true)
	greedy["schema_version"] = 6
	greedy["campaign_stars"] = {str(CampaignCatalog.TEACH_REEL): 99}
	var greedy_progress := PlayerProgress.from_dictionary(greedy)
	if greedy_progress.campaign_stars_for(CampaignCatalog.TEACH_REEL) != 1:
		failures.append("a save claiming 99 stars was loaded unclamped")
		return 0
	return 1

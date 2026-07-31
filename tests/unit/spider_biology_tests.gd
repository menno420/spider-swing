extends RefCounted
class_name SpiderBiologyTests
## Contracts for the biological inspiration layer.
##
## These guard honesty, not balance: every playable profile must say what
## inspired it and what the game invents, no composite may be dressed as a
## verified species, and biology must never start carrying tuning values.

## Tuning keys owned by SpiderCatalog. A biological record that grew one of
## these would have quietly become a second balance table.
const TUNING_KEYS := [
	"radius_scale", "gravity_scale", "drive_scale", "speed_scale",
	"reel_scale", "burst_scale", "glide_duration", "glide_gravity_scale",
	"surface_bounce_enabled",
]
const REQUIRED_KEYS := [
	"inspiration", "inspired_by", "hook", "real_trait", "game_adaptation",
	"sources",
]


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_every_profile_has_a_record(failures)
	passed += _test_every_record_classifies_its_claim(failures)
	passed += _test_every_record_discloses_the_game_invention(failures)
	passed += _test_only_species_records_claim_an_accepted_name(failures)
	passed += _test_fictional_profiles_name_themselves_as_invented(failures)
	passed += _test_ballooner_is_behaviour_and_denies_flight(failures)
	passed += _test_sources_resolve_to_citable_entries(failures)
	passed += _test_no_source_is_registered_but_uncited(failures)
	passed += _test_invented_names_name_the_science_they_borrow(failures)
	passed += _test_biology_carries_no_tuning_values(failures)
	passed += _test_garage_summary_shows_the_classification(failures)
	return {"passed": passed, "failures": failures}


static func _test_every_profile_has_a_record(
	failures: PackedStringArray,
) -> int:
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		if not SpiderBiologyCatalog.has_record(spider_id):
			failures.append("%s has no biological record" % spider_id)
			return 0
	if SpiderBiologyCatalog.RECORDS.size() != SpiderCatalog.ALL_IDS.size():
		failures.append("biology records and playable profiles are out of step")
		return 0
	if not SpiderBiologyCatalog.record(&"not_a_spider").is_empty():
		failures.append("an unknown profile resolved to a record")
		return 0
	return 1


static func _test_every_record_classifies_its_claim(
	failures: PackedStringArray,
) -> int:
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var item := SpiderBiologyCatalog.record(spider_id)
		for key: String in REQUIRED_KEYS:
			if not item.has(key) or str(item[key]).is_empty():
				failures.append("%s record is missing %s" % [spider_id, key])
				return 0
		var inspiration := StringName(item["inspiration"])
		if inspiration not in SpiderBiologyCatalog.INSPIRATION_TYPES:
			failures.append("%s claims unknown inspiration %s" % [
				spider_id, inspiration])
			return 0
		if SpiderBiologyCatalog.inspiration_label(inspiration) == "UNCLASSIFIED":
			failures.append("%s has no readable classification" % spider_id)
			return 0
	return 1


static func _test_every_record_discloses_the_game_invention(
	failures: PackedStringArray,
) -> int:
	# The disclosure is the whole point of the layer: a profile may exaggerate
	# freely as long as the exaggeration is named somewhere the player can read.
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var disclosure := str(
			SpiderBiologyCatalog.record(spider_id)["game_adaptation"])
		if disclosure.length() < 40:
			failures.append("%s does not disclose what the game invents" %
				spider_id)
			return 0
	return 1


static func _test_only_species_records_claim_an_accepted_name(
	failures: PackedStringArray,
) -> int:
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var item := SpiderBiologyCatalog.record(spider_id)
		var is_species := \
			StringName(item["inspiration"]) == SpiderBiologyCatalog.SPECIES
		var accepted := str(item["accepted_name"])
		if is_species and accepted.is_empty():
			failures.append("%s claims a species without an accepted name" %
				spider_id)
			return 0
		if not is_species and not accepted.is_empty():
			failures.append("%s is not species-level but claims %s" % [
				spider_id, accepted])
			return 0
		if is_species and str(item["reference_authority"]).is_empty():
			failures.append("%s names a species without its authority" %
				spider_id)
			return 0
	if SpiderBiologyCatalog.scientific_line(&"ballooner") != "":
		failures.append("behaviour-level ballooner asserts a binomial")
		return 0
	return 1


static func _test_fictional_profiles_name_themselves_as_invented(
	failures: PackedStringArray,
) -> int:
	# Invented spiders are welcome (D-0027). What is not welcome is an invented
	# spider a player could mistake for a documented one, so the disclosure has
	# to say the animal itself is invented — not merely that a stat is tuned.
	var fictional := 0
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var item := SpiderBiologyCatalog.record(spider_id)
		if StringName(item["inspiration"]) != SpiderBiologyCatalog.FICTIONAL:
			continue
		fictional += 1
		var disclosure := str(item["game_adaptation"]).to_lower()
		if not disclosure.contains("invented spider"):
			failures.append(
				"%s is fictional but does not say the spider is invented" %
					spider_id)
			return 0
		var display_name := str(SpiderCatalog.profile(spider_id)["name"])
		if not disclosure.contains(display_name.to_lower()):
			failures.append(
				"%s does not disclaim its own name" % spider_id)
			return 0
	if fictional != 1:
		failures.append("expected exactly one fictional profile, found %d" %
			fictional)
		return 0
	return 1


static func _test_ballooner_is_behaviour_and_denies_flight(
	failures: PackedStringArray,
) -> int:
	var item := SpiderBiologyCatalog.record(SpiderCatalog.BALLOONER)
	if StringName(item["inspiration"]) != SpiderBiologyCatalog.BEHAVIOUR:
		failures.append("Ballooner is not labelled a behaviour")
		return 0
	if not str(item["game_adaptation"]).to_lower().contains("not"):
		failures.append("Ballooner glide is not disclosed as fictional")
		return 0
	if not str(item["game_adaptation"]).to_lower().contains("flight"):
		failures.append("Ballooner does not separate the glide from flight")
		return 0
	return 1


static func _test_sources_resolve_to_citable_entries(
	failures: PackedStringArray,
) -> int:
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var cited := SpiderBiologyCatalog.sources_for(spider_id)
		if cited.is_empty():
			failures.append("%s cites no source" % spider_id)
			return 0
		if cited.size() != (
			SpiderBiologyCatalog.record(spider_id)["sources"] as Array).size():
			failures.append("%s cites an unregistered source id" % spider_id)
			return 0
		for source: Dictionary in cited:
			for key: String in ["title", "publisher", "url"]:
				if str(source.get(key, "")).is_empty():
					failures.append("%s cites a source missing %s" % [
						spider_id, key])
					return 0
			if not str(source["url"]).begins_with("https://"):
				failures.append("%s cites a non-resolvable url" % spider_id)
				return 0
	return 1


## The second research report (2026-07-31) shipped 84 citation keys and no
## register defining them, which is what makes a citation decorative. Guard both
## directions: a cited id must resolve, and a registered source must be cited by
## something — an orphan entry is a source nobody checked.
static func _test_no_source_is_registered_but_uncited(
	failures: PackedStringArray,
) -> int:
	var cited := {}
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		for source_id: StringName in SpiderBiologyCatalog.record(
			spider_id)["sources"]:
			cited[source_id] = true
	for source_id: StringName in SpiderBiologyCatalog.SOURCES:
		if not cited.has(source_id):
			failures.append("source %s is registered but nothing cites it" %
				source_id)
			return 0
	return 1


## D-0031: a real spider with a usable name always wins. Where a name had to be
## invented, the player is owed the science instead — every real spider the
## profile borrows from, named, and what each one actually contributes. One
## invented spider may combine several real ones; that is the point of a list.
static func _test_invented_names_name_the_science_they_borrow(
	failures: PackedStringArray,
) -> int:
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var item := SpiderBiologyCatalog.record(spider_id)
		var origin := StringName(item["name_origin"])
		if origin not in SpiderBiologyCatalog.NAME_ORIGINS:
			failures.append("%s has unknown name origin %s" % [spider_id, origin])
			return 0
		var borrowed: Array = item["drawn_from"]
		if borrowed.is_empty():
			failures.append("%s names no real spider at all" % spider_id)
			return 0
		for entry: Dictionary in borrowed:
			for key: String in ["name", "family", "contributes"]:
				if str(entry.get(key, "")).is_empty():
					failures.append("%s borrows from an entry missing %s" % [
						spider_id, key])
					return 0
		if origin == SpiderBiologyCatalog.NAME_INVENTED:
			if not SpiderBiologyCatalog.has_invented_name(spider_id):
				failures.append("%s invented-name lookup disagrees with its record"
					% spider_id)
				return 0
			var line := SpiderBiologyCatalog.drawn_from_line(spider_id)
			for entry: Dictionary in borrowed:
				if not line.contains(str(entry["name"])):
					failures.append("%s omits %s from its borrowed list" % [
						spider_id, entry["name"]])
					return 0
		# A species-level record names exactly the one animal it claims to be.
		if StringName(item["inspiration"]) == SpiderBiologyCatalog.SPECIES:
			if borrowed.size() != 1 or \
					str(borrowed[0]["name"]) != str(item["accepted_name"]):
				failures.append("%s claims a species but borrows elsewhere" %
					spider_id)
				return 0
	return 1


static func _test_biology_carries_no_tuning_values(
	failures: PackedStringArray,
) -> int:
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var item := SpiderBiologyCatalog.record(spider_id)
		for key: String in TUNING_KEYS:
			if item.has(key):
				failures.append("%s biology record carries tuning key %s" % [
					spider_id, key])
				return 0
	# The reverse direction matters just as much: profiles stay free of prose.
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var profile_item := SpiderCatalog.profile(spider_id)
		for key: String in ["inspiration", "accepted_name", "sources"]:
			if profile_item.has(key):
				failures.append("%s profile carries biology key %s" % [
					spider_id, key])
				return 0
	return 1


static func _test_garage_summary_shows_the_classification(
	failures: PackedStringArray,
) -> int:
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var item := SpiderBiologyCatalog.record(spider_id)
		var summary := SpiderBiologyCatalog.garage_summary(spider_id)
		if not summary.contains(str(item["inspired_by"])):
			failures.append("%s summary omits its inspiration" % spider_id)
			return 0
		var label := SpiderBiologyCatalog.inspiration_label(
			StringName(item["inspiration"]))
		if not summary.contains(label):
			failures.append("%s summary omits the %s classification" % [
				spider_id, label])
			return 0
	if SpiderBiologyCatalog.garage_summary(&"not_a_spider") != "":
		failures.append("an unknown profile produced a summary")
		return 0
	return 1

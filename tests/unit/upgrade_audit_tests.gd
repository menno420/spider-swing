extends RefCounted
class_name UpgradeAuditTests
## Contracts protecting the upgrade audit's premises.
##
## The 2026-08-01 audit found two tracks that change the config and change
## nothing about play. Distinguishing that from a track that never reached the
## config at all took a hand-written probe, and the whole finding would have
## been worthless without it. These contracts make that check permanent: a
## track that silently stops applying now fails the suite instead of quietly
## reading as "measured, no effect".
##
## They deliberately assert **wiring**, not balance. What a track is worth is a
## measurement (`docs/measurements/2026-08-01-upgrade-audit.md`), and pinning a
## balance number here would freeze tuning the owner has not approved.

## Fields no upgrade may push past their documented ceiling. Each cap is
## written into `SpiderCatalog.apply_to_config` as a `minf`/`maxf` clamp; this
## is the contract that the clamp is still there.
const CAPS := [
	{"field": "burst_distance_fraction", "max": 0.60},
	{"field": "automatic_take_up_retention", "max": 0.94},
]

## OQ-13 owns the product decision for Quick Feet after free drive removal.
## Its persisted id and bought levels remain intact, but it is deliberately the
## one temporarily inert track rather than being silently repointed by an agent.
const PENDING_REDESIGN_TRACKS := [&"skitter_drive"]


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_every_track_reaches_the_config(failures)
	passed += _test_track_ids_are_unique(failures)
	passed += _test_burst_breakthrough_grants_the_second_charge(failures)
	passed += _test_documented_caps_hold_at_max_level(failures)
	return {"passed": passed, "failures": failures}


## Build a config with exactly one track levelled and everything else at zero.
static func _config_with_track(
	profile_id: StringName,
	upgrade_id: StringName,
	level: int,
) -> SwingConfig:
	var progress := PlayerProgress.defaults()
	progress.selected_spider_id = profile_id
	if level > 0:
		progress.upgrade_levels[str(upgrade_id)] = level
	return SpiderCatalog.resolved_config(SwingConfig.PRESET_BALANCED, progress)


## Every scripted property on a SwingConfig, as name -> value.
static func _snapshot(config: SwingConfig) -> Dictionary:
	var result := {}
	for entry: Dictionary in config.get_property_list():
		if int(entry.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		var name := str(entry["name"])
		result[name] = config.get(name)
	return result


## The load-bearing one. A track that reaches level 20 and moves nothing in the
## config is not "a weak upgrade" — it is disconnected, and any measurement of
## it is measuring the baseline twice.
static func _test_every_track_reaches_the_config(
	failures: PackedStringArray,
) -> int:
	for profile_id: StringName in SpiderCatalog.ALL_IDS:
		var baseline := _snapshot(
			_config_with_track(profile_id, &"", 0))
		for upgrade: Dictionary in SpiderCatalog.upgrades_for(profile_id):
			var upgrade_id := StringName(upgrade["id"])
			var maxed := _snapshot(_config_with_track(
				profile_id, upgrade_id, SpiderCatalog.MAX_UPGRADE_LEVEL))
			var changed: Array[String] = []
			for field: String in baseline:
				if maxed[field] != baseline[field]:
					changed.append(field)
			if changed.is_empty() and upgrade_id not in PENDING_REDESIGN_TRACKS:
				failures.append(
					("track %s changes no config value at level %d — it is "
						+ "disconnected, not weak") % [
						upgrade_id, SpiderCatalog.MAX_UPGRADE_LEVEL])
				return 0
	return 1


static func _test_track_ids_are_unique(
	failures: PackedStringArray,
) -> int:
	var seen: Array[StringName] = []
	for upgrade: Dictionary in SpiderCatalog.all_upgrades():
		var upgrade_id := StringName(upgrade["id"])
		if upgrade_id in seen:
			failures.append("duplicate upgrade id %s" % upgrade_id)
			return 0
		seen.append(upgrade_id)
	if seen.is_empty():
		failures.append("no upgrade tracks exist at all")
		return 0
	return 1


## Anchor Drive's level-20 step is a rule change, not a bigger number: a second
## stored Burst charge. The audit measured it bundled with the longer pull, so
## the rule itself is worth pinning separately from any tuning.
static func _test_burst_breakthrough_grants_the_second_charge(
	failures: PackedStringArray,
) -> int:
	var upgrade_id := &"classic_burst"
	var below := _config_with_track(SpiderCatalog.CLASSIC, upgrade_id, 19)
	var at := _config_with_track(SpiderCatalog.CLASSIC, upgrade_id, 20)
	if below.burst_charge_capacity != 1:
		failures.append(
			"Anchor Drive granted a second Burst charge before level 20 (%d)" %
				below.burst_charge_capacity)
		return 0
	if at.burst_charge_capacity != 2:
		failures.append(
			"Anchor Drive did not grant the second Burst charge at level 20 (%d)"
				% at.burst_charge_capacity)
		return 0
	return 1


static func _test_documented_caps_hold_at_max_level(
	failures: PackedStringArray,
) -> int:
	for profile_id: StringName in SpiderCatalog.ALL_IDS:
		var progress := PlayerProgress.defaults()
		progress.selected_spider_id = profile_id
		for upgrade: Dictionary in SpiderCatalog.upgrades_for(profile_id):
			progress.upgrade_levels[str(upgrade["id"])] = \
				SpiderCatalog.MAX_UPGRADE_LEVEL
		var config := SpiderCatalog.resolved_config(
			SwingConfig.PRESET_BALANCED, progress)
		for cap: Dictionary in CAPS:
			var field := str(cap["field"])
			var value := float(config.get(field))
			if value > float(cap["max"]) + 0.0001:
				failures.append("%s on %s reached %.4f, cap is %.4f" % [
					field, profile_id, value, float(cap["max"])])
				return 0
		# A fully upgraded config must still be a legal one.
		var invalid := config.validate()
		if not invalid.is_empty():
			failures.append("maxed %s produced an invalid config: %s" % [
				profile_id, invalid[0]])
			return 0
	return 1

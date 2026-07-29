extends RefCounted
class_name SpiderCatalog
## Data-defined Phase 0 spider candidates and their fly-funded upgrades.
##
## Profiles modify the one authoritative SwingConfig. They are intentionally
## trade-offs, not separate motors or paid replacements for core skill.

const CLASSIC := &"classic"
const SKITTER := &"skitter"
const ANCHORITE := &"anchorite"
const BALLOONER := &"ballooner"
const ALL_IDS: Array[StringName] = [CLASSIC, SKITTER, ANCHORITE, BALLOONER]
const MAX_UPGRADE_LEVEL := 3
const UPGRADE_COSTS := [5, 10, 20]

const PROFILES := [
	{
		"id": CLASSIC,
		"name": "Garden Spider",
		"role": "BALANCED",
		"description": "The reference spider: readable weight, reach, and control.",
		"tradeoff": "No extreme strength and no hidden weakness.",
		"radius_scale": 1.0,
		"gravity_scale": 1.0,
		"drive_scale": 1.0,
		"speed_scale": 1.0,
		"reel_scale": 1.0,
		"burst_scale": 1.0,
		"glide_duration": 0.0,
		"glide_gravity_scale": 1.0,
		"upgrades": [&"classic_reel", &"classic_burst"],
	},
	{
		"id": SKITTER,
		"name": "Skitter",
		"role": "SMALL · AGILE",
		"description": "A compact spider that changes pace quickly and fits tighter gaps.",
		"tradeoff": "Shorter, softer Bursts demand more deliberate anchor timing.",
		"radius_scale": 0.86,
		"gravity_scale": 0.97,
		"drive_scale": 1.16,
		"speed_scale": 1.04,
		"reel_scale": 1.02,
		"burst_scale": 0.92,
		"glide_duration": 0.0,
		"glide_gravity_scale": 1.0,
		"upgrades": [&"skitter_size", &"skitter_drive"],
	},
	{
		"id": ANCHORITE,
		"name": "Anchorite",
		"role": "HEAVY · POWERFUL",
		"description": "A heavy spider with strong Reel-In and stable momentum.",
		"tradeoff": "Falls faster, turns slower, and needs more room around hazards.",
		"radius_scale": 1.12,
		"gravity_scale": 1.12,
		"drive_scale": 0.88,
		"speed_scale": 0.95,
		"reel_scale": 1.16,
		"burst_scale": 1.10,
		"glide_duration": 0.0,
		"glide_gravity_scale": 1.0,
		"upgrades": [&"anchorite_reel", &"anchorite_momentum"],
	},
	{
		"id": BALLOONER,
		"name": "Ballooner",
		"role": "LIGHT · GLIDING",
		"description": "Spreads silk while detached to delay the drop after release.",
		"tradeoff": "Lower drive and a wider body make rapid corrections less forgiving.",
		"radius_scale": 1.02,
		"gravity_scale": 0.98,
		"drive_scale": 0.94,
		"speed_scale": 0.96,
		"reel_scale": 0.96,
		"burst_scale": 0.96,
		"glide_duration": 1.20,
		"glide_gravity_scale": 0.48,
		"upgrades": [&"ballooner_glide", &"ballooner_reach"],
	},
]

const UPGRADES := [
	{
		"id": &"classic_reel",
		"profile": CLASSIC,
		"name": "Silk Winder",
		"description": "Reel-In shortens the web 5% faster per level.",
	},
	{
		"id": &"classic_burst",
		"profile": CLASSIC,
		"name": "Anchor Instinct",
		"description": "Anchor Burst crosses 3% more distance per level.",
	},
	{
		"id": &"skitter_size",
		"profile": SKITTER,
		"name": "Compact Stance",
		"description": "Hitbox radius shrinks another 3% per level.",
	},
	{
		"id": &"skitter_drive",
		"profile": SKITTER,
		"name": "Quick Feet",
		"description": "Forward recovery gains 5% per level.",
	},
	{
		"id": &"anchorite_reel",
		"profile": ANCHORITE,
		"name": "Heavy Winder",
		"description": "Reel-In shortens the web 6% faster per level.",
	},
	{
		"id": &"anchorite_momentum",
		"profile": ANCHORITE,
		"name": "Momentum Core",
		"description": "Burst exit speed gains 5% per level.",
	},
	{
		"id": &"ballooner_glide",
		"profile": BALLOONER,
		"name": "Long Silk Sail",
		"description": "Detached glide lasts 0.25 seconds longer per level.",
	},
	{
		"id": &"ballooner_reach",
		"profile": BALLOONER,
		"name": "Featherline",
		"description": "Maximum web reach gains 4% per level.",
	},
]


static func profile(profile_id: StringName) -> Dictionary:
	for item: Dictionary in PROFILES:
		if StringName(item["id"]) == profile_id:
			return item.duplicate(true)
	return PROFILES[0].duplicate(true)


static func upgrade(upgrade_id: StringName) -> Dictionary:
	for item: Dictionary in UPGRADES:
		if StringName(item["id"]) == upgrade_id:
			return item.duplicate(true)
	return {}


static func upgrades_for(profile_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item: Dictionary in UPGRADES:
		if StringName(item["profile"]) == profile_id:
			result.append(item.duplicate(true))
	return result


static func cost_for_level(current_level: int) -> int:
	if current_level < 0 or current_level >= MAX_UPGRADE_LEVEL:
		return 0
	return int(UPGRADE_COSTS[current_level])


static func apply_to_config(
	config: SwingConfig,
	progress: PlayerProgress,
) -> void:
	var selected := (
		progress.selected_spider_id
		if progress.selected_spider_id in ALL_IDS
		else CLASSIC
	)
	var item := profile(selected)
	config.player_collision_radius *= float(item["radius_scale"])
	config.gravity *= float(item["gravity_scale"])
	config.horizontal_drive_acceleration *= float(item["drive_scale"])
	config.starting_target_speed *= float(item["speed_scale"])
	config.maximum_target_speed *= float(item["speed_scale"])
	config.reel_retraction_rate *= float(item["reel_scale"])
	config.burst_exit_speed *= float(item["burst_scale"])
	config.detached_gravity_scale = float(item["glide_gravity_scale"])
	config.glide_duration = float(item["glide_duration"])

	for upgrade_item: Dictionary in upgrades_for(selected):
		var upgrade_id := StringName(upgrade_item["id"])
		var level := progress.upgrade_level(upgrade_id)
		match upgrade_id:
			&"classic_reel":
				config.reel_retraction_rate *= 1.0 + 0.05 * float(level)
			&"classic_burst":
				config.burst_distance_fraction = minf(
					0.70,
					config.burst_distance_fraction + 0.03 * float(level),
				)
			&"skitter_size":
				config.player_collision_radius *= 1.0 - 0.03 * float(level)
			&"skitter_drive":
				config.horizontal_drive_acceleration *= \
					1.0 + 0.05 * float(level)
			&"anchorite_reel":
				config.reel_retraction_rate *= 1.0 + 0.06 * float(level)
			&"anchorite_momentum":
				config.burst_exit_speed *= 1.0 + 0.05 * float(level)
			&"ballooner_glide":
				config.glide_duration += 0.25 * float(level)
			&"ballooner_reach":
				config.web_maximum_length *= 1.0 + 0.04 * float(level)

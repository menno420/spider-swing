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
const SPRINGTAIL := &"springtail"
const ALL_IDS: Array[StringName] = [
	CLASSIC, SKITTER, ANCHORITE, BALLOONER, SPRINGTAIL,
]
const MAX_UPGRADE_LEVEL := 5
const UPGRADE_COSTS := [5, 10, 20, 35, 55]

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
		"surface_bounce_enabled": false,
		"upgrades": [
			&"classic_reel", &"classic_burst", &"classic_burst_floor",
		],
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
		"surface_bounce_enabled": false,
		"upgrades": [
			&"skitter_size", &"skitter_drive", &"skitter_burst_floor",
		],
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
		"surface_bounce_enabled": false,
		"upgrades": [
			&"anchorite_reel", &"anchorite_momentum",
			&"anchorite_burst_floor",
		],
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
		"surface_bounce_enabled": false,
		"upgrades": [
			&"ballooner_glide", &"ballooner_reach",
			&"ballooner_burst_floor",
		],
	},
	{
		"id": SPRINGTAIL,
		"name": "Springtail",
		"role": "SPRING · RECOVERY",
		"description": "A guarded spider that can rebound from one moderate rail hit.",
		"tradeoff": "A wider body and weaker drive demand planning; obstacles and hard hits still kill.",
		"radius_scale": 1.08,
		"gravity_scale": 1.04,
		"drive_scale": 0.92,
		"speed_scale": 0.97,
		"reel_scale": 0.98,
		"burst_scale": 0.92,
		"glide_duration": 0.0,
		"glide_gravity_scale": 1.0,
		"surface_bounce_enabled": true,
		"upgrades": [
			&"springtail_shell", &"springtail_bounce", &"springtail_reel",
		],
	},
]

const UPGRADES := [
	{
		"id": &"classic_reel",
		"profile": CLASSIC,
		"name": "Silk Winder",
		"description": "Reel-In shortens the web 8% faster per level.",
	},
	{
		"id": &"classic_burst",
		"profile": CLASSIC,
		"name": "Anchor Instinct",
		"description": "Anchor Burst crosses 3% more distance per level.",
	},
	{
		"id": &"classic_burst_floor",
		"profile": CLASSIC,
		"name": "Reliable Launch",
		"description": "Minimum useful Burst travel gains 24 px per level.",
	},
	{
		"id": &"skitter_size",
		"profile": SKITTER,
		"name": "Compact Stance",
		"description": "Hitbox radius shrinks another 2% per level.",
	},
	{
		"id": &"skitter_drive",
		"profile": SKITTER,
		"name": "Quick Feet",
		"description": "Forward recovery gains 4% per level.",
	},
	{
		"id": &"skitter_burst_floor",
		"profile": SKITTER,
		"name": "Pounce Thread",
		"description": "Minimum useful Burst travel gains 20 px per level.",
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
		"id": &"anchorite_burst_floor",
		"profile": ANCHORITE,
		"name": "Heavy Launch",
		"description": "Minimum useful Burst travel gains 22 px per level.",
	},
	{
		"id": &"ballooner_glide",
		"profile": BALLOONER,
		"name": "Long Silk Sail",
		"description": "Detached glide lasts 0.18 seconds longer per level.",
	},
	{
		"id": &"ballooner_reach",
		"profile": BALLOONER,
		"name": "Featherline",
		"description": "Maximum web reach gains 3% per level.",
	},
	{
		"id": &"ballooner_burst_floor",
		"profile": BALLOONER,
		"name": "Silk Catapult",
		"description": "Minimum useful Burst travel gains 20 px per level.",
	},
	{
		"id": &"springtail_shell",
		"profile": SPRINGTAIL,
		"name": "Impact Carapace",
		"description": "Maximum survivable rail impact gains 60 px/s per level.",
	},
	{
		"id": &"springtail_bounce",
		"profile": SPRINGTAIL,
		"name": "Elastic Guard",
		"description": "Rail bounce strength gains 4% per level.",
	},
	{
		"id": &"springtail_reel",
		"profile": SPRINGTAIL,
		"name": "Recovery Winder",
		"description": "Reel-In shortens the web 5% faster per level.",
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
	config.surface_bounce_enabled = bool(item["surface_bounce_enabled"])

	for upgrade_item: Dictionary in upgrades_for(selected):
		var upgrade_id := StringName(upgrade_item["id"])
		var level := progress.upgrade_level(upgrade_id)
		match upgrade_id:
			&"classic_reel":
				config.reel_retraction_rate *= 1.0 + 0.08 * float(level)
			&"classic_burst":
				config.burst_distance_fraction = minf(
					0.70,
					config.burst_distance_fraction + 0.03 * float(level),
				)
			&"classic_burst_floor":
				config.burst_minimum_distance += 24.0 * float(level)
			&"skitter_size":
				config.player_collision_radius *= 1.0 - 0.02 * float(level)
			&"skitter_drive":
				config.horizontal_drive_acceleration *= \
					1.0 + 0.04 * float(level)
			&"skitter_burst_floor":
				config.burst_minimum_distance += 20.0 * float(level)
			&"anchorite_reel":
				config.reel_retraction_rate *= 1.0 + 0.06 * float(level)
			&"anchorite_momentum":
				config.burst_exit_speed *= 1.0 + 0.05 * float(level)
			&"anchorite_burst_floor":
				config.burst_minimum_distance += 22.0 * float(level)
			&"ballooner_glide":
				config.glide_duration += 0.18 * float(level)
			&"ballooner_reach":
				config.web_maximum_length *= 1.0 + 0.03 * float(level)
			&"ballooner_burst_floor":
				config.burst_minimum_distance += 20.0 * float(level)
			&"springtail_shell":
				config.surface_bounce_max_impact_speed += 60.0 * float(level)
			&"springtail_bounce":
				config.surface_bounce_retention = minf(
					0.72,
					config.surface_bounce_retention + 0.04 * float(level),
				)
			&"springtail_reel":
				config.reel_retraction_rate *= 1.0 + 0.05 * float(level)

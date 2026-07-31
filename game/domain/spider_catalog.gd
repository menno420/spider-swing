extends RefCounted
class_name SpiderCatalog
## Data-defined spider candidates and their fly-funded adventure upgrades.
##
## Profiles modify the one authoritative SwingConfig. They are intentionally
## trade-offs, not separate motors or paid replacements for core skill.

const CLASSIC := &"classic"
const SKITTER := &"skitter"
const ANCHORITE := &"anchorite"
const BALLOONER := &"ballooner"
# The persisted id stays "springtail" on purpose: it keys saved profile
# selection and the springtail_shell / springtail_bounce upgrade levels. The
# player-facing name became Buckler in D-0027; renaming the storage key would
# buy nothing a player can see and would cost a save migration.
const BUCKLER := &"springtail"
const ALL_IDS: Array[StringName] = [
	CLASSIC, SKITTER, ANCHORITE, BALLOONER, BUCKLER,
]
const MAX_UPGRADE_LEVEL := 20
const LEGACY_LEVEL_MULTIPLIER := 4
const BREAKTHROUGH_INTERVAL := 5
const UPGRADE_COSTS := [
	2, 2, 3, 3, 5,
	3, 4, 4, 5, 7,
	5, 6, 7, 8, 12,
	8, 10, 12, 15, 20,
]

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
	},
	{
		"id": BUCKLER,
		"name": "Buckler",
		"role": "GUARDED · RECOVERY",
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
	},
]

const SCOPE_CORE := &"core"
const SCOPE_IDENTITY := &"identity"

const REEL_SPEED := &"reel_speed"
const BURST_REACH := &"burst_reach"
const BURST_FLOOR := &"burst_floor"
const REEL_CAPACITY := &"reel_capacity"
const REEL_RECOVERY := &"reel_recovery"
const TAKE_UP_RETENTION := &"take_up_retention"
const BURST_RHYTHM := &"burst_rhythm"
const COMPACT_STANCE := &"compact_stance"
const QUICK_FEET := &"quick_feet"
const HEAVY_MOMENTUM := &"heavy_momentum"
const PENDULUM_MASS := &"pendulum_mass"
const GLIDE_DURATION := &"glide_duration"
const SILK_REACH := &"silk_reach"
const IMPACT_SHELL := &"impact_shell"
const ELASTIC_GUARD := &"elastic_guard"

# These five definitions are instantiated for every spider. Keeping the kinds
# in one table prevents profiles from quietly receiving different core systems.
const CORE_TRACKS := [
	{
		"suffix": &"reel",
		"kind": REEL_SPEED,
		"name": "Silk Winder",
		"description":
			"Reel-In shortens the web 1.25% faster per tuning step.",
	},
	{
		"suffix": &"burst",
		"kind": BURST_REACH,
		"name": "Anchor Drive",
		"description":
			"Anchor Burst crosses 0.5% more of the starting distance per tuning step. Level 10 stores a second Burst charge.",
	},
	{
		"suffix": &"burst_floor",
		"kind": BURST_FLOOR,
		"name": "Reliable Launch",
		"description":
			"Minimum useful Burst travel gains 5 px per tuning step.",
	},
	{
		"suffix": &"reel_capacity",
		"kind": REEL_CAPACITY,
		"name": "Silk Reserve",
		"description":
			"Reel energy capacity gains 1% per tuning step.",
	},
	{
		"suffix": &"reel_recovery",
		"kind": REEL_RECOVERY,
		"name": "Rapid Recovery",
		"description":
			"Reel energy regenerates 1% faster and empty lockout shortens slightly per tuning step.",
	},
]

const UNIQUE_TRACKS := {
	CLASSIC: [
		{
			"suffix": &"flow",
			"kind": TAKE_UP_RETENTION,
			"name": "Balanced Flow",
			"description":
				"Automatic take-up keeps 0.25% less slack per tuning step, shortening the web.",
		},
		{
			"suffix": &"rhythm",
			"kind": BURST_RHYTHM,
			"name": "Garden Rhythm",
			"description":
				"Anchor Burst recovers 0.4% sooner per tuning step.",
		},
	],
	SKITTER: [
		{
			"suffix": &"size",
			"kind": COMPACT_STANCE,
			"name": "Compact Stance",
			"description":
				"Hitbox radius shrinks 0.4% per tuning step.",
		},
		{
			"suffix": &"drive",
			"kind": QUICK_FEET,
			"name": "Quick Feet",
			"description":
				"Forward recovery gains 0.83% per tuning step.",
		},
	],
	ANCHORITE: [
		{
			"suffix": &"momentum",
			"kind": HEAVY_MOMENTUM,
			"name": "Momentum Core",
			"description":
				"Burst exit speed gains 1.04% per tuning step.",
		},
		{
			"suffix": &"pendulum",
			"kind": PENDULUM_MASS,
			"name": "Pendulum Mass",
			"description":
				"Anchor Burst retains 0.3% more tangential motion per tuning step.",
		},
	],
	BALLOONER: [
		{
			"suffix": &"glide",
			"kind": GLIDE_DURATION,
			"name": "Long Silk Sail",
			"description":
				"Detached glide lasts 0.038 seconds longer per tuning step.",
		},
		{
			"suffix": &"reach",
			"kind": SILK_REACH,
			"name": "Featherline",
			"description":
				"Maximum web reach gains 0.625% per tuning step.",
		},
	],
	BUCKLER: [
		{
			"suffix": &"shell",
			"kind": IMPACT_SHELL,
			"name": "Impact Carapace",
			"description":
				"Maximum survivable rail impact gains 12.5 px/s per tuning step.",
		},
		{
			"suffix": &"bounce",
			"kind": ELASTIC_GUARD,
			"name": "Elastic Guard",
			"description":
				"Rail bounce retention gains 0.83% per tuning step.",
		},
	],
}


static func profile(profile_id: StringName) -> Dictionary:
	for item: Dictionary in PROFILES:
		if StringName(item["id"]) == profile_id:
			return item.duplicate(true)
	return PROFILES[0].duplicate(true)


static func upgrade(upgrade_id: StringName) -> Dictionary:
	for profile_id: StringName in ALL_IDS:
		for item: Dictionary in upgrades_for(profile_id):
			if StringName(item["id"]) == upgrade_id:
				return item
	return {}


static func upgrades_for(profile_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if profile_id not in ALL_IDS:
		return result
	for template: Dictionary in CORE_TRACKS:
		result.append(_instantiate_track(profile_id, template, SCOPE_CORE))
	var unique_tracks: Array = UNIQUE_TRACKS.get(profile_id, [])
	for template: Dictionary in unique_tracks:
		result.append(_instantiate_track(profile_id, template, SCOPE_IDENTITY))
	return result


static func all_upgrades() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for profile_id: StringName in ALL_IDS:
		result.append_array(upgrades_for(profile_id))
	return result


static func cost_for_level(current_level: int) -> int:
	if current_level < 0 or current_level >= MAX_UPGRADE_LEVEL:
		return 0
	return int(UPGRADE_COSTS[current_level])


static func breakthrough_count(level: int) -> int:
	return floori(
		float(clampi(level, 0, MAX_UPGRADE_LEVEL)) /
			float(BREAKTHROUGH_INTERVAL),
	)


static func effective_steps(level: int) -> int:
	var safe_level := clampi(level, 0, MAX_UPGRADE_LEVEL)
	return safe_level + breakthrough_count(safe_level)


static func is_breakthrough_level(level: int) -> bool:
	return level > 0 and level <= MAX_UPGRADE_LEVEL and \
		posmod(level, BREAKTHROUGH_INTERVAL) == 0


static func next_breakthrough_level(level: int) -> int:
	var safe_level := clampi(level, 0, MAX_UPGRADE_LEVEL)
	if safe_level >= MAX_UPGRADE_LEVEL:
		return MAX_UPGRADE_LEVEL
	var completed_intervals := floori(
		float(safe_level) / float(BREAKTHROUGH_INTERVAL),
	)
	return mini(
		MAX_UPGRADE_LEVEL,
		(completed_intervals + 1) * BREAKTHROUGH_INTERVAL,
	)


static func resolved_config(
	preset_name: StringName,
	progress: PlayerProgress,
) -> SwingConfig:
	var config := SwingConfig.from_preset(preset_name)
	apply_to_config(config, progress)
	return config


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
		var steps := float(effective_steps(level))
		match StringName(upgrade_item["kind"]):
			REEL_SPEED:
				config.reel_retraction_rate *= 1.0 + 0.0125 * steps
			BURST_REACH:
				config.burst_distance_fraction = minf(
					0.60,
					config.burst_distance_fraction + 0.005 * steps,
				)
				# The level-10 breakthrough is a rule change, not a bigger
				# number: a second stored Burst on one serial refill timer.
				if level >= 2 * BREAKTHROUGH_INTERVAL:
					config.burst_charge_capacity = maxi(
						config.burst_charge_capacity, 2)
			BURST_FLOOR:
				config.burst_minimum_distance += 5.0 * steps
			REEL_CAPACITY:
				config.reel_energy_capacity *= 1.0 + 0.01 * steps
			REEL_RECOVERY:
				config.reel_regeneration_rate *= 1.0 + 0.01 * steps
				config.reel_empty_lockout *= maxf(0.75, 1.0 - 0.005 * steps)
			TAKE_UP_RETENTION:
				config.automatic_take_up_retention = minf(
					0.94,
					config.automatic_take_up_retention + 0.0025 * steps,
				)
			BURST_RHYTHM:
				config.burst_cooldown *= maxf(0.82, 1.0 - 0.004 * steps)
			COMPACT_STANCE:
				config.player_collision_radius *= maxf(
					0.88,
					1.0 - 0.004 * steps,
				)
			QUICK_FEET:
				config.horizontal_drive_acceleration *= \
					1.0 + (1.0 / 120.0) * steps
			HEAVY_MOMENTUM:
				config.burst_exit_speed *= 1.0 + 0.0104 * steps
			PENDULUM_MASS:
				config.burst_tangential_retention = minf(
					0.75,
					config.burst_tangential_retention + 0.003 * steps,
				)
			GLIDE_DURATION:
				config.glide_duration += 0.0375 * steps
			SILK_REACH:
				config.web_maximum_length *= 1.0 + 0.00625 * steps
			IMPACT_SHELL:
				config.surface_bounce_max_impact_speed += 12.5 * steps
			ELASTIC_GUARD:
				config.surface_bounce_retention = minf(
					0.72,
					config.surface_bounce_retention + (1.0 / 120.0) * steps,
				)


static func _instantiate_track(
	profile_id: StringName,
	template: Dictionary,
	scope: StringName,
) -> Dictionary:
	var item := template.duplicate(true)
	item["id"] = StringName("%s_%s" % [profile_id, template["suffix"]])
	item["profile"] = profile_id
	item["scope"] = scope
	item["breakthrough_interval"] = BREAKTHROUGH_INTERVAL
	item.erase("suffix")
	return item

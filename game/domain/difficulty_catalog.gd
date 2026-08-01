extends RefCounted
class_name DifficultyCatalog
## Difficulty modes: Relaxed, Standard, Harsh.
##
## D-0033 settled the shape. A mode changes **which content the stream may
## serve** and **how much recovery the player gets** — never the physics. The
## one owner-approved preset stays authoritative for every mode, so the swing
## feels identical in all three and only the course around it moves.
##
## That boundary is not a convention here, it is enforced: `PHYSICS_FIELDS`
## lists every value a mode must never touch, `CONTENT_FIELDS` lists the ones
## it may, and a contract applies each mode to a fresh config and asserts the
## physics fields come out bit-identical to Standard's. Adding a knob to the
## wrong list fails the suite.
##
## Standard is the approved preset unmodified — its override set is empty by
## construction, not by coincidence, so "Standard == baseline" cannot drift.

const MODE_RELAXED := &"relaxed"
const MODE_STANDARD := &"standard"
const MODE_HARSH := &"harsh"

## Every value a difficulty mode may never move. The approved `balanced_baseline`
## tuning: gravity, drive, speed curve, web, reel, Burst, Dive, camera, and the
## player's own collision radius. If a mode changed one of these the swing would
## feel different per mode, which is exactly what D-0033 forbids.
const PHYSICS_FIELDS := [
	"gravity", "spider_mass", "horizontal_drive_acceleration",
	"starting_target_speed", "maximum_target_speed", "speed_curve_distance",
	"maximum_horizontal_overspeed", "release_momentum_bonus_speed", "air_drag",
	"web_minimum_length", "web_maximum_length",
	"web_tap_retargets_when_attached", "attachment_cone_degrees",
	"attachment_snap_radius", "attachment_correction_cap",
	"attachment_catch_fraction", "rope_elasticity_allowance", "rope_damping",
	"reel_retraction_rate", "reel_energy_capacity", "reel_drain_rate",
	"reel_regeneration_rate", "reel_empty_lockout",
	"automatic_take_up_enabled", "automatic_take_up_retention",
	"burst_distance_fraction", "burst_minimum_distance",
	"burst_pull_duration", "burst_exit_speed", "burst_tangential_retention",
	"burst_cooldown", "burst_charge_capacity",
	"dive_distance_fraction", "dive_pull_duration", "dive_exit_speed",
	"dive_tangential_retention", "downward_target_threshold",
	"camera_follow_strength", "camera_look_ahead", "player_collision_radius",
	"input_buffer_duration", "lower_world_boundary",
	"camera_left_kill_distance", "death_confirmation_seconds",
	"surface_snap_distance", "pickup_collision_radius",
]

## The sanctioned difficulty surface: obstacle size and gate width (what the
## stream serves), how early hazards and tight corridors appear (when it serves
## it), and the rescue life plus non-lethal rails (how much recovery there is).
## All of these already reach `CourseStream.reset()` or the collision policy;
## none of them is a physics value.
const CONTENT_FIELDS := [
	"course_boundaries_enabled", "course_boundaries_lethal",
	"corridor_contours_enabled", "corridor_clearance_scale",
	"corridor_tight_gap_scale", "tight_corridor_start_distance",
	"middle_hazard_start_distance", "edge_obstacle_scale",
	"floating_obstacle_scale", "gate_opening_scale", "guided_start_enabled",
	"rescue_life_enabled", "rescue_shield_duration",
]

## `records_eligible` drives the authoritative best distance and the region
## checkpoints it unlocks. `leaderboards_eligible` is the future competitive
## surface, and D-0033 reserves it for Standard alone.
##
## Relaxed is excluded from records because its rails are not lethal — a run
## that cannot fall off the course would unlock every checkpoint on its first
## attempt. Harsh keeps records: it is strictly harder than Standard, so a
## distance reached there cheapens nothing. Both still keep their own per-mode
## best, which is the point of separate bests.
const MODES := [
	{
		"id": MODE_RELAXED,
		"name": "RELAXED",
		"order": 0,
		"blurb": "Rails catch you instead of killing you, hazards start "
			+ "later, gaps are wider. Keeps its own best distance; sets no "
			+ "record and unlocks no checkpoints.",
		"records_eligible": false,
		"leaderboards_eligible": false,
		"overrides": {
			"course_boundaries_lethal": false,
			"rescue_shield_duration": 1.40,
			"gate_opening_scale": 1.30,
			"edge_obstacle_scale": 0.80,
			"floating_obstacle_scale": 0.76,
			"corridor_clearance_scale": 1.20,
			"corridor_tight_gap_scale": 1.25,
			"middle_hazard_start_distance": 20000.0,
			"tight_corridor_start_distance": 40000.0,
		},
	},
	{
		"id": MODE_STANDARD,
		"name": "STANDARD",
		"order": 1,
		"blurb": "The approved course, unmodified. The only mode eligible "
			+ "for a leaderboard.",
		"records_eligible": true,
		"leaderboards_eligible": true,
		"overrides": {},
	},
	{
		"id": MODE_HARSH,
		"name": "HARSH",
		"order": 2,
		"blurb": "No rescue life, tighter gaps, hazards from the start. "
			+ "Sets records and unlocks checkpoints; not leaderboard "
			+ "eligible.",
		"records_eligible": true,
		"leaderboards_eligible": false,
		"overrides": {
			"rescue_life_enabled": false,
			"gate_opening_scale": 1.00,
			"edge_obstacle_scale": 1.06,
			"floating_obstacle_scale": 1.02,
			"corridor_clearance_scale": 0.88,
			"corridor_tight_gap_scale": 0.85,
			"middle_hazard_start_distance": 5000.0,
			"tight_corridor_start_distance": 10000.0,
		},
	},
]


static func all_modes() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for mode: Dictionary in MODES:
		result.append(mode.duplicate(true))
	return result


static func mode_for_id(mode_id: StringName) -> Dictionary:
	for mode: Dictionary in MODES:
		if StringName(mode["id"]) == mode_id:
			return mode.duplicate(true)
	return {}


static func has_mode(mode_id: StringName) -> bool:
	return not mode_for_id(mode_id).is_empty()


static func mode_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for mode: Dictionary in MODES:
		result.append(StringName(mode["id"]))
	return result


## Unknown ids resolve to Standard rather than failing: a save naming a mode a
## later build removed must still load and play.
static func resolve(mode_id: StringName) -> StringName:
	return mode_id if has_mode(mode_id) else MODE_STANDARD


static func records_eligible(mode_id: StringName) -> bool:
	var mode := mode_for_id(resolve(mode_id))
	return bool(mode["records_eligible"])


static func leaderboards_eligible(mode_id: StringName) -> bool:
	var mode := mode_for_id(resolve(mode_id))
	return bool(mode["leaderboards_eligible"])


## Apply a mode's content and recovery overrides in place, after the preset and
## any spider/upgrade resolution. Only `CONTENT_FIELDS` are writable — an
## override naming anything else is ignored and reported rather than applied,
## so a typo cannot silently retune the swing.
static func apply_to_config(
	config: SwingConfig,
	mode_id: StringName,
) -> void:
	var mode := mode_for_id(resolve(mode_id))
	var overrides: Dictionary = mode["overrides"]
	for field: String in overrides:
		if not field in CONTENT_FIELDS:
			push_error(
				"[difficulty] mode %s tried to override non-content field %s"
					% [mode["id"], field])
			continue
		config.set(field, overrides[field])

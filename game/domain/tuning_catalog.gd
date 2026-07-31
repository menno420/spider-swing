extends RefCounted
class_name TuningCatalog
## Single source of truth for every owner-facing Swing Laboratory control.
##
## Simulation values remain owned by SwingConfig. This catalog owns only their
## human-readable grouping, safe ranges, step size, and touch-friendly choices.

const CATEGORY_MOVEMENT := &"movement"
const CATEGORY_PACING := &"pacing"
const CATEGORY_ROPE := &"rope"
const CATEGORY_PULLS := &"pulls"
const CATEGORY_COURSE := &"course"
const CATEGORY_ROUTES := &"routes"
const CATEGORY_RUN := &"run"
const CATEGORY_ABILITIES := &"abilities"
const CATEGORY_VISUALS := &"visuals"
const CATEGORY_OVERLAYS := &"overlays"
const CATEGORY_TOOLS := &"tools"
const DEBUG_START_DISTANCE := &"debug_start_m"
const DEBUG_UPGRADE_LEVEL := &"debug_upgrade_level"

const CATEGORIES := [
	{
		"id": CATEGORY_MOVEMENT,
		"label": "MOVEMENT",
		"help": "Weight, forward momentum, reach, and aiming assistance.",
	},
	{
		"id": CATEGORY_PACING,
		"label": "PACING",
		"help": "Starting pace, maximum pace, and how gradually speed grows.",
	},
	{
		"id": CATEGORY_ROPE,
		"label": "ROPE",
		"help": "How attachment, Reel-In, and rope shortening behave.",
	},
	{
		"id": CATEGORY_PULLS,
		"label": "PULLS",
		"help": "Anchor Burst and the separate downward Dive Pull.",
	},
	{
		"id": CATEGORY_COURSE,
		"label": "COURSE",
		"help": "Ceiling/floor rules, obstacle sizes, and the difficulty ramp.",
	},
	{
		"id": CATEGORY_ROUTES,
		"label": "ROUTES",
		"help": "How the solid ceiling and floor shape space around challenges.",
	},
	{
		"id": CATEGORY_RUN,
		"label": "RUN",
		"help": "Opening help, recovery, exact-distance starts, and upgrade tests.",
	},
	{
		"id": CATEGORY_ABILITIES,
		"label": "SPECIAL",
		"help": "Temporary Burst power and Buckler's one-charge rail recovery.",
	},
	{
		"id": CATEGORY_VISUALS,
		"label": "LOOK",
		"help": "Swap environment art without changing any collision shape.",
	},
	{
		"id": CATEGORY_OVERLAYS,
		"label": "OVERLAYS",
		"help": "Reveal optional collision and web-target diagnostics.",
	},
	{
		"id": CATEGORY_TOOLS,
		"label": "TOOLS",
		"help": "Pause, step, record, replay, and export diagnostics.",
	},
]

const PARAMETERS := [
	{
		"id": &"gravity",
		"category": CATEGORY_MOVEMENT,
		"label": "Gravity",
		"help": "How quickly the spider falls.",
		"format": &"number",
		"minimum": 400.0,
		"maximum": 1800.0,
		"step": 40.0,
		"quick": [980.0, 1120.0, 1320.0],
	},
	{
		"id": &"drive",
		"category": CATEGORY_MOVEMENT,
		"label": "Forward drive",
		"help": "How strongly forward speed recovers after slowing down.",
		"format": &"number",
		"minimum": 100.0,
		"maximum": 1000.0,
		"step": 25.0,
		"quick": [410.0, 470.0, 570.0],
	},
	{
		"id": &"web_range",
		"category": CATEGORY_MOVEMENT,
		"label": "Maximum web reach",
		"help": "Farthest solid point a tap can attach to.",
		"format": &"pixels",
		"minimum": 500.0,
		"maximum": 1400.0,
		"step": 50.0,
		"quick": [800.0, 1000.0, 1200.0, 1400.0],
	},
	{
		"id": &"aim_forgiveness",
		"category": CATEGORY_MOVEMENT,
		"label": "Aim forgiveness",
		"help": "How far a tap may miss a solid surface and still connect.",
		"format": &"pixels",
		"minimum": 80.0,
		"maximum": 320.0,
		"step": 10.0,
		"quick": [160.0, 220.0, 280.0, 320.0],
	},
	{
		"id": &"start_speed",
		"category": CATEGORY_PACING,
		"label": "Starting speed",
		"help": "Forward target speed at the beginning of a run.",
		"format": &"speed",
		"minimum": 240.0,
		"maximum": 520.0,
		"step": 20.0,
		"quick": [300.0, 360.0, 420.0, 480.0],
	},
	{
		"id": &"maximum_speed",
		"category": CATEGORY_PACING,
		"label": "Maximum speed",
		"help": "Forward target speed once the full learning curve is complete.",
		"format": &"speed",
		"minimum": 500.0,
		"maximum": 1000.0,
		"step": 20.0,
		"quick": [640.0, 760.0, 880.0, 1000.0],
	},
	{
		"id": &"full_speed_m",
		"category": CATEGORY_PACING,
		"label": "Full speed reached",
		"help": "Distance where maximum speed is finally reached; default is 5,000 m.",
		"format": &"meters",
		"minimum": 20000.0,
		"maximum": 80000.0,
		"step": 5000.0,
		"quick": [30000.0, 50000.0, 65000.0, 80000.0],
	},
	{
		"id": &"reel_rate",
		"category": CATEGORY_ROPE,
		"label": "Reel-In speed",
		"help": "How quickly holding REEL shortens the rope.",
		"format": &"speed",
		"minimum": 80.0,
		"maximum": 720.0,
		"step": 20.0,
		"quick": [260.0, 320.0, 400.0, 440.0],
	},
	{
		"id": &"reel_capacity_seconds",
		"category": CATEGORY_ROPE,
		"label": "Full Reel time",
		"help": "Continuous hold time available from a full Reel meter.",
		"format": &"seconds",
		"minimum": 0.8,
		"maximum": 4.0,
		"step": 0.2,
		"quick": [1.0, 1.5, 2.0, 3.33],
	},
	{
		"id": &"auto_take_up",
		"category": CATEGORY_ROPE,
		"label": "Keep shortened rope",
		"help": "Retains inward slack as the spider catches up, without boosting.",
		"format": &"toggle",
		"minimum": 0.0,
		"maximum": 1.0,
		"step": 1.0,
		"quick": [0.0, 1.0],
	},
	{
		"id": &"take_up_pct",
		"category": CATEGORY_ROPE,
		"label": "Shortening retained",
		"help": "How much naturally gained shorter rope length is kept.",
		"format": &"percent",
		"minimum": 0.0,
		"maximum": 1.0,
		"step": 0.05,
		"quick": [0.70, 0.85, 1.0],
	},
	{
		"id": &"attach_catch_pct",
		"category": CATEGORY_MOVEMENT,
		"label": "Attach catch-up",
		"help": "Immediate rope shortening allowed when a web first connects.",
		"format": &"percent",
		"minimum": 0.0,
		"maximum": 0.20,
		"step": 0.01,
		"quick": [0.0, 0.08, 0.12, 0.20],
	},
	{
		"id": &"rope_damping",
		"category": CATEGORY_ROPE,
		"label": "Rope damping",
		"help": "How much swinging vibration the rope removes.",
		"format": &"decimal",
		"minimum": 0.0,
		"maximum": 0.30,
		"step": 0.01,
		"quick": [0.0, 0.035, 0.08, 0.15],
	},
	{
		"id": &"tap_retarget",
		"category": CATEGORY_ROPE,
		"label": "Tap retargets web",
		"help": "When attached, a new valid tap replaces the current web.",
		"format": &"toggle",
		"minimum": 0.0,
		"maximum": 1.0,
		"step": 1.0,
		"quick": [0.0, 1.0],
	},
	{
		"id": &"burst_pull_pct",
		"category": CATEGORY_PULLS,
		"label": "Anchor Burst distance",
		"help": "Share of the distance crossed toward an upper/forward target.",
		"format": &"percent",
		"minimum": 0.10,
		"maximum": 0.80,
		"step": 0.05,
		"quick": [0.40, 0.50, 0.60, 0.70],
	},
	{
		"id": &"burst_minimum",
		"category": CATEGORY_PULLS,
		"label": "Minimum Burst travel",
		"help": "Minimum useful movement from a valid close-range Anchor Burst.",
		"format": &"pixels",
		"minimum": 20.0,
		"maximum": 260.0,
		"step": 10.0,
		"quick": [60.0, 80.0, 120.0, 180.0],
	},
	{
		"id": &"burst_duration",
		"category": CATEGORY_PULLS,
		"label": "Anchor Burst time",
		"help": "How long the Burst movement takes.",
		"format": &"seconds",
		"minimum": 0.08,
		"maximum": 0.40,
		"step": 0.02,
		"quick": [0.12, 0.20, 0.28],
	},
	{
		"id": &"pull_cooldown",
		"category": CATEGORY_PULLS,
		"label": "Burst cooldown",
		"help": "Wait between Anchor Bursts; it does not limit Dive Pull.",
		"format": &"seconds",
		"minimum": 0.30,
		"maximum": 2.50,
		"step": 0.10,
		"quick": [0.75, 1.0, 1.65, 2.0],
	},
	{
		"id": &"burst_charges",
		"category": CATEGORY_ABILITIES,
		"label": "Stored Bursts",
		"help": "How many Anchor Bursts can be held ready; the cooldown refills one at a time.",
		"format": &"number",
		"minimum": 1.0,
		"maximum": 3.0,
		"step": 1.0,
		"quick": [1.0, 2.0],
	},
	{
		"id": &"dive_pull_pct",
		"category": CATEGORY_PULLS,
		"label": "Downward pull distance",
		"help": "Share of the distance crossed by the one-shot Dive Pull.",
		"format": &"percent",
		"minimum": 0.05,
		"maximum": 0.60,
		"step": 0.05,
		"quick": [0.30, 0.35, 0.40, 0.50],
	},
	{
		"id": &"dive_duration",
		"category": CATEGORY_PULLS,
		"label": "Downward pull time",
		"help": "How long the one-shot Dive Pull takes.",
		"format": &"seconds",
		"minimum": 0.08,
		"maximum": 0.32,
		"step": 0.02,
		"quick": [0.10, 0.16, 0.24],
	},
	{
		"id": &"course_rails",
		"category": CATEGORY_COURSE,
		"label": "Ceiling and floor",
		"help": "Keeps solid upper and lower surfaces in the course.",
		"format": &"toggle",
		"minimum": 0.0,
		"maximum": 1.0,
		"step": 1.0,
		"quick": [0.0, 1.0],
	},
	{
		"id": &"lethal_rails",
		"category": CATEGORY_COURSE,
		"label": "Lethal ceiling and floor",
		"help": "Touching either solid boundary ends the run.",
		"format": &"toggle",
		"minimum": 0.0,
		"maximum": 1.0,
		"step": 1.0,
		"quick": [0.0, 1.0],
	},
	{
		"id": &"mid_hazard_m",
		"category": CATEGORY_COURSE,
		"label": "Floating hazards begin",
		"help": "Distance before obstacles may enter the middle lane.",
		"format": &"meters",
		"minimum": 2500.0,
		"maximum": 20000.0,
		"step": 1000.0,
		"quick": [5000.0, 10000.0, 15000.0, 20000.0],
	},
	{
		"id": &"edge_obstacle_size",
		"category": CATEGORY_COURSE,
		"label": "Edge obstacle size",
		"help": "Size of leaves and shapes growing from ceiling or floor.",
		"format": &"percent",
		"minimum": 0.70,
		"maximum": 1.15,
		"step": 0.02,
		"quick": [0.85, 0.94, 1.0, 1.08],
	},
	{
		"id": &"floating_obstacle_size",
		"category": CATEGORY_COURSE,
		"label": "Floating obstacle size",
		"help": "Overall size of detached middle-lane challenges.",
		"format": &"percent",
		"minimum": 0.70,
		"maximum": 1.15,
		"step": 0.02,
		"quick": [0.80, 0.90, 1.0, 1.08],
	},
	{
		"id": &"gate_opening_size",
		"category": CATEGORY_COURSE,
		"label": "Gate opening size",
		"help": "Extra clear space between the upper and lower root-gate arcs.",
		"format": &"percent",
		"minimum": 0.80,
		"maximum": 1.40,
		"step": 0.04,
		"quick": [1.0, 1.12, 1.24, 1.36],
	},
	{
		"id": &"corridor_contours",
		"category": CATEGORY_ROUTES,
		"label": "Shaped ceiling and floor",
		"help": "Moves the solid rails around obstacles instead of keeping a flat tunnel.",
		"format": &"toggle",
		"minimum": 0.0,
		"maximum": 1.0,
		"step": 1.0,
		"quick": [0.0, 1.0],
	},
	{
		"id": &"route_clearance",
		"category": CATEGORY_ROUTES,
		"label": "Bypass room",
		"help": "Extra ceiling or floor space around most obstacle routes.",
		"format": &"percent",
		"minimum": 0.50,
		"maximum": 1.50,
		"step": 0.10,
		"quick": [0.70, 1.0, 1.20, 1.50],
	},
	{
		"id": &"tight_gap_size",
		"category": CATEGORY_ROUTES,
		"label": "Small-gap opening",
		"help": "Height of later rail-only passages where both sides close inward.",
		"format": &"percent",
		"minimum": 0.75,
		"maximum": 1.40,
		"step": 0.05,
		"quick": [0.85, 1.0, 1.15, 1.30],
	},
	{
		"id": &"tight_corridor_m",
		"category": CATEGORY_ROUTES,
		"label": "Inward rails begin",
		"help": "Distance before any ceiling/floor pattern may narrow toward the route.",
		"format": &"meters",
		"minimum": 10000.0,
		"maximum": 80000.0,
		"step": 2500.0,
		"quick": [10000.0, 20000.0, 30000.0, 50000.0],
	},
	{
		"id": &"guided_start",
		"category": CATEGORY_RUN,
		"label": "Start already swinging",
		"help": "Begins on a normal web; early input can still replace it.",
		"format": &"toggle",
		"minimum": 0.0,
		"maximum": 1.0,
		"step": 1.0,
		"quick": [0.0, 1.0],
	},
	{
		"id": &"rescue_life",
		"category": CATEGORY_RUN,
		"label": "One rescue per run",
		"help": "The first lethal mistake triggers a safe silk recovery.",
		"format": &"toggle",
		"minimum": 0.0,
		"maximum": 1.0,
		"step": 1.0,
		"quick": [0.0, 1.0],
	},
	{
		"id": DEBUG_START_DISTANCE,
		"category": CATEGORY_RUN,
		"label": "Start at exact distance",
		"help": "Type meters and press Enter, or adjust; the debug run awards nothing.",
		"format": &"meters",
		"minimum": 0.0,
		"maximum": 1000000.0,
		"step": 1000.0,
		"quick": [0.0, 50000.0, 100000.0, 250000.0],
	},
	{
		"id": DEBUG_UPGRADE_LEVEL,
		"category": CATEGORY_RUN,
		"label": "Upgrade test level",
		"help": "Resolves every selected-spider track without changing ownership.",
		"format": &"debug_level",
		"minimum": -1.0,
		"maximum": 20.0,
		"step": 1.0,
		"quick": [-1.0, 0.0, 10.0, 20.0],
	},
	{
		"id": &"boost_duration",
		"category": CATEGORY_ABILITIES,
		"label": "Burst Frenzy time",
		"help": "How long a boost removes Anchor Burst cooldown.",
		"format": &"seconds",
		"minimum": 1.0,
		"maximum": 10.0,
		"step": 0.50,
		"quick": [2.0, 4.0, 6.0, 8.0],
	},
	{
		"id": &"impact_shell",
		"category": CATEGORY_ABILITIES,
		"label": "One-charge rail bounce",
		"help": "Allows one moderate ceiling/floor hit; upper web contact rearms it.",
		"format": &"toggle",
		"minimum": 0.0,
		"maximum": 1.0,
		"step": 1.0,
		"quick": [0.0, 1.0],
	},
	{
		"id": &"safe_impact_speed",
		"category": CATEGORY_ABILITIES,
		"label": "Maximum safe impact",
		"help": "Fastest inward rail hit the charged shell can survive.",
		"format": &"speed",
		"minimum": 300.0,
		"maximum": 1100.0,
		"step": 40.0,
		"quick": [520.0, 680.0, 840.0, 1000.0],
	},
	{
		"id": &"bounce_strength",
		"category": CATEGORY_ABILITIES,
		"label": "Rail bounce strength",
		"help": "Share of inward impact speed returned away from the rail.",
		"format": &"percent",
		"minimum": 0.20,
		"maximum": 0.80,
		"step": 0.05,
		"quick": [0.30, 0.42, 0.55, 0.70],
	},
]


static func category_count() -> int:
	return CATEGORIES.size()


static func tools_category_index() -> int:
	return CATEGORIES.size() - 1


static func category(index: int) -> Dictionary:
	if index < 0 or index >= CATEGORIES.size():
		return CATEGORIES[0].duplicate(true)
	return CATEGORIES[index].duplicate(true)


static func category_index(category_id: StringName) -> int:
	for index in range(CATEGORIES.size()):
		if StringName(CATEGORIES[index]["id"]) == category_id:
			return index
	return 0


static func parameter_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for item: Dictionary in PARAMETERS:
		ids.append(StringName(item["id"]))
	return ids


static func parameters_for_category(category_id: StringName) -> Array[Dictionary]:
	var matches: Array[Dictionary] = []
	for item: Dictionary in PARAMETERS:
		if StringName(item["category"]) == category_id:
			matches.append(item.duplicate(true))
	return matches


static func descriptor(parameter: StringName) -> Dictionary:
	for item: Dictionary in PARAMETERS:
		if StringName(item["id"]) == parameter:
			return item.duplicate(true)
	return {}


static func clamp_value(parameter: StringName, value: float) -> float:
	var item := descriptor(parameter)
	if item.is_empty():
		return value
	return clampf(
		value,
		float(item["minimum"]),
		float(item["maximum"]),
	)


static func step_for(parameter: StringName) -> float:
	var item := descriptor(parameter)
	return float(item.get("step", 0.0))

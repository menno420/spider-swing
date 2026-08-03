extends RefCounted
class_name CourseDifficultyProfile
## Pure mode profile composed with `CoursePressure` and `CourseAxisEnvelope`.
##
## [D-0055] makes Standard the identity profile and derives Relaxed/Harsh on
## selection axes rather than movement. Every function here is pure in its
## declared inputs; no distance appears because `CoursePressure` already owns
## distance -> amount. Course selection supplies mode as one more deterministic
## input alongside seed, chunk and pressure.

const SELECTION_STANDARD := &"standard"
const SELECTION_LEGIBLE := &"legible"
const SELECTION_VARIABLE := &"variable"

const PROFILES := [
	{
		"id": DifficultyCatalog.MODE_RELAXED,
		"legal_continuations": 2,
		"recovery_interval_delta": -1,
		"repetition_cooldown_chunks": 1,
		"admission_pressure_scale": 0.82,
		"admission_pressure_offset": 0.0,
		"multi_obstacle_pressure_delta": 0.030,
		"reaction_spacing_scale": 1.25,
		"selection_style": SELECTION_LEGIBLE,
	},
	{
		"id": DifficultyCatalog.MODE_STANDARD,
		"legal_continuations": 3,
		"recovery_interval_delta": 0,
		"repetition_cooldown_chunks": 2,
		"admission_pressure_scale": 1.0,
		"admission_pressure_offset": 0.0,
		"multi_obstacle_pressure_delta": 0.0,
		"reaction_spacing_scale": 1.0,
		"selection_style": SELECTION_STANDARD,
	},
	{
		"id": DifficultyCatalog.MODE_HARSH,
		"legal_continuations": 4,
		"recovery_interval_delta": 1,
		"repetition_cooldown_chunks": 3,
		"admission_pressure_scale": 1.10,
		"admission_pressure_offset": 0.035,
		"multi_obstacle_pressure_delta": -0.010,
		"reaction_spacing_scale": 0.90,
		"selection_style": SELECTION_VARIABLE,
	},
]

const PROFILE_RECOVERY_INTERVAL_MINIMUM := 2
const PROFILE_RECOVERY_INTERVAL_MAXIMUM := 6


static func all_profiles() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in PROFILES:
		result.append(entry.duplicate(true))
	return result


static func for_mode(mode_id: StringName) -> Dictionary:
	var resolved := DifficultyCatalog.resolve(mode_id)
	for entry: Dictionary in PROFILES:
		if StringName(entry["id"]) == resolved:
			return entry.duplicate(true)
	return PROFILES[1].duplicate(true)


static func legal_continuations(mode_id: StringName, pool_size: int) -> int:
	if pool_size <= 0:
		return 0
	return mini(
		pool_size,
		int(for_mode(mode_id).get("legal_continuations", 3)),
	)


static func repetition_cooldown_chunks(mode_id: StringName) -> int:
	return int(for_mode(mode_id).get("repetition_cooldown_chunks", 2))


## Mode-shaped pressure for authored-rung admission. Standard is the identity;
## the other modes can only transform the one scalar, never introduce a second
## distance law.
static func admission_pressure(mode_id: StringName, pressure: float) -> float:
	var profile := for_mode(mode_id)
	return clampf(
		clampf(pressure, 0.0, 1.0) *
			float(profile.get("admission_pressure_scale", 1.0)) +
			float(profile.get("admission_pressure_offset", 0.0)),
		0.0,
		1.0,
	)


static func recovery_interval(mode_id: StringName, pressure: float) -> int:
	return clampi(
		CourseAxisEnvelope.recovery_interval(pressure) +
			int(for_mode(mode_id).get("recovery_interval_delta", 0)),
		PROFILE_RECOVERY_INTERVAL_MINIMUM,
		PROFILE_RECOVERY_INTERVAL_MAXIMUM,
	)


## Profile cadence, preserving Standard byte-for-byte by delegating to the
## existing envelope implementation. The transition guard prevents adjacent
## open chunks when an interval changes.
static func is_recovery_chunk(
	mode_id: StringName,
	chunk_index: int,
	pressure: float,
	previous_pressure: float = -1.0,
) -> bool:
	if DifficultyCatalog.resolve(mode_id) == DifficultyCatalog.MODE_STANDARD:
		return CourseAxisEnvelope.is_recovery_chunk(
			chunk_index, pressure, previous_pressure)
	if not _cadence_fires(mode_id, chunk_index, pressure):
		return false
	if chunk_index <= 0:
		return true
	var prior := pressure if previous_pressure < 0.0 else previous_pressure
	return not _cadence_fires(mode_id, chunk_index - 1, prior)


static func _cadence_fires(
	mode_id: StringName,
	chunk_index: int,
	pressure: float,
) -> bool:
	var interval := recovery_interval(mode_id, pressure)
	return interval > 0 and posmod(chunk_index, interval) == interval - 1


static func multi_obstacle_admitted(
	mode_id: StringName,
	pressure: float,
) -> bool:
	var threshold := clampf(
		CourseAxisEnvelope.MULTI_OBSTACLE_PRESSURE +
			float(for_mode(mode_id).get("multi_obstacle_pressure_delta", 0.0)),
		0.0,
		1.0,
	)
	return pressure >= threshold


## Scale only the authored x-distance between sequential opposite-side
## commitments. The geometry owners apply this scalar to their own offsets, so
## the profile shapes reaction time without owning or duplicating geometry.
## Standard's identity value is what keeps its existing placements exact.
static func reaction_spacing_scale(mode_id: StringName) -> float:
	return float(for_mode(mode_id).get("reaction_spacing_scale", 1.0))


## Select inside a bounded legal-continuation window around Standard's exact
## seeded choice. Standard returns that index unchanged. Relaxed takes the
## lowest authored rung in its two-choice window with a stable tie-break; Harsh
## takes the highest rung in a four-choice window and varies ties by seed/chunk.
## A non-empty input always yields a valid index.
static func select_index(
	mode_id: StringName,
	pool: Array,
	standard_index: int,
	chunk_index: int,
	course_seed: int,
	region_index: int,
) -> int:
	if pool.is_empty():
		return -1
	var size := pool.size()
	var base := posmod(standard_index, size)
	var resolved := DifficultyCatalog.resolve(mode_id)
	if resolved == DifficultyCatalog.MODE_STANDARD:
		return base
	var count := legal_continuations(resolved, size)
	var candidates: Array[int] = []
	for offset in count:
		candidates.append(posmod(base + offset, size))
	var target_label := 2147483647 \
		if resolved == DifficultyCatalog.MODE_RELAXED else -2147483648
	var matching: Array[int] = []
	for index: int in candidates:
		var label := int((pool[index] as Dictionary).get("difficulty", 0))
		var better := label < target_label \
			if resolved == DifficultyCatalog.MODE_RELAXED else label > target_label
		if better:
			target_label = label
			matching = [index]
		elif label == target_label:
			matching.append(index)
	if matching.is_empty():
		return base
	if resolved == DifficultyCatalog.MODE_RELAXED:
		return matching[posmod(course_seed + region_index, matching.size())]
	var variable := course_seed * 31 + chunk_index * 17 + region_index * 13
	return matching[posmod(variable, matching.size())]

extends RefCounted
class_name RunRecord
## One immutable-by-convention, local-only record paired with a RunSettlement.
##
## This is evidence about a completed run, not a leaderboard entry. It retains
## the authoritative facts needed to compare runs while leaving ranking and
## remote-trust policy deliberately undefined.

const SCHEMA_VERSION := 2

var record_id: String = ""
var settlement_id: String = ""
var build_version: String = ""
var android_version_code: int = 0
var runtime_platform: String = ""
var swing_config_schema_version: int = 0
var trace_format: String = ""
var course_seed: int = 0
var run_mode: StringName = &"unknown"
var difficulty_id: StringName = DifficultyCatalog.MODE_STANDARD
var spider_profile_id: StringName = SpiderCatalog.CLASSIC
var resolved_upgrade_levels: Dictionary = {}
var preset_id: StringName = SwingConfig.PRESET_BALANCED
var start_distance_pixels: float = 0.0
var rewards_eligible: bool = false
var records_eligible: bool = false
var leaderboards_eligible: bool = false
var attempt_ordinal: int = 0
var lifetime_completed_run_ordinal: int = 0
## Assigned by RunRecordLedger so first-session prompt policy survives restarts
## and can distinguish the first three eligible human runs from later play.
var feedback_eligible_run_ordinal: int = 0
var input_source: StringName = &"human"
var configuration_kind: StringName = &"standard"
var configuration_details: Dictionary = {}

var final_distance_pixels: float = 0.0
var travelled_distance_pixels: float = 0.0
var active_duration_seconds: float = 0.0
var mean_forward_speed_pixels_per_second: float = 0.0
var maximum_forward_speed_pixels_per_second: float = 0.0
var above_reference_speed_share: float = 0.0

var successful_web_attachments: int = 0
var reel_activations: int = 0
var reel_held_seconds: float = 0.0
var reel_empty_events: int = 0
var burst_activations: int = 0
var dive_activations: int = 0

var terminal_outcome: StringName = &"death"
var death_cause: StringName = &"unknown"
var final_region_id: StringName = CourseRegionCatalog.BRAMBLE_CANOPY
var rescue_consumed: bool = false
var flies_collected: int = 0
var flies_per_kilometre: float = 0.0
var campaign_level_id: StringName = &""


static func create(
	settlement: RunSettlement,
	metrics: Dictionary,
	context: Dictionary,
	terminal: StringName = &"death",
) -> RunRecord:
	var record := RunRecord.new()
	record.settlement_id = settlement.settlement_id
	record.record_id = str(context.get("record_id", settlement.settlement_id))
	if record.record_id.is_empty():
		record.record_id = settlement.settlement_id
	record.build_version = str(context.get("build_version", "unknown"))
	record.android_version_code = maxi(
		0, int(context.get("android_version_code", 0)))
	record.runtime_platform = str(context.get("runtime_platform", "unknown"))
	record.swing_config_schema_version = maxi(
		0, int(context.get("swing_config_schema_version", 0)))
	record.trace_format = str(context.get("trace_format", ""))
	record.course_seed = settlement.course_seed
	record.run_mode = settlement.run_mode
	record.difficulty_id = StringName(str(context.get(
		"difficulty_id", DifficultyCatalog.MODE_STANDARD)))
	record.spider_profile_id = StringName(str(context.get(
		"spider_profile_id", SpiderCatalog.CLASSIC)))
	record.resolved_upgrade_levels = _validated_upgrade_levels(
		context.get("resolved_upgrade_levels", {}))
	record.preset_id = StringName(str(context.get(
		"preset_id", SwingConfig.PRESET_BALANCED)))
	record.start_distance_pixels = maxf(0.0, settlement.start_distance_pixels)
	record.rewards_eligible = settlement.rewards_eligible
	record.records_eligible = settlement.records_eligible
	record.leaderboards_eligible = settlement.leaderboards_eligible
	record.attempt_ordinal = maxi(0, int(context.get("attempt_ordinal", 0)))
	record.input_source = StringName(str(context.get("input_source", "human")))
	record.configuration_kind = StringName(str(context.get(
		"configuration_kind", "standard")))
	var details: Variant = context.get("configuration_details", {})
	record.configuration_details = (
		(details as Dictionary).duplicate(true)
		if details is Dictionary else {}
	)

	record.final_distance_pixels = maxf(0.0, settlement.distance_pixels)
	record.travelled_distance_pixels = maxf(
		0.0,
		record.final_distance_pixels - record.start_distance_pixels,
	)
	record.active_duration_seconds = _nonnegative_float(
		metrics.get("active_duration_seconds", 0.0))
	record.mean_forward_speed_pixels_per_second = _nonnegative_float(
		metrics.get("mean_forward_speed_pixels_per_second", 0.0))
	record.maximum_forward_speed_pixels_per_second = _nonnegative_float(
		metrics.get("maximum_forward_speed_pixels_per_second", 0.0))
	record.above_reference_speed_share = clampf(
		_finite_float(metrics.get("above_reference_speed_share", 0.0)),
		0.0,
		1.0,
	)
	record.successful_web_attachments = maxi(
		0, int(metrics.get("successful_web_attachments", 0)))
	record.reel_activations = maxi(0, int(metrics.get("reel_activations", 0)))
	record.reel_held_seconds = _nonnegative_float(
		metrics.get("reel_held_seconds", 0.0))
	record.reel_empty_events = maxi(
		0, int(metrics.get("reel_empty_events", 0)))
	record.burst_activations = maxi(
		0, int(metrics.get("burst_activations", 0)))
	record.dive_activations = maxi(
		0, int(metrics.get("dive_activations", 0)))
	record.terminal_outcome = terminal
	record.death_cause = settlement.death_cause
	record.final_region_id = StringName(CourseRegionCatalog.region_for_distance(
		record.final_distance_pixels).get("id", CourseRegionCatalog.BRAMBLE_CANOPY))
	record.rescue_consumed = bool(metrics.get("rescue_consumed", false))
	record.flies_collected = maxi(0, settlement.flies_collected)
	var travelled_kilometres := record.travelled_distance_pixels / (
		CourseRegionCatalog.PIXELS_PER_METRE * 1000.0)
	record.flies_per_kilometre = (
		0.0
		if travelled_kilometres <= 0.0
		else float(record.flies_collected) / travelled_kilometres
	)
	record.campaign_level_id = settlement.campaign_level_id
	return record


static func from_dictionary(data: Dictionary) -> RunRecord:
	var source_schema := int(data.get("schema_version", 1))
	if source_schema < 1 or source_schema > SCHEMA_VERSION:
		return null
	var id := str(data.get("record_id", ""))
	if id.is_empty():
		return null
	var record := RunRecord.new()
	record.record_id = id
	record.settlement_id = str(data.get("settlement_id", id))
	if record.settlement_id.is_empty():
		return null
	record.build_version = str(data.get("build_version", "unknown"))
	record.android_version_code = maxi(0, int(data.get("android_version_code", 0)))
	record.runtime_platform = str(data.get("runtime_platform", "unknown"))
	record.swing_config_schema_version = maxi(
		0, int(data.get("swing_config_schema_version", 0)))
	record.trace_format = str(data.get("trace_format", ""))
	record.course_seed = int(data.get("course_seed", 0))
	record.run_mode = StringName(str(data.get("run_mode", "unknown")))
	record.difficulty_id = StringName(str(data.get(
		"difficulty_id", DifficultyCatalog.MODE_STANDARD)))
	record.spider_profile_id = StringName(str(data.get(
		"spider_profile_id", SpiderCatalog.CLASSIC)))
	record.resolved_upgrade_levels = _validated_upgrade_levels(
		data.get("resolved_upgrade_levels", {}))
	record.preset_id = StringName(str(data.get(
		"preset_id", SwingConfig.PRESET_BALANCED)))
	record.start_distance_pixels = _nonnegative_float(
		data.get("start_distance_pixels", 0.0))
	record.rewards_eligible = bool(data.get("rewards_eligible", false))
	record.records_eligible = bool(data.get("records_eligible", false))
	record.leaderboards_eligible = bool(data.get("leaderboards_eligible", false))
	record.attempt_ordinal = maxi(0, int(data.get("attempt_ordinal", 0)))
	record.lifetime_completed_run_ordinal = maxi(
		0, int(data.get("lifetime_completed_run_ordinal", 0)))
	record.feedback_eligible_run_ordinal = maxi(
		0, int(data.get("feedback_eligible_run_ordinal", 0)))
	record.input_source = StringName(str(data.get("input_source", "unknown")))
	record.configuration_kind = StringName(str(data.get(
		"configuration_kind", "unknown")))
	var details: Variant = data.get("configuration_details", {})
	record.configuration_details = (
		(details as Dictionary).duplicate(true)
		if details is Dictionary else {}
	)
	record.final_distance_pixels = _nonnegative_float(
		data.get("final_distance_pixels", 0.0))
	record.travelled_distance_pixels = _nonnegative_float(data.get(
		"travelled_distance_pixels",
		maxf(0.0, record.final_distance_pixels - record.start_distance_pixels),
	))
	record.active_duration_seconds = _nonnegative_float(
		data.get("active_duration_seconds", 0.0))
	record.mean_forward_speed_pixels_per_second = _nonnegative_float(
		data.get("mean_forward_speed_pixels_per_second", 0.0))
	record.maximum_forward_speed_pixels_per_second = _nonnegative_float(
		data.get("maximum_forward_speed_pixels_per_second", 0.0))
	record.above_reference_speed_share = clampf(_finite_float(
		data.get("above_reference_speed_share", 0.0)), 0.0, 1.0)
	record.successful_web_attachments = maxi(
		0, int(data.get("successful_web_attachments", 0)))
	record.reel_activations = maxi(0, int(data.get("reel_activations", 0)))
	record.reel_held_seconds = _nonnegative_float(
		data.get("reel_held_seconds", 0.0))
	record.reel_empty_events = maxi(0, int(data.get("reel_empty_events", 0)))
	record.burst_activations = maxi(0, int(data.get("burst_activations", 0)))
	record.dive_activations = maxi(0, int(data.get("dive_activations", 0)))
	record.terminal_outcome = StringName(str(data.get(
		"terminal_outcome", "death")))
	record.death_cause = StringName(str(data.get("death_cause", "unknown")))
	record.final_region_id = StringName(str(data.get(
		"final_region_id", CourseRegionCatalog.BRAMBLE_CANOPY)))
	record.rescue_consumed = bool(data.get("rescue_consumed", false))
	record.flies_collected = maxi(0, int(data.get("flies_collected", 0)))
	record.flies_per_kilometre = _nonnegative_float(
		data.get("flies_per_kilometre", 0.0))
	record.campaign_level_id = StringName(str(data.get("campaign_level_id", "")))
	return record


func copy() -> RunRecord:
	return RunRecord.from_dictionary(to_dictionary())


func is_first_session_feedback_eligible() -> bool:
	return records_eligible and input_source == &"human" and \
		configuration_kind == &"standard" and terminal_outcome == &"death" and \
		start_distance_pixels <= 0.001 and \
		DifficultyCatalog.has_mode(difficulty_id)


func to_dictionary() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"record_id": record_id,
		"settlement_id": settlement_id,
		"build_version": build_version,
		"android_version_code": android_version_code,
		"runtime_platform": runtime_platform,
		"swing_config_schema_version": swing_config_schema_version,
		"trace_format": trace_format,
		"course_seed": course_seed,
		"run_mode": str(run_mode),
		"difficulty_id": str(difficulty_id),
		"spider_profile_id": str(spider_profile_id),
		"resolved_upgrade_levels": resolved_upgrade_levels.duplicate(true),
		"preset_id": str(preset_id),
		"start_distance_pixels": start_distance_pixels,
		"rewards_eligible": rewards_eligible,
		"records_eligible": records_eligible,
		"leaderboards_eligible": leaderboards_eligible,
		"attempt_ordinal": attempt_ordinal,
		"lifetime_completed_run_ordinal": lifetime_completed_run_ordinal,
		"feedback_eligible_run_ordinal": feedback_eligible_run_ordinal,
		"input_source": str(input_source),
		"configuration_kind": str(configuration_kind),
		"configuration_details": configuration_details.duplicate(true),
		"final_distance_pixels": final_distance_pixels,
		"travelled_distance_pixels": travelled_distance_pixels,
		"active_duration_seconds": active_duration_seconds,
		"mean_forward_speed_pixels_per_second":
			mean_forward_speed_pixels_per_second,
		"maximum_forward_speed_pixels_per_second":
			maximum_forward_speed_pixels_per_second,
		"above_reference_speed_share": above_reference_speed_share,
		"successful_web_attachments": successful_web_attachments,
		"reel_activations": reel_activations,
		"reel_held_seconds": reel_held_seconds,
		"reel_empty_events": reel_empty_events,
		"burst_activations": burst_activations,
		"dive_activations": dive_activations,
		"terminal_outcome": str(terminal_outcome),
		"death_cause": str(death_cause),
		"final_region_id": str(final_region_id),
		"rescue_consumed": rescue_consumed,
		"flies_collected": flies_collected,
		"flies_per_kilometre": flies_per_kilometre,
		"campaign_level_id": str(campaign_level_id),
	}


static func _validated_upgrade_levels(raw: Variant) -> Dictionary:
	var result := {}
	if not raw is Dictionary:
		return result
	for raw_key: Variant in raw as Dictionary:
		var upgrade_id := StringName(str(raw_key))
		if SpiderCatalog.upgrade(upgrade_id).is_empty():
			continue
		result[str(upgrade_id)] = clampi(
			int((raw as Dictionary)[raw_key]),
			0,
			SpiderCatalog.MAX_UPGRADE_LEVEL,
		)
	return result


static func _finite_float(raw: Variant) -> float:
	var value := float(raw)
	return value if is_finite(value) else 0.0


static func _nonnegative_float(raw: Variant) -> float:
	return maxf(0.0, _finite_float(raw))

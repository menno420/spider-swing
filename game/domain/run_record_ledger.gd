extends RefCounted
class_name RunRecordLedger
## Versioned, bounded local history plus fixed-size lifetime aggregates.

const SCHEMA_VERSION := 1
const HISTORY_LIMIT := 100
const EXPORT_FORMAT := "spider-swing-local-run-evidence@1"

var records: Array[RunRecord] = []
var total_completed_recorded_runs: int = 0
var total_active_duration_seconds: float = 0.0
var total_distance_travelled_pixels: float = 0.0
## Only comparable, records-eligible, zero-start difficulty runs enter this
## fixed set. Practice/debug/Campaign evidence stays visible without competing.
var best_distance_pixels_by_difficulty: Dictionary = {}


static func defaults() -> RunRecordLedger:
	return RunRecordLedger.new()


static func from_dictionary(data: Dictionary) -> RunRecordLedger:
	var source_schema := int(data.get("schema_version", 1))
	if source_schema < 1 or source_schema > SCHEMA_VERSION:
		return null
	var ledger := RunRecordLedger.new()
	ledger.total_completed_recorded_runs = maxi(
		0, int(data.get("total_completed_recorded_runs", 0)))
	ledger.total_active_duration_seconds = _nonnegative_float(
		data.get("total_active_duration_seconds", 0.0))
	ledger.total_distance_travelled_pixels = _nonnegative_float(
		data.get("total_distance_travelled_pixels", 0.0))
	var raw_bests: Variant = data.get("best_distance_pixels_by_difficulty", {})
	if raw_bests is Dictionary:
		for mode_id: StringName in DifficultyCatalog.mode_ids():
			if (raw_bests as Dictionary).has(str(mode_id)):
				ledger.best_distance_pixels_by_difficulty[str(mode_id)] = \
					_nonnegative_float((raw_bests as Dictionary)[str(mode_id)])
	var seen := {}
	var raw_records: Variant = data.get("records", [])
	if raw_records is Array:
		for raw_record: Variant in raw_records:
			if not raw_record is Dictionary:
				continue
			var record := RunRecord.from_dictionary(raw_record as Dictionary)
			if record == null or seen.has(record.record_id):
				continue
			seen[record.record_id] = true
			ledger.records.append(record)
	while ledger.records.size() > HISTORY_LIMIT:
		ledger.records.remove_at(0)
	# A hand-authored or partially migrated schema-1 document may omit lifetime
	# aggregates. Derive the honest minimum from retained records once; persisted
	# aggregate values otherwise survive rolling eviction unchanged.
	if ledger.total_completed_recorded_runs == 0 and not ledger.records.is_empty():
		ledger._derive_lifetime_from_retained_records()
	return ledger


func append_record(record: RunRecord) -> bool:
	if record == null or record.record_id.is_empty() or has_record(record.record_id):
		return false
	var stored := record.copy()
	if stored == null:
		return false
	total_completed_recorded_runs += 1
	stored.lifetime_completed_run_ordinal = total_completed_recorded_runs
	total_active_duration_seconds += stored.active_duration_seconds
	total_distance_travelled_pixels += stored.travelled_distance_pixels
	_update_best(stored)
	records.append(stored)
	while records.size() > HISTORY_LIMIT:
		records.remove_at(0)
	return true


func has_record(record_id: String) -> bool:
	for record: RunRecord in records:
		if record.record_id == record_id:
			return true
	return false


func latest_record() -> RunRecord:
	return null if records.is_empty() else records[-1].copy()


func recent_records_newest_first() -> Array[RunRecord]:
	var result: Array[RunRecord] = []
	for index in range(records.size() - 1, -1, -1):
		result.append(records[index].copy())
	return result


func best_distance_for_difficulty(mode_id: StringName) -> float:
	return _nonnegative_float(best_distance_pixels_by_difficulty.get(
		str(DifficultyCatalog.resolve(mode_id)), 0.0))


func copy() -> RunRecordLedger:
	return RunRecordLedger.from_dictionary(to_dictionary())


func export_dictionary() -> Dictionary:
	return {
		"format": EXPORT_FORMAT,
		"local_only": true,
		"transmission": "none",
		"ledger": to_dictionary(),
	}


func to_dictionary() -> Dictionary:
	var encoded: Array[Dictionary] = []
	for record: RunRecord in records:
		encoded.append(record.to_dictionary())
	return {
		"schema_version": SCHEMA_VERSION,
		"history_limit": HISTORY_LIMIT,
		"records": encoded,
		"total_completed_recorded_runs": total_completed_recorded_runs,
		"total_active_duration_seconds": total_active_duration_seconds,
		"total_distance_travelled_pixels": total_distance_travelled_pixels,
		"best_distance_pixels_by_difficulty":
			best_distance_pixels_by_difficulty.duplicate(true),
	}


func _derive_lifetime_from_retained_records() -> void:
	total_active_duration_seconds = 0.0
	total_distance_travelled_pixels = 0.0
	best_distance_pixels_by_difficulty.clear()
	for index in range(records.size()):
		var record := records[index]
		record.lifetime_completed_run_ordinal = index + 1
		total_active_duration_seconds += record.active_duration_seconds
		total_distance_travelled_pixels += record.travelled_distance_pixels
		_update_best(record)
	total_completed_recorded_runs = records.size()


func _update_best(record: RunRecord) -> void:
	if not record.records_eligible or record.start_distance_pixels > 0.001 or \
			record.input_source != &"human" or \
			not DifficultyCatalog.has_mode(record.difficulty_id):
		return
	var key := str(DifficultyCatalog.resolve(record.difficulty_id))
	best_distance_pixels_by_difficulty[key] = maxf(
		_nonnegative_float(best_distance_pixels_by_difficulty.get(key, 0.0)),
		record.final_distance_pixels,
	)


static func _nonnegative_float(raw: Variant) -> float:
	var value := float(raw)
	return maxf(0.0, value) if is_finite(value) else 0.0

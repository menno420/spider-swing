extends RefCounted
class_name DebugTestProfile
## Versioned, player-owned setup for noncompetitive laboratory runs.
##
## This is deliberately separate from PlayerSettings and PlayerProgress:
## ordinary play never reads it, and saving a comparison cannot become an
## upgrade purchase or a competitive result. SaveRepository remains the only
## filesystem writer.

const SCHEMA_VERSION := 1
const SLOT_IDS: Array[StringName] = [&"a", &"b", &"c"]

var working_values: Dictionary = {}
var saved_slots: Dictionary = {}
var override_ids: Array[StringName] = []


static func defaults(
	preset_name: StringName = SwingConfig.PRESET_BALANCED,
) -> DebugTestProfile:
	var profile := DebugTestProfile.new()
	profile.working_values = _preset_values(preset_name)
	return profile


static func defaults_from_config(config: SwingConfig) -> DebugTestProfile:
	var profile := DebugTestProfile.new()
	profile.working_values = _config_values(config)
	return profile


static func from_dictionary(
	data: Dictionary,
	preset_name: StringName = SwingConfig.PRESET_BALANCED,
) -> DebugTestProfile:
	var profile := defaults(preset_name)
	profile.working_values = _validated_values(
		data.get("working_values", {}),
		profile.working_values,
	)
	profile.override_ids = _validated_override_ids(
		data.get("override_ids", []))
	var requested_slots: Variant = data.get("saved_slots", {})
	if requested_slots is Dictionary:
		for slot_id: StringName in SLOT_IDS:
			var slot_key := str(slot_id)
			if not (requested_slots as Dictionary).has(slot_key):
				continue
			var raw_slot: Variant = (requested_slots as Dictionary)[slot_key]
			if raw_slot is Dictionary:
				var slot_dictionary := raw_slot as Dictionary
				var slot_values: Variant = slot_dictionary.get(
					"values", slot_dictionary)
				profile.saved_slots[slot_id] = {
					"values": _validated_values(
						slot_values,
						profile.working_values,
					),
					"override_ids": _validated_override_ids(
						slot_dictionary.get("override_ids", [])),
				}
	return profile


func copy() -> DebugTestProfile:
	return DebugTestProfile.from_dictionary(to_dictionary())


func to_dictionary() -> Dictionary:
	var serialized_slots := {}
	for slot_id: StringName in SLOT_IDS:
		if saved_slots.has(slot_id):
			var slot := saved_slots[slot_id] as Dictionary
			serialized_slots[str(slot_id)] = {
				"values": _serialize_values(slot["values"] as Dictionary),
				"override_ids": _serialize_override_ids(
					slot["override_ids"] as Array),
			}
	return {
		"schema_version": SCHEMA_VERSION,
		"working_values": _serialize_values(working_values),
		"override_ids": _serialize_override_ids(override_ids),
		"saved_slots": serialized_slots,
	}


func value(parameter_id: StringName) -> float:
	if working_values.has(parameter_id):
		return float(working_values[parameter_id])
	return float(_preset_values(SwingConfig.PRESET_BALANCED).get(
		parameter_id,
		0.0,
	))


func set_value(
	parameter_id: StringName,
	requested_value: float,
	explicit_override: bool = true,
) -> bool:
	if parameter_id not in TuningCatalog.parameter_ids():
		return false
	var safe_value := TuningCatalog.clamp_value(parameter_id, requested_value)
	var changed := not is_equal_approx(value(parameter_id), safe_value)
	working_values[parameter_id] = safe_value
	if explicit_override and parameter_id not in [
		TuningCatalog.DEBUG_START_DISTANCE,
		TuningCatalog.DEBUG_UPGRADE_LEVEL,
	] and parameter_id not in override_ids:
		override_ids.append(parameter_id)
		changed = true
	return changed


func replace_resolved_values(
	requested_values: Dictionary,
	baseline_values: Dictionary,
) -> bool:
	var next := _validated_values(requested_values, working_values)
	var next_overrides: Array[StringName] = []
	for parameter_id: StringName in TuningCatalog.parameter_ids():
		if parameter_id in [
			TuningCatalog.DEBUG_START_DISTANCE,
			TuningCatalog.DEBUG_UPGRADE_LEVEL,
		]:
			continue
		if not is_equal_approx(
			float(next.get(parameter_id, 0.0)),
			float(baseline_values.get(parameter_id, 0.0)),
		):
			next_overrides.append(parameter_id)
	var changed := not _values_equal(next, working_values) or \
		not _override_ids_equal(next_overrides, override_ids)
	working_values = next
	override_ids = next_overrides
	return changed


func rebase(baseline_values: Dictionary) -> bool:
	var changed := false
	var validated := _validated_values(baseline_values, working_values)
	for parameter_id: StringName in TuningCatalog.parameter_ids():
		if parameter_id in override_ids or parameter_id in [
			TuningCatalog.DEBUG_START_DISTANCE,
			TuningCatalog.DEBUG_UPGRADE_LEVEL,
		]:
			continue
		var next_value := float(validated.get(parameter_id, value(parameter_id)))
		if not is_equal_approx(value(parameter_id), next_value):
			working_values[parameter_id] = next_value
			changed = true
	return changed


func reset_working(
	preset_name: StringName = SwingConfig.PRESET_BALANCED,
) -> bool:
	var next := _preset_values(preset_name)
	if _values_equal(next, working_values) and override_ids.is_empty():
		return false
	working_values = next
	override_ids.clear()
	return true


func save_slot(slot_id: StringName) -> bool:
	if slot_id not in SLOT_IDS:
		return false
	var next := {
		"values": working_values.duplicate(true),
		"override_ids": override_ids.duplicate(),
	}
	if saved_slots.has(slot_id):
		var current := saved_slots[slot_id] as Dictionary
		if _values_equal(
			current["values"] as Dictionary,
			next["values"] as Dictionary,
		) and _override_ids_equal(
			current["override_ids"] as Array,
			next["override_ids"] as Array,
		):
			return false
	saved_slots[slot_id] = next
	return true


func load_slot(slot_id: StringName) -> bool:
	if slot_id not in SLOT_IDS or not saved_slots.has(slot_id):
		return false
	var slot := saved_slots[slot_id] as Dictionary
	var next := (slot["values"] as Dictionary).duplicate(true)
	var next_overrides := _validated_override_ids(slot["override_ids"])
	if _values_equal(next, working_values) and \
			_override_ids_equal(next_overrides, override_ids):
		return false
	working_values = next
	override_ids = next_overrides
	return true


func has_slot(slot_id: StringName) -> bool:
	return slot_id in SLOT_IDS and saved_slots.has(slot_id)


func slot_difference_count(slot_id: StringName) -> int:
	if not has_slot(slot_id):
		return -1
	var slot := saved_slots[slot_id] as Dictionary
	var slot_values := slot["values"] as Dictionary
	var slot_overrides := _validated_override_ids(slot["override_ids"])
	var changed := 0
	for parameter_id: StringName in TuningCatalog.parameter_ids():
		var is_special := parameter_id in [
			TuningCatalog.DEBUG_START_DISTANCE,
			TuningCatalog.DEBUG_UPGRADE_LEVEL,
		]
		var current_overrides := parameter_id in override_ids
		var saved_overrides := parameter_id in slot_overrides
		# Derived values may legitimately rebase when the selected spider,
		# upgrades, difficulty, or base preset changes. They are not a saved
		# configuration difference unless either side explicitly overrides them.
		if not is_special and not current_overrides and not saved_overrides:
			continue
		if current_overrides != saved_overrides or not is_equal_approx(
				float(slot_values.get(parameter_id, 0.0)),
				value(parameter_id),
		):
			changed += 1
	return changed


func tuning_overrides() -> Dictionary:
	var result := {}
	for parameter_id: StringName in override_ids:
		result[parameter_id] = value(parameter_id)
	return result


func resolved_values() -> Dictionary:
	return working_values.duplicate(true)


static func _preset_values(preset_name: StringName) -> Dictionary:
	return _config_values(SwingConfig.from_preset(preset_name))


static func _config_values(config: SwingConfig) -> Dictionary:
	var values := {}
	for parameter_id: StringName in TuningCatalog.parameter_ids():
		match parameter_id:
			TuningCatalog.DEBUG_START_DISTANCE:
				values[parameter_id] = 0.0
			TuningCatalog.DEBUG_UPGRADE_LEVEL:
				values[parameter_id] = -1.0
			_:
				values[parameter_id] = TuningCatalog.clamp_value(
					parameter_id,
					config.value_for(parameter_id),
				)
	return values


static func _validated_override_ids(raw_ids: Variant) -> Array[StringName]:
	var result: Array[StringName] = []
	if not raw_ids is Array:
		return result
	for raw_id: Variant in raw_ids as Array:
		var parameter_id := StringName(str(raw_id))
		if parameter_id in TuningCatalog.parameter_ids() and \
				parameter_id not in [
					TuningCatalog.DEBUG_START_DISTANCE,
					TuningCatalog.DEBUG_UPGRADE_LEVEL,
				] and parameter_id not in result:
			result.append(parameter_id)
	return result


static func _serialize_override_ids(raw_ids: Array) -> Array[String]:
	var result: Array[String] = []
	for raw_id: Variant in raw_ids:
		result.append(str(raw_id))
	return result


static func _validated_values(
	raw_values: Variant,
	fallback: Dictionary,
) -> Dictionary:
	var values := fallback.duplicate(true)
	if not raw_values is Dictionary:
		return values
	for parameter_id: StringName in TuningCatalog.parameter_ids():
		var key := str(parameter_id)
		var raw: Variant = (raw_values as Dictionary).get(
			parameter_id,
			(raw_values as Dictionary).get(key, values.get(parameter_id, 0.0)),
		)
		if raw is float or raw is int:
			values[parameter_id] = TuningCatalog.clamp_value(
				parameter_id,
				float(raw),
			)
	return values


static func _serialize_values(values: Dictionary) -> Dictionary:
	var serialized := {}
	for parameter_id: StringName in TuningCatalog.parameter_ids():
		serialized[str(parameter_id)] = float(values.get(parameter_id, 0.0))
	return serialized


static func _values_equal(first: Dictionary, second: Dictionary) -> bool:
	for parameter_id: StringName in TuningCatalog.parameter_ids():
		if not is_equal_approx(
			float(first.get(parameter_id, 0.0)),
			float(second.get(parameter_id, 0.0)),
		):
			return false
	return true


static func _override_ids_equal(first: Array, second: Array) -> bool:
	if first.size() != second.size():
		return false
	for raw_id: Variant in first:
		if StringName(str(raw_id)) not in second:
			return false
	return true

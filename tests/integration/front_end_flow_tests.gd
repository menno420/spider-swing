extends RefCounted
class_name FrontEndFlowTests
## Contracts for startup navigation, tutorial completeness, and real settings.


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_startup_is_home_not_gameplay(failures)
	passed += _test_primary_routes_are_real_buttons(failures)
	passed += _test_tutorial_covers_current_mechanics(failures)
	passed += _test_settings_are_validated_and_emitted(failures)
	passed += _test_settings_are_scrollable_and_mobile_readable(failures)
	passed += _test_settings_codec_round_trip(failures)
	passed += _test_settings_repository_round_trip(failures)
	passed += _test_progression_is_idempotent_and_persistent(failures)
	passed += _test_checkpoint_migration_and_practice_are_noncompetitive(
		failures)
	passed += _test_legacy_upgrade_levels_migrate_proportionally(failures)
	passed += _test_garage_shop_and_creator_are_real_routes(failures)
	passed += _test_garage_uses_spider_cosmetic_rails(failures)
	passed += _test_field_guide_separates_biology_from_game(failures)
	passed += _test_shop_exposes_seven_mobile_readable_tracks(failures)
	passed += _test_shop_explains_breakthrough_bonuses(failures)
	passed += _test_debug_upgrade_overlay_never_persists(failures)
	passed += _test_debug_upgrade_overlay_restores_exact_saved_levels(failures)
	passed += _test_garage_and_shop_disclose_debug_upgrade_levels(failures)
	passed += _test_debug_run_setup_stages_and_starts_before_play(failures)
	passed += _test_upgrades_and_creator_edits_use_progression_service(failures)
	passed += _test_composition_root_mounts_front_end_first(failures)
	return {"passed": passed, "failures": failures}


static func _test_startup_is_home_not_gameplay(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	var plays: Array[PlayerSettings] = []
	state.play_requested.connect(func(settings: PlayerSettings) -> void:
		plays.append(settings))
	state.configure(PlayerSettings.defaults())
	if state.screen != FrontEndState.Screen.HOME or not plays.is_empty():
		failures.append("front end does not start at HOME without starting a run")
		return 0
	return 1


static func _test_primary_routes_are_real_buttons(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults())
	var view := FrontEndView.new()
	view.bind_state(state)
	for button_name: StringName in [
		&"Play", &"Garage", &"Shop", &"Tutorial", &"Creator", &"Practice",
		&"Settings", &"FieldGuide",
	]:
		var button := view.front_end_button(button_name)
		if button == null or button.mouse_filter != Control.MOUSE_FILTER_STOP:
			failures.append("%s is not an event-consuming Button" % button_name)
			view.free()
			return 0
	view.front_end_button(&"Tutorial").pressed.emit()
	if state.screen != FrontEndState.Screen.TUTORIAL:
		failures.append("Tutorial button does not route to tutorial")
		view.free()
		return 0
	view.front_end_button(&"TutorialBack").pressed.emit()
	view.front_end_button(&"Settings").pressed.emit()
	if state.screen != FrontEndState.Screen.SETTINGS:
		failures.append("Settings button does not route to settings")
		view.free()
		return 0
	view.free()
	return 1


static func _test_tutorial_covers_current_mechanics(
	failures: PackedStringArray,
) -> int:
	if FrontEndState.TUTORIAL_STEPS.size() != 6:
		failures.append("tutorial must have exactly six focused steps")
		return 0
	var combined := ""
	for step: Dictionary in FrontEndState.TUTORIAL_STEPS:
		for key in ["title", "body", "tip"]:
			combined += " " + str(step.get(key, ""))
	for required: String in [
		"moves forward automatically",
		"solid ceiling or obstacle edge",
		"tap anywhere",
		"hold REEL",
		"fixed rate",
		"BURST",
		"double-tap",
		"minimum Burst travel",
		"40% Dive Pull",
		"lethal by default",
		"Buckler",
		"upper web",
		"ends the run",
		"MENU",
	]:
		if required.to_lower() not in combined.to_lower():
			failures.append("tutorial omits required concept: %s" % required)
			return 0
	return 1


static func _test_settings_are_validated_and_emitted(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults())
	var published: Array[PlayerSettings] = []
	state.settings_changed.connect(func(settings: PlayerSettings) -> void:
		published.append(settings))
	state.set_swing_preset(SwingConfig.PRESET_AGILE)
	state.set_control_hints(false)
	state.set_reduced_motion(true)
	state.set_debug_tools(false)
	state.set_swing_preset(&"not_a_real_preset")
	if published.size() != 4:
		failures.append("settings changes were not emitted exactly once each")
		return 0
	if state.settings.swing_preset != SwingConfig.PRESET_AGILE or \
			state.settings.show_control_hints or \
			not state.settings.reduced_motion or \
			state.settings.show_debug_tools:
		failures.append("settings state did not retain validated choices")
		return 0
	return 1


static func _test_settings_are_scrollable_and_mobile_readable(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults())
	var view := FrontEndView.new()
	view.bind_state(state)
	var scroll := view.find_child("SettingsScroll", true, false) as ScrollContainer
	var content := view.find_child("SettingsContent", true, false) as VBoxContainer
	var preset_rail := view.find_child(
		"SwingPresetRail",
		true,
		false,
	) as HBoxContainer
	var reset := view.front_end_button(&"ResetSettings")
	var play := view.front_end_button(&"SettingsPlay")
	if scroll == null or content == null:
		failures.append("Settings is not backed by a named scrolling content area")
		view.free()
		return 0
	if scroll.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_AUTO or \
			scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
		failures.append("Settings scroll direction is not mobile-safe")
		view.free()
		return 0
	if scroll.follow_focus or scroll.scroll_deadzone < 10 or \
			scroll.scroll_vertical_custom_step < 48.0:
		failures.append("Settings touch scrolling can still snap or feel twitchy")
		view.free()
		return 0
	if not _scroll_descendants_bubble_drag(scroll):
		failures.append(
			"Settings still blocks swipes that begin on a control or card")
		view.free()
		return 0
	if preset_rail == null or preset_rail.get_child_count() != 3:
		failures.append("swing presets are not a consistent three-card selector")
		view.free()
		return 0
	for preset_index in range(3):
		var preset := view.front_end_button(
			StringName("SwingPreset%d" % preset_index),
		)
		if preset == null or preset.custom_minimum_size.y < 64.0 or \
				preset.get_theme_font_size("font_size") < 20:
			failures.append("swing preset cards remain too small to read or tap")
			view.free()
			return 0
	if reset.custom_minimum_size.y < 64.0 or \
			play.custom_minimum_size.y < 64.0:
		failures.append("Settings action buttons remain too small for mobile")
		view.free()
		return 0
	if content.get_theme_constant("separation") < 18:
		failures.append("Settings content remains visually cramped")
		view.free()
		return 0
	view.free()
	return 1


static func _test_settings_codec_round_trip(
	failures: PackedStringArray,
) -> int:
	var expected := PlayerSettings.defaults()
	expected.swing_preset = SwingConfig.PRESET_WEIGHTY
	expected.show_control_hints = false
	expected.reduced_motion = true
	expected.show_debug_tools = false
	var decoded := SaveRepository.decode_settings(JSON.stringify(
		expected.to_dictionary()))
	if decoded.to_dictionary() != expected.to_dictionary():
		failures.append("settings codec did not round-trip versioned values")
		return 0
	var invalid := SaveRepository.decode_settings(
		"{\"swing_preset\":\"impossible\"}")
	if invalid.swing_preset != SwingConfig.PRESET_BALANCED:
		failures.append("invalid persisted preset did not fall back safely")
		return 0
	return 1


static func _test_settings_repository_round_trip(
	failures: PackedStringArray,
) -> int:
	var path := "user://front_end_flow_test_settings.json"
	_remove_test_file(path)
	_remove_test_file("%s.tmp" % path)
	_remove_test_file("%s.bak" % path)
	var repository := SaveRepository.new(path)
	var expected := PlayerSettings.defaults()
	expected.swing_preset = SwingConfig.PRESET_AGILE
	expected.show_control_hints = false
	expected.reduced_motion = true
	if not repository.save_settings(expected):
		failures.append("SaveRepository could not atomically write settings")
		return 0
	var actual := repository.load_settings()
	_remove_test_file(path)
	_remove_test_file("%s.tmp" % path)
	_remove_test_file("%s.bak" % path)
	if actual.to_dictionary() != expected.to_dictionary():
		failures.append("SaveRepository did not restore its atomic write")
		return 0
	return 1


static func _test_composition_root_mounts_front_end_first(
	failures: PackedStringArray,
) -> int:
	var file := FileAccess.open("res://game/bootstrap/main.gd", FileAccess.READ)
	if file == null:
		failures.append("composition root source cannot be read")
		return 0
	var source := file.get_as_text()
	if not source.contains("var failures := _mount_front_end()"):
		failures.append("startup does not explicitly mount the front end")
		return 0
	if source.contains("var failures: PackedStringArray = _mount_swing_lab()"):
		failures.append("startup still directly mounts gameplay")
		return 0
	if not source.contains("_front_end_state.play_requested.connect(_start_game)"):
		failures.append("Play does not own the transition into gameplay")
		return 0
	if not source.contains(
		"_front_end_state.debug_play_requested.connect(_start_debug_game)"
	) or not source.contains(
		"_session.configure_run(run_mode, start_distance_pixels, -1, debug_start)"
	):
		failures.append("debug pre-run setup bypasses the composition root")
		return 0
	return 1


static func _test_progression_is_idempotent_and_persistent(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	var service := ProgressionService.new()
	var settlement := RunSettlement.create(
		"test-settlement",
		10500.0,
		25,
		&"obstacle",
	)
	var first := service.apply_settlement(progress, settlement)
	var second := service.apply_settlement(progress, settlement)
	if not bool(first["applied"]) or bool(second["applied"]):
		failures.append("progression did not apply one settlement exactly once")
		return 0
	if progress.total_flies != 25 or \
			progress.spendable_flies != 25 or \
			PlayerProgress.STYLE_AMBER not in progress.unlocked_spider_styles or \
			PlayerProgress.STYLE_COMET not in progress.unlocked_spider_styles:
		failures.append("fly and distance milestones did not unlock cosmetics")
		return 0
	var settings_path := "user://progress_test_settings.json"
	var progress_path := "user://progress_test_progress.json"
	for path: String in [
		settings_path,
		"%s.tmp" % settings_path,
		"%s.bak" % settings_path,
		progress_path,
		"%s.tmp" % progress_path,
		"%s.bak" % progress_path,
	]:
		_remove_test_file(path)
	var repository := SaveRepository.new(settings_path, progress_path)
	if not repository.save_progress(progress):
		failures.append("SaveRepository could not atomically write progress")
		return 0
	var restored := repository.load_progress()
	for path: String in [
		settings_path,
		"%s.tmp" % settings_path,
		"%s.bak" % settings_path,
		progress_path,
		"%s.tmp" % progress_path,
		"%s.bak" % progress_path,
	]:
		_remove_test_file(path)
	if restored.to_dictionary() != progress.to_dictionary():
		failures.append("SaveRepository did not restore progression")
		return 0
	return 1


static func _test_checkpoint_migration_and_practice_are_noncompetitive(
	failures: PackedStringArray,
) -> int:
	var migrated := PlayerProgress.from_dictionary({
		"schema_version": 4,
		"best_distance_pixels":
			CourseRegionCatalog.REGION_LENGTH_PIXELS + 10.0,
		"total_flies": 12,
		"spendable_flies": 12,
		"upgrade_levels": {"classic_reel": 5},
	})
	if not migrated.has_region_checkpoint(
		CourseRegionCatalog.BRAMBLE_CANOPY) or \
			migrated.has_region_checkpoint(CourseRegionCatalog.SILK_HOLLOW) or \
			migrated.upgrade_level(&"classic_reel") != 5:
		failures.append(
			"schema-4 checkpoint migration changed an existing upgrade level")
		return 0
	var restored := PlayerProgress.from_dictionary(migrated.to_dictionary())
	if restored.to_dictionary() != migrated.to_dictionary():
		failures.append("schema-5 checkpoint identity did not round-trip")
		return 0

	var service := ProgressionService.new()
	var before := migrated.to_dictionary()
	var practice := RunSettlement.create(
		"practice-settlement",
		CourseRegionCatalog.REGION_LENGTH_PIXELS * 3.0,
		99,
		&"obstacle",
		SwingLabSession.RUN_PRACTICE,
		CourseRegionCatalog.REGION_LENGTH_PIXELS,
		false,
		77,
	)
	var result := service.apply_settlement(migrated, practice)
	var after := migrated.to_dictionary()
	if not bool(result["applied"]) or \
			int(result["flies_granted"]) != 0 or \
			after["total_flies"] != before["total_flies"] or \
			after["spendable_flies"] != before["spendable_flies"] or \
			after["best_distance_pixels"] != before["best_distance_pixels"]:
		failures.append("practice settlement changed economy or records")
		return 0

	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults(), migrated)
	var requests: Array[StringName] = []
	state.practice_play_requested.connect(func(
		_settings: PlayerSettings,
		region_id: StringName,
		_start_distance: float,
	) -> void:
		requests.append(region_id))
	var view := FrontEndView.new()
	view.bind_state(state)
	view.front_end_button(&"Practice").pressed.emit()
	var bramble := view.front_end_button(&"PracticeBrambleCanopy")
	var hollow := view.front_end_button(&"PracticeSilkHollow")
	if state.screen != FrontEndState.Screen.PRACTICE or \
			bramble == null or hollow == null or \
			bramble.disabled or not hollow.disabled:
		failures.append("practice route does not expose reached and locked regions")
		view.free()
		return 0
	bramble.pressed.emit()
	hollow.pressed.emit()
	if requests != [CourseRegionCatalog.BRAMBLE_CANOPY]:
		failures.append("locked checkpoint emitted a practice start")
		view.free()
		return 0
	view.free()
	return 1


static func _test_garage_shop_and_creator_are_real_routes(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults(), PlayerProgress.defaults())
	var view := FrontEndView.new()
	view.bind_state(state)
	view.front_end_button(&"Garage").pressed.emit()
	if state.screen != FrontEndState.Screen.GARAGE or \
			view.front_end_button(&"GaragePlay") == null:
		failures.append("Garage is not a functional Home route")
		view.free()
		return 0
	view.front_end_button(&"GarageBack").pressed.emit()
	view.front_end_button(&"Shop").pressed.emit()
	if state.screen != FrontEndState.Screen.SHOP or \
			view.front_end_button(&"ShopGarage") == null:
		failures.append("Shop is not a functional Home route")
		view.free()
		return 0
	view.front_end_button(&"ShopBack").pressed.emit()
	view.front_end_button(&"Creator").pressed.emit()
	if state.screen != FrontEndState.Screen.CREATOR or \
			view.front_end_button(&"CreatorPlay") == null or \
			view.front_end_button(&"CourseSlot0") == null:
		failures.append("Course Lab is not a functional editable Home route")
		view.free()
		return 0
	view.free()
	return 1


static func _test_field_guide_separates_biology_from_game(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults(), PlayerProgress.defaults())
	var view := FrontEndView.new()
	view.bind_state(state)
	view.front_end_button(&"Garage").pressed.emit()
	var strip := view.find_child("GarageInspiration", true, false) as Label
	if strip == null or not strip.text.begins_with("INSPIRED BY"):
		failures.append("Garage does not name what the selected spider is inspired by")
		view.free()
		return 0
	var garage_preview := view.find_child(
		"GarageSpiderPreview",
		true,
		false,
	) as TextureRect
	if garage_preview == null or garage_preview.texture == null or \
			garage_preview.texture.resource_path != ArtAssetCatalog.texture_path(
				ArtAssetCatalog.spider_asset_id(SpiderCatalog.CLASSIC),
			):
		failures.append("Garage does not preview the selected production sprite")
		view.free()
		return 0
	view.front_end_button(&"GarageFieldGuide").pressed.emit()
	if state.screen != FrontEndState.Screen.FIELD_GUIDE:
		failures.append("Garage does not route to the Field Guide")
		view.free()
		return 0
	var scroll := view.find_child("FieldGuideScroll", true, false) \
		as ScrollContainer
	if scroll == null or \
			scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
		failures.append("the Field Guide is not a vertical touch scroller")
		view.free()
		return 0
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var entry_name := "FieldGuideEntry%s" % str(spider_id).to_pascal_case()
		var entry := view.find_child(entry_name, true, false) as Control
		if entry == null:
			failures.append("the Field Guide omits %s" % spider_id)
			view.free()
			return 0
		# Inspiration, real biology, and the game's invention must each be
		# present and separately labelled; a merged claim is the failure mode
		# this screen exists to prevent.
		var found := {"INSPIRED BY": false, "REAL SPIDER": false,
			"IN THIS GAME": false}
		for label: Node in entry.find_children("*", "Label", true, false):
			for marker: String in found:
				if (label as Label).text.begins_with(marker):
					found[marker] = true
		for marker: String in found:
			if not found[marker]:
				failures.append("%s entry has no %s line" % [spider_id, marker])
				view.free()
				return 0
	# The guide is entered from two places, so back must follow the route the
	# player actually took rather than always landing in the Garage.
	var guide_back := view.front_end_button(&"FieldGuideBack")
	if not guide_back.text.contains("GARAGE"):
		failures.append("the Field Guide back route does not name the Garage")
		view.free()
		return 0
	guide_back.pressed.emit()
	if state.screen != FrontEndState.Screen.GARAGE:
		failures.append("the Field Guide does not return to the Garage")
		view.free()
		return 0
	state.show_home()
	view.front_end_button(&"FieldGuide").pressed.emit()
	if state.screen != FrontEndState.Screen.FIELD_GUIDE:
		failures.append("Home does not route to the Field Guide")
		view.free()
		return 0
	if not guide_back.text.contains("HOME"):
		failures.append("the Field Guide back route does not follow its origin")
		view.free()
		return 0
	guide_back.pressed.emit()
	if state.screen != FrontEndState.Screen.HOME:
		failures.append("the Field Guide does not return to Home")
		view.free()
		return 0
	view.front_end_button(&"Garage").pressed.emit()
	view.front_end_button(&"GarageBack").pressed.emit()
	view.front_end_button(&"Shop").pressed.emit()
	var shop_preview := view.find_child(
		"ShopSpiderPreview",
		true,
		false,
	) as TextureRect
	if shop_preview == null or shop_preview.texture == null or \
			shop_preview.texture.resource_path != garage_preview.texture.resource_path:
		failures.append("Shop does not reuse the selected production sprite")
		view.free()
		return 0
	view.free()
	return 1


static func _test_garage_uses_spider_cosmetic_rails(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults(), PlayerProgress.defaults())
	var requested_webs: Array[StringName] = []
	state.web_variant_requested.connect(func(web_variant: StringName) -> void:
		requested_webs.append(web_variant))
	var view := FrontEndView.new()
	view.bind_state(state)
	view.front_end_button(&"Garage").pressed.emit()
	var style_rail := view.find_child(
		"SpiderStyleRail",
		true,
		false,
	) as HBoxContainer
	var web_rail := view.find_child(
		"WebVariantRail",
		true,
		false,
	) as HBoxContainer
	var silk_preview := view.find_child(
		"SilkTreatmentPreview",
		true,
		false,
	) as SilkPreview
	if style_rail == null or web_rail == null or silk_preview == null or \
			style_rail.get_child_count() != 3 or web_rail.get_child_count() != 3:
		failures.append("Garage cosmetics are not one themed body-and-silk rail")
		view.free()
		return 0
	if view.find_child("SpiderStylePicker", true, false) != null or \
			view.find_child("WebVariantPicker", true, false) != null:
		failures.append("Garage still exposes a native dropdown beside themed UI")
		view.free()
		return 0
	var dew := view.front_end_button(&"WebVariantDewSilk")
	if dew == null or dew.custom_minimum_size.y < 44.0:
		failures.append("Silk cards are too small for the mobile Garage")
		view.free()
		return 0
	dew.pressed.emit()
	if requested_webs != [PlayerProgress.WEB_DEW]:
		failures.append("the custom Silk rail does not emit the selected treatment")
		view.free()
		return 0
	if view.theme == null or \
			view.theme.get_stylebox(&"grabber", &"VScrollBar") == null:
		failures.append("front-end widgets do not share the central spider theme")
		view.free()
		return 0
	view.free()
	return 1


static func _test_shop_exposes_seven_mobile_readable_tracks(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults(), PlayerProgress.defaults())
	var view := FrontEndView.new()
	view.bind_state(state)
	view.front_end_button(&"Shop").pressed.emit()
	var scroll := view.find_child(
		"ShopUpgradeScroll",
		true,
		false,
	) as ScrollContainer
	if scroll == null or \
			scroll.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_AUTO or \
			scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED or \
			scroll.follow_focus or scroll.scroll_deadzone < 10 or \
			scroll.scroll_vertical_custom_step < 48.0:
		failures.append("Shop upgrades are not in a mobile-safe scrolling region")
		view.free()
		return 0
	if not _scroll_descendants_bubble_drag(scroll):
		failures.append(
			"Shop still blocks swipes that begin on an upgrade card")
		view.free()
		return 0
	var core := view.front_end_button(&"UpgradeClassicReel")
	var identity := view.front_end_button(&"UpgradeClassicFlow")
	if core == null or identity == null or \
			core.custom_minimum_size.y < 64.0 or \
			identity.custom_minimum_size.y < 64.0 or \
			not core.text.contains("CORE") or \
			not identity.text.contains("IDENTITY") or \
			not core.text.contains("LEVEL 0/20"):
		failures.append("Shop does not clearly present core and identity progression")
		view.free()
		return 0
	var knots := view.find_child(
		"UpgradeKnotsClassicReel",
		true,
		false,
	) as Label
	var balance := view.find_child(
		"FlyBalanceBadge",
		true,
		false,
	) as PanelContainer
	if knots == null or not knots.text.contains("SILK KNOTS") or balance == null:
		failures.append("Shop lacks its spider-themed progress and fly balance cues")
		view.free()
		return 0
	var visible_tracks := 0
	for item: Dictionary in SpiderCatalog.upgrades_for(SpiderCatalog.CLASSIC):
		var upgrade_id := StringName(item["id"])
		var row := view.find_child(
			"UpgradeRow%s" % str(upgrade_id).to_pascal_case(),
			true,
			false,
		) as Control
		if row != null and row.visible:
			visible_tracks += 1
	if visible_tracks != 7:
		failures.append("Shop does not expose exactly seven selected-spider tracks")
		view.free()
		return 0
	view.free()
	return 1


static func _scroll_descendants_bubble_drag(node: Node) -> bool:
	for child: Node in node.get_children():
		var control := child as Control
		if control != null and \
				control.mouse_filter != Control.MOUSE_FILTER_PASS:
			return false
		if not _scroll_descendants_bubble_drag(child):
			return false
	return true


static func _test_shop_explains_breakthrough_bonuses(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	progress.upgrade_levels["classic_reel"] = 4
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults(), progress)
	var view := FrontEndView.new()
	view.bind_state(state)
	view.front_end_button(&"Shop").pressed.emit()
	var rule := view.find_child(
		"ShopProgressionRule",
		true,
		false,
	) as Label
	var description := view.find_child(
		"UpgradeDescriptionClassicReel",
		true,
		false,
	) as Label
	var button := view.front_end_button(&"UpgradeClassicReel")
	if rule == null or \
			not rule.text.contains("Levels 5, 10, 15, and 20") or \
			not rule.text.contains("listed increase twice") or \
			description == null or \
			not description.text.contains(
				"Level 5 breakthrough grants 2 tuning steps") or \
			button == null or not button.text.contains("BREAKTHROUGH ×2"):
		failures.append(
			"Shop does not explain that every fifth-level purchase applies " +
			"the listed increase twice")
		view.free()
		return 0
	view.free()

	progress = PlayerProgress.defaults()
	progress.upgrade_levels["classic_reel"] = SpiderCatalog.MAX_UPGRADE_LEVEL
	state = FrontEndState.new()
	state.configure(PlayerSettings.defaults(), progress)
	view = FrontEndView.new()
	view.bind_state(state)
	view.front_end_button(&"Shop").pressed.emit()
	description = view.find_child(
		"UpgradeDescriptionClassicReel",
		true,
		false,
	) as Label
	if description == null or \
			not description.text.contains(
				"4 breakthroughs earned · 24 tuning steps total"):
		failures.append(
			"maxed Shop card does not summarize its four bonus steps")
		view.free()
		return 0
	view.free()
	return 1


static func _test_debug_upgrade_overlay_never_persists(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	progress.total_flies = 37
	progress.spendable_flies = 19
	progress.upgrade_levels = {
		"classic_reel": 3,
		"classic_flow": 7,
		"skitter_size": 5,
	}
	var before := progress.to_dictionary()
	var service := ProgressionService.new()
	service.set_debug_upgrade_overlay_level(SpiderCatalog.MAX_UPGRADE_LEVEL)
	var resolved := service.resolved_progress(progress)
	for item: Dictionary in SpiderCatalog.upgrades_for(SpiderCatalog.CLASSIC):
		if resolved.upgrade_level(StringName(item["id"])) != \
				SpiderCatalog.MAX_UPGRADE_LEVEL:
			failures.append("debug overlay did not resolve every selected track")
			return 0
	if resolved.upgrade_level(&"skitter_size") != 5 or \
			progress.to_dictionary() != before:
		failures.append("debug overlay mutated owned or unselected upgrade levels")
		return 0

	var session := SwingLabSession.new()
	session.configure_progress(progress, service)
	session.configure_run(SwingLabSession.RUN_STANDARD, 0.0, 811)
	session._reset_run()
	var snapshot := session.current_snapshot()
	var settlements: Array[RunSettlement] = []
	session.settlement_created.connect(func(value: RunSettlement) -> void:
		settlements.append(value))
	session._emit_settlement(&"debug-overlay-test")
	if snapshot.run_mode != SwingLabSession.RUN_PRACTICE or \
			snapshot.records_eligible or settlements.size() != 1 or \
			settlements[0].rewards_eligible or \
			settlements[0].records_eligible or \
			settlements[0].leaderboards_eligible:
		failures.append("upgrade overlay run remained competitive")
		session.free()
		return 0
	session.free()

	var settings_path := "user://debug_overlay_test_settings.json"
	var progress_path := "user://debug_overlay_test_progress.json"
	for path: String in [
		settings_path,
		"%s.tmp" % settings_path,
		"%s.bak" % settings_path,
		progress_path,
		"%s.tmp" % progress_path,
		"%s.bak" % progress_path,
	]:
		_remove_test_file(path)
	var repository := SaveRepository.new(settings_path, progress_path)
	if not repository.save_progress(progress):
		failures.append("real progress could not save while debug overlay was active")
		return 0
	var persisted_file := FileAccess.open(progress_path, FileAccess.READ)
	var persisted_text := (
		persisted_file.get_as_text() if persisted_file != null else ""
	)
	if persisted_file != null:
		persisted_file.close()
	var restored := repository.load_progress()
	for path: String in [
		settings_path,
		"%s.tmp" % settings_path,
		"%s.bak" % settings_path,
		progress_path,
		"%s.tmp" % progress_path,
		"%s.bak" % progress_path,
	]:
		_remove_test_file(path)
	if persisted_text.contains("debug_upgrade") or \
			restored.to_dictionary() != before or \
			ProgressionService.new().debug_upgrade_overlay_enabled():
		failures.append("debug upgrade overlay leaked into persisted progress")
		return 0
	return 1


static func _test_debug_upgrade_overlay_restores_exact_saved_levels(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	progress.selected_spider_id = SpiderCatalog.CLASSIC
	progress.upgrade_levels = {
		"classic_reel": 18,
		"classic_burst": 1,
		"classic_flow": 3,
		"classic_rhythm": 14,
		"skitter_size": 9,
	}
	var exact_saved := progress.to_dictionary()
	var service := ProgressionService.new()
	service.set_debug_upgrade_overlay_level(11)
	var overlaid := service.resolved_progress(progress)
	if overlaid.upgrade_level(&"classic_reel") != 11 or \
			overlaid.upgrade_level(&"classic_flow") != 11 or \
			overlaid.upgrade_level(&"skitter_size") != 9:
		failures.append("selectable overlay did not resolve only the active spider")
		return 0
	service.clear_debug_upgrade_overlay()
	var restored := service.resolved_progress(progress)
	if service.debug_upgrade_overlay_enabled() or \
			service.debug_upgrade_overlay_level() != \
				ProgressionService.DEBUG_UPGRADE_OVERLAY_DISABLED or \
			restored.to_dictionary() != exact_saved or \
			progress.to_dictionary() != exact_saved:
		failures.append("disabling overlay did not restore exact saved levels")
		return 0
	return 1


static func _test_garage_and_shop_disclose_debug_upgrade_levels(
	failures: PackedStringArray,
) -> int:
	var settings := PlayerSettings.defaults()
	settings.show_debug_tools = true
	var progress := PlayerProgress.defaults()
	progress.spendable_flies = 100
	progress.upgrade_levels["classic_reel"] = 4
	var service := ProgressionService.new()
	service.set_debug_upgrade_overlay_level(20)
	var state := FrontEndState.new()
	state.configure(settings, progress, service)
	var purchase_requests: Array[StringName] = []
	state.upgrade_purchase_requested.connect(func(upgrade_id: StringName) -> void:
		purchase_requests.append(upgrade_id))
	var view := FrontEndView.new()
	view.bind_state(state)
	state.show_garage()
	if not view._garage_role.text.contains("DEBUG UPGRADE OVERLAY") or \
			not view._garage_role.text.contains("NOT OWNED"):
		failures.append("Garage does not disclose the unowned debug overlay")
		view.free()
		return 0
	state.show_shop()
	var rule := view.find_child(
		"ShopProgressionRule",
		true,
		false,
	) as Label
	var upgrade := view.front_end_button(&"UpgradeClassicReel")
	upgrade.pressed.emit()
	if rule == null or not rule.text.contains("NOT OWNED") or \
			not rule.text.contains("Saved levels are unchanged") or \
			upgrade == null or not upgrade.disabled or \
			not upgrade.text.contains("DEBUG OVERLAY LEVEL 20/20") or \
			not purchase_requests.is_empty():
		failures.append("Shop does not disclose or safely pause debug ownership")
		view.free()
		return 0

	state.set_debug_tools(false)
	state.request_upgrade_purchase(&"classic_reel")
	if service.debug_upgrade_overlay_enabled() or \
			state.displayed_upgrade_level(&"classic_reel") != 4 or \
			upgrade.disabled or upgrade.text.contains("DEBUG OVERLAY") or \
			purchase_requests != [&"classic_reel"]:
		failures.append(
			"turning DEBUG off did not restore owned UI and purchase routing")
		view.free()
		return 0
	view.free()
	return 1


static func _test_debug_run_setup_stages_and_starts_before_play(
	failures: PackedStringArray,
) -> int:
	var settings := PlayerSettings.defaults()
	settings.show_debug_tools = false
	var progress := PlayerProgress.defaults()
	progress.upgrade_levels["classic_reel"] = 3
	progress.upgrade_levels["classic_burst"] = 1
	var exact_saved := progress.to_dictionary()
	var service := ProgressionService.new()
	var state := FrontEndState.new()
	state.configure(settings, progress, service)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	var view := FrontEndView.new()
	view.size = Vector2(viewport.size)
	viewport.add_child(view)
	view.bind_state(state)
	var route := view.front_end_button(&"DebugRunSetup")
	if route == null or route.visible:
		failures.append("debug run setup is reachable while debug tools are off")
		viewport.free()
		return 0
	route.pressed.emit()
	if state.screen != FrontEndState.Screen.HOME:
		failures.append("hidden debug route bypassed its application guard")
		viewport.free()
		return 0

	state.set_debug_tools(true)
	if not route.visible:
		failures.append("debug run setup did not appear after enabling debug tools")
		viewport.free()
		return 0
	route.pressed.emit()
	var screen := view.find_child(
		"DebugRunSetupScreen", true, false) as Control
	var card := view.find_child("DebugRunSetupCard", true, false) as Control
	var columns := view.find_child(
		"DebugRunSetupColumns", true, false) as HBoxContainer
	var entry := view.find_child(
		"DebugRunDistanceEntry", true, false) as LineEdit
	var warning := view.find_child(
		"DebugRunAwardsWarning", true, false) as Label
	if state.screen != FrontEndState.Screen.DEBUG_RUN_SETUP or \
			screen == null or not screen.visible or card == null or \
			columns == null or columns.get_child_count() != 2 or entry == null or \
			warning == null or not warning.text.contains("NO RECORD"):
		failures.append("debug route did not open a complete pre-run setup")
		viewport.free()
		return 0
	if card.anchor_left < 0.0 or card.anchor_top < 0.0 or \
			card.anchor_right > 1.0 or card.anchor_bottom > 1.0:
		failures.append("debug setup card is not enclosed by the 1280×720 view")
		viewport.free()
		return 0
	for button_name: StringName in [
		&"DebugDistanceMinus", &"DebugDistancePlus",
		&"DebugUpgradeMinus", &"DebugUpgradePlus", &"DebugRunStart",
	]:
		var button := view.front_end_button(button_name)
		if button == null or button.custom_minimum_size.y < 64.0:
			failures.append("%s is not a mobile-sized pre-run control" % button_name)
			viewport.free()
			return 0

	# OWNED -> L0 -> L1 -> L0 proves both large controls cross the overlay edge.
	view.front_end_button(&"DebugUpgradePlus").pressed.emit()
	view.front_end_button(&"DebugUpgradePlus").pressed.emit()
	view.front_end_button(&"DebugUpgradeMinus").pressed.emit()
	if state.debug_run_upgrade_level != 0:
		failures.append("pre-run upgrade −/+ does not switch levels directly")
		viewport.free()
		return 0
	state.set_debug_run_upgrade_level(6)
	entry.text = "12345,7"
	entry.text_changed.emit(entry.text)
	var debug_requests: Array[Dictionary] = []
	state.debug_play_requested.connect(func(
		requested_settings: PlayerSettings,
		distance_pixels: float,
		upgrade_level: int,
	) -> void:
		debug_requests.append({
			"debug": requested_settings.show_debug_tools,
			"distance": distance_pixels,
			"level": upgrade_level,
		}))
	view.front_end_button(&"DebugRunStart").pressed.emit()
	if debug_requests.size() != 1 or not bool(debug_requests[0]["debug"]) or \
			not is_equal_approx(float(debug_requests[0]["distance"]), 123457.0) or \
			int(debug_requests[0]["level"]) != 6 or \
			service.debug_upgrade_overlay_level() != 6 or \
			progress.to_dictionary() != exact_saved:
		failures.append("pre-run choices did not start one exact temporary test")
		viewport.free()
		return 0

	var session := SwingLabSession.new()
	session.configure_progress(progress, service)
	session.configure_run(
		SwingLabSession.RUN_PRACTICE,
		123457.0,
		913,
		true,
	)
	session._reset_run()
	var snapshot := session.current_snapshot()
	if not snapshot.debug_start_active or \
			snapshot.run_mode != SwingLabSession.RUN_PRACTICE or \
			snapshot.records_eligible or \
			not is_equal_approx(snapshot.distance_pixels, 123457.0) or \
			snapshot.debug_upgrade_overlay_level != 6:
		failures.append("pre-run setup did not inherit debug practice ownership")
		session.free()
		viewport.free()
		return 0
	session.free()

	var standard_requests: Array[PlayerSettings] = []
	state.play_requested.connect(func(value: PlayerSettings) -> void:
		standard_requests.append(value))
	state.request_play()
	if standard_requests.size() != 1 or service.debug_upgrade_overlay_enabled() or \
			progress.to_dictionary() != exact_saved:
		failures.append("normal PLAY did not restore exact owned upgrade state")
		viewport.free()
		return 0
	state.set_debug_tools(false)
	state.show_home()
	route.pressed.emit()
	state.request_debug_play()
	if route.visible or state.screen != FrontEndState.Screen.HOME or \
			debug_requests.size() != 1:
		failures.append("pre-run debug controls bypassed show_debug_tools gating")
		viewport.free()
		return 0
	viewport.free()
	return 1


static func _test_upgrades_and_creator_edits_use_progression_service(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	progress.spendable_flies = 20
	progress.selected_spider_id = SpiderCatalog.SKITTER
	var service := ProgressionService.new()
	var track := &"skitter_size"
	var result := service.purchase_upgrade(progress, track)
	if not bool(result.get("purchased", false)) or \
			progress.upgrade_level(track) != 1 or \
			progress.spendable_flies != 18 or \
			bool(result.get("breakthrough", true)):
		failures.append("fly-funded spider upgrade did not apply atomically")
		return 0
	progress.upgrade_levels[str(track)] = 4
	progress.spendable_flies = 20
	result = service.purchase_upgrade(progress, track)
	if not bool(result.get("purchased", false)) or \
			progress.upgrade_level(track) != 5 or \
			progress.spendable_flies != 15 or \
			not bool(result.get("breakthrough", false)):
		failures.append("level-five purchase did not report its breakthrough")
		return 0
	if not service.select_spider_profile(progress, SpiderCatalog.BALLOONER):
		failures.append("an unlocked comparison spider could not be selected")
		return 0
	var before := progress.creator_pattern[0]
	if not service.cycle_creator_piece(progress, 0) or \
			progress.creator_pattern[0] == before:
		failures.append("creator slot did not cycle through the progression seam")
		return 0
	service.clear_creator_pattern(progress)
	for piece: StringName in progress.creator_pattern:
		if piece != &"empty":
			failures.append("creator clear left an authored obstacle behind")
			return 0
	return 1


static func _test_legacy_upgrade_levels_migrate_proportionally(
	failures: PackedStringArray,
) -> int:
	var legacy := {
		"schema_version": 3,
		"spendable_flies": 41,
		"upgrade_levels": {
			"classic_reel": 1,
			"classic_burst_floor": 5,
			"skitter_size": 3,
			"unknown_track": 5,
		},
	}
	var migrated := PlayerProgress.from_dictionary(legacy)
	if migrated.upgrade_level(&"classic_reel") != 4 or \
			migrated.upgrade_level(&"classic_burst_floor") != 20 or \
			migrated.upgrade_level(&"skitter_size") != 12 or \
			migrated.upgrade_levels.has("unknown_track"):
		failures.append("legacy five-level progress did not migrate proportionally")
		return 0
	var round_trip := PlayerProgress.from_dictionary(migrated.to_dictionary())
	if round_trip.upgrade_level(&"classic_reel") != 4 or \
			round_trip.upgrade_level(&"classic_burst_floor") != 20 or \
			round_trip.upgrade_level(&"skitter_size") != 12:
		failures.append("current-schema upgrade levels were migrated twice")
		return 0
	return 1


static func _remove_test_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

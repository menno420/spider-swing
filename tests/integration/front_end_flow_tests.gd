extends RefCounted
class_name FrontEndFlowTests
## Contracts for startup navigation, tutorial completeness, and real settings.

const SpiderWebPanelScript = preload(
	"res://game/presentation/scripts/spider_web_panel.gd")


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_startup_is_home_not_gameplay(failures)
	passed += _test_primary_routes_are_real_buttons(failures)
	passed += _test_home_has_primary_action_hierarchy(failures)
	passed += _test_focused_hubs_are_enclosed_and_shallow(failures)
	passed += _test_menus_are_thumb_sized_and_state_their_progress(failures)
	passed += _test_home_deck_reports_the_run_you_are_about_to_start(failures)
	passed += _test_tutorial_covers_current_mechanics(failures)
	passed += _test_tutorial_previews_use_live_assets_and_cosmetics(failures)
	passed += _test_tutorial_is_enclosed_on_short_landscapes(failures)
	passed += _test_settings_are_validated_and_emitted(failures)
	passed += _test_settings_are_scrollable_and_mobile_readable(failures)
	passed += _test_settings_codec_round_trip(failures)
	passed += _test_settings_repository_round_trip(failures)
	passed += _test_debug_profile_repository_round_trip(failures)
	passed += _test_debug_profile_preserves_unoverridden_progression(failures)
	passed += _test_progression_is_idempotent_and_persistent(failures)
	passed += _test_checkpoint_migration_and_practice_are_noncompetitive(
		failures)
	passed += _test_legacy_upgrade_levels_migrate_proportionally(failures)
	passed += _test_garage_shop_and_creator_are_real_routes(failures)
	passed += _test_garage_uses_spider_cosmetic_rails(failures)
	passed += _test_spider_web_theme_is_reusable_and_layout_passive(failures)
	passed += _test_field_guide_separates_biology_from_game(failures)
	passed += _test_shop_exposes_seven_mobile_readable_tracks(failures)
	passed += _test_shop_explains_breakthrough_bonuses(failures)
	passed += _test_debug_upgrade_overlay_never_persists(failures)
	passed += _test_debug_upgrade_overlay_restores_exact_saved_levels(failures)
	passed += _test_garage_and_shop_disclose_debug_upgrade_levels(failures)
	passed += _test_debug_overlay_ends_with_the_run_it_was_launched_for(failures)
	passed += _test_debug_run_setup_stages_and_starts_before_play(failures)
	passed += _test_debug_bird_presets_change_only_test_profile(failures)
	passed += _test_debug_bird_controls_are_visible_and_labeled(failures)
	passed += _test_upgrades_and_creator_edits_use_progression_service(failures)
	passed += _test_composition_root_mounts_front_end_first(failures)
	passed += _test_trace_watch_is_reachable_and_debug_only(failures)
	passed += _test_every_campaign_level_is_reachable_and_scrolls(failures)
	passed += _test_field_guide_sections_grow_with_their_copy(failures)
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
		&"Play", &"SpiderHub", &"PlayModesHub", &"GuideHub", &"Settings",
		&"Garage", &"Shop", &"Tutorial", &"Campaign", &"Creator", &"Practice",
		&"FieldGuide",
	]:
		var button := view.front_end_button(button_name)
		if button == null or button.mouse_filter != Control.MOUSE_FILTER_STOP:
			failures.append("%s is not an event-consuming Button" % button_name)
			view.free()
			return 0
	view.front_end_button(&"GuideHub").pressed.emit()
	if state.screen != FrontEndState.Screen.GUIDE_HUB:
		failures.append("Guide choice does not open its focused hub")
		view.free()
		return 0
	view.front_end_button(&"Tutorial").pressed.emit()
	if state.screen != FrontEndState.Screen.TUTORIAL:
		failures.append("Guide hub does not route to Tutorial")
		view.free()
		return 0
	view.front_end_button(&"TutorialBack").pressed.emit()
	if state.screen != FrontEndState.Screen.GUIDE_HUB:
		failures.append("Tutorial does not return to its Guide hub")
		view.free()
		return 0
	view.front_end_button(&"GuideHubBack").pressed.emit()
	view.front_end_button(&"Settings").pressed.emit()
	if state.screen != FrontEndState.Screen.SETTINGS:
		failures.append("Settings button does not route to settings")
		view.free()
		return 0
	view.free()
	return 1


static func _test_home_has_primary_action_hierarchy(
	failures: PackedStringArray,
) -> int:
	var settings := PlayerSettings.defaults()
	settings.show_debug_tools = true
	var state := FrontEndState.new()
	state.configure(settings, PlayerProgress.defaults())
	var view := FrontEndView.new()
	view.bind_state(state)
	var identity := view.find_child("HomeIdentityPanel", true, false) as Control
	var dashboard := view.find_child("HomeWebPanel", true, false) as Control
	var preview := view.find_child("HomeSpiderPreview", true, false) as TextureRect
	var routes := view.find_child("HomeRouteGrid", true, false) as Control
	var play := view.front_end_button(&"Play")
	var debug_route := view.front_end_button(&"DebugRunSetup")
	if identity == null or dashboard == null or preview == null or \
			routes == null or play == null or preview.texture == null or \
			dashboard.anchor_left > 0.4 or dashboard.anchor_right < 0.95 or \
			play.custom_minimum_size.y < 68.0 or \
			play.get_theme_font_size("font_size") < 20 or \
			debug_route == null or debug_route.get_parent() != routes or \
			debug_route.custom_minimum_size.y < 56.0 or \
			debug_route.custom_minimum_size.y > 72.0:
		failures.append("Home lost its identity, dominant Play, or focused route map")
		view.free()
		return 0
	# Play is the only filled control in the front end, so hierarchy never rests
	# on comparing two outline hues. [D-0053]
	var hero := play.get_theme_stylebox("normal") as StyleBoxFlat
	var route_style := view.front_end_button(&"SpiderHub") \
		.get_theme_stylebox("normal") as StyleBoxFlat
	if hero == null or route_style == null or hero.bg_color.a < 0.95 or \
			hero.bg_color.get_luminance() <= route_style.bg_color.get_luminance():
		failures.append("Home's primary action is not the one filled control")
		view.free()
		return 0
	var expected_routes := ["SpiderHub", "PlayModesHub", "GuideHub", "Settings"]
	var actual_routes: Array[String] = []
	for route: Control in routes.get_children():
		if route is Button and route.name != "DebugRunSetup":
			actual_routes.append(route.name)
			if not (route as Button).text.contains("\n"):
				failures.append("Home route does not explain its purpose at a glance")
				view.free()
				return 0
			if route.custom_minimum_size.y < 80.0:
				failures.append("Home route is below its 80 px touch floor")
				view.free()
				return 0
	if actual_routes != expected_routes:
		failures.append("Home exposes feature buttons instead of four semantic choices")
		view.free()
		return 0
	view.free()
	return 1


static func _test_focused_hubs_are_enclosed_and_shallow(
	failures: PackedStringArray,
) -> int:
	var settings := PlayerSettings.defaults()
	settings.show_debug_tools = true
	var state := FrontEndState.new()
	state.configure(settings, PlayerProgress.defaults())
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 600)
	var view := FrontEndView.new()
	view.size = Vector2(viewport.size)
	viewport.add_child(view)
	view.bind_state(state)
	for panel_name in [
		"HomeWebPanel", "SpiderHubIdentity", "SpiderHubRoutes",
		"PlayModesHubRoutes", "GuideHubRoutes",
	]:
		var panel := view.find_child(panel_name, true, false) as Control
		if panel == null or panel.anchor_left < 0.0 or panel.anchor_top < 0.0 or \
				panel.anchor_right > 1.0 or panel.anchor_bottom > 1.0 or \
				panel.anchor_left >= panel.anchor_right or \
				panel.anchor_top >= panel.anchor_bottom:
			failures.append("%s escapes the short landscape shell" % panel_name)
			viewport.free()
			return 0

	view.front_end_button(&"SpiderHub").pressed.emit()
	if state.screen != FrontEndState.Screen.SPIDER_HUB:
		failures.append("Spider choice does not open its focused hub")
		viewport.free()
		return 0
	view.front_end_button(&"Garage").pressed.emit()
	view.front_end_button(&"GarageBack").pressed.emit()
	if state.screen != FrontEndState.Screen.SPIDER_HUB:
		failures.append("Garage does not return to Spider hub")
		viewport.free()
		return 0
	view.front_end_button(&"SpiderHubBack").pressed.emit()
	view.front_end_button(&"PlayModesHub").pressed.emit()
	view.front_end_button(&"Campaign").pressed.emit()
	view.front_end_button(&"CampaignBack").pressed.emit()
	if state.screen != FrontEndState.Screen.PLAY_MODES_HUB:
		failures.append("Campaign does not return to Play Modes hub")
		viewport.free()
		return 0
	view.front_end_button(&"PlayModesHubBack").pressed.emit()
	view.front_end_button(&"GuideHub").pressed.emit()
	view.front_end_button(&"FieldGuide").pressed.emit()
	if state.screen != FrontEndState.Screen.FIELD_GUIDE or \
			state.field_guide_return_screen != FrontEndState.Screen.GUIDE_HUB:
		failures.append("Guide hub does not own the Field Guide return path")
		viewport.free()
		return 0
	view.front_end_button(&"FieldGuideBack").pressed.emit()
	if state.screen != FrontEndState.Screen.GUIDE_HUB:
		failures.append("Field Guide does not return to Guide hub")
		viewport.free()
		return 0
	viewport.free()
	return 1


## `canvas_items`/`expand` maps the 1280×720 reference onto a 2340×1080 phone at
## 1.5×, and xxhdpi is 2.5 device pixels per dp, so one reference pixel is 0.6 dp
## and the 48 dp touch minimum is 80 reference pixels. Front-end controls
## measured a 32–41 dp median against that, so these floors are the recovered
## ground: they are deliberately below 80 where a screen genuinely cannot spend
## the height, and no control may shrink past them again.
const MINIMUM_TARGET_HEIGHTS := {
	# name: reference pixels
	&"Play": 68.0,
	&"SpiderHub": 80.0,
	&"PlayModesHub": 80.0,
	&"GuideHub": 80.0,
	&"Settings": 80.0,
	&"Garage": 120.0,
	&"Shop": 120.0,
	&"Campaign": 120.0,
	&"Practice": 120.0,
	&"Creator": 120.0,
	&"Tutorial": 120.0,
	&"FieldGuide": 120.0,
	&"SpiderHubBack": 60.0,
	&"GuideHubBack": 60.0,
	&"GarageFieldGuide": 56.0,
	&"SpiderStyleGarden": 56.0,
	&"WebVariantDewSilk": 56.0,
}


## The Field Guide's four sections carry the longest copy in the build, and
## `docs/product/menu-ux-review-2026-08-02.md` listed the panel as 69 % empty
## and possibly "mis-wired". **A rendered measurement says otherwise** — with a
## spider selected the panel is fully used and the copy overflows into a working
## scroller; the 69 % came from measuring a screen that had never been shown.
##
## A rendered measurement cannot live here, because a suite is synchronous and
## layout needs frames. What is pinned instead is the wiring that lets a section
## grow: each body label autowraps and expands horizontally, and the panel sets
## only a minimum height, never a maximum. Break any of those and long copy is
## clipped with nothing on screen to say so — which is the regression the audit
## thought it had found.
static func _test_field_guide_sections_grow_with_their_copy(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults(), PlayerProgress.defaults())
	var view := FrontEndView.new()
	view.bind_state(state)

	var section_names := [
		"FieldGuideSectionRealAnimal",
		"FieldGuideSectionInSpiderSwing",
		"FieldGuideSectionFieldNote",
		"FieldGuideSectionSources",
	]
	for section_name: String in section_names:
		var panel := view.find_child(section_name, true, false) as Control
		if panel == null:
			failures.append("Field Guide section %s is missing" % section_name)
			view.free()
			return 0
		# A maximum would clip; a minimum only sets a floor.
		if panel.size_flags_vertical == Control.SIZE_SHRINK_CENTER:
			failures.append(
				"Field Guide section %s cannot grow past its floor" % section_name)
			view.free()
			return 0
		var wrapped := 0
		for candidate: Node in panel.find_children("", "Label", true, false):
			var label := candidate as Label
			if label.autowrap_mode == TextServer.AUTOWRAP_OFF:
				continue
			wrapped += 1
			if label.size_flags_horizontal != Control.SIZE_EXPAND_FILL:
				failures.append(
					("Field Guide section %s has a wrapping label that does not "
						+ "expand, so its width — and therefore its wrap — is "
						+ "undefined") % section_name)
				view.free()
				return 0
		if wrapped == 0:
			failures.append(
				("Field Guide section %s has no wrapping body label, so long "
					+ "copy would run off its edge") % section_name)
			view.free()
			return 0

	# The sections must live inside a scroller: measured, they total 500 px of
	# copy against a 401 px viewport, so a fifth of it is below the fold.
	var scroll := view.find_child("FieldGuideScroll", true, false)
	if scroll == null or not (scroll is ScrollContainer):
		failures.append(
			"the Field Guide detail has no scroller, so the copy that does not "
			+ "fit is unreachable")
		view.free()
		return 0
	view.free()
	return 1


## A level in the catalog that has no button is a level nobody can play, and
## adding one is exactly the change that causes it. The campaign card is a fixed
## fraction of the screen, so six 84 px buttons plus two tier headings no longer
## fit — the list must scroll rather than run off the card's bottom edge, which
## nothing on screen would show.
static func _test_every_campaign_level_is_reachable_and_scrolls(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults(), PlayerProgress.defaults())
	var view := FrontEndView.new()
	view.bind_state(state)

	for level_id: StringName in CampaignCatalog.level_ids():
		var button := view.front_end_button(
			StringName("CampaignLevel_%s" % level_id))
		if button == null:
			failures.append(
				"campaign level %s has no button — it is unplayable" % level_id)
			view.free()
			return 0
		if button.custom_minimum_size.y < 80.0:
			failures.append(
				"campaign level %s is below the 80 px touch floor" % level_id)
			view.free()
			return 0

	var scroll := view.find_child("CampaignLevelScroll", true, false)
	if scroll == null or not (scroll is ScrollContainer):
		failures.append(
			"the campaign level list has no scroller, so levels past the "
			+ "card's height are unreachable with no visible sign of it")
		view.free()
		return 0

	# Grouping is the reason the list outgrew its card, so it has to be real:
	# every tier the catalog declares must contribute at least one button.
	for tier: Dictionary in CampaignCatalog.tiers():
		var tier_levels := CampaignCatalog.levels_for_tier(
			StringName(tier["id"]))
		if tier_levels.is_empty():
			failures.append("campaign tier %s renders no levels" % tier["id"])
			view.free()
			return 0
	view.free()
	return 1


static func _test_menus_are_thumb_sized_and_state_their_progress(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	progress.spendable_flies = 41
	progress.upgrade_levels["classic_reel"] = SpiderCatalog.MAX_UPGRADE_LEVEL
	progress.upgrade_levels["classic_flow"] = 6
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults(), progress)
	var view := FrontEndView.new()
	view.bind_state(state)

	for button_name: StringName in MINIMUM_TARGET_HEIGHTS:
		var button := view.front_end_button(button_name)
		var floor_px := float(MINIMUM_TARGET_HEIGHTS[button_name])
		if button == null or button.custom_minimum_size.y < floor_px:
			failures.append("%s is below its %.0f px touch floor" % [
				button_name, floor_px])
			view.free()
			return 0

	# The difficulty you are on must be the strongest state on Home, not the
	# dimmest. `disabled` paints it with font_disabled_color at 2.6:1.
	for mode: Dictionary in DifficultyCatalog.all_modes():
		var difficulty := view.front_end_button(
			StringName("Difficulty_%s" % StringName(mode["id"])))
		if difficulty == null or difficulty.disabled or \
				difficulty.custom_minimum_size.y < 64.0:
			failures.append("difficulty choice is disabled or below its touch floor")
			view.free()
			return 0
	for mode: Dictionary in DifficultyCatalog.all_modes():
		var mode_id := StringName(mode["id"])
		var button := view.front_end_button(
			StringName("Difficulty_%s" % mode_id))
		var chosen := mode_id == state.selected_difficulty()
		var style := button.get_theme_stylebox("normal") as StyleBoxFlat
		# Marked twice — a heavier border and an accent fill — so the state does
		# not rest on colour alone, and a prefix that survives both.
		if style == null or button.text.begins_with("▸ ") != chosen or \
				(style.border_width_top >= 3) != chosen or \
				(style.bg_color.a < 1.0) != chosen:
			failures.append("the selected difficulty is not marked as chosen")
			view.free()
			return 0

	# 41 flies, one maxed track and one at level 6 out of seven Garden tracks.
	var expectations := {
		"SpiderHubStatus": [
			"46 / 280 levels", "1 of 7 tracks maxed", "41 flies to spend"],
		"PlayModesHubStatus": ["CAMPAIGN", "PRACTICE", "COURSE LAB"],
		"GuideHubStatus": [
			"%d lessons" % FrontEndState.TUTORIAL_STEPS.size(),
			"%d spiders" % SpiderCatalog.ALL_IDS.size()],
	}
	for status_name: String in expectations:
		var status := view.find_child(status_name, true, false) as Label
		if status == null:
			failures.append("%s is missing" % status_name)
			view.free()
			return 0
		for fragment: String in expectations[status_name]:
			if not status.text.contains(fragment):
				failures.append("%s does not report \"%s\"" % [
					status_name, fragment])
				view.free()
				return 0
	view.free()
	return 1


## Home states the run you are about to start. Every figure on the deck has to
## come from PlayerProgress or the resolved config — no derived "power" score
## and no placeholder, or the screen is decoration wearing an instrument's
## clothes. [D-0053]
static func _test_home_deck_reports_the_run_you_are_about_to_start(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	progress.spendable_flies = 41
	progress.best_distance_by_mode["standard"] = 73390.0
	progress.upgrade_levels = {
		"classic_reel": 18, "classic_reel_capacity": 9,
		"classic_reel_recovery": 7, "classic_burst": 8,
		"classic_burst_floor": 4, "classic_flow": 6, "classic_rhythm": 2,
	}
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults(), progress)
	var view := FrontEndView.new()
	view.bind_state(state)

	# 73 390 px is 7 339 m, which lands in the second of eight regions.
	var expectations := {
		"HomeBestCaption": "PERSONAL BEST · STANDARD",
		"HomeBestValue": "7 339 m",
		"HomeRegionLabel": "region 2 of 8",
		# 18+9+7 reel, 8+4 burst, 6+2 identity — grouped by the catalogue's own
		# scopes and kinds, so the totals cannot drift from the tracks.
		"HomeLoadoutName0": "REEL",       "HomeLoadoutLevel0": "34/120",
		"HomeLoadoutName1": "BURST",      "HomeLoadoutLevel1": "12/80",
		"HomeLoadoutLevel2": "8/80",
		"SpiderHubBadge": "41",
	}
	for node_name: String in expectations:
		var label := view.find_child(node_name, true, false) as Label
		if label == null or not label.text.contains(expectations[node_name]):
			failures.append("Home deck %s does not report %s" % [
				node_name, expectations[node_name]])
			view.free()
			return 0

	# The effect lines must move with the resolved config, not be fixed strings.
	var reel_detail := view.find_child("HomeLoadoutDetail0", true, false) as Label
	var burst_detail := view.find_child("HomeLoadoutDetail1", true, false) as Label
	if reel_detail == null or burst_detail == null or \
			not reel_detail.text.contains("m/s") or \
			not burst_detail.text.contains("charge"):
		failures.append("Home loadout chips do not state their resolved effect")
		view.free()
		return 0
	var upgraded_reel := reel_detail.text

	var base := PlayerProgress.defaults()
	base.best_distance_by_mode["standard"] = 73390.0
	var fresh := FrontEndState.new()
	fresh.configure(PlayerSettings.defaults(), base)
	var fresh_view := FrontEndView.new()
	fresh_view.bind_state(fresh)
	var fresh_reel := fresh_view.find_child(
		"HomeLoadoutDetail0", true, false) as Label
	var fresh_level := fresh_view.find_child(
		"HomeLoadoutLevel0", true, false) as Label
	if fresh_reel == null or fresh_reel.text == upgraded_reel or \
			fresh_level == null or not fresh_level.text.begins_with("0/"):
		failures.append("Home loadout does not change with owned upgrades")
		fresh_view.free()
		view.free()
		return 0
	fresh_view.free()
	view.free()
	return 1


static func _test_tutorial_covers_current_mechanics(
	failures: PackedStringArray,
) -> int:
	var lesson_ids: Array[StringName] = []
	var goals: Array[StringName] = []
	var mechanic_counts := {}
	for lesson: Dictionary in FrontEndState.TUTORIAL_STEPS:
		var lesson_id := StringName(lesson.get("id", &""))
		var goal := StringName(lesson.get("goal", &""))
		if lesson_id == &"" or lesson_id in lesson_ids:
			failures.append("tutorial lesson ids are missing or duplicated")
			return 0
		if goal == &"" or goal in goals:
			failures.append("tutorial teaching goals are missing or duplicated")
			return 0
		if lesson.has("body") or lesson.has("tip"):
			failures.append("tutorial returned to paragraph-plus-tip teaching")
			return 0
		var points: Array = lesson.get("points", [])
		if points.size() != FrontEndState.TUTORIAL_POINT_COUNT:
			failures.append("tutorial lessons must expose three readable teaching points")
			return 0
		var point_labels := PackedStringArray()
		for point: Dictionary in points:
			var point_label := str(point.get("label", ""))
			var point_text := str(point.get("text", ""))
			if point_label.is_empty() or point_label in point_labels or \
					point_text.is_empty() or point_text.length() > 80:
				failures.append(
					"tutorial teaching points are missing, duplicated, or paragraph-sized")
				return 0
			point_labels.append(point_label)
		lesson_ids.append(lesson_id)
		goals.append(goal)
		for mechanic: StringName in lesson.get("mechanics", []):
			mechanic_counts[mechanic] = int(mechanic_counts.get(mechanic, 0)) + 1
	for expected_id: StringName in [
		&"opening_pressure", &"attach", &"swing_release", &"reel",
		&"anchor_burst", &"dive_recovery", &"read_course",
		&"survive_restart",
	]:
		if expected_id not in lesson_ids:
			failures.append("tutorial omits focused lesson: %s" % expected_id)
			return 0
	if lesson_ids.find(&"anchor_burst") == lesson_ids.find(&"dive_recovery"):
		failures.append("Burst and Dive still share one overloaded tutorial lesson")
		return 0
	for required: StringName in [
		&"opening_web", &"no_drive", &"earned_speed", &"bird_pressure",
		&"attach_legality", &"attach_range", &"aim_guides",
		&"swing_arc", &"release_momentum", &"poor_release",
		&"reel_rate", &"reel_radius", &"reel_energy", &"reel_recharge",
		&"slack_take_up", &"burst_aimed", &"burst_button",
		&"burst_fraction", &"burst_minimum", &"burst_charges",
		&"dive_fraction", &"dive_one_shot", &"dive_upper_rearm",
		&"pull_recovery", &"route_change", &"flies", &"obstacles",
		&"lethal_rails", &"burst_frenzy", &"regions", &"rescue",
		&"buckler_bounce", &"death_attribution", &"restart", &"menu",
	]:
		if int(mechanic_counts.get(required, 0)) != 1:
			failures.append(
				"tutorial mechanic %s must have one declared teaching owner" % required)
			return 0
	return 1


static func _test_tutorial_previews_use_live_assets_and_cosmetics(
	failures: PackedStringArray,
) -> int:
	var preview_source := FileAccess.get_file_as_string(
		"res://game/presentation/scripts/tutorial_preview.gd")
	var gameplay_source := FileAccess.get_file_as_string(
		"res://game/presentation/scripts/swing_lab.gd")
	if not gameplay_source.contains("CanopyObstacleArt.directional_spec"):
		failures.append("gameplay no longer shares canopy obstacle orientation")
		return 0
	for forbidden_factory in [
		"SwingLabSession.new(", "SimulationWorld.new(",
		"ProgressionService.new(", "SaveRepository.new(",
	]:
		if forbidden_factory in preview_source:
			failures.append(
				"tutorial preview took authoritative ownership through %s" % \
					forbidden_factory)
			return 0
	var selected_spider := SpiderCatalog.ANCHORITE
	var selected_asset := ArtAssetCatalog.spider_asset_id(selected_spider)
	var preview := TutorialPreview.new()
	preview.size = Vector2(620.0, 360.0)
	for lesson: Dictionary in FrontEndState.TUTORIAL_STEPS:
		preview.configure(
			lesson,
			true,
			selected_spider,
			PlayerProgress.STYLE_COMET,
			PlayerProgress.WEB_DEW,
		)
		var contract := preview.preview_contract()
		if StringName(contract.get("lesson_id", &"")) != \
				StringName(lesson.get("id", &"")) or \
				StringName(contract.get("spider_asset", &"")) != selected_asset or \
				StringName(contract.get("web_variant", &"")) != PlayerProgress.WEB_DEW:
			failures.append("tutorial preview ignores its lesson or selected cosmetics")
			preview.free()
			return 0
		var requested: Array[StringName] = contract["requested_assets"]
		var resolved: PackedStringArray = contract["resolved_assets"]
		var fallbacks: PackedStringArray = contract["fallback_assets"]
		var expected_callouts := TutorialPreview.lesson_callout_labels(lesson)
		var callouts: PackedStringArray = contract["callout_labels"]
		if requested.size() < 6 or resolved.size() != requested.size() or \
				not fallbacks.is_empty() or bool(contract.get("primitive_only", true)) or \
				callouts != expected_callouts or \
				callouts.size() != FrontEndState.TUTORIAL_POINT_COUNT:
			failures.append(
				"tutorial lesson %s does not resolve the live game art contract" % \
					lesson.get("id", ""))
			preview.free()
			return 0
		for obstacle_visual: Dictionary in contract.get("obstacle_visuals", []):
			var mounted_to_ceiling := StringName(obstacle_visual.get(
				"mount", &"")) == CanopyObstacleArt.MOUNT_CEILING
			if bool(obstacle_visual.get("flip_y", false)) != mounted_to_ceiling:
				failures.append("tutorial obstacle orientation disagrees with its mount")
				preview.free()
				return 0
		var frozen_phase := float(contract.get("motion_phase", -1.0))
		preview._process(3.0)
		if not is_equal_approx(
			frozen_phase,
			float(preview.preview_contract().get("motion_phase", -2.0)),
		):
			failures.append("Reduced Motion does not produce a stable tutorial pose")
			preview.free()
			return 0
	preview.free()
	var floor_hook := CanopyObstacleArt.directional_spec(
		CourseObstacleCatalog.CANOPY_HOOK_VINE_RIGHT,
		CanopyObstacleArt.MOUNT_FLOOR,
	)
	var ceiling_hook := CanopyObstacleArt.directional_spec(
		CourseObstacleCatalog.CANOPY_HOOK_VINE_RIGHT,
		CanopyObstacleArt.MOUNT_CEILING,
	)
	if floor_hook.is_empty() or ceiling_hook.is_empty() or \
			bool(floor_hook.get("flip_y", true)) or \
			not bool(ceiling_hook.get("flip_y", false)):
		failures.append("shared canopy orientation does not flip only ceiling art")
		return 0
	return 1


static func _test_tutorial_is_enclosed_on_short_landscapes(
	failures: PackedStringArray,
) -> int:
	for viewport_size: Vector2i in [
		Vector2i(1280, 720), Vector2i(1280, 600), Vector2i(1040, 480),
	]:
		var state := FrontEndState.new()
		state.configure(PlayerSettings.defaults(), PlayerProgress.defaults())
		state.show_tutorial()
		var viewport := SubViewport.new()
		viewport.size = viewport_size
		var view := FrontEndView.new()
		view.size = Vector2(viewport_size)
		viewport.add_child(view)
		view.bind_state(state)
		var tutorial := view.find_child("Tutorial", true, false) as Control
		var copy_panel := view.find_child(
			"TutorialCopyWebPanel", true, false) as Control
		for node_name in [
			"AnimatedMechanicsPreview", "TutorialCopyWebPanel",
			"TutorialNavigation",
		]:
			var panel := view.find_child(node_name, true, false) as Control
			if panel == null or panel.anchor_left < 0.0 or panel.anchor_top < 0.0 or \
					panel.anchor_right > 1.0 or panel.anchor_bottom > 1.0:
				failures.append(
					"%s escapes tutorial at %s" % [node_name, viewport_size])
				viewport.free()
				return 0
		for index in range(FrontEndState.TUTORIAL_POINT_COUNT):
			var point_card := view.find_child(
				"TutorialPointCard%d" % (index + 1), true, false) as Control
			var cue := view.find_child(
				"TutorialPointCue%d" % (index + 1), true, false) as Label
			var point_text := view.find_child(
				"TutorialPointText%d" % (index + 1), true, false) as Label
			if copy_panel == null or point_card == null or cue == null or \
					point_text == null or cue.text.is_empty() or \
					point_text.text.is_empty() or \
					point_text.get_theme_font_size("font_size") < 17:
				failures.append("tutorial teaching points are not readable at %s" % viewport_size)
				viewport.free()
				return 0
		for button_name: StringName in [
			&"TutorialBack", &"TutorialPrevious", &"TutorialLessonAction",
			&"TutorialNext",
		]:
			var button := view.front_end_button(button_name)
			if button == null or button.custom_minimum_size.y < 80.0:
				failures.append(
					"%s is below the tutorial touch floor" % button_name)
				viewport.free()
				return 0
		if tutorial == null or not tutorial.find_children(
			"", "ScrollContainer", true, false).is_empty():
			failures.append("tutorial introduced a competing scroll/gesture owner")
			viewport.free()
			return 0
		if view.front_end_button(&"TutorialLessonAction").text != "START RUN":
			failures.append("ordinary tutorial launch is mislabeled as practice")
			viewport.free()
			return 0
		state.show_tutorial_lesson(&"attach")
		if view.front_end_button(&"TutorialLessonAction").text != \
				"PRACTISE LESSON":
			failures.append("practice-enabled tutorial action is not truthfully labeled")
			viewport.free()
			return 0
		viewport.free()
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
	state.set_music_volume(0.85)
	state.set_effects_enabled(false)
	state.set_haptics_enabled(false)
	state.set_debug_tools(false)
	state.set_swing_preset(&"not_a_real_preset")
	if published.size() != 7:
		failures.append("settings changes were not emitted exactly once each")
		return 0
	if state.settings.swing_preset != SwingConfig.PRESET_AGILE or \
			state.settings.show_control_hints or \
			not state.settings.reduced_motion or \
			not is_equal_approx(state.settings.music_volume, 0.85) or \
			state.settings.effects_enabled or \
			state.settings.haptics_enabled or \
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
	var music := view.find_child("MusicVolumeSlider", true, false) as HSlider
	var music_value := view.find_child(
		"MusicVolumeValue", true, false) as Label
	var effects := view.find_child("EffectsToggle", true, false) as CheckButton
	var haptics := view.find_child("HapticsToggle", true, false) as CheckButton
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
	if music == null or music_value == null or effects == null or haptics == null or \
			music.custom_minimum_size.y < 60.0 or \
			not is_equal_approx(music.min_value, 0.0) or \
			not is_equal_approx(music.max_value, 100.0) or \
			not is_equal_approx(music.step, 5.0) or \
			music_value.text != "50%" or \
			effects.custom_minimum_size.y < 52.0 or \
			haptics.custom_minimum_size.y < 52.0:
		failures.append("audio and haptic controls are missing or too small")
		view.free()
		return 0
	music.set_value_no_signal(100.0)
	music.value_changed.emit(100.0)
	if not is_equal_approx(
			state.settings.music_volume, PlayerSettings.MAX_MUSIC_VOLUME) or \
			music_value.text != "100%" or not state.settings.effects_enabled or \
			not state.settings.haptics_enabled:
		failures.append("Music slider changed another feedback setting or missed 100%")
		view.free()
		return 0
	music.set_value_no_signal(0.0)
	music.value_changed.emit(0.0)
	if not is_zero_approx(state.settings.music_volume) or \
			music_value.text != "OFF" or not state.settings.effects_enabled or \
			not state.settings.haptics_enabled:
		failures.append("Music slider does not reach independent true silence")
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
	expected.music_volume = 0.85
	expected.effects_enabled = false
	expected.haptics_enabled = false
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
	var legacy_on := PlayerSettings.from_dictionary({"schema_version": 3})
	var legacy_off := PlayerSettings.from_dictionary({
		"schema_version": 3,
		"music_enabled": false,
	})
	var clamped := PlayerSettings.from_dictionary({
		"schema_version": 4,
		"music_volume": 4.0,
	})
	if not is_equal_approx(
			legacy_on.music_volume, PlayerSettings.DEFAULT_MUSIC_VOLUME) or \
			not is_equal_approx(
				legacy_off.music_volume, PlayerSettings.MIN_MUSIC_VOLUME) or \
			not is_equal_approx(
				clamped.music_volume, PlayerSettings.MAX_MUSIC_VOLUME) or \
			not legacy_on.effects_enabled or not legacy_on.haptics_enabled:
		failures.append("older Music toggles did not migrate to exact slider levels")
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
	expected.music_volume = 0.8
	expected.effects_enabled = false
	expected.haptics_enabled = false
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


static func _test_debug_profile_repository_round_trip(
	failures: PackedStringArray,
) -> int:
	var settings_path := "user://debug_profile_test_settings.json"
	var progress_path := "user://debug_profile_test_progress.json"
	var profile_path := "user://debug_profile_test_profile.json"
	for path: String in [settings_path, progress_path, profile_path]:
		_remove_test_file(path)
		_remove_test_file("%s.tmp" % path)
		_remove_test_file("%s.bak" % path)
	var repository := SaveRepository.new(
		settings_path,
		progress_path,
		profile_path,
	)
	var expected := DebugTestProfile.defaults(SwingConfig.PRESET_BALANCED)
	expected.set_value(&"reel_rate", 440.0)
	expected.set_value(&"bird_speed", 680.0)
	expected.set_value(TuningCatalog.DEBUG_START_DISTANCE, 123450.0)
	expected.save_slot(&"a")
	expected.set_value(&"gravity", 1320.0)
	if not repository.save_debug_test_profile(expected):
		failures.append("SaveRepository could not atomically write Test Lab setup")
		return 0
	var actual := repository.load_debug_test_profile()
	var clamped := DebugTestProfile.from_dictionary({
		"working_values": {
			"reel_rate": 9999.0,
			"unknown_axis": 12.0,
		},
	})
	for path: String in [settings_path, progress_path, profile_path]:
		_remove_test_file(path)
		_remove_test_file("%s.tmp" % path)
		_remove_test_file("%s.bak" % path)
	if actual.to_dictionary() != expected.to_dictionary() or \
			not actual.has_slot(&"a") or \
			not is_equal_approx(clamped.value(&"reel_rate"), 720.0) or \
			clamped.to_dictionary()["working_values"].has("unknown_axis"):
		failures.append("Test Lab profile did not validate and round-trip independently")
		return 0
	return 1


## The editor shows resolved values, but only explicitly changed axes may be
## applied after spider/upgrade resolution. This guards the exact failure mode
## where auto-saving a full catalogue would turn L40 into a fixed baseline.
static func _test_debug_profile_preserves_unoverridden_progression(
	failures: PackedStringArray,
) -> int:
	var settings := PlayerSettings.defaults()
	settings.show_debug_tools = true
	var progress := PlayerProgress.defaults()
	var service := ProgressionService.new()
	var state := FrontEndState.new()
	state.configure(settings, progress, service)
	state.set_debug_run_upgrade_level(SpiderCatalog.MAX_UPGRADE_LEVEL)
	var comparison_service := ProgressionService.new()
	comparison_service.set_debug_upgrade_overlay_level(
		SpiderCatalog.MAX_UPGRADE_LEVEL)
	var expected_config := SpiderCatalog.resolved_config(
		settings.swing_preset,
		comparison_service.resolved_progress(progress),
	)
	DifficultyCatalog.apply_to_config(expected_config, state.selected_difficulty())
	var sparse := state.debug_tuning_overrides()
	if sparse.has(&"reel_rate") or \
			not is_equal_approx(
				state.debug_tuning_value(&"reel_rate"),
				expected_config.reel_retraction_rate,
			):
		failures.append("Test Lab flattened the unedited L40 Reel value")
		return 0
	var requests: Array[Dictionary] = []
	state.debug_play_requested.connect(func(
		_settings: PlayerSettings,
		_distance: float,
		_level: int,
		_bird: Dictionary,
		tuning: Dictionary,
	) -> void:
		requests.append(tuning.duplicate(true)))
	state.request_debug_play()
	if requests.size() != 1 or requests[0].has(&"reel_rate") or \
			service.debug_upgrade_overlay_level() != SpiderCatalog.MAX_UPGRADE_LEVEL:
		failures.append("Test Lab emitted resolved progression as a manual override")
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
		"_session.configure_run("
	) or not source.contains(
		"campaign_level_id,\n\t\ttutorial_lesson_id,"
	) or not source.contains(
		"_front_end_state.debug_tuning_request_is_valid("
	):
		failures.append("debug pre-run setup bypasses its composition-root guard")
		return 0
	if not source.contains(
		"_front_end_state.campaign_play_requested.connect(_start_campaign_game)"
	):
		failures.append("campaign start bypasses the composition root")
		return 0
	if not source.contains("load_debug_test_profile") or \
			not source.contains("save_debug_test_profile") or \
			not source.contains("apply_debug_tuning_profile"):
		failures.append("saved Test Lab profiles bypass repository or session ownership")
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
	# 5 km + 10 px, i.e. one region length: that unlocks whichever region starts
	# at 5 km, which after the 0.39.0 swap is Ancient Forest.
	if not migrated.has_region_checkpoint(
		CourseRegionCatalog.ANCIENT_FOREST) or \
			migrated.has_region_checkpoint(CourseRegionCatalog.SILK_HOLLOW) or \
			migrated.upgrade_level(&"classic_reel") != 10:
		failures.append(
			"schema-4 checkpoint migration did not scale its upgrade level once")
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
	view.front_end_button(&"PlayModesHub").pressed.emit()
	view.front_end_button(&"Practice").pressed.emit()
	var forest := view.front_end_button(&"PracticeAncientForest")
	var hollow := view.front_end_button(&"PracticeSilkHollow")
	if state.screen != FrontEndState.Screen.PRACTICE or \
			forest == null or hollow == null or \
			forest.disabled or not hollow.disabled:
		failures.append("practice route does not expose reached and locked regions")
		view.free()
		return 0
	forest.pressed.emit()
	hollow.pressed.emit()
	if requests != [CourseRegionCatalog.ANCIENT_FOREST]:
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
	view.front_end_button(&"SpiderHub").pressed.emit()
	view.front_end_button(&"Garage").pressed.emit()
	if state.screen != FrontEndState.Screen.GARAGE or \
			view.front_end_button(&"GaragePlay") == null:
		failures.append("Garage is not a functional Spider-hub route")
		view.free()
		return 0
	view.front_end_button(&"GarageBack").pressed.emit()
	view.front_end_button(&"Shop").pressed.emit()
	if state.screen != FrontEndState.Screen.SHOP or \
			view.front_end_button(&"ShopGarage") == null:
		failures.append("Shop is not a functional Spider-hub route")
		view.free()
		return 0
	view.front_end_button(&"ShopBack").pressed.emit()
	view.front_end_button(&"SpiderHubBack").pressed.emit()
	view.front_end_button(&"PlayModesHub").pressed.emit()
	view.front_end_button(&"Creator").pressed.emit()
	if state.screen != FrontEndState.Screen.CREATOR or \
			view.front_end_button(&"CreatorPlay") == null or \
			view.front_end_button(&"CourseSlot0") == null:
		failures.append("Course Lab is not a functional Play-Modes route")
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
	view.front_end_button(&"SpiderHub").pressed.emit()
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
		var entry := view.find_child(entry_name, true, false) as Button
		if entry == null or entry.custom_minimum_size.y < 64.0:
			failures.append("the Field Guide omits %s" % spider_id)
			view.free()
			return 0
		entry.pressed.emit()
		if state.field_guide_spider_id != spider_id or \
				not view._field_guide_inspiration.text.begins_with("INSPIRED BY") or \
				view._field_guide_real.text.is_empty() or \
				view._field_guide_game.text.is_empty() or \
				view._field_guide_sources.text.is_empty():
			failures.append(
				"%s does not resolve separate real, game, and source detail" % spider_id)
			view.free()
			return 0
	for section_name in [
		"FieldGuideSectionRealAnimal",
		"FieldGuideSectionInSpiderSwing",
		"FieldGuideSectionFieldNote",
		"FieldGuideSectionSources",
	]:
		if view.find_child(section_name, true, false) == null:
			failures.append("Field Guide lacks glance-readable section %s" % section_name)
			view.free()
			return 0
	# The guide is entered from the Guide hub and Garage, so back must follow
	# the route the player actually took rather than guessing.
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
	view.front_end_button(&"GuideHub").pressed.emit()
	view.front_end_button(&"FieldGuide").pressed.emit()
	if state.screen != FrontEndState.Screen.FIELD_GUIDE:
		failures.append("Guide hub does not route to the Field Guide")
		view.free()
		return 0
	if not guide_back.text.contains("GUIDE"):
		failures.append("the Field Guide back route does not follow its origin")
		view.free()
		return 0
	guide_back.pressed.emit()
	if state.screen != FrontEndState.Screen.GUIDE_HUB:
		failures.append("the Field Guide does not return to Guide hub")
		view.free()
		return 0
	view.front_end_button(&"GuideHubBack").pressed.emit()
	view.front_end_button(&"SpiderHub").pressed.emit()
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


static func _test_spider_web_theme_is_reusable_and_layout_passive(
	failures: PackedStringArray,
) -> int:
	var material: Dictionary = SpiderWebPanelScript.material_geometry(
		Vector2(480.0, 240.0))
	if (material["grain"] as Array).size() != 72 or \
			(material["pits"] as Array).size() != 24 or \
			maxf(
				SpiderUiTheme.PANEL.r,
				maxf(SpiderUiTheme.PANEL.g, SpiderUiTheme.PANEL.b),
			) - minf(
				SpiderUiTheme.PANEL.r,
				minf(SpiderUiTheme.PANEL.g, SpiderUiTheme.PANEL.b),
			) > 0.04:
		failures.append("front-end surface is not neutral textured slate")
		return 0
	for grain: PackedVector2Array in material["grain"]:
		for point: Vector2 in grain:
			if point.x < 0.0 or point.x > 480.0 or \
					point.y < 0.0 or point.y > 240.0:
				failures.append("slate grain escaped its reusable card")
				return 0
	for pit: Vector2 in material["pits"]:
		if pit.x < 0.0 or pit.x > 480.0 or pit.y < 0.0 or pit.y > 240.0:
			failures.append("slate pit escaped its reusable card")
			return 0
	var geometry: Dictionary = SpiderWebPanelScript.ornament_geometry(
		Vector2(480.0, 240.0))
	if (geometry["fibres"] as Array).size() < 8 or \
			(geometry["spokes"] as Array).size() != 12 or \
			(geometry["rings"] as Array).size() != 6 or \
			(geometry["knots"] as Array).size() != 6 or \
			(geometry["cocoons"] as Array).size() != 2:
		failures.append(
			"spider-web cards lost fibres, tension webs, knots, or cocoons")
		return 0
	for group_name in ["fibres", "spokes", "rings", "cocoons"]:
		for shape: PackedVector2Array in geometry[group_name]:
			for point: Vector2 in shape:
				if point.x < 0.0 or point.x > 480.0 or \
						point.y < 0.0 or point.y > 240.0:
					failures.append(
						"spider-web card ornament escaped its visual bounds")
					return 0
	for knot: Vector2 in geometry["knots"]:
		if knot.x < 0.0 or knot.x > 480.0 or \
				knot.y < 0.0 or knot.y > 240.0:
			failures.append("spider-web silk knot escaped its visual bounds")
			return 0

	var button_style := SpiderUiTheme.button_style(
		SpiderUiTheme.PANEL_SOFT, SpiderUiTheme.MOSS)
	if button_style.corner_radius_top_left >= \
			button_style.corner_radius_top_right or \
			button_style.corner_radius_bottom_right >= \
			button_style.corner_radius_bottom_left or \
			not button_style.border_blend:
		failures.append("buttons lost their tensioned cocoon silhouette")
		return 0

	var progress := PlayerProgress.defaults()
	progress.selected_spider_id = SpiderCatalog.ANCHORITE
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults(), progress)
	var view := FrontEndView.new()
	view.bind_state(state)
	for panel_name in [
		"HomeWebPanel",
		"GarageDetailWebPanel",
		"ShopWebPanel",
		"DebugRunSetupCard",
	]:
		var panel := view.find_child(panel_name, true, false) as PanelContainer
		if panel == null or panel.get_script() != SpiderWebPanelScript or \
				panel.mouse_filter != Control.MOUSE_FILTER_PASS:
			failures.append(
				"%s does not use the passive reusable spider-web card" % panel_name)
			view.free()
			return 0
	var garage_panel := view.find_child(
		"GarageDetailWebPanel", true, false) as PanelContainer
	var shop_panel := view.find_child(
		"ShopWebPanel", true, false) as PanelContainer
	var expected_accent := SpiderUiTheme.SAP
	if not (garage_panel.get("accent_color") as Color).is_equal_approx(
			expected_accent) or \
			not (shop_panel.get("accent_color") as Color).is_equal_approx(
				expected_accent):
		failures.append("Garage and Shop do not carry the selected spider accent")
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
			not core.text.contains("LEVEL 0/40"):
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
			not rule.text.contains("Every fifth level through 40") or \
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
				"8 breakthroughs earned · 48 tuning steps total"):
		failures.append(
			"maxed Shop card does not summarize its eight bonus steps")
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
	session.run_finalized.connect(func(
		value: RunSettlement,
		_record: RunRecord,
	) -> void:
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
	service.set_debug_upgrade_overlay_level(SpiderCatalog.MAX_UPGRADE_LEVEL)
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
			not upgrade.text.contains("DEBUG OVERLAY LEVEL 40/40") or \
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


## The overlay was only ever released when the *next* normal run was launched,
## so a debug run left the menu quoting borrowed levels and refusing purchases
## until the player stumbled onto Play or the DEBUG toggle. Owner-reported on
## 0.34.0: "the upgrades for my spider are not available anymore until I play a
## normal run first."
static func _test_debug_overlay_ends_with_the_run_it_was_launched_for(
	failures: PackedStringArray,
) -> int:
	var settings := PlayerSettings.defaults()
	settings.show_debug_tools = true
	var progress := PlayerProgress.defaults()
	progress.spendable_flies = 500
	progress.upgrade_levels["classic_reel"] = 7
	var owned := progress.to_dictionary()
	var service := ProgressionService.new()
	var state := FrontEndState.new()
	state.configure(settings, progress, service)
	var purchases: Array[StringName] = []
	state.upgrade_purchase_requested.connect(func(upgrade_id: StringName) -> void:
		purchases.append(upgrade_id))
	var launches: Array[int] = []
	state.debug_play_requested.connect(func(
		_settings: PlayerSettings,
		_distance: float,
		level: int,
		_bird: Dictionary,
		_tuning: Dictionary,
	) -> void:
		launches.append(level))

	state.show_debug_run_setup()
	state.set_debug_run_upgrade_level(20)
	state.request_quick_debug_play()
	if launches != [20] or not state.debug_upgrade_overlay_enabled() or \
			state.displayed_upgrade_level(&"classic_reel") != 20:
		failures.append("quick debug launch did not apply its upgrade overlay")
		return 0
	state.request_upgrade_purchase(&"classic_reel")
	if not purchases.is_empty():
		failures.append("a borrowed-level run still routed a purchase")
		return 0

	# Exactly what the composition root does when the run hands the menu back.
	state.end_debug_run_overlay()
	if state.debug_upgrade_overlay_enabled() or \
			state.displayed_upgrade_level(&"classic_reel") != 7 or \
			state.progress.to_dictionary() != owned:
		failures.append("returning to the menu did not release the run overlay")
		return 0
	state.request_upgrade_purchase(&"classic_reel")
	if purchases != [&"classic_reel"]:
		failures.append("owned upgrades stayed unspendable after a debug run")
		return 0
	# The launcher keeps its remembered level, so the next debug run is unchanged.
	if state.debug_run_upgrade_level != 20:
		failures.append("releasing the overlay also forgot the launcher setting")
		return 0

	var file := FileAccess.open("res://game/bootstrap/main.gd", FileAccess.READ)
	if file == null:
		failures.append("composition root source cannot be read")
		return 0
	var show_front_end := file.get_as_text().split("func _show_front_end()")
	if show_front_end.size() != 2 or not show_front_end[1].split("\nfunc ")[0] \
			.contains("_front_end_state.end_debug_run_overlay()"):
		failures.append("returning to the menu does not release the run overlay")
		return 0
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
	if not route.visible or not route.text.contains("QUICK SETUP"):
		failures.append("quick Debug Test Run did not appear after enabling debug tools")
		viewport.free()
		return 0
	route.pressed.emit()
	var quick_screen := view.find_child(
		"DebugRunSetupScreen", true, false) as Control
	var card := view.find_child("DebugRunSetupCard", true, false) as Control
	var shell := view.find_child(
		"DebugRunSetupShell", true, false) as VBoxContainer
	var scroll := view.find_child(
		"DebugRunSetupScroll", true, false) as ScrollContainer
	var columns := view.find_child(
		"DebugRunSetupColumns", true, false) as HBoxContainer
	var entry := view.find_child(
		"DebugRunDistanceEntry", true, false) as LineEdit
	var warning := view.find_child(
		"DebugRunAwardsWarning", true, false) as Label
	var start := view.front_end_button(&"DebugRunStart")
	var advanced := view.front_end_button(&"DebugTestLab")
	var quick_bird_label := view.find_child(
		"DebugQuickBirdLabel_bird_speed", true, false) as Label
	if state.screen != FrontEndState.Screen.DEBUG_RUN_SETUP or \
			quick_screen == null or not quick_screen.visible or card == null or \
			shell == null or scroll == null or columns == null or entry == null or \
			warning == null or start == null or advanced == null or \
			quick_bird_label == null or \
			not warning.text.contains("NO RECORDS") or columns.get_child_count() != 3:
		failures.append("debug route did not restore the compact launch form")
		viewport.free()
		return 0
	if card.anchor_left < 0.0 or card.anchor_top < 0.0 or \
			card.anchor_right > 1.0 or card.anchor_bottom > 1.0:
		failures.append("quick debug setup card is not enclosed by the view")
		viewport.free()
		return 0
	if start.get_parent() != shell or start.get_index() <= scroll.get_index() or \
			scroll.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_AUTO or \
			scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED or \
			quick_bird_label.custom_minimum_size.x > 78.0 or \
			start.mouse_filter != Control.MOUSE_FILTER_STOP or \
			start.custom_minimum_size.y < 60.0 or \
			advanced.custom_minimum_size.y < 56.0:
		failures.append("quick setup lost its phone-width row, pinned start, or Advanced route")
		viewport.free()
		return 0
	for button_name: StringName in [
		&"DebugDistanceQuick0", &"DebugDistanceQuick1",
		&"DebugDistanceQuick2", &"DebugDistanceQuick3",
		&"DebugUpgradeQuick0", &"DebugUpgradeQuick1",
		&"DebugUpgradeQuick2", &"DebugUpgradeQuick3",
		&"DebugQuickBirdPreset_off", &"DebugQuickBirdPreset_slow",
		&"DebugQuickBirdPreset_base", &"DebugQuickBirdPreset_fast",
	]:
		if view.front_end_button(button_name) == null:
			failures.append("quick setup is missing %s" % button_name)
			viewport.free()
			return 0

	# A hidden advanced override must remain saved without leaking into a quick
	# launch whose screen does not disclose it.
	state.set_debug_tuning_value(&"reel_rate", 440.0)
	state.set_debug_run_upgrade_level(6)
	view.front_end_button(&"DebugQuickBirdPreset_slow").pressed.emit()
	entry.text = "12345,7"
	entry.text_changed.emit(entry.text)
	var debug_requests: Array[Dictionary] = []
	state.debug_play_requested.connect(func(
		requested_settings: PlayerSettings,
		distance_pixels: float,
		upgrade_level: int,
		bird_overrides: Dictionary,
		tuning_overrides: Dictionary,
	) -> void:
		debug_requests.append({
			"debug": requested_settings.show_debug_tools,
			"distance": distance_pixels,
			"level": upgrade_level,
			"bird": bird_overrides.duplicate(true),
			"tuning": tuning_overrides.duplicate(true),
		}))
	start.pressed.emit()
	if debug_requests.size() != 1 or not bool(debug_requests[0]["debug"]) or \
			not is_equal_approx(float(debug_requests[0]["distance"]), 123457.0) or \
			int(debug_requests[0]["level"]) != 6 or \
			debug_requests[0]["bird"] != \
				FrontEndState.BIRD_DEBUG_PRESETS[&"slow"] or \
			not (debug_requests[0]["tuning"] as Dictionary).is_empty() or \
			not state.debug_tuning_request_is_valid({}) or \
			service.debug_upgrade_overlay_level() != 6 or \
			progress.to_dictionary() != exact_saved:
		failures.append("quick launch leaked hidden tuning or changed ownership")
		viewport.free()
		return 0

	var session := SwingLabSession.new()
	session.configure_progress(progress, service)
	session.configure_bird_debug_overrides(debug_requests[0]["bird"])
	session.configure_run(
		SwingLabSession.RUN_PRACTICE,
		123457.0,
		913,
		true,
	)
	session._reset_run()
	session.apply_debug_tuning_profile(debug_requests[0]["tuning"])
	var snapshot := session.current_snapshot()
	if not snapshot.debug_start_active or snapshot.records_eligible or \
			not is_equal_approx(snapshot.distance_pixels, 123457.0) or \
			snapshot.debug_upgrade_overlay_level != 6 or \
			not is_equal_approx(
				float(snapshot.tuning_values[&"bird_speed"]), 240.0) or \
			is_equal_approx(float(snapshot.tuning_values[&"reel_rate"]), 440.0):
		failures.append("quick launch did not apply only its visible conditions")
		session.free()
		viewport.free()
		return 0
	session.free()

	advanced.pressed.emit()
	var lab_screen := view.find_child(
		"DebugTestLabScreen", true, false) as Control
	var lab_shell := view.find_child(
		"DebugTestLabShell", true, false) as VBoxContainer
	var profile_strip := view.find_child(
		"DebugProfileStrip", true, false) as PanelContainer
	var category_rail := view.find_child(
		"DebugCategoryRail", true, false) as GridContainer
	var category_stack := view.find_child(
		"DebugCategoryStack", true, false) as Control
	var footer := view.find_child(
		"DebugTestLabFooter", true, false) as HBoxContainer
	var lab_start := view.front_end_button(&"DebugTestLabStart")
	if state.screen != FrontEndState.Screen.DEBUG_TEST_LAB or \
			lab_screen == null or not lab_screen.visible or lab_shell == null or \
			profile_strip == null or category_rail == null or category_stack == null or \
			footer == null or lab_start == null or category_rail.columns != 8 or \
			category_rail.get_child_count() != 8 or \
			state.debug_tuning_request_is_valid({}):
		failures.append("Advanced Test Lab is not distinct from the quick launcher")
		viewport.free()
		return 0
	if lab_start.get_parent() != footer or footer.get_parent() != lab_shell or \
			footer.get_index() <= category_stack.get_index():
		failures.append("Advanced Test Lab lost its pinned launch action")
		viewport.free()
		return 0
	if category_rail.columns != 8 or category_rail.get_child_count() != 8:
		failures.append("Test Lab does not expose all eight pre-run categories")
		viewport.free()
		return 0
	for category_id: StringName in FrontEndView.TEST_LAB_CATEGORIES:
		var category_index := TuningCatalog.category_index(category_id)
		var category_button := view.front_end_button(
			StringName("DebugCategory_%s" % category_id))
		var category_panel := view.find_child(
			"DebugCategoryPanel_%s" % category_id, true, false) as Control
		var category_scroll := view.find_child(
			"DebugTestLabScroll_%s" % category_id,
			true,
			false,
		) as ScrollContainer
		if category_button == null or category_panel == null or \
				category_scroll == null or \
				category_scroll.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_AUTO or \
				category_scroll.horizontal_scroll_mode != \
					ScrollContainer.SCROLL_MODE_DISABLED:
			failures.append("%s is not a mobile Test Lab category" % category_id)
			viewport.free()
			return 0
		category_button.pressed.emit()
		if state.debug_category_index != category_index or not category_panel.visible:
			failures.append("%s does not become the selected Test Lab category" % category_id)
			viewport.free()
			return 0
		for parameter: Dictionary in TuningCatalog.parameters_for_category(
			category_id):
			var parameter_id := StringName(parameter["id"])
			var parameter_card := view.find_child(
				"DebugParameter_%s" % parameter_id, true, false) as PanelContainer
			var minus := view.front_end_button(
				StringName("DebugTuningMinus_%s" % parameter_id))
			var plus := view.front_end_button(
				StringName("DebugTuningPlus_%s" % parameter_id))
			if parameter_card == null or minus == null or plus == null or \
					minus.custom_minimum_size.y < 48.0 or \
					plus.custom_minimum_size.y < 48.0:
				failures.append("%s lacks direct mobile pre-run controls" % parameter_id)
				viewport.free()
				return 0

	# The working set saves immediately; A captures the whole catalogue and can
	# later restore it after multiple values diverge.
	var profile_events: Array[DebugTestProfile] = []
	state.debug_test_profile_changed.connect(func(profile: DebugTestProfile) -> void:
		profile_events.append(profile))
	state.set_debug_tuning_value(&"reel_rate", 440.0)
	view.front_end_button(&"DebugProfileSave_a").pressed.emit()
	state.set_debug_tuning_value(&"reel_rate", 520.0)
	state.set_debug_tuning_value(&"gravity", 1320.0)
	if state.debug_test_profile.slot_difference_count(&"a") != 2:
		failures.append("saved comparison A does not report its two changed axes")
		viewport.free()
		return 0
	view.front_end_button(&"DebugProfileLoad_a").pressed.emit()
	if not is_equal_approx(state.debug_tuning_value(&"reel_rate"), 440.0) or \
			not is_equal_approx(state.debug_tuning_value(&"gravity"), 1120.0) or \
			profile_events.size() < 4:
		failures.append("comparison A did not restore the complete auto-saved setup")
		viewport.free()
		return 0

	lab_start.pressed.emit()
	if debug_requests.size() != 2 or \
			not is_equal_approx(float(
				(debug_requests[1]["tuning"] as Dictionary)[&"reel_rate"]), 440.0) or \
			not state.debug_tuning_request_is_valid(
				debug_requests[1]["tuning"] as Dictionary):
		failures.append("Advanced Test Lab did not apply its saved sparse overrides")
		viewport.free()
		return 0

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
	route.pressed.emit()
	state.request_debug_play()
	if route.visible or state.screen != FrontEndState.Screen.HOME or \
			debug_requests.size() != 2:
		failures.append("pre-run debug controls bypassed show_debug_tools gating")
		viewport.free()
		return 0
	viewport.free()
	return 1


static func _test_debug_bird_presets_change_only_test_profile(
	failures: PackedStringArray,
) -> int:
	var settings := PlayerSettings.defaults()
	settings.show_debug_tools = true
	var state := FrontEndState.new()
	state.configure(settings)
	var original_settings := state.settings.to_dictionary()
	for preset_id: StringName in [&"off", &"slow", &"base", &"fast"]:
		state.apply_debug_bird_preset(preset_id)
		var expected: Dictionary = FrontEndState.BIRD_DEBUG_PRESETS[preset_id]
		if state.debug_bird_overrides() != expected:
			failures.append("%s bird preset did not stage all three axes" % preset_id)
			return 0
	state.apply_debug_bird_preset(&"off")
	if not is_zero_approx(state.debug_bird_speed) or \
			not is_equal_approx(state.debug_bird_acceleration, 12.0) or \
			state.settings.to_dictionary() != original_settings:
		failures.append("bird-off changed player settings instead of only Test Lab")
		return 0
	state.adjust_debug_bird_value(&"bird_speed", 1)
	state.adjust_debug_bird_value(&"bird_acceleration", -1)
	state.adjust_debug_bird_value(&"bird_start_offset", 1)
	if not is_equal_approx(state.debug_bird_speed, 20.0) or \
			not is_equal_approx(state.debug_bird_acceleration, 10.0) or \
			not is_equal_approx(state.debug_bird_start_offset, 800.0):
		failures.append("bird −/+ controls did not use the published steps")
		return 0
	return 1


static func _test_debug_bird_controls_are_visible_and_labeled(
	failures: PackedStringArray,
) -> int:
	var settings := PlayerSettings.defaults()
	settings.show_debug_tools = true
	var state := FrontEndState.new()
	state.configure(settings)
	state.show_debug_test_lab()
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	var view := FrontEndView.new()
	view.size = Vector2(viewport.size)
	viewport.add_child(view)
	view.bind_state(state)
	view.front_end_button(&"DebugCategory_pacing").pressed.emit()
	var card := view.find_child(
		"DebugCategoryPanel_pacing", true, false) as Control
	var presets := view.find_child("DebugBirdPresets", true, false) as Control
	if card == null or presets == null or not card.visible or \
			presets.get_child_count() != 5:
		failures.append("Test Lab does not expose bird tuning inside Pacing")
		viewport.free()
		return 0
	for preset_id: StringName in [&"off", &"slow", &"base", &"fast"]:
		var button := view.front_end_button(
			StringName("DebugBirdPreset_%s" % preset_id))
		if button == null or button.custom_minimum_size.y < 44.0 or \
				button.text != str(preset_id).to_upper():
			failures.append("bird comparison preset is missing or unreadable")
			viewport.free()
			return 0
	view.front_end_button(&"DebugBirdPreset_off").pressed.emit()
	var speed_label := view.find_child(
		"DebugTuningValue_bird_speed", true, false) as Label
	if speed_label == null or speed_label.text != "OFF":
		failures.append("bird speed zero is not visibly labeled OFF")
		viewport.free()
		return 0
	view.front_end_button(&"DebugBirdPreset_fast").pressed.emit()
	if not speed_label.text.contains("38.0 m/s") or \
			not is_equal_approx(state.debug_bird_start_offset, 600.0):
		failures.append("FAST preset does not show its exact comparison values")
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
			progress.spendable_flies != 19 or \
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
	if migrated.upgrade_level(&"classic_reel") != 8 or \
			migrated.upgrade_level(&"classic_burst_floor") != 40 or \
			migrated.upgrade_level(&"skitter_size") != 24 or \
			migrated.upgrade_levels.has("unknown_track"):
		failures.append("legacy five-level progress did not migrate to forty levels")
		return 0
	var round_trip := PlayerProgress.from_dictionary(migrated.to_dictionary())
	if round_trip.upgrade_level(&"classic_reel") != 8 or \
			round_trip.upgrade_level(&"classic_burst_floor") != 40 or \
			round_trip.upgrade_level(&"skitter_size") != 24:
		failures.append("current-schema upgrade levels were migrated twice")
		return 0
	var schema_seven := PlayerProgress.from_dictionary({
		"schema_version": 7,
		"upgrade_levels": {
			"classic_reel": 1,
			"classic_burst": 5,
			"classic_reel_capacity": 10,
			"classic_reel_recovery": 20,
		},
	})
	if schema_seven.upgrade_level(&"classic_reel") != 2 or \
			schema_seven.upgrade_level(&"classic_burst") != 10 or \
			schema_seven.upgrade_level(&"classic_reel_capacity") != 20 or \
			schema_seven.upgrade_level(&"classic_reel_recovery") != 40:
		failures.append("schema-7 twenty-level ownership was not doubled once")
		return 0
	return 1


static func _remove_test_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


## The Advanced Test Lab must offer the bundled lab runs, and only when Debug
## Tools are on. The quick launcher stays deliberately free of replay controls.
##
## The review loop is the whole point of recording traces: a search rewarded
## for distance will use whatever the physics allows, and no statistic
## separates "played well" from "found a loophole" — a person watching it does.
## If this route is unreachable, every trace in the build is inert.
##
## The request must also carry the trace's OWN path rather than the staged
## distance and upgrade level on the same screen: the trace names the world it
## was recorded in, and letting the screen's controls override that would
## replay a different run under the reported run's name.
static func _test_trace_watch_is_reachable_and_debug_only(
	failures: PackedStringArray,
) -> int:
	var settings := PlayerSettings.defaults()
	settings.show_debug_tools = true
	var state := FrontEndState.new()
	state.configure(settings, PlayerProgress.defaults(), ProgressionService.new())
	var requested: Array[String] = []
	state.trace_watch_requested.connect(
		func(_settings: PlayerSettings, path: String) -> void:
			requested.append(path))

	var traces := state.available_traces()
	if traces.is_empty():
		failures.append("no bundled traces are offered on the Test Run screen")
		return 0
	state.show_debug_test_lab()
	var view := FrontEndView.new()
	view.bind_state(state)
	var watch := view.find_child("DebugTraceWatch", true, false)
	var picker := view.find_child("DebugTracePicker", true, false)
	if watch == null or picker == null:
		failures.append("the Test Run screen has no trace picker or watch button")
		view.free()
		return 0
	var label := view.find_child("DebugTraceLabel", true, false) as Label
	if label == null or label.text.is_empty():
		failures.append("the trace picker shows no trace")
		view.free()
		return 0
	view.free()

	# Stepping must actually move the selection — a +1/−1 round trip returning
	# to the start is satisfied by a picker that never moves at all, which is
	# the bug the first version of this assertion could not see. Two traces
	# are bundled precisely so this has something real to step between.
	var first := str(state.selected_trace()["path"])
	if traces.size() >= 2:
		state.select_debug_trace(1)
		if str(state.selected_trace()["path"]) == first:
			failures.append("stepping the trace picker did not change the selection")
			return 0
		state.select_debug_trace(-1)
	if str(state.selected_trace()["path"]) != first:
		failures.append("stepping forward and back did not return to the start")
		return 0

	state.request_watch_trace()
	if requested.size() != 1 or requested[0] != first:
		failures.append("watching the selected trace did not request its path")
		return 0

	# Debug-only, like every other route on this screen.
	var plain := PlayerSettings.defaults()
	plain.show_debug_tools = false
	var locked := FrontEndState.new()
	locked.configure(plain, PlayerProgress.defaults(), ProgressionService.new())
	var blocked: Array[String] = []
	locked.trace_watch_requested.connect(
		func(_settings: PlayerSettings, path: String) -> void:
			blocked.append(path))
	locked.request_watch_trace()
	if not blocked.is_empty():
		failures.append("trace watching fired with Debug Tools disabled")
		return 0
	return 1

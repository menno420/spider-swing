extends RefCounted
class_name TutorialPracticeCatalog
## Application-owned tutorial objectives and deterministic launch metadata.
##
## The catalog observes authoritative `SimulationEvent` facts but never owns
## movement, input, settlement, progression, or persistence. Session-local
## objective state is intentionally disposable: replaying a lesson is always
## available and completing one writes nothing to the save.

const OBJECTIVE_ATTACH := &"tutorial_attach"
const OBJECTIVE_RELEASE_MOMENTUM := &"tutorial_release_momentum"
const OBJECTIVE_REEL := &"tutorial_reel"
const OBJECTIVE_BURST := &"tutorial_anchor_burst"
const OBJECTIVE_DIVE_RECOVERY := &"tutorial_dive_recovery"

const LESSONS := [
	{
		"lesson_id": &"opening_pressure",
		"practice_available": false,
		"objective_id": &"",
		"fixed_seed": -1,
		"start_distance_pixels": 0.0,
		"objective": "",
		"coaching": "",
	},
	{
		"lesson_id": &"attach",
		"practice_available": true,
		"objective_id": OBJECTIVE_ATTACH,
		"fixed_seed": 5101,
		"start_distance_pixels": 0.0,
		"objective": "Attach one web to a legal solid target.",
		"coaching": "Tap a solid ceiling or anchorable obstacle inside web range.",
	},
	{
		"lesson_id": &"swing_release",
		"practice_available": true,
		"objective_id": OBJECTIVE_RELEASE_MOMENTUM,
		"fixed_seed": 5102,
		"start_distance_pixels": 0.0,
		"objective": "Release from a rising arc and earn forward momentum.",
		"coaching": "Build a wide arc, then release while the spider is rising.",
	},
	{
		"lesson_id": &"reel",
		"practice_available": true,
		"objective_id": OBJECTIVE_REEL,
		"shared_campaign_level_id": CampaignCatalog.TEACH_REEL,
		"required_verb": CampaignCatalog.VERB_REEL,
		"fixed_seed": 5103,
		"start_distance_pixels": 0.0,
		"objective": "Shorten an attached web with REEL.",
		"coaching": "Attach first, then hold REEL until the line starts shortening.",
	},
	{
		"lesson_id": &"anchor_burst",
		"practice_available": true,
		"objective_id": OBJECTIVE_BURST,
		"shared_campaign_level_id": CampaignCatalog.TEACH_BURST,
		"required_verb": CampaignCatalog.VERB_BURST,
		"fixed_seed": 5104,
		"start_distance_pixels": 0.0,
		"objective": "Start one Anchor Burst.",
		"coaching": "Double-tap a solid above, or use BURST for the fallback target.",
	},
	{
		"lesson_id": &"dive_recovery",
		"practice_available": true,
		"objective_id": OBJECTIVE_DIVE_RECOVERY,
		"shared_campaign_level_id": CampaignCatalog.TEACH_DIVE,
		"required_verb": CampaignCatalog.VERB_DIVE,
		"fixed_seed": 5105,
		"start_distance_pixels": 0.0,
		"objective": "Dive Pull, then attach an upper recovery web to rearm Dive.",
		"coaching": "Tap a solid below, then secure a solid above when Dive is spent.",
	},
	{
		"lesson_id": &"read_course",
		"practice_available": false,
		"objective_id": &"",
		"fixed_seed": -1,
		"start_distance_pixels": 0.0,
		"objective": "",
		"coaching": "",
	},
	{
		"lesson_id": &"survive_restart",
		"practice_available": false,
		"objective_id": &"",
		"fixed_seed": -1,
		"start_distance_pixels": 0.0,
		"objective": "",
		"coaching": "",
	},
]


static func all_lessons() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for lesson: Dictionary in LESSONS:
		result.append(lesson.duplicate(true))
	return result


static func lesson(lesson_id: StringName) -> Dictionary:
	for entry: Dictionary in LESSONS:
		if StringName(entry.get("lesson_id", &"")) == lesson_id:
			return entry.duplicate(true)
	return {}


static func has_lesson(lesson_id: StringName) -> bool:
	return not lesson(lesson_id).is_empty()


static func practice_available(lesson_id: StringName) -> bool:
	return bool(lesson(lesson_id).get("practice_available", false))


static func initial_progress(lesson_id: StringName) -> Dictionary:
	if not practice_available(lesson_id):
		return {}
	return {
		"lesson_id": lesson_id,
		"objective_id": StringName(lesson(lesson_id).get("objective_id", &"")),
		"stage": 0,
		"complete": false,
	}


## Return new session-local progress after one authoritative event. Distance is
## deliberately absent: surviving or crossing a coordinate cannot prove an
## attach, a quality release, or the requested verb.
static func observe(
	lesson_id: StringName,
	progress: Dictionary,
	event: SimulationEvent,
) -> Dictionary:
	var next := progress.duplicate(true)
	if next.is_empty() or bool(next.get("complete", false)):
		return next
	var objective_id := StringName(next.get("objective_id", &""))
	match objective_id:
		OBJECTIVE_ATTACH:
			if event.kind == SimulationEvent.Kind.ATTACHED:
				next["complete"] = true
		OBJECTIVE_RELEASE_MOMENTUM:
			if event.kind == SimulationEvent.Kind.RELEASED and \
					float(event.data.get("forward_bonus", 0.0)) > 0.001:
				next["complete"] = true
		OBJECTIVE_REEL, OBJECTIVE_BURST:
			var required := StringName(lesson(lesson_id).get("required_verb", &""))
			if CampaignCatalog.verb_for_event_kind(event.kind) == required:
				next["complete"] = true
		OBJECTIVE_DIVE_RECOVERY:
			if int(next.get("stage", 0)) == 0 and \
					CampaignCatalog.verb_for_event_kind(event.kind) == \
					CampaignCatalog.VERB_DIVE:
				next["stage"] = 1
			elif int(next.get("stage", 0)) == 1 and \
					event.kind == SimulationEvent.Kind.ATTACHED and \
					bool(event.data.get("dive_rearmed", false)):
				next["stage"] = 2
				next["complete"] = true
	return next


static func progress_text(lesson_id: StringName, progress: Dictionary) -> String:
	if bool(progress.get("complete", false)):
		return "ACTION COMPLETE"
	if StringName(progress.get("objective_id", &"")) == OBJECTIVE_DIVE_RECOVERY:
		return (
			"DIVE STARTED · ATTACH AN UPPER RECOVERY WEB"
			if int(progress.get("stage", 0)) == 1
			else "DIVE PULL · THEN RECOVER ABOVE"
		)
	return str(lesson(lesson_id).get("objective", "")).to_upper()

extends RefCounted
class_name AudioAssetCatalog
## Presentation-only mapping from authoritative events to original SFX assets.
##
## Simulation decides what happened. This catalog only decides which audible
## treatment represents that fact; variant order and cooldowns cannot feed back
## into gameplay.

const ROOT := "res://assets/runtime/audio/"

const WEB_ATTACH := [
	ROOT + "web-attach-01.wav",
	ROOT + "web-attach-02.wav",
	ROOT + "web-attach-03.wav",
]
const WEB_RELEASE := [
	ROOT + "web-release-01.wav",
	ROOT + "web-release-02.wav",
]
const REEL_START := [ROOT + "reel-start.wav"]
const REEL_LOOP := ROOT + "reel-loop.wav"
const REEL_EMPTY := [ROOT + "reel-empty.wav"]
const BURST := [
	ROOT + "burst-01.wav",
	ROOT + "burst-02.wav",
]
const DIVE := [
	ROOT + "dive-01.wav",
	ROOT + "dive-02.wav",
]
const FLY_CATCH := [
	ROOT + "fly-catch-01.wav",
	ROOT + "fly-catch-02.wav",
	ROOT + "fly-catch-03.wav",
]
const INVALID := [ROOT + "invalid-target.wav"]
const RESCUE := [ROOT + "rescue-silk.wav"]
const DEATH := [ROOT + "death-impact.wav"]
const BOOST := [ROOT + "boost-catch.wav"]
const SURFACE_BOUNCE := [ROOT + "surface-bounce.wav"]
const MUSIC_BED := ROOT + "haunted-silk-bed.wav"
const MUSIC_TENSION := ROOT + "haunted-chase-pulse.wav"

const HAZARD_CUES := {
	&"mist_echo": ROOT + "mist-echo.wav",
	&"glass_phase": ROOT + "glass-phase.wav",
	&"rotten_crack": ROOT + "rotten-crack.wav",
	&"storm_gust": ROOT + "storm-gust.wav",
	&"storm_charge": ROOT + "storm-charge.wav",
}


static func paths_for_event(event: SimulationEvent) -> PackedStringArray:
	match event.kind:
		SimulationEvent.Kind.ATTACHED:
			return PackedStringArray(WEB_ATTACH)
		SimulationEvent.Kind.RELEASED:
			return PackedStringArray(WEB_RELEASE)
		SimulationEvent.Kind.REEL_STARTED:
			return PackedStringArray(REEL_START)
		SimulationEvent.Kind.REEL_EMPTY:
			return PackedStringArray(REEL_EMPTY)
		SimulationEvent.Kind.BURST_STARTED:
			return PackedStringArray(BURST)
		SimulationEvent.Kind.DIVE_STARTED:
			return PackedStringArray(DIVE)
		SimulationEvent.Kind.FLY_COLLECTED:
			return PackedStringArray(FLY_CATCH)
		SimulationEvent.Kind.INVALID_TARGET, SimulationEvent.Kind.OUT_OF_RANGE, \
				SimulationEvent.Kind.REEL_UNAVAILABLE, \
				SimulationEvent.Kind.BURST_UNAVAILABLE, \
				SimulationEvent.Kind.DIVE_UNAVAILABLE:
			return PackedStringArray(INVALID)
		SimulationEvent.Kind.RESCUE_USED:
			return PackedStringArray(RESCUE)
		SimulationEvent.Kind.DEATH_REQUESTED:
			return PackedStringArray(DEATH)
		SimulationEvent.Kind.BOOST_COLLECTED:
			return PackedStringArray(BOOST)
		SimulationEvent.Kind.SURFACE_BOUNCED:
			return PackedStringArray(SURFACE_BOUNCE)
		SimulationEvent.Kind.ANCHOR_FAILED:
			return PackedStringArray([str(HAZARD_CUES[&"rotten_crack"])])
		SimulationEvent.Kind.HAZARD_CUE:
			var cue := StringName(event.data.get("cue", &"mist_echo"))
			if HAZARD_CUES.has(cue):
				return PackedStringArray([str(HAZARD_CUES[cue])])
	return PackedStringArray()


static func variant_key(event: SimulationEvent) -> StringName:
	if event.kind == SimulationEvent.Kind.HAZARD_CUE:
		return StringName("hazard:%s" % str(event.data.get("cue", &"mist_echo")))
	return StringName("event:%d" % event.kind)


static func cooldown_seconds(event: SimulationEvent) -> float:
	match event.kind:
		SimulationEvent.Kind.ATTACHED, SimulationEvent.Kind.RELEASED:
			return 0.045
		SimulationEvent.Kind.FLY_COLLECTED:
			return 0.03
		SimulationEvent.Kind.INVALID_TARGET, SimulationEvent.Kind.OUT_OF_RANGE, \
				SimulationEvent.Kind.REEL_UNAVAILABLE, \
				SimulationEvent.Kind.BURST_UNAVAILABLE, \
				SimulationEvent.Kind.DIVE_UNAVAILABLE:
			return 0.12
		SimulationEvent.Kind.HAZARD_CUE:
			return 0.08
	return 0.0


static func all_paths() -> PackedStringArray:
	var result := PackedStringArray()
	for group: Array in [
		WEB_ATTACH, WEB_RELEASE, REEL_START, REEL_EMPTY, BURST, DIVE,
		FLY_CATCH, INVALID, RESCUE, DEATH, BOOST, SURFACE_BOUNCE,
	]:
		result.append_array(PackedStringArray(group))
	result.append(REEL_LOOP)
	for cue: StringName in HAZARD_CUES:
		result.append(str(HAZARD_CUES[cue]))
	result.append(MUSIC_BED)
	result.append(MUSIC_TENSION)
	return result


static func music_paths() -> PackedStringArray:
	return PackedStringArray([MUSIC_BED, MUSIC_TENSION])

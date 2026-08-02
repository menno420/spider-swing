extends Node
class_name AudioDirector
## Presentation-owned event-to-sound orchestration.
##
## It consumes snapshots and SimulationEvents, round-robins high-frequency
## variants, caps repeated cues, and eases a two-stem music mix. It never emits
## a gameplay command or mutates simulation/application state.

const VOICE_COUNT := 6
const MUSIC_BED_VOLUME_DB := -3.0
const MUSIC_TENSION_SILENT_DB := -60.0
const MUSIC_TENSION_MAX_DB := -7.0
const MUSIC_ATTACK_PER_SECOND := 0.72
const MUSIC_RELEASE_PER_SECOND := 0.34

var _effects_enabled: bool = true
var _music_enabled: bool = true
var _streams: Dictionary = {}
var _voices: Array[AudioStreamPlayer] = []
var _voice_cursor: int = 0
var _loop_player: AudioStreamPlayer
var _music_bed_player: AudioStreamPlayer
var _music_tension_player: AudioStreamPlayer
var _variant_cursors: Dictionary = {}
var _cooldowns: Dictionary = {}
var _reel_active: bool = false
var _music_tension: float = 0.0
var _music_tension_target: float = 0.0
var _music_playback_requested: bool = false


func _ready() -> void:
	for path: String in AudioAssetCatalog.all_paths():
		if ResourceLoader.exists(path):
			var stream := load(path) as AudioStream
			if stream != null:
				_streams[path] = stream
	for _index in range(VOICE_COUNT):
		var voice := AudioStreamPlayer.new()
		voice.bus = &"Master"
		add_child(voice)
		_voices.append(voice)
	_loop_player = AudioStreamPlayer.new()
	_loop_player.bus = &"Master"
	add_child(_loop_player)
	_loop_player.stream = _looping_stream(
		_streams.get(AudioAssetCatalog.REEL_LOOP) as AudioStream)
	_music_bed_player = _music_player(
		AudioAssetCatalog.MUSIC_BED, MUSIC_BED_VOLUME_DB)
	_music_tension_player = _music_player(
		AudioAssetCatalog.MUSIC_TENSION, MUSIC_TENSION_SILENT_DB)
	set_process(true)
	_apply_music_playback()


func configure_effects(enabled: bool) -> void:
	_effects_enabled = enabled
	if not enabled:
		_stop_effects()


func effects_enabled() -> bool:
	return _effects_enabled


func configure_music(enabled: bool) -> void:
	_music_enabled = enabled
	_apply_music_playback()


func music_enabled() -> bool:
	return _music_enabled


func music_playback_requested() -> bool:
	return _music_playback_requested


func present_event(event: SimulationEvent) -> void:
	if event.kind in [
		SimulationEvent.Kind.REEL_EMPTY,
		SimulationEvent.Kind.RELEASED,
		SimulationEvent.Kind.DEATH_REQUESTED,
		SimulationEvent.Kind.RESCUE_USED,
		SimulationEvent.Kind.RUN_RESTARTED,
	]:
		_stop_reel_loop()
	if not _effects_enabled:
		return
	var cooldown_key := AudioAssetCatalog.variant_key(event)
	if float(_cooldowns.get(cooldown_key, 0.0)) > 0.0:
		return
	var path := choose_path(event)
	if path.is_empty():
		return
	var cooldown := AudioAssetCatalog.cooldown_seconds(event)
	if cooldown > 0.0:
		_cooldowns[cooldown_key] = cooldown
	_play_one_shot(path)
	if event.kind == SimulationEvent.Kind.REEL_STARTED:
		_start_reel_loop()


func present_snapshot(snapshot: SimulationSnapshot) -> void:
	var next_reel_active := snapshot.reel_active and snapshot.web_attached and \
		snapshot.reel_energy > 0.0 and snapshot.reel_lockout <= 0.0
	if next_reel_active and not _reel_active:
		_start_reel_loop()
	elif not next_reel_active and _reel_active:
		_stop_reel_loop()
	_music_tension_target = music_tension_for_snapshot(snapshot)


func choose_path(event: SimulationEvent) -> String:
	var paths := AudioAssetCatalog.paths_for_event(event)
	if paths.is_empty():
		return ""
	var key := AudioAssetCatalog.variant_key(event)
	var cursor := int(_variant_cursors.get(key, 0))
	_variant_cursors[key] = cursor + 1
	return paths[cursor % paths.size()]


func advance_cooldowns(delta: float) -> void:
	for key: StringName in _cooldowns.keys():
		var remaining := maxf(0.0, float(_cooldowns[key]) - delta)
		if remaining <= 0.0:
			_cooldowns.erase(key)
		else:
			_cooldowns[key] = remaining


func leave_run() -> void:
	_music_tension_target = 0.0
	_stop_effects()


func stop_all() -> void:
	_stop_effects()
	_music_playback_requested = false
	if _music_bed_player != null:
		_music_bed_player.stop()
	if _music_tension_player != null:
		_music_tension_player.stop()


func _stop_effects() -> void:
	for voice: AudioStreamPlayer in _voices:
		voice.stop()
	_stop_reel_loop()


func _process(delta: float) -> void:
	advance_cooldowns(delta)
	var response := (
		MUSIC_ATTACK_PER_SECOND
		if _music_tension_target > _music_tension
		else MUSIC_RELEASE_PER_SECOND
	)
	_music_tension = move_toward(
		_music_tension, _music_tension_target, response * delta)
	if _music_tension_player != null:
		_music_tension_player.volume_db = lerpf(
			MUSIC_TENSION_SILENT_DB,
			MUSIC_TENSION_MAX_DB,
			smoothstep(0.0, 1.0, _music_tension),
		)


func _play_one_shot(path: String) -> void:
	if _voices.is_empty():
		return
	var stream := _streams.get(path) as AudioStream
	if stream == null:
		return
	var voice := _voices[_voice_cursor]
	_voice_cursor = (_voice_cursor + 1) % _voices.size()
	voice.stream = stream
	voice.play()


func _start_reel_loop() -> void:
	_reel_active = true
	if not _effects_enabled or _loop_player == null or \
			_loop_player.stream == null or _loop_player.playing:
		return
	_loop_player.play()


func _stop_reel_loop() -> void:
	_reel_active = false
	if _loop_player != null:
		_loop_player.stop()


func _music_player(path: String, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = &"Master"
	player.volume_db = volume_db
	player.stream = _looping_stream(_streams.get(path) as AudioStream)
	add_child(player)
	return player


func _looping_stream(source: AudioStream) -> AudioStream:
	if source is AudioStreamWAV:
		var loop_stream := source.duplicate() as AudioStreamWAV
		loop_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		loop_stream.loop_begin = 0
		loop_stream.loop_end = roundi(
			loop_stream.get_length() * float(loop_stream.mix_rate)
		)
		return loop_stream
	return source


func _apply_music_playback() -> void:
	if _music_bed_player == null or _music_tension_player == null:
		return
	if not _music_enabled:
		_music_playback_requested = false
		_music_bed_player.stop()
		_music_tension_player.stop()
		return
	if not _music_bed_player.playing:
		_music_bed_player.play()
	if not _music_tension_player.playing:
		_music_tension_player.play(_music_bed_player.get_playback_position())
	_music_playback_requested = true


static func music_tension_for_snapshot(snapshot: SimulationSnapshot) -> float:
	if snapshot == null or snapshot.run_state != &"active":
		return 0.0
	var pace := clampf(inverse_lerp(480.0, 900.0, absf(snapshot.velocity.x)), 0.0, 1.0)
	pace *= 0.18
	if not snapshot.bird_enabled or not is_finite(snapshot.bird_gap):
		return pace
	var gap_signal := clampf(
		inverse_lerp(900.0, 250.0, snapshot.bird_gap), 0.0, 1.0)
	var bird_pressure := pow(gap_signal, 1.7)
	if snapshot.bird_closing:
		bird_pressure += 0.12
	return clampf(maxf(pace, bird_pressure), 0.0, 1.0)

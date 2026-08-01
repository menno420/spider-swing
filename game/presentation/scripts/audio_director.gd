extends Node
class_name AudioDirector
## Presentation-owned event-to-sound orchestration.
##
## It consumes snapshots and SimulationEvents, round-robins high-frequency
## variants, and caps repeated cues. It never emits a gameplay command or
## mutates simulation/application state.

const VOICE_COUNT := 6

var _effects_enabled: bool = true
var _streams: Dictionary = {}
var _voices: Array[AudioStreamPlayer] = []
var _voice_cursor: int = 0
var _loop_player: AudioStreamPlayer
var _variant_cursors: Dictionary = {}
var _cooldowns: Dictionary = {}
var _reel_active: bool = false


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
	var loop_source := _streams.get(AudioAssetCatalog.REEL_LOOP) as AudioStream
	if loop_source is AudioStreamWAV:
		var loop_stream := loop_source.duplicate() as AudioStreamWAV
		loop_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		loop_stream.loop_begin = 0
		loop_stream.loop_end = roundi(
			loop_stream.get_length() * float(loop_stream.mix_rate)
		)
		_loop_player.stream = loop_stream
	else:
		_loop_player.stream = loop_source
	set_process(true)


func configure_effects(enabled: bool) -> void:
	_effects_enabled = enabled
	if not enabled:
		stop_all()


func effects_enabled() -> bool:
	return _effects_enabled


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


func stop_all() -> void:
	for voice: AudioStreamPlayer in _voices:
		voice.stop()
	_stop_reel_loop()


func _process(delta: float) -> void:
	advance_cooldowns(delta)


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

extends AudioStreamPlayer
class_name SFX

var sfx = {}

static var _instance: SFX

## The SFX player `from` should use: its own `_sfx_player` if it declares one,
## otherwise the registered player.
static func get_sfx_player(from: Node) -> SFX:
	if "_sfx_player" in from and from._sfx_player is SFX:
		return from._sfx_player
	return _instance

func _add_audio_directory(dir:String):
	for f in ResourceLoader.list_directory(dir):
		var res_name = "%s/%s" % [dir, f]
		if f.ends_with(".wav") or f.ends_with(".mp3") or f.ends_with(".ogg"):
			var res = ResourceLoader.load(res_name)
			if res:
				var key = f.get_basename()
				assert(key)
				if sfx.has(key):
					print("Warn: deuplicate sfx entry for ",key)
				sfx[key] = res
		else:
			_add_audio_directory(res_name)

func get_playback() -> AudioStreamPlaybackPolyphonic:
	if not has_stream_playback():
		play()
	return get_stream_playback()

class SFXControl:
	var master
	var id
	var label: String
	func _init(master:AudioStreamPlaybackPolyphonic , id: int, label: String):
		self.master = master
		self.id = id
		self.label = label

	func valid() -> bool:
		return master.is_stream_playing(id)

	func set_volume(volume_db: float) -> bool:
		if not valid():
			return false
		master.set_stream_volume(id, volume_db)
		return true

	func stop():
		master.stop_stream(id)

func play_sfx(effect_name:String) -> SFXControl:
	if not sfx.has(effect_name):
		print("Warn: no sfx named %s" % effect_name)
		return null

	var pb = get_playback()
	if not pb:
		print("Warn: audio is fucked while attempting to play %s" % effect_name)
		return null

	return SFXControl.new(pb, pb.play_stream(sfx[effect_name]), effect_name)

func _ready():
	_add_audio_directory("res://audio/plain_sfx")
	_add_audio_directory("res://audio/bitcrushed_sfx")
	_add_audio_directory("res://audio/eating")
	stream = AudioStreamPolyphonic.new()
	bus = &"SFX"
	stream.polyphony = 8
	_instance = self

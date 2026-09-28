extends AudioStreamPlayer
class_name SFX

var sfx = {}

func _add_audio_directory(dir:String):
	for f in ResourceLoader.list_directory(dir):
		var res_name = "%s/%s" % [dir, f]
		if f.ends_with(".wav") or f.ends_with(".mp3") or f.ends_with("*.ogg"):
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

func play_sfx(effect_name:String):
	if not sfx.has(effect_name):
		print("Warn: no sfx named %s" % effect_name)
		return
	var pb = get_playback()
	if not pb:
		print("Warn: audio is fucked while attempting to play %s" % effect_name)
		return
	pb.play_stream(sfx[effect_name])

func _ready():
	_add_audio_directory("res://audio/plain_sfx")
	_add_audio_directory("res://audio/bitcrushed_sfx")
	_add_audio_directory("res://audio/eating")
	stream = AudioStreamPolyphonic.new()
	bus = &"SFX"
	stream.polyphony = 8

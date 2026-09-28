extends AudioStreamPlayer
class_name SFXPlayer

var sfx = {}

func _build_sfx_table():
	var sfx_dir = "res://audio/sfx"
	for f in ResourceLoader.list_directory(sfx_dir):
		if f.ends_with(".wav"):
			var res = ResourceLoader.load("%s/%s" % [sfx_dir, f])
			if res:
				var key = f.get_basename()
				assert(key)
				assert(not sfx.has(key))
				sfx[key] = res

var plays_back = {}
func get_playback(audio_player: Node) -> AudioStreamPlayback:
	if plays_back.has(audio_player):
		return plays_back[audio_player]
	audio_player.play()
	plays_back[audio_player] = audio_player.get_stream_playback()
	return get_playback(audio_player)

class SFXControl:
	var master
	var id
	var label
	func _init(master:AudioStreamPlaybackPolyphonic , id: int, label: String):
		#assert(id != AudioStreamPlaybackPolyphonic.INVALID_ID)
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

var playback:AudioStreamPlaybackPolyphonic
var relay_playback: AudioStreamPlaybackPolyphonic
func play_sfx(effect_name: String) -> SFXControl:
	if not sfx:
		_build_sfx_table()
	if not sfx.has(effect_name):
		print("Warn: no sfx named %s" % effect_name)
		return null

	var id: int
	var pb = get_playback(self)
	if not pb:
		print("warning: failed to play %s, fuckass bug" % effect_name)
		return null
	id = pb.play_stream(sfx[effect_name])
	return SFXControl.new(pb, id, effect_name)

static func get_sfx_player(from: Node) -> SFXPlayer:
	if "_sfx_player" in from and from._sfx_player is SFXPlayer:
		return from._sfx_player
	var root = Root.get_root(from)
	if root:
		return root.get_node_or_null("%SFXPlayer")
	return null

func _ready():
	if not sfx:
		_build_sfx_table()
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = 8

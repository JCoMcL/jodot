extends AudioStreamPlayer2D

func _readier():
	#Fuckit.music_played.emit(stream)
	Fuckit.relay_audio(self)

func _ready():
	_readier.call_deferred()

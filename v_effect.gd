extends EffectSprite2D
class_name VFXSprite

var playing = false

signal expire
func _expire():
	playing = false
	expire.emit()

func stop():
	playing = false

func play(s: VFX.Subframes, loops:int = 1):
	assert(not playing)
	playing = true
	while playing:
		for i in range(s.end - s.start + 1):
			frame = s.start + i
			await Utils.delay(1.0/s.rate)
			if not playing:
				break
		loops -= 1
		if not playing:
			break
		playing = loops != 0 #therefore negative numbers loop infinitely
	_expire()

func _ready():
	hframes = texture.get_size().x / texture.get_size().y

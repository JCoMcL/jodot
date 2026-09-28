class_name Clock
extends TextureRect

var ticks:int=0
func tick(amount:int=1):
	if ticks < 12 and ticks + amount >= 12:
		Events.time_over.emit()
		print("time_over")

	ticks += 1
	texture = (texture as HandyAtlas)
	texture.add_xy(1,0)
	match ticks:
		9:
			Sfx.play_sfx("tick")
		10:
			Sfx.play_sfx("tock")
		11:
			Sfx.play_sfx("tick")

var tick_cumer = Cumer.new(2, tick)
var ringing_cumer = Cumer.new(12, texture.cycle_x.bind(1,11,13))
func _process(delta: float) -> void:
	if ticks > 11:
		ringing_cumer.add(delta)
	else:
		tick_cumer.add(delta)

func _ready() -> void:
	texture = (texture as HandyAtlas) # tells the editor what type it is and also throws an error if type mismatch
	texture.region.size = texture.atlas.get_size() / Vector2(14,1)
	size = texture.region.size * 0.5
	texture.set_xy(0,0)

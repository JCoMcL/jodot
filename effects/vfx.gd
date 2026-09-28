extends Node
class_name VFX

func acquire(at:Node2D, offset: Vector2=Vector2.ZERO) -> VFXSprite:
	var vs: VFXSprite = pool.next(at)
	assert(vs)
	assert(at and is_instance_valid(at))
	Game.add_to_playfield(vs, at)
	vs.position += offset
	#vs.reset_physics_interpolation()
	return vs

func get_animation(id: StringName) -> Subframes:
	var anim = effects[id]
	if anim is Array:
		anim = anim.pick_random()
	return anim

func play(id: StringName, at:Node2D, offset: Vector2=Vector2.ZERO) -> VFXSprite:
	var vs:VFXSprite = acquire(at, offset)
	if has_method(id):
		self[id].call(vs)
	vs.play(get_animation(id))
	return vs


func play_looping(id: StringName, at:Node2D, offset: Vector2=Vector2.ZERO) -> VFXSprite:
	var vs:VFXSprite = acquire(at, offset)
	vs.play(get_animation(id), -1)
	return vs

class Subframes:
	var start: int
	var end: int
	var rate: int
	var label: StringName
	func _init(start, end, rate, label):
		self.start = start
		self.end = end
		self.rate = rate
		self.label = label

var json = preload("res://vfx/vfx.json")
var effects: Dictionary
var pool: Pool
func _ready():
	pool=Pool.new(preload("res://vfx/v_effect.tscn"), 16)

	var r = RegEx.new()
	r.compile("[^0-9]+")
	for tag in json.data.meta.frameTags:
		var k = r.search(tag.name).get_string()
		var v = Subframes.new(
			int(tag.from),
			int(tag.to),
			tag.data if tag.has("data") else 20,
			tag.name
		)
		if k != tag.name: # contains numbers and is therefore part of a group
			if effects.has(k):
				assert(effects[k] is Array)
				effects[k].append(v)
			else:
				effects[k] = [v]
		else:
			effects[tag.name] = v
	print("Compiled vfx table:\n%s" % effects)

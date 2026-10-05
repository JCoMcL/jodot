extends Node
class_name VFX

static var effects: Dictionary
static var pool: Pool

static var _instance: VFX
static var _built := false

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

func _ready():
	_instance = self

## Parses the frame table and builds the sprite pool, on first use.
static func _build():
	if _built:
		return
	_built = true

	pool=Pool.new(preload("res://effects/v_effect.tscn"), 16)

	var json = load("res://effects/vfx.json")
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

static func acquire(at:Node2D, offset: Vector2=Vector2.ZERO) -> VFXSprite:
	_build()
	var vs: VFXSprite = pool.next(at)
	assert(vs)
	assert(at and is_instance_valid(at))
	#Game.add_to_playfield(vs, at)
	vs.position += offset
	#vs.reset_physics_interpolation()
	return vs

static func get_animation(id: StringName) -> Subframes:
	_build()
	var anim = effects[id]
	if anim is Array:
		anim = anim.pick_random()
	return anim

static func play(id: StringName, at:Node2D, offset: Vector2=Vector2.ZERO) -> VFXSprite:
	var vs:VFXSprite = acquire(at, offset)
	if _instance and _instance.has_method(id):
		_instance[id].call(vs)
	vs.play(get_animation(id))
	return vs


static func play_looping(id: StringName, at:Node2D, offset: Vector2=Vector2.ZERO) -> VFXSprite:
	var vs:VFXSprite = acquire(at, offset)
	vs.play(get_animation(id), -1)
	return vs

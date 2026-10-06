extends Object
class_name VFX

# --- Static Part ---

static var effects: Dictionary[StringName,Variant]: # Variant: either Subframes or Array[Subframes]
	get():
		if not effects:
			effects = build_effects_table(
				preload("res://effects/vfx.png"),
				preload("res://effects/vfx.json"),
			)
		return effects
static var pool=Pool.new(preload("res://effects/v_effect.tscn"), 16)

class Subframes:
	var spritesheet:Texture2D
	var start: int
	var end: int
	var rate: int
	var label: StringName
	func _init(spritesheet, start, end, rate, label):
		self.spritesheet = spritesheet
		self.start = start
		self.end = end
		self.rate = rate
		self.label = label

static func build_effects_table(spritesheet:Texture2D, spritesheet_json:Object) -> Dictionary[StringName, Variant]:
	var out:Dictionary[StringName, Variant]
	var r = RegEx.new()
	r.compile("[^0-9]+")
	for tag in spritesheet_json.data.meta.frameTags:
		var k = r.search(tag.name).get_string()
		var v = Subframes.new(
			spritesheet,
			int(tag.from),
			int(tag.to),
			tag.data if tag.has("data") else 20,
			tag.name
		)
		if k != tag.name: # contains numbers and is therefore part of a group
			if out.has(k):
				assert(out[k] is Array)
				out[k].append(v)
			else:
				out[k] = [v]
		else:
			out[tag.name] = v
	print("built vfx table:\n%s" % out)
	return out

static func acquire(at:Node, offset: Vector2=Vector2.ZERO) -> VFXSprite:
	var vs: VFXSprite = pool.next(at)
	assert(vs)
	assert(at and is_instance_valid(at))
	#Game.add_to_playfield(vs, at)
	vs.position += offset
	#vs.reset_physics_interpolation()
	return vs

static func get_animation(id: StringName) -> Subframes:
	var anim = effects[id]
	if anim is Array:
		anim = anim.pick_random()
	return anim

static func play(id: StringName, at:Node, offset: Vector2=Vector2.ZERO) -> VFXSprite:
	var vs:VFXSprite = acquire(at, offset)
	vs.play(get_animation(id))
	return vs


static func play_looping(id: StringName, at:Node, offset: Vector2=Vector2.ZERO) -> VFXSprite:
	var vs:VFXSprite = acquire(at, offset)
	vs.play(get_animation(id), -1)
	return vs

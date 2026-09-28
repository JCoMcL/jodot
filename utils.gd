@tool
extends Node

# --- collision ---

enum {AREAS, BODIES, AREAS_AND_BODIES}
func configure_query_parameters(pq: Object, mask, collider_type):
	pq.collide_with_areas = (collider_type == AREAS || collider_type == AREAS_AND_BODIES)
	pq.collide_with_bodies = (collider_type == BODIES || collider_type == AREAS_AND_BODIES)
	pq.collision_mask = Layers.layers[mask] if mask is String else mask

func get_objects_at(where: Vector2, mask=65535, collider_type=AREAS_AND_BODIES, world: World2D=null) -> Array:
	var pq := PhysicsPointQueryParameters2D.new()
	configure_query_parameters(pq, mask, collider_type)
	pq.position = where
	if ! world:
		world=get_viewport().get_world_2d()

	return world.direct_space_state.intersect_point(pq).map(func (d): return d.collider)

func get_objects_under_body(what: Node2D, mask=65532, collider_type=AREAS_AND_BODIES, world: World2D=null) -> Array[Node2D]:
	var out: Array[Node2D]
	if what is CollisionObject2D:
		for c in what.get_children():
			if c is CollisionShape2D:
				for result in get_objects_under_body(c, mask, collider_type, world):
					out.append(result) # This code is not very wheelchair accessible
	elif what is CollisionShape2D and what.shape:
		var pq := PhysicsShapeQueryParameters2D.new()
		pq.shape = what.shape
		pq.transform = what.global_transform
		configure_query_parameters(pq, mask, collider_type)
		if ! world:
			world=get_viewport().get_world_2d()
		var result = world.direct_space_state.intersect_shape(pq)
		for o in result:
			out.append(o.collider)
	return out

# --- coordinates ---

func viewport_to_world(v: Vector2, relative_to: Node = self):
	var vp = relative_to.get_viewport()
	return vp.global_canvas_transform.affine_inverse() * vp.canvas_transform.affine_inverse() * v

# --- rects ---

func union_rect(a: Array[Rect2]) -> Rect2:
	if not a:
		return Rect2()

	var top_left = a[0].position
	var bottom_right = a[0].end
	for r in a:
		top_left.x = r.position.x if r.position.x < top_left.x else top_left.x
		top_left.y = r.position.y if r.position.y < top_left.y else top_left.y
		bottom_right.x = r.end.x if r.end.x > bottom_right.x else bottom_right.x
		bottom_right.y = r.end.y if r.end.y > bottom_right.y else bottom_right.y

	return Rect2(top_left, bottom_right - top_left)

func globalise_rect(r: Rect2, rect_owner: Node2D):
	r.position *= rect_owner.global_scale
	r.position += rect_owner.global_position
	r.size *= rect_owner.global_scale
	return r

func localise_rect(r: Rect2, rect_owner: Node2D):
	r.position -= rect_owner.global_position
	r.position /= rect_owner.global_scale
	r.size /= rect_owner.global_scale
	return r

func get_global_rect(n: Node2D) -> Rect2:
	if n.has_method("get_global_rect"):
		return n.get_global_rect()
	if n.has_method("get_rect"):
		return globalise_rect(n.get_rect(), n)
	if n is CollisionObject2D:
		var shape_rects: Array[Rect2]
		for id in n.get_shape_owners():
			var offset = n.shape_owner_get_transform(id).origin
			for i in n.shape_owner_get_shape_count(id):
				var r = n.shape_owner_get_shape(id, i).get_rect()
				r.position += offset
				shape_rects.append(r)
		return globalise_rect(union_rect(shape_rects), n)
	push_warning("Warn: get_global_rect: no support for object: %s" % n)
	return Rect2()

func get_local_rect(n: Node2D) -> Rect2:
	return localise_rect(get_global_rect(n), n)

# --- nodes ---

func get_ancestry(n: Node) -> Array[Node]:
	var out: Array[Node]
	var current = n
	while current:
		out.append(current)
		current = current.get_parent()
	out.reverse()
	return out

# --- time ---

func delay(secs):
	await get_tree().create_timer(secs).timeout

# --- random ---

var rng = RandomNumberGenerator.new()
func triangular_distribution(lower: float = -1.0, upper: float = 1.0) -> float:
	return rng.randf_range(upper, lower) + rng.randf_range(upper, lower)

func percent_chance(i):
	return rng.randf() * 100 < i

func cointoss() -> bool:
	return randf() < 0.5

func randf_exp():
	return rng.randf() ** 2

func pick_random_exp(a: Array):
	## each successive element is less likely to be picked
	return a[ int((randf_exp()) * a.size()) ]

func vary(f: float, factor: float):
	return f + (randf() - 0.5) * f * factor

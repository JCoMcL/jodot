@tool
extends Node

func snap_force(initial:Vector2, direction:Vector2, delta:float, snappiness:float = 300, sharpness:float = 0.3) -> Vector2:
	return initial.move_toward(direction * sharpness / delta, snappiness) - initial #TODO refactor

# --- space, shape, and coordinates ---

func nearest(f:float, a:float, b:float):
	return a if abs(f-a) < abs(f-b) else b

func get_nearest_point_on_perimeter(r: Rect2, p: Vector2):
	p.x =  clampf(p.x, r.position.x, r.end.x)
	p.y =  clampf(p.y, r.position.y, r.end.y)
	var nearest_x = nearest(p.x, r.position.x, r.end.x)
	var nearest_y = nearest(p.y, r.position.y, r.end.y)
	if abs(p.x - nearest_x) > abs(nearest_y - p.y):
		return Vector2(p.x, nearest_y)
	else:
		return Vector2(nearest_x, p.y)

func viewport_to_world(v: Vector2, relative_to: Node = self):
	var vp = relative_to.get_viewport()
	return vp.global_canvas_transform.affine_inverse() * vp.canvas_transform.affine_inverse() * v

func get_viewport_world_rect(relative_to: Node = self) -> Rect2:
	var r = relative_to.get_viewport().get_visible_rect()
	var start = viewport_to_world(r.position, relative_to)
	var end = viewport_to_world(r.end, relative_to)
	return Rect2(start, end - start)

func four_corners(r: Rect2) -> Array[Vector2]:
	return [
		r.position,
		Vector2(r.position.x, r.end.y),
		r.end,
		Vector2(r.end.x, r.position.y)
	]

func nearest_overlapping_position(inner: Rect2, outer: Rect2) -> Vector2:
	if outer.encloses(inner):
		return inner.position

	# return inner's position plus the offset of the furthest vertex from outer
	var new_pos = four_corners(inner).filter(func(p):
		return not outer.has_point(p) #only outside points
	).map(func(v):
		return get_nearest_point_on_perimeter(outer, v) - v
	).reduce(func(v:Vector2, longest):
		return v if v.length_squared() > longest.length_squared() else longest
	) * 1.01 + inner.position

	if inner.size.x >= outer.size.x:
		new_pos.x = outer.position.x - (inner.size.x - outer.size.x) / 2
	if inner.size.y >= outer.size.y:
		new_pos.y = outer.position.y - (inner.size.y - outer.size.y) / 2

	#test that it works
	var new_inner = Rect2(new_pos, inner.size)
	assert(outer.encloses(new_inner) or inner.size.x >= outer.size.x or inner.size.y >= outer.size.y)

	return new_pos

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

func get_canvas_item_global_z(node: CanvasItem) -> int:
	if not node.z_as_relative:
		return node.z_index
	var parent = node.get_parent()
	if parent is CanvasItem:
		return node.z_index + get_canvas_item_global_z(parent)
	return node.z_index

func get_global_rect(o: Node) -> Rect2:
	if not o:
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	if not Engine.is_editor_hint() or o.get_script().is_tool():
		if o.has_method("get_global_rect"):
			return o.get_global_rect()
		if o.has_method("get_rect"):
			var r = o.get_rect()
			r.position += o.global_position
			return r
	if o is CollisionShape2D and o.shape:
		var r = o.shape.get_rect()
		r.position += o.global_position
		return r
	if o is Area2D:
		for child in o.get_children():
			if child is CollisionShape2D and child.shape:
				return get_global_rect(child)

	return Rect2(o.global_position, Vector2.ZERO)

# --- nodes ---

func get_level_container(from: Node) -> Node:
	if from is LevelContainer:
		return from
	if from.get_parent():
		return get_level_container(from.get_parent())
	else:
		return null

func find_node_by_name(root: Node, target_name: String) -> Node:
	if root.name == target_name:
		return root
	for child in root.get_children():
		var found = find_node_by_name(child, target_name)
		if found:
			return found
	return null

func replace_node(current_node, new_node, parent):
	var index = parent.get_children().find(current_node)
	current_node.queue_free()
	if new_node:
		var n = new_node.instantiate()
		print("instantiated: ", n.name, " at ", n.global_position)
		parent.add_child(n)
		parent.move_child(n, index)
		n.global_position = parent.global_position

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

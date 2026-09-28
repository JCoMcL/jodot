extends Node
class_name Grid

@export var grid_auto_step_time:float = 1.0
var _step_time_accum:float

var grid: Array[Array] #[Node]
var node_positions: Dictionary = {} #{Node: Vector2i}
var grid_history: Array[Dictionary] #{Node: Vector2i]

class NodeInfo:
	var pos: Vector2i
	var parent: Node
	func _init(n: Node3D):
		pos = grid.get_object_grid_pos(n)
		parent = n.get_parent()

var _dirty: bool = false

signal grid_changed
signal step

func sync():
	_step_time_accum = 0
	if _dirty or grid_history.is_empty():
		grid_history.append(node_positions.duplicate())
	_dirty = false
	step.emit()

const grid_size = 128
const tiles_size = 1.0

func grid_to_world(x: int, y: int) -> Vector3:
	return Vector3(x * tiles_size, 0, y * tiles_size)

func world_to_grid(v: Vector3) -> Vector2i:
	return Vector2i(roundi(v.x / tiles_size), roundi(v.z / tiles_size))

func get_object_grid_pos(n: Node) -> Vector2i:
	var node3d := n as Node3D
	if node3d == null:
		return Vector2i.ZERO
	return world_to_grid(Vector3(node3d.global_position.x, 0, node3d.global_position.z))

func snapped_to_grid(v: Vector3) -> Vector3:
	return Vector3(roundi(v.x / tiles_size) * tiles_size, v.y, roundi(v.z / tiles_size) * tiles_size)

func snap_to_grid(n: Node3D):
	n.global_position = snapped_to_grid(n.global_position)

func _to_index(coord: int) -> int:
	return grid_size / 2 + coord

func _in_bounds(x: int, y: int) -> bool:
	var ix := _to_index(x)
	var iy := _to_index(y)
	return ix >= 0 and ix < grid_size and iy >= 0 and iy < grid_size

func get_at_pos(x: int, y: int) -> Node:
	if not _in_bounds(x, y):
		return null
	return grid[_to_index(x)][_to_index(y)]

func set_at_pos(n: Node, x: int, y: int) -> bool:
	if not _in_bounds(x, y):
		return false
	var ix := _to_index(x)
	var iy := _to_index(y)
	if grid[ix][iy] != null and grid[ix][iy] != n:
		return false
	var old_info: Variant = node_positions.get(n)
	if old_info != null:
		if old_info.pos == Vector2i(x, y):
			return true
		grid[_to_index(old_info.pos.x)][_to_index(old_info.pos.y)] = null
	grid[ix][iy] = n
	node_positions[n] = NodeInfo.new(n)
	_dirty = true
	grid_changed.emit()
	return true

func update_pos(n: Node):
	var pos = get_object_grid_pos(n)
	set_at_pos(n, pos.x, pos.y)

func remove(n: Node) -> void:
	var info: Variant = node_positions.get(n)
	if info == null:
		return
	grid[_to_index(info.pos.x)][_to_index(info.pos.y)] = null
	node_positions.erase(n)
	_dirty = true
	grid_changed.emit()

func _init_grid():
	grid.clear()
	grid.resize(grid_size)
	for i in range(grid_size):
		grid[i] = []
		grid[i].resize(grid_size)
	node_positions.clear()
	grid_history.clear()

func move(n: PhysicsBody3D, dir: Vector3) -> KinematicCollision3D:
	var initial_pos = snapped_to_grid(n.global_position)
	var delta = dir.normalized() * tiles_size
	var collision = n.move_and_collide(delta)
	if collision:
		var col = collision.get_collider()
		if col and col.has_method("nudge") and  col.nudge(delta):
			n.global_position = initial_pos + delta
		else:
			n.global_position = initial_pos
	update_pos(n)
	return collision

func _ready():
	_init_grid()

func undo():
	if grid_history.is_empty():
		return
	var prev: Dictionary = grid_history.pop_back()
	for i in range(grid_size):
		for j in range(grid_size):
			grid[i][j] = null
	node_positions.clear()
	for n in prev:
		var info: NodeInfo = prev[n]
		node_positions[n] = info
		grid[_to_index(info.pos.x)][_to_index(info.pos.y)] = n
		var node3d := n as Node3D
		if node3d != null:
			if not node3d.is_inside_tree():
				info.parent.add_child(node3d)
			node3d.global_position = snapped_to_grid(Vector3(info.pos.x * tiles_size, node3d.global_position.y, info.pos.y * tiles_size))
	_dirty = false
	grid_changed.emit()

func clear():
	_init_grid()

func _process(delta):
	_step_time_accum += delta
	if grid_auto_step_time > 0 and _step_time_accum > grid_auto_step_time:
		sync()

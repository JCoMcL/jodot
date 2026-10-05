@tool
extends Node

func snap_force(initial:Vector2, direction:Vector2, delta:float, snappiness:float = 300, sharpness:float = 0.3) -> Vector2:
	return initial.move_toward(direction * sharpness / delta, snappiness) - initial #TODO refactor

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

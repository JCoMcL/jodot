@tool
extends Node

enum {UP, DOWN, LEFT, RIGHT, NONE}

const each = [UP, DOWN, LEFT, RIGHT]

func pretty(i:int):
	return ["Up", "Down", "Left", "Right", "None"][i]

func test_spread(f: float, within: float, of: float) -> bool:
	return (of - within) < f and f < (of + within)

func get_strict_direction(to: Vector2):
	var angle = rad_to_deg(to.angle()) + 155
	if test_spread(angle, 30, 65):
		return UP
	if test_spread(angle, 20, 155):
		return RIGHT
	if test_spread(angle, 30, 245) :
		return DOWN
	if test_spread(angle, 20, 340):
		return LEFT
	return NONE

func get_x(x: float, deadzone=0.0):
	if absf(x) <= deadzone: return NONE
	return RIGHT if x > 0 else LEFT
func get_y(y: float, deadzone=0.0):
	if absf(y) <= deadzone: return NONE
	return UP if y < 0 else DOWN
func get_direction(v: Vector2, deadzone=0.0):
	if absf(v.x) > absf(v.y):
		return get_x(v.x, deadzone)
	return get_y(v.y, deadzone)

func _get_vec(o) -> Vector2:
	if o is Vector2:
		return o
	if o is Node2D:
		return o.global_position
	assert(false, "type error")
	return Vector2.ZERO

func get_relative(from, to, deadzone=0.0):
	return get_direction(_get_vec(to) - _get_vec(from), deadzone)

func to_vec(i: int) -> Vector2:
	match i:
		UP:
			return Vector2.UP
		DOWN:
			return Vector2.DOWN
		LEFT:
			return Vector2.LEFT
		RIGHT:
			return Vector2.RIGHT
	return Vector2.ZERO

func to_radians(i: int):
	return to_vec(i).angle()

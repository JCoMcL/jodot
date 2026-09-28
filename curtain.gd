@tool
class_name Curtain
extends ColorRect

@export var duration = 0.5
@export_tool_button("close", "ControlAlignCenter") var close_button = close
@export_tool_button("open", "ControlAlignFullRect") var open_button = open

func set_openness(f: float):
	material.set_shader_parameter("factor", 1.0-f)
func get_openness():
	return 1.0 - material.get_shader_parameter("factor")

var current_tween: Tween
func new_tween() -> Tween:
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	current_tween = create_tween()
	return current_tween

func _ready():
	open()

enum {DOWN, UP, LEFT, RIGHT}
func close(direction=DOWN, specific_duration = duration):
	visible=true
	material.set_shader_parameter("direction", direction)
	var t = new_tween()
	t.tween_method(set_openness, get_openness(), 0.0, specific_duration * get_openness())
	await t.finished
func open(direction=UP, specific_duration = duration):
	material.set_shader_parameter("direction", [UP,DOWN,RIGHT,LEFT][direction])
	var t = new_tween()
	t.tween_method(set_openness, get_openness(), 1.0, specific_duration* (1.0 - get_openness()))
	await t.finished
	visible = false

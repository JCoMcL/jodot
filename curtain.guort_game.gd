@tool
extends ColorRect

@export var duration = 0.3
@export_tool_button("close", "ControlAlignCenter") var close_button = close
@export_tool_button("open", "ControlAlignFullRect") var open_button = open

func set_openness(f: float):
	material.set_shader_parameter("factor", f)
func get_openness():
	return material.get_shader_parameter("factor")

var current_tween: Tween
func new_tween() -> Tween:
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	current_tween = create_tween()
	return current_tween

func close(specific_duration = duration) -> Signal:
	var t = new_tween()
	t.tween_method(set_openness, get_openness(), 0.0, specific_duration * get_openness())
	return t.finished
func open(specific_duration = duration) -> Signal:
	var t = new_tween()
	t.tween_method(set_openness, get_openness(), 1.0, specific_duration* (1.0 - get_openness()))
	return t.finished

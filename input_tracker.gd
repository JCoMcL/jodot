extends Object
class_name InputTracker

var movement_input: Vector2

var _input_left: float
var _input_right: float
var _input_up: float
var _input_down: float

var firing: bool

func sanity_check():
	if not Input.is_action_pressed("left"):
		_input_left = 0.0
	if not Input.is_action_pressed("right"):
		_input_right = 0.0
	if not Input.is_action_pressed("up"):
		_input_up = 0.0
	if not Input.is_action_pressed("down"):
		_input_down = 0.0

	if not Input.is_action_pressed("fire"):
		firing = false

func _input(ev: InputEvent) -> void:
	if ev.is_action("left"):
		_input_left = ev.get_action_strength("left")
	elif ev.is_action("right"):
		_input_right = ev.get_action_strength("right")
	elif ev.is_action("up"):
		_input_up = ev.get_action_strength("up")
	elif ev.is_action("down"):
		_input_down = ev.get_action_strength("down")

	elif ev.is_action("fire"):
		firing = not ev.is_action_released("fire")

	movement_input = Vector2(_input_right - _input_left, _input_down - _input_up).normalized()

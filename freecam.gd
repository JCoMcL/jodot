extends Camera2D

@export var sensitivity = 0.05

func _process(delta):
	position += Input.get_last_mouse_velocity() * sensitivity


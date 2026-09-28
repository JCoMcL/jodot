extends CollisionObject3D
class_name Interactable

signal interacted_with

func _ready():
	input_ray_pickable = true

func _on_interacted_with():
	interacted_with.emit()
	print("clik")

func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_interacted_with()

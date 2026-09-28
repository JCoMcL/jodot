extends Node3D

func attach_interactable(search_pattern:String, f:Callable):
	for container in find_children(search_pattern):
		for n in container.find_children("", "Interactable"):
			n.interacted_with.connect(f)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attach_interactable("Carriage*", %Train.travel)
	attach_interactable("Bench*", Root.get_root(self).wait_for_train)

extends StaticBody3D
class_name Interactable

@export var description: String = "interact"

signal activated

func interact(p: PlayerCharacter):
	activated.emit()

func _ready() -> void:
	collision_layer |= ColorTools.layers["interactable"]

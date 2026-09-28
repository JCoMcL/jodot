@tool
extends Node3D

@export var length: float:
	set(value):
		length=value
		_ready()
@export var width: float:
	set(value):
		width=value
		_ready()

var ilength: int
var iwidth: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ceilingMesh: MultiMeshInstance3D
	ilength = round(length)
	iwidth = round(width)
	ceilingMesh = get_node("MultiMeshInstance3D")
	ceilingMesh.multimesh.instance_count = ilength * iwidth
	for x in range(ilength):
		for y in range(iwidth):
			var transform: Transform3D = Transform3D()
			transform.origin = Vector3(x*2, y*2, 0)
			ceilingMesh.multimesh.set_instance_transform((x*iwidth+y), transform)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

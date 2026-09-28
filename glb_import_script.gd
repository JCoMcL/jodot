@tool # Needed so it runs in editor.
extends EditorScenePostImport

# This sample changes all node names.
# Called right after the scene is imported and gets the root node.
var root_scene: Node
func _post_import(scene):
	# Change all node names to "modified_[oldnodename]"
	root_scene=scene
	iterate(scene)
	return scene # Remember to return the imported scene

var interactable_script = preload("res://stations/interactable.gd")
func make_interactable(n: Node):
	assert(n is CollisionObject3D)
	n.set_script(interactable_script)

var firefly = preload("res://props/firefly/firefly.tscn")
func iterate(node: Node):
	if node != null:
		if node is CollisionObject3D:
			make_interactable(node)
		if node is Light3D:
			print("light")
			var f = firefly.instantiate()
			node.add_child(f)
			f.owner = root_scene
			node.light_energy /= 1000
			node.shadow_enabled = true


		for child in node.get_children():
			iterate(child)

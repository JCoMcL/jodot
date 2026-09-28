@tool # Needed so it runs in editor.
extends EditorScenePostImport

# This sample changes all node names.
# Called right after the scene is imported and gets the root node.
func _post_import(scene):
	# Change all node names to "modified_[oldnodename]"
	iterate(scene)
	return scene # Remember to return the imported scene

var color_script = preload("res://color_ojects/color_object.gd")
func make_color_object(n: Node, c: ColorTools.Colors):
	assert(n is Node3D)
	n.set_script(color_script)
	var col_ob: ColorObject = n as ColorObject
	col_ob.color = c
# Recursive function that is called on every node
# (for demonstration purposes; EditorScenePostImport only requires a `_post_import(scene)` function).
func iterate(node: Node):
	if node != null:
		if node.name.begins_with("Red_"):
			make_color_object(node, ColorTools.Colors.RED)
		if node.name.begins_with("Green_"):
			make_color_object(node, ColorTools.Colors.GREEN)
		if node.name.begins_with("Blue_"):
			make_color_object(node, ColorTools.Colors.BLUE)
		if node.name.begins_with("White_"):
			make_color_object(node, ColorTools.Colors.WHITE)
			
		for child in node.get_children():
			iterate(child)

extends Node2D
class_name LevelContainer
@export var current_level_scene: PackedScene
var current_level: Node
var old_level: Node

func _ready():
	if not current_level and current_level_scene:
		load_scene(current_level_scene)
	cleanup()
	$Overlay/Curtain.open(2)

func cleanup():
	if old_level:
		old_level.queue_free()
	add_child(current_level)
	$Overlay/Curtain.open()

func load_scene(scn: PackedScene) -> Node:
	if current_level:
		old_level = current_level
		remove_child(current_level)
	current_level_scene = scn
	current_level = scn.instantiate()
	return current_level

func transition_to(scn: PackedScene, bring: Array[Node] = [], entrypoint: NodePath = ""):
	var loaded_scene = await load_scene_after_curtains(scn)
	for n in bring:
		var n_relative_position = n.position
		n.owner = null # TODO what is owner exactly? Can it solve some problems here?
		n.reparent(loaded_scene.get_node(entrypoint))
		n.position = n_relative_position
		n.reset_physics_interpolation()
	cleanup()

func load_scene_after_curtains(scn: PackedScene) -> Node:
	await $Overlay/Curtain.close()
	return load_scene(scn)

func reset_level():
	await load_scene_after_curtains(current_level_scene)
	cleanup()

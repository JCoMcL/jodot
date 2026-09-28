class_name LevelContainer
extends Node2D

## Hosts one level scene at a time and swaps between them behind a [Curtain],
## so a level change is never a visible hitch.
##
## Works for 2D and 3D levels. A [Node3D] level is parented under
## [member viewport_container] so it renders inside the 2D tree, the way a
## 3D level shown behind 2D UI would; everything else is parented directly.
## Leave [member viewport_container] empty to keep 3D in the same tree.

## Shown when the container first enters the tree.
@export var current_level_scene: PackedScene = null

## Path to the [Curtain] used to hide transitions. Optional: if it's unset or
## the node is missing, transitions just happen instantly.
@export var curtain_path: NodePath = ^"Overlay/Curtain"

## Where [Node3D] levels are parented, so they render behind the 2D UI.
@export var viewport_container_path: NodePath = ^""

## The level currently in the tree.
var current_level: Node = null

## The level being swapped out, kept alive for one frame so it isn't freed
## before its replacement is ready.
var old_level: Node = null

@onready var curtain: Curtain = get_node_or_null(curtain_path) as Curtain
@onready var viewport_container: Node = get_node_or_null(viewport_container_path)

func _ready() -> void:
	if curtain:
		# start shut, so the first level doesn't pop in
		curtain.close()
	if current_level_scene:
		load_scene(current_level_scene)
		commit()

## Instantiates [param scn] and makes it the pending level. Does not touch the
## tree; call [method commit] (or use [method transition_to]) to swap it in.
func load_scene(scn: PackedScene) -> Node:
	if current_level and current_level.get_parent():
		remove_child(current_level)
		old_level = current_level
	current_level_scene = scn
	current_level = scn.instantiate()
	return current_level

## Parents the pending level, disposing of the previous one, then reopens the
## curtain.
func commit() -> void:
	if old_level and is_instance_valid(old_level):
		old_level.queue_free()
	old_level = null
	if not current_level:
		if curtain:
			curtain.open()
		return

	if current_level is Node3D and viewport_container:
		viewport_container.add_child(current_level)
	else:
		add_child(current_level)

	if curtain:
		curtain.open()

## Closes the curtain, swaps to [param scn], and reopens.
##
## Nodes in [param bring] are carried over into the new level, reparented
## under [param entrypoint] with their positions preserved. Use this to keep
## the player, or anything else that should survive a level change.
func transition_to(scn: PackedScene, bring: Array[Node] = [], entrypoint: NodePath = ^"") -> void:
	if curtain:
		await curtain.close()

	var loaded := load_scene(scn)
	if not bring.is_empty():
		var target: Node = loaded.get_node_or_null(entrypoint) if entrypoint else loaded
		if not target:
			push_error("LevelContainer: entrypoint '%s' not found in the new level" % entrypoint)
			target = loaded
		for n in bring:
			var relative_position = (n as Node2D).position if n is Node2D else Vector2.ZERO
			# owner ties a node to the scene it was saved in; it has to go
			# before the node can be reparented into a different one
			n.owner = null
			n.reparent(target)
			if n is Node2D:
				n.position = relative_position
			n.reset_physics_interpolation()
	commit()

## Reloads [member current_level_scene] from scratch.
func reset_level() -> void:
	await transition_to(current_level_scene)

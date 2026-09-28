class_name World
extends Node2D

@export var level_holder: Node2D
var current_level: BaseRoom
var player: PlayerScript
@onready var inactive_rooms: Node = $InvactiveRooms

var game_over: bool = false

var saved_tadpoles := 0

func _ready() -> void:
	current_level = level_holder.get_child(0)
	player = $Player
	player.set_camera_boundaries(current_level.get_room_boundaries())
	current_level.on_world_changed()

func switch_room(room_name: String, door_name: String) -> void:
	SceneLoader.play_change_animation()
	await SceneLoader.animation_player.animation_finished
	var room: BaseRoom
	if current_level.name == room_name:
		room = current_level
	else:
		current_level.reparent(inactive_rooms, false)
		room = inactive_rooms.get_node(room_name)
		room.reparent(level_holder, false)
		current_level = room
		current_level.on_world_changed()
	var children := room.get_children()
	var door: Door = null
	for node in children:
		if node is Door && node.name == door_name:
			door = node
			break
	assert(door != null, "Can't find the door " + door_name + " for room " + room.name + "!")
	door.just_used = true
	player.global_position = door.global_position
	player.set_camera_boundaries(room.get_room_boundaries())
	
	# Also set the player's cursor to its right place
	player.interaction_crosshair.position = player.position
	
	SceneLoader.play_change_animation_reverse()

func _on_gameover_timeout() -> void:
	SceneLoader.switch_scene("res://src/world.tscn")

# Get the world from the current scene.
static func get_world(from: Node) -> World:
	var current := from
	while current:
		if current is World:
			return current
		current = current.get_parent()
	return null

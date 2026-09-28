class_name Interactable
extends Area2D

signal interact_event(player_node: PlayerScript)

func _ready():
	set_collision_layer_value(4, true)

func interact(player: PlayerScript):
	interact_event.emit(player)

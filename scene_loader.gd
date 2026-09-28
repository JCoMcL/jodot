extends CanvasLayer

# Autoload script for transitioning between rooms.

@onready var animation_player := $AnimationPlayer

func switch_scene(scene_path: String) -> void:
	animation_player.play("change_room")
	await animation_player.animation_finished
	call_deferred("_deferred_switch_scene", scene_path)
	animation_player.play_backwards("change_room")

func play_change_animation() -> void:
	animation_player.play("change_room")

func play_change_animation_reverse() -> void:
	animation_player.play_backwards("change_room")

func _deferred_switch_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

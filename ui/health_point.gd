class_name HealthPoint
extends TextureRect

@onready var anim_player := %AnimationPlayer

func _process(delta: float) -> void:
	pass

func remove_self() -> void:
	visible = false

class_name HealthBar
extends HBoxContainer

@onready var anim_player := %AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player.play("fade_in")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func lose_hp(id: int) -> void:
	var health_point = get_child(id) as HealthPoint
	health_point.remove_self()

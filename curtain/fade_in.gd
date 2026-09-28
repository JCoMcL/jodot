extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var t = get_tree().create_tween()
	volume_db = -40
	t.tween_property(self, "volume_db", 0, 20)
	pass

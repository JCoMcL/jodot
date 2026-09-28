extends RayCast3D

func _physics_process(delta: float) -> void:
	if is_colliding():
		$Cursor.visible = true
		$Cursor.global_position = get_collision_point()
	else:
		$Cursor.visible = false

extends Control

func random_pos():
	return Vector2(size.x * randf(), size.y * randf())
func spawn_vfx():
	VFX.play("pop", self, random_pos())

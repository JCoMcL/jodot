extends CharacterBody3D

var angular_velocity:Vector3

var flippin = false

func flip():
	if flippin:
		return
	flippin = true
	velocity.y += 3
	angular_velocity = Vector3(randf(), randf(), randf()) * 50

func _physics_process(delta: float) -> void:
	rotation += angular_velocity * delta
	velocity += get_gravity()*delta
	move_and_slide()
	if is_on_floor():
		flippin = false
		angular_velocity = Vector3.ZERO
		rotation = Vector3.ZERO

	if flippin and velocity.y < 0:
		visible = false

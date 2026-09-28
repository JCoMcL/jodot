@tool
class_name FirstPersonCharacter
extends CharacterBody3D

const speed = 3.0
const accel = 20.0

@export_range(0.2, 2.0, 0.01) var mouse_sensitivity:float = 1

@export var height = 1.6:
	set(val):
		height = max(val, width)
		setup_children()
@export var width = 0.5:
	set(val):
		width = val
		if height < val:
			height = val
		else:
			setup_children()

# --- Crouching ---

func set_body_to_head():
	var head_col:SphereShape3D = $Head/CollisionShape3D.shape
	var body_col:CapsuleShape3D = $CollisionShape3D.shape
	body_col.radius = head_col.radius
	body_col.height = $Head.position.y + head_col.radius
	$CollisionShape3D.position.y = body_col.height / 2

func setup_children() -> void:
	if not is_node_ready():
		# the above setters will trigger this early, so we have to wait until our children come home
		await ready
	assert (height >= width) #TODO: assert does nothing in tool mode, need a better we to handle this

	collision_layer = Layers.physics3D["Player"]
	collision_mask = Layers.physics3D["Solid"]
	$Head.collision_layer = collision_layer
	$Head.collision_mask = collision_mask

	var head_col:SphereShape3D = $Head/CollisionShape3D.shape
	head_col.radius = width/2
	$Head.position.y = height - head_col.radius

	set_body_to_head()

	%InteractRay.collision_mask = Layers.physics3D["Interactive"]

func change_height(new_height:float) -> KinematicCollision3D:
	var delta = Vector3(0, new_height - $Head.position.y, 0)
	var result = $Head.move_and_collide(delta)
	set_body_to_head()
	return result

# --- Interaction ---

func _interact():
	var target = %InteractRay.get_collider()
	if target:
		target.interact(self)

# --- Main ---

func _ready():
	setup_children()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	velocity += get_gravity() * delta

	var crouching = Input.is_action_pressed("crouch")
	const crouch_speed:float = 10
	var target_height = height * (0.4 if crouching else 1.0)
	change_height(lerpf($Head.position.y, target_height, 1.0 - exp(-crouch_speed * delta)))

	var walk_input := Input.get_vector("left", "right", "forward", "backward").normalized()
	var walk = walk_input.rotated(-rotation.y) * speed * clampf($Head.position.y / height, 0.0, 1.0)

	# maybe this should be relative to the floor normal, but probably doesn't matter
	velocity.x = move_toward(velocity.x, walk.x, accel * delta)
	velocity.z = move_toward(velocity.z, walk.y, accel * delta)

	var target =  %InteractRay.get_collider()
	if target:
		target.hover(self)


	move_and_slide()

func _input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if ev.is_action_pressed("interact"):
		_interact()
	if ev.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if ev is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var look = ev.relative * -mouse_sensitivity / 1000

		if DisplayServer.get_name() == &"web":
			look *=  0.6 # Look is faster on the web for some reason

		rotate_y(look.x)
		# Rotating the camera instead of the head, as the head is a sphere so it doesn't need to rotate.
		# and moving collision objects unneccesarily can have side-effects.
		%Camera.rotate_x(look.y)
		const max_vertical_look = PI/2
		%Camera.rotation.x = clampf(%Camera.rotation.x, -max_vertical_look, max_vertical_look)

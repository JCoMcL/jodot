@tool
extends CollisionObject3D

signal interacted
signal interacted_by(Node3D)

@export var shape:Shape3D:
	set(s):
		if not is_node_ready():
			await ready
		$CollisionShape3D.shape = s
	get():
		if not is_node_ready():
			await ready
		return $CollisionShape3D.shape
@export var tooltip:String = "[LMB] interact":
	set(s):
		tooltip = s
		if not is_node_ready():
			await ready
		%Label.text = s

func _ready() -> void:
	if not Engine.is_editor_hint():
		collision_layer = Layers.physics3D["Interactive"]
		$Tooltip.modulate.a = 0

var hover_timer:float = 0
func hover(observer: Node3D):
	hover_timer = 0.2
	var pos_difference = observer.global_position - global_position
	$Tooltip.rotation.y = atan2(pos_difference.x, pos_difference.z)
	pass

func interact(operator: Node3D):
	print(self, "interacted with")
	$Tooltip.visible = false #HACK
	interacted.emit()
	interacted_by.emit(operator)

func _process(delta):
	if Engine.is_editor_hint():
		return

	if hover_timer > 0:
		hover_timer -= delta
	var hovered = hover_timer > 0
	$Tooltip.modulate.a = move_toward(
		$Tooltip.modulate.a,
		0.2 if hovered else 0.0,
		1.2 * delta
	)

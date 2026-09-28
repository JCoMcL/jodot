extends Label

@onready var prompt : String

func _ready() -> void:
	#%AnimationPlayer.play("pop_in")
	text = prompt
	visible = true
	get_tree().create_timer(1).timeout.connect(hide)

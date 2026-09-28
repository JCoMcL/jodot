extends RichTextLabel

# Note: To use this, put it as a node's child
# Then, on their script, put @onready var floating_text = $FloatingText
# run floating_text.display_temporary_text(text: String) to display a temporary text

@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Auto font size scaling
@export var long_text_threshold: int = 20
@export var default_font_size: int = 24
@export var min_font_size: int = 20

# Call this whenever you want to display a text temporarily
func display_temporary_text(text: String) -> void:
	self.text = text
	
	if text.length() > long_text_threshold:
		add_theme_font_size_override("normal_font_size", min_font_size)
	else:
		add_theme_font_size_override("normal_font_size", default_font_size)
	
	anim_player.play("scroll")
	
	await anim_player.animation_finished
	
	self.text = ""

func display_persistent_text(text: String) -> void:
	self.text = text
	
	if text.length() > long_text_threshold:
		add_theme_font_size_override("normal_font_size", min_font_size)
	else:
		add_theme_font_size_override("normal_font_size", default_font_size)

	anim_player.play("scroll")

func disable_persistent_text() -> void:
	# Stop the scrolling prematurely so that when the sign is re-entered it's a fresh start
	if anim_player.is_playing():
		anim_player.stop()
	
	self.text = ""

@tool
class_name InventoryPanel
extends Control

func _ready() -> void:
	visible = false

func create_inventory_panel(items:Array):
	visible = true
	var grid := $GridContainer
	for child in grid.get_children():
		child.queue_free()
	var bg_tex = preload("res://ui/itembackground.png")
	for item in items:
		var overlay = Control.new()
		overlay.set_custom_minimum_size(Vector2(200, 200))
		overlay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		overlay.size_flags_vertical = Control.SIZE_EXPAND_FILL

		var bg = TextureRect.new()
		bg.texture = bg_tex
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bg.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bg.size_flags_vertical = Control.SIZE_EXPAND_FILL
		bg.anchor_left = 0.0
		bg.anchor_top = 0.0
		bg.anchor_right = 1.0
		bg.anchor_bottom = 1.0
		bg.offset_left = 0
		bg.offset_top = 0
		bg.offset_right = 0
		bg.offset_bottom = 0

		var tex = TextureRect.new()
		tex.texture = item["image"]
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		tex.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tex.size_flags_vertical = Control.SIZE_EXPAND_FILL
		tex.anchor_left = 0.0
		tex.anchor_top = 0.0
		tex.anchor_right = 1.0
		tex.anchor_bottom = 1.0
		tex.offset_left = 0
		tex.offset_top = 0
		tex.offset_right = 0
		tex.offset_bottom = 0

		overlay.add_child(bg)
		overlay.add_child(tex)

		var label = Label.new()
		label.text = item["name"]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		var vbox = VBoxContainer.new()
		vbox.add_child(overlay)
		vbox.add_child(label)
		grid.add_child(vbox)

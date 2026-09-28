class_name Root
extends Control

var SCENES = {
	&"train": preload("res://interior.tscn"),
	&"1": preload("res://stations/station_1.tscn"),
	&"2": preload("res://stations/kings_cross.tscn"),
	&"3": preload("res://stations/ruin.tscn"),
	&"4": preload("res://stations/end_of_the_line.tscn"),
	&"5": preload("res://stations/temp/temp_station_5.tscn")
}

var TRAINS = {
	&"train1": ["1", "2", "3"],
	&"train4": ["3", "4"]
}

#UI
static var inventory := [] # Array of {name, image}
var inventory_panel: InventoryPanel = null
var inventory_button = null
#Gameplay
var current_train = TRAINS.keys()[0]
var current_station = SCENES.keys()[1]
var timetable = generate_timetable()
var camera:Camera3D

@onready var backdrop = $Background

static func get_dialogue_panel(from: Node) -> DialoguePanel:
	for c in get_root(from).get_children():
		if c is DialoguePanel:
			return c
	return null

static func remove_from_inventory(item_name: String):
	for i in range(inventory.size()):
		print("checking %s against %s" % [inventory[i]["name"], item_name])
		if inventory[i]["name"] == item_name:
			inventory.remove_at(i)
			return

static func add_item_to_inventory(item_name: String, image: Texture):
	inventory.append({"name": item_name, "image": image})

static func has_item(item_name: String) -> bool:
	for item in inventory:
		if item["name"] == item_name:
			return true
	return false

static func get_root(from: Node) -> Root:
	while from and from is not Root:
		from = from.get_parent()
	return from

static func set_camera(from: Camera3D):
	get_root(from).camera = from

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	inventory.append({"name": "Love Letter", "image": preload("res://ui/loveletter.png")})
	inventory.append({"name": "Locket", "image": preload("res://ui/locket.png")})
	create_inventory_panel()
	create_inventory_button()
	change_scene("1")

func change_scene(id:StringName):
	assert(SCENES.has(id))
	if SCENES[id] is PackedScene:
		SCENES[id] = SCENES[id].instantiate()
	assert(SCENES[id] is Node)
	SFXPlayer.get_sfx_player(self).play_sfx("switch_station")
	await %Curtain.close(Curtain.RIGHT)
	await get_tree().create_timer(0.3).timeout


	assert(backdrop.is_inside_tree())
	backdrop.get_parent().remove_child(backdrop)
	assert(not backdrop.is_inside_tree())
	backdrop = SCENES[id]
	if backdrop is Node3D:
		%SubViewport.add_child(backdrop)
	elif backdrop is Control:
		add_child(backdrop)
		move_child(backdrop, 0)
		backdrop.visible=true

	print("train: %s, station: %s" % [current_train, id])
	print("other trains at station: %s" % ", ".join(get_other_trains(id)))
	print("table of trains at station: %s" % ", ".join(timetable))
	create_inventory_panel()
	create_inventory_button()
	%Curtain.open(Curtain.RIGHT)

func create_inventory_button():
	var inventory_button_scene := preload("res://ui/inventory_button.tscn")
	inventory_button = inventory_button_scene.instantiate()
	add_child(inventory_button)
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	inventory_panel.visible = false

func create_inventory_panel():
	if inventory_panel == null:
		var inventory_panel_scene = preload("res://ui/inventory_panel.tscn")
		inventory_panel = inventory_panel_scene.instantiate()
		add_child(inventory_panel)
		inventory_panel.visible = false
	inventory_panel.create_inventory_panel(inventory)
	show_inventory_panel()

func show_inventory_panel():
	inventory_panel.visible = true

func _on_inventory_button_pressed():
	inventory_panel.visible = not inventory_panel.visible


func get_trains(station_name:String) -> Array:
	var trains = []
	for train in TRAINS.keys():
		if TRAINS[train].has(station_name):
			trains.append(train)
	return trains

func get_other_trains(station:String) -> Array:
	var trains = []
	for train in TRAINS.keys():
		if TRAINS[train].has(station) and train != current_train:
			trains.append(train)
	return trains

func generate_timetable():
	var trains = get_other_trains(current_station)
	trains.shuffle()
	trains.insert(0, current_train)
	return trains

func wait_for_train():
	await %Curtain.close(%Curtain.DOWN)
	SFXPlayer.get_sfx_player(self).play_sfx("train")
	if get_other_trains(current_station).size() > 0:
		current_train = get_other_trains(current_station)[0]
	await get_tree().create_timer(3.0).timeout
	await %Curtain.open(%Curtain.UP)

func soft_clamp(val:float, upper:float) ->float:
	if val < 0:
		return val
	if val > upper * 2:
		return upper
	var upper_mult = upper * 4
	return val * ((upper_mult - val) / upper_mult)

func soft_clamp_signed(val:float, upper) ->float:
	return soft_clamp(abs(val), upper) * sign(val)

func soft_clamp_vec2(v:Vector2, upper:float):
	return Vector2(
			soft_clamp_signed(v.x, upper),
			soft_clamp_signed(v.y, upper)
		)

func clamp_vec2(v:Vector2, max_val):
	return Vector2(
		clampf(v.x, -max_val, max_val),
		clampf(v.y, -max_val, max_val)
	)

func update_offset(offset:Vector2):
	var cursor_offset = soft_clamp_vec2(offset, 0.49)
	%Cursor.position = (cursor_offset + Vector2(0.5, 0.5)) * get_viewport().get_visible_rect().size
	if camera:
		camera.set_rotation_offset(offset - cursor_offset)

const offset_max = 1.5
var offset_from_centre = Vector2.ZERO
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		get_viewport().set_input_as_handled()
		offset_from_centre += event.screen_relative / get_viewport().get_visible_rect().size
		offset_from_centre = clamp_vec2(offset_from_centre, offset_max*2)
		update_offset(soft_clamp_vec2(offset_from_centre, offset_max))
	elif event is InputEventMouseButton:
		event.position = %Cursor.position
		%SubViewport.push_input(event)

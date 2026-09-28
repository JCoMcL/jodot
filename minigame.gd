class_name Minigame
extends Node

@export var game_name : String ## Displayed before the game starts in big text
@export var control_type : Main.control_type ## Tells the player what kind of input the game expects
@export var should_win_on_timeover : bool = false ## If false, the game is lost when the timer runs out. If true, the game is won when the timer runs out

var minigame_end_duration : float = 0.7
var time_over : bool = false
var game_ended : bool = false
var game_won : bool = false

func _ready() -> void:
	Events.time_over.connect(_time_over)

func set_position(pos:Vector2):
	# OOP is so cool
	var base = self as Node
	if base is Control:
		base.position = pos
	elif base is Node2D:
		base.position = pos

func screenshake(amplitude : float = 10.0, duration : float = 0.3) -> void:
	var elapsed := 0.0
	while elapsed < duration:
		var decay := 1.0 - elapsed / duration
		var offset := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * amplitude * decay
		set_position(offset)
		$Background.position = -offset
		elapsed += get_process_delta_time()
		await get_tree().process_frame
	set_position(Vector2.ZERO)
	$Background.position = Vector2.ZERO

func _time_over() -> void:
	time_over = true
	if !game_ended:
		if should_win_on_timeover:
			_minigame_won()
			Sfx.play_sfx("correct")
		else:
			_minigame_loss()
			Sfx.play_sfx("ring short")

		await get_tree().create_timer(minigame_end_duration).timeout
	if game_won:
		Events.minigame_won.emit()
	else:
		Events.minigame_lost.emit()

	queue_free()

func _minigame_loss() -> void:
	if game_ended:
		return
	game_ended = true
	Sfx.play_sfx("booing")
	game_won = false

func _minigame_won() -> void:
	if game_ended:
		return
	game_ended = true
	Sfx.play_sfx("cheering")
	game_won = true

static func get_game(from:Node) -> Minigame:
	var curr = from
	while curr:
		if curr is Minigame:
			return curr
		curr = curr.get_parent()
	return null

static func win_game(from:Node):
	get_game(from)._minigame_won()

static func lose_game(from:Node):
	get_game(from)._minigame_loss()

extends Node2D

#==========TODO==========#
#Add Powerups?

#==========Variables==========#
var TIME = 60
var COIN_TIME = 3

var current_label = ""
var current_character_index = -1

var score = 0

#==========Onready Variables==========#
onready var player = $Player
onready var ysort = $Ysort
onready var coins_timer = $CoinsTimer
onready var stage_timer = $StageTimer
onready var ui = $UI
onready var timer_label = $UI/TimerLabel
onready var score_label = $UI/ScoreLabel

#==========Preload Variables==========#
onready var coins = preload("res://src/objects/challengemenu5/Coins.tscn")
onready var score_animation = preload("res://src/objects/ScoreAnimation.tscn")

#==========Functions==========#
func _ready():
	Global.current_menu = self
	randomize()
	init()

func init():
	generate_coins(5)
	stage_timer.wait_time = TIME
	stage_timer.start()
	coins_timer.wait_time = COIN_TIME
	coins_timer.start()

func _process(delta : float) -> void:
	update_ui()

func update_ui() -> void:
	timer_label.text = String(stage_timer.time_left).pad_decimals(2)
	score_label.text = String(score)

func add_score(n : int) -> void:
	score += n

func add_score_animation(position : Vector2, score : int) -> void:
	var s = score_animation.instance()
	s.position = position
	add_child(s)
	s.set_score(String(score))

func generate_coins(n : int) -> void:
	for _i in range(n):
		var screen_size = get_viewport_rect().size
		var c = coins.instance()
		c.position.x = rand_range(20, screen_size.x - 20)
		c.position.y = rand_range(20, screen_size.y - 20)
		ysort.add_child(c)

func find_direction(typed_character : String) -> void:
	for text in player.get_prompts():
		var next_character = text.substr(0,1)
		
		if next_character == typed_character:
			current_label = text
			current_character_index = 1
			player.select_direction(current_label)
			player.set_next_character(current_character_index)
			return
			
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		if current_label == "":
			find_direction(key_typed)
		else:
			var prompt = current_label
			var next_character = prompt.substr(current_character_index, 1)
			if key_typed == next_character and typed_event.unicode != 0:
				
				current_character_index += 1
				player.set_next_character(current_character_index)
				if current_character_index == prompt.length():
					
					player.change_direction()
					player.reset_direction(current_label)
					
					current_character_index = -1
					current_label = ""


#==========Connected Functions==========#
func _on_CoinsTimer_timeout():
	generate_coins(1)

func _on_StageTimer_timeout():
	stage_timer.stop()

#Testing
func _on_TestButton_pressed():
	Global.switch_scene("MainMenu")

extends Node2D

#==========TODO==========#
#Add Powerups?

#==========Variables==========#
const CHALLENGE_NUM : int = 4

var TIME : float = 20#60
var COIN_TIME : float = 3

var current_label : String = ""
var current_character_index : int = -1
var score : float = 0
var gameover : bool = false
var current_session_time : float = 0

var wpm : Array = [0, 0] #[overall, count]
var accuracy : Array = [0, 0] #[total_letters, correct_count]
var cur_accuracy : Array = []
var tracing_wpm : bool = false
var total_time : float = 0

#==========Onready Variables==========#
onready var pause_menu = $UI/PauseMenu
onready var gameover_menu = $GameOverMenu
onready var tutorial_menu = $UI/TutorialMenu
onready var countdown_menu = $UI/CountdownMenu
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
	
	#Initialize countdown
	if Global.user_data["SeenTutorials"][CHALLENGE_NUM]:
		countdown_menu.start()
		
	#Initialize tutorial menu
	tutorial_menu.start(CHALLENGE_NUM)
	Global.set_seen_tutorial(CHALLENGE_NUM)
	
	#Initialize for testing
	Global.setup_research_variables("Challenge" + String(CHALLENGE_NUM + 1), Time.get_date_string_from_system(true))

func _process(delta : float) -> void:
	update_ui()
	#Trace session time
	current_session_time += delta
	#Trace WPM
	if tracing_wpm:
		total_time += delta

func update_ui() -> void:
	timer_label.text = String(stage_timer.time_left).pad_decimals(2)
	score_label.text = String(score)

func add_score(n : int) -> void:
	score += n

func register_wpm() -> void:
	if total_time > 0:
		wpm[0] += (current_label.length() * 60) / (5 * total_time)
		wpm[1] += 1
	tracing_wpm = false
	total_time = 0
	
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
			cur_accuracy = []
			for j in range(0, current_label.length()):
				cur_accuracy.append(true)
			tracing_wpm = true
			Global.play_keyboard_sfx()
			return
			
func _unhandled_input(event : InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if !pause_menu.visible and !gameover_menu.visible and !tutorial_menu.visible:
			pause_menu.pause()
		
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
					#Get Accuracy
					for b in cur_accuracy:
						if b:
							accuracy[1] += 1
						accuracy[0] += 1
					#Get Wpm
					register_wpm()
					
					player.change_direction()
					player.reset_direction(current_label)
					
					current_character_index = -1
					current_label = ""
				Global.play_keyboard_sfx()
			else:
				cur_accuracy[current_character_index-1] = false
				player.apply_text_shake(10, 10)
				Global.play_sfx("ErrorKey")

func show_gameover_menu() -> void:
	var total_accuracy : float = 0
	var total_wpm : float = 0
	if accuracy[0] > 0:
		total_accuracy = (accuracy[1] / float(accuracy[0])) * 100
	if wpm[1] > 0:
		total_wpm = (wpm[0]/float(wpm[1]))
	#Register Stats
	Global.register_challenge_stats(CHALLENGE_NUM, total_wpm, total_accuracy, current_session_time, score)
	Global.save_research_variables("Challenge" + String(CHALLENGE_NUM + 1), Time.get_date_string_from_system(true), total_wpm, total_accuracy, current_session_time)
	Global.save_user_data()
	gameover_menu.init("SCORE: " + String(score) + "\nH-SCORE: " + String(Global.user_data["ChallengeStats"][CHALLENGE_NUM]["highest_score"]) + "\nACCURACY: " + String(stepify(total_accuracy,1)) + "\nWPM: " + String(stepify(total_wpm,1)))
	gameover_menu.show()
	
func gameover():
	get_tree().paused = true
	gameover = true
	show_gameover_menu()

#==========Connected Functions==========#
func _on_CoinsTimer_timeout():
	generate_coins(1)

func _on_StageTimer_timeout():
	gameover()
	stage_timer.stop()

#Testing
func _on_TestButton_pressed():
	Global.switch_scene("MainMenu")

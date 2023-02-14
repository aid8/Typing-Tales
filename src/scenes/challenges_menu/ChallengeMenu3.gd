extends Node2D
#==========TODO==========#
#WHEN TILE IS BEING TYPED, HIGHLIGHT ALSO

#==========Variables==========#
const CHALLENGE_NUM : int = 2

var GAME_TIME : float = 60
var TILE_SPAWN : float = 5
var SCORE_MULTIPLIER : float = 1.25
var KEY_SCORE : float = 5
var POWERUP_TIMERS : Dictionary = {
	"green" : 10,
	"blue" : 10,
	"red" : 10,
}

var tiles : Array = []
var current_character_index : int = -1
var active_tile = null
var first_tile = null
var score : float = 0
var gameover : bool = false
var current_session_time : float = 0

var powerups : Dictionary = {
	"green" : false, #Multiplier
	"blue" : false, #Slow timer
	"red" : false, #Fast tile spawn
}

var colors : Dictionary = {
	"green" : Color(0.376471,0.654902,0.376471,1),
	"blue" : Color(0.105882,0.4,0.611765,1),
	"red" : Color(0.768627,0.419608,0.419608,1),
}

var wpm : Array = [0, 0] #[overall, count]
var accuracy : Array = [0, 0] #[total_letters, correct_count]
var cur_accuracy : Array = []
var tracing_wpm : bool = false
var total_time : float = 0

#==========Onready Variables==========#
onready var pause_menu : Node2D = $UI/PauseMenu
onready var gameover_menu : CanvasLayer = $GameOverMenu
onready var countdown_menu : Node2D = $UI/CountdownMenu
onready var tutorial_menu : Node2D = $UI/TutorialMenu
onready var starting_tile_position : Position2D = $StartingTilePosition
onready var ysort : YSort = $YSort

onready var red_bar : TextureProgress = $UI/RedBar
onready var blue_bar : TextureProgress = $UI/BlueBar
onready var green_bar : TextureProgress = $UI/GreenBar
onready var timer_label : Label = $UI/TimerLabel
onready var score_label : Label = $UI/ScoreLabel

onready var game_timer : Timer = $GameTimer
onready var green_timer : Timer = $GreenTimer
onready var blue_timer : Timer = $BlueTimer
onready var red_timer : Timer = $RedTimer

#==========Preload Variables==========#
onready var tile = preload("res://src/objects/challengemenu3/Tile.tscn")

#==========Functions==========#
func _ready():
	Global.current_menu = self
	init()
	create_tiles()

func _process(delta : float) -> void:
	timer_label.text = String(game_timer.time_left).pad_decimals(2)
	#Progress bars
	if powerups.green:
		green_bar.max_value = POWERUP_TIMERS.green
		green_bar.value = green_timer.time_left
	if powerups.blue:
		blue_bar.max_value = POWERUP_TIMERS.blue
		blue_bar.value = blue_timer.time_left
	if powerups.red:
		red_bar.max_value = POWERUP_TIMERS.red
		red_bar.value = red_timer.time_left
	#Trace session time
	current_session_time += delta
	#Trace WPM
	if tracing_wpm:
		total_time += delta
		
func init() -> void:
	game_timer.start(GAME_TIME)
	update_ui()
	
	#Initialize countdown
	if Global.user_data["SeenTutorials"][CHALLENGE_NUM]:
		countdown_menu.start()
		
	#Initialize tutorial menu
	tutorial_menu.start(CHALLENGE_NUM)
	Global.set_seen_tutorial(CHALLENGE_NUM)
	
	#Initialize for testing
	Global.setup_research_variables("Challenge" + String(CHALLENGE_NUM + 1), Time.get_date_string_from_system())

	#Shuffle Word Bank
	WordList.init()
	
	#Change BGM
	BackgroundMusic.play_music("Challenge3BGM")

func update_ui() -> void:
	score_label.text = String(score)

func register_wpm() -> void:
	if total_time > 0:
		wpm[0] += (active_tile.get_prompt().length() * 60) / (5 * total_time)
		wpm[1] += 1
	tracing_wpm = false
	Global.user_data["TotalTimeSpent"][2] += total_time
	total_time = 0
	
func add_score(text_length : int) -> void:
	var comp = text_length * KEY_SCORE
	if powerups.green:
		comp *= SCORE_MULTIPLIER
	score += comp
	update_ui()

func create_tiles() -> void:
	var width = 125
	var height = 125
	var gap = 10
	var j = 0
	var k = 0
	for i in range(1, 17):
		var t = tile.instance()
		t.position.x = starting_tile_position.position.x + ((width + gap) * k)
		t.position.y = starting_tile_position.position.y + ((height + gap) * j) 
		if i % 4 == 0:
			j += 1
			k = -1
		k += 1
		ysort.add_child(t)
		tiles.push_back(t)

func get_tiles_starting_letters() -> Array:
	var texts = []
	for tile in tiles:
		var text = tile.get_prompt()
		if text.length() > 0:
			texts.append(text[0])
	return texts

func find_tile(typed_character : String) -> void:
	#for tile in tiles.get_children():
	for tile in tiles:
		if first_tile != null and first_tile == tile:
			continue
		var prompt = tile.get_prompt()
		var next_character = prompt.substr(0,1)
		if next_character == typed_character:
			#print("found new enemy starting ", next_character)
			cur_accuracy = []
			for j in range(0, prompt.length()):
				cur_accuracy.append(true)
			active_tile = tile
			current_character_index = 1
			active_tile.set_next_character(current_character_index)
			active_tile.toggle_highlight(true, "start")
			tracing_wpm = true
			Global.play_keyboard_sfx()
			return

func _unhandled_input(event : InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if !pause_menu.visible and !gameover_menu.visible and !tutorial_menu.visible:
			pause_menu.pause()
			Global.play_sfx("Cancel")
		
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		if active_tile == null:
			find_tile(key_typed)
		else:
			var prompt = active_tile.get_prompt()
			var next_character = prompt.substr(current_character_index, 1)
			
			#Cancel typing
			if typed_event.scancode == 16777218:
				active_tile.set_next_character(-1)
				active_tile.toggle_highlight(false)
				current_character_index = -1
				active_tile = null
				tracing_wpm = false
				total_time = 0
				Global.play_sfx("Bell_2")
				return
			
			if key_typed == next_character and typed_event.unicode != 0:
				#print("success: ", key_typed)
				current_character_index += 1
				active_tile.set_next_character(current_character_index)
				if current_character_index == prompt.length():
					#print("done")
					current_character_index = -1
					#active_tile.damage()
					
					#Get accuracy and add letter mastery
					for i in range(0, cur_accuracy.size()):
						if cur_accuracy[i]:
							accuracy[1] += 1
						accuracy[0] += 1
						Global.add_letter_mastery(prompt[i], cur_accuracy[i], false)
					#Add word mastery
					Global.add_word_mastery(prompt, cur_accuracy.count(true) / float(cur_accuracy.size()))
					#Get Wpm
					register_wpm()
					
					#SFX
					Global.play_sfx("Correct_3")
					
					if first_tile == null:
						first_tile = active_tile
						first_tile.toggle_highlight(true, "end")
					else:
						#Do magic here
						if first_tile.get_current_color() == active_tile.get_current_color():
							#Check color and add score
							if active_tile.get_current_color() == colors.green:
								green_timer.start(POWERUP_TIMERS.green)
								powerups.green = true
							elif active_tile.get_current_color() == colors.blue:
								blue_timer.start(POWERUP_TIMERS.blue)
								powerups.blue = true
								game_timer.set_paused(true)
							else:
								red_timer.start(POWERUP_TIMERS.red)
								powerups.red = true
							add_score(prompt.length())
							
							if !powerups.red:
								first_tile.delayed_refresh_tile(TILE_SPAWN)
								active_tile.delayed_refresh_tile(TILE_SPAWN)
							else:
								first_tile.refresh_tile()
								active_tile.refresh_tile()
							
							#SFX
							Global.play_sfx("Powerup")
						else:
							first_tile.cancel_tile()
							active_tile.cancel_tile()
						active_tile.toggle_highlight(false)
						first_tile.toggle_highlight(false)
						first_tile = null
					active_tile = null
				Global.play_keyboard_sfx()
			else:
				cur_accuracy[current_character_index-1] = false
				active_tile.apply_text_shake(10, 10)
				Global.play_sfx("ErrorKey")
				#if typed_event.scancode != KEY_SHIFT and typed_event.scancode != KEY_ESCAPE: 
					#print("incorrect %s, should be %s" % [key_typed, next_character])

func show_gameover_menu() -> void:
	var total_accuracy : float = 0
	var total_wpm : float = 0
	if accuracy[0] > 0:
		total_accuracy = (accuracy[1] / float(accuracy[0])) * 100
	if wpm[1] > 0:
		total_wpm = (wpm[0]/float(wpm[1]))
	#Register Stats
	Global.register_challenge_stats(CHALLENGE_NUM, total_wpm, total_accuracy, current_session_time, score)
	Global.save_research_variables("Challenge" + String(CHALLENGE_NUM + 1), Time.get_date_string_from_system(), total_wpm, total_accuracy, current_session_time) 
	Global.save_user_data()
	gameover_menu.init("SCORE: " + String(score) + "\nH-SCORE: " + String(Global.user_data["ChallengeStats"][CHALLENGE_NUM]["highest_score"]) + "\nACCURACY: " + String(stepify(total_accuracy,1)) + "\nWPM: " + String(stepify(total_wpm,1)))
	gameover_menu.show()
	
#==========Connected Functions==========#
func _on_GameTimer_timeout():
	get_tree().paused = true
	gameover = true
	game_timer.stop()
	show_gameover_menu()

func _on_GreenTimer_timeout():
	powerups.green = false

func _on_BlueTimer_timeout():
	powerups.blue = false
	game_timer.set_paused(false)

func _on_RedTimer_timeout():
	powerups.red = false

#Testing
func _on_TestButton_pressed():
	Global.switch_scene("MainMenu")

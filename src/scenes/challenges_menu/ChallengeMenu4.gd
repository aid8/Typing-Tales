extends Node2D

#==========TODO==========#
#Add Score
#balance speed of brick depending on bricks stacked
#Increase speed as time passes

#==========Variables==========#
const CHALLENGE_NUM : int = 3

var BRICK_SPAWN_TIME : float = 2
var BRICK_LIMIT : int = 9
var SCORE_MULT : float = 1.25

var bricks_stacked : float = 0
var current_brick
var current_character_index : int = 0
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
onready var stage_bottom = $Stage/StageBottom
onready var spawn_brick_position = $Stage/SpawnBrickPosition
onready var spawn_timer = $SpawnTimer
onready var ui = $UI
onready var score_label = $UI/ScoreLabel

#==========Preload Variables==========#
onready var brick = preload("res://src/objects/challengemenu4/Brick.tscn")

#==========Functions==========#
func _ready():
	Global.current_menu = self
	init()

func init():
	spawn_timer.wait_time = BRICK_SPAWN_TIME
	spawn_timer.start()
	update_ui()
	
	#Initialize countdown
	if Global.user_data["SeenTutorials"][CHALLENGE_NUM]:
		countdown_menu.start()
		
	#Initialize tutorial menu
	tutorial_menu.start(CHALLENGE_NUM)
	Global.set_seen_tutorial(CHALLENGE_NUM)
	
	#Initialize for testing
	Global.setup_research_variables("Challenge" + String(CHALLENGE_NUM + 1), Time.get_date_string_from_system(true))

func _process(delta : float) -> void:
	current_session_time += delta
	if tracing_wpm:
		total_time += delta

func update_ui():
	score_label.text = String(score)

func add_score(n : int) -> void:
	score += n
	update_ui()

func register_wpm() -> void:
	if total_time > 0:
		wpm[0] += (current_brick.get_prompt().length() * 60) / (5 * total_time)
		wpm[1] += 1
	tracing_wpm = false
	total_time = 0
	
func spawn_brick():
	var b = brick.instance()
	b.position = spawn_brick_position.global_position
	add_child(b)
	current_brick = b
	cur_accuracy = []
	for j in range(0, current_brick.get_prompt().length()):
		cur_accuracy.append(true)
	spawn_timer.stop()

func reset_brick():
	current_brick = null
	current_character_index = 0
	tracing_wpm = false
	spawn_timer.start()

func add_stack(stack : float) -> void:
	bricks_stacked += stack
	if bricks_stacked >= BRICK_LIMIT:
		gameover()

func _unhandled_input(event : InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if !pause_menu.visible and !gameover_menu.visible and !tutorial_menu.visible:
			pause_menu.pause()
		
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		if current_brick != null:
			var prompt = current_brick.get_prompt()
			var next_character = prompt.substr(current_character_index, 1)
			if key_typed == next_character and typed_event.unicode != 0:
				#If first character
				if current_character_index == 0:
					tracing_wpm = true
				#print("success: ", key_typed)
				current_character_index += 1
				current_brick.set_next_character(current_character_index)
				if current_character_index == prompt.length():
					#print("done")
					#Get Accuracy
					for b in cur_accuracy:
						if b:
							accuracy[1] += 1
						accuracy[0] += 1
					#Get Wpm
					register_wpm()
					
					add_score(prompt.length() * SCORE_MULT)
					current_character_index = 0
					current_brick.die()
					spawn_timer.start()
			else:
				cur_accuracy[current_character_index-1] = false

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
func _on_SpawnTimer_timeout():
	spawn_brick()

func _on_StageBottom_body_entered(body):
	if body.get("type") == "Brick":
		body.disable_brick()
		reset_brick()
		add_stack(1)

#Testing
func _on_TestButton_pressed():
	Global.switch_scene("MainMenu")

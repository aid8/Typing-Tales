extends Node2D
#==========TODO==========#
#Add session time
#POLISH

#==========Variables==========#
const CHALLENGE_NUM : int = 0
const MAX_ENLARGEMENT : int = 5
const ENLARGEMENT_ADDITION : float = 1.2

var current_session_time : float = 0
var platform_index : int
var target_platform : Area2D = null
var current_letter_index : int = -1
var current_player_platform_index : int = -1
var next_target_platform_index : int = -1
var gameover : bool = false
var total_score : float = 0
var cur_score : float = 0
var lives : int = 5 #new

var wpm : Array = [0, 0] #[overall, count]
var accuracy : Array = [0, 0] #[total_letters, correct_count]
var cur_accuracy : Array = []
var tracing_wpm : bool = false
var total_time : float = 0

var fall_speed : float = 80
var additional_fall_speed : float = 15
var fall_speed_time_diff : float = 10
var spawn_timer : float = 4.0
var subtract_spawn_time : float = 0.3
var spawn_time_diff : float = 10
#var heart_uis : Array = []
var cur_enlargement : int = 0

#==========Onready Variables==========#
onready var rand : RandomNumberGenerator = RandomNumberGenerator.new()
onready var platforms : Array = [$Platform1, $Platform2, $Platform3]
onready var player : Area2D = $Player
onready var falling_speed_timer : Timer = $FallingSpeedTimer
onready var spawn_speed_timer : Timer = $SpawnSpeedTimer
onready var gameover_menu : CanvasLayer = $GameOverMenu
onready var game_ui : CanvasLayer = $GameUI
onready var lives_label : Label = $LivesLabel
onready var health_bar : Node2D = $GameUI/HealthBar
onready var pause_menu : Node2D = $GameUI/PauseMenu
onready var score_label : Label = $GameUI/ScoreLabel
onready var tutorial_menu : Node2D = $GameUI/TutorialMenu
onready var countdown_menu : Node2D = $GameUI/CountdownMenu

#==========Preload Variables==========#
onready var falling_object = preload("res://src/objects/challengemenu1/FallingObject.tscn")
onready var score_animation = preload("res://src/objects/ScoreAnimation.tscn")

#==========Functions==========#
func _ready():
	Global.current_menu = self
	rand.randomize()
	for p in platforms:
		p.set_random_word()
	falling_speed_timer.start(fall_speed_time_diff)
	spawn_speed_timer.start(spawn_time_diff)
	platform_index = rand.randi_range(0, 2)
	switch_player_platform(1)
	spawn_falling_object()
	
	#Initialize ui
	lives_label.text = "Lives: " + String(lives)
	health_bar.init(lives)
	
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
	BackgroundMusic.play_music("Challenge1BGM")

func _process(delta : float) -> void:
	current_session_time += delta
	if tracing_wpm:
		total_time += delta

func register_wpm() -> void:
	if total_time > 0:
		wpm[0] += (target_platform.text.length() * 60) / (5 * total_time)
		wpm[1] += 1
	tracing_wpm = false
	total_time = 0
	
func spawn_falling_object() -> void:
	var fo = falling_object.instance()
	var xpos = platforms[platform_index].global_position.x
	fo.position.x = xpos
	fo.position.y = 0
	fo.initialize(fall_speed)
	add_child(fo)
	platform_index = rand.randi_range(0, 2)
	
	if !gameover:
		yield(get_tree().create_timer(spawn_timer, false), "timeout")
		spawn_falling_object()

func switch_player_platform(index : int) -> void:
	player.position = platforms[index].get_node("Position2D").global_position
	current_player_platform_index = index
	platforms[index].toggle_text(true)
	for i in len(platforms):
		if i == index:
			continue
		platforms[i].toggle_text(false)

func get_platform_words() -> Array:
	return [platforms[0].text, platforms[1].text, platforms[2].text]

func _unhandled_input(event : InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if !pause_menu.visible and !gameover_menu.visible and !tutorial_menu.visible:
			pause_menu.pause()
			Global.play_sfx("Cancel")
		
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		if target_platform == null:
			for i in len(platforms):
				var platform_text = platforms[i].text
				if platform_text.substr(0, 1) == key_typed and platforms[i].available:
					cur_accuracy = []
					for j in range(0, platform_text.length()):
						cur_accuracy.append(true)
					target_platform = platforms[i]
					current_letter_index = 1
					target_platform.set_next_character(current_letter_index)
					next_target_platform_index = i
					tracing_wpm = true
					Global.play_keyboard_sfx()
					break
		else:
			var prompt = target_platform.text
			var next_character = prompt.substr(current_letter_index, 1)
			#print(next_character, "-", key_typed)
			if key_typed == next_character and typed_event.unicode != 0:
				#cur_score += 10
				current_letter_index += 1
				target_platform.set_next_character(current_letter_index)
				if current_letter_index == prompt.length():
					#Add and reset score
					#add_score_animation(target_platform.get_node("Position2D").global_position, cur_score)
					#total_score += cur_score
					#cur_score = 0
					
					#get accuracy and add letter mastery
					for i in range(0, cur_accuracy.size()):
						if cur_accuracy[i]:
							accuracy[1] += 1
						accuracy[0] += 1
						Global.add_letter_mastery(prompt[i], cur_accuracy[i], false)
					#Add word mastery
					Global.add_word_mastery(prompt, cur_accuracy.count(true) / float(cur_accuracy.size()))
					
					#get wpm
					register_wpm()
					
					target_platform.set_random_word()
					current_letter_index = -1
					switch_player_platform(next_target_platform_index)
					target_platform = null
					Global.play_sfx("Correct_3")
				Global.play_keyboard_sfx()
			else:
				cur_accuracy[current_letter_index-1] = false
				target_platform.apply_text_shake(10, 10)
				Global.play_sfx("ErrorKey")
				#cur_score -= 2
				#if cur_score <= 0:
				#	cur_score = 0
			
		#print (typed_event.scancode)
		if typed_event.scancode == 16777231:
			switch_player_platform(0)
		elif typed_event.scancode == 16777234:
			switch_player_platform(1)
		elif typed_event.scancode == 16777233:
			switch_player_platform(2)

func add_score_animation(position : Vector2, score : int) -> void:
	var s = score_animation.instance()
	s.position = position
	add_child(s)
	s.set_score(String(score))

#func save_research_variables(mode : String, date : String, wpm : float, accuracy : float, time : float) -> void:
func show_gameover_menu() -> void:
	var total_accuracy : float = 0
	var total_wpm : float = 0
	if accuracy[0] > 0:
		total_accuracy = (accuracy[1] / float(accuracy[0])) * 100
	if wpm[1] > 0:
		total_wpm = (wpm[0]/float(wpm[1]))
	#Register Stats
	Global.register_challenge_stats(CHALLENGE_NUM, total_wpm, total_accuracy, current_session_time, total_score)
	Global.save_research_variables("Challenge" + String(CHALLENGE_NUM + 1), Time.get_date_string_from_system(), total_wpm, total_accuracy, current_session_time) 
	Global.save_user_data()
	gameover_menu.init("SCORE: " + String(total_score) + "\nH-SCORE: " + String(Global.user_data["ChallengeStats"][CHALLENGE_NUM]["highest_score"]) + "\nACCURACY: " + String(stepify(total_accuracy,1)) + "\nWPM: " + String(stepify(total_wpm,1)))
	gameover_menu.show()

func subtract_lives()-> void:
	health_bar.subtract_life()
	lives = health_bar.get_lives()
	lives_label.text = "Lives: " + String(lives)
	resize_player(false)
	#SFX
	Global.play_sfx("Lose")
	if lives <= 0:
		get_tree().paused = true
		gameover = true
		show_gameover_menu()
		print("GAME OVER")

func resize_player(enlarge : bool) -> void:
	if enlarge:
		if cur_enlargement >= MAX_ENLARGEMENT:
			return
		cur_enlargement += 1
		player.scale *= ENLARGEMENT_ADDITION
	else:
		if cur_enlargement <= 0:
			return
		cur_enlargement -= 1
		player.scale /= ENLARGEMENT_ADDITION

func update_ui() -> void:
	score_label.text = String(total_score)

#==========Connected Functions==========#
func _on_Player_body_entered(body):
	if body.type == "FallingObject":
		#cur and total score?
		cur_score = fall_speed
		var edited_pos = player.position
		edited_pos.y -= 50
		add_score_animation(edited_pos, cur_score)
		total_score += cur_score
		update_ui()
		body.queue_free()
		resize_player(true)
		Global.play_sfx("Correct_1")

func _on_FallingSpeedTimer_timeout():
	fall_speed += additional_fall_speed
	print("Difficulty Increased")

func _on_SpawnSpeedTimer_timeout():
	if spawn_timer > 0.5:
		spawn_timer -= subtract_spawn_time

#Testing
func _on_TestButton_pressed():
	Global.switch_scene("MainMenu")

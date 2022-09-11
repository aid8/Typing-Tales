extends Node2D
#==========TODO==========#
#POLISH
#ADD COUNTDOWN

#==========Variables==========#
var platform_index : int
var target_platform : Area2D = null
var current_letter_index : int = -1
var current_player_platform_index : int = -1
var next_target_platform_index : int = -1
var gameover : bool = false
var total_score : int = 0
var cur_score : int = 0

var wpm : Array = [0, 0] #[overall, count]
var accuracy : Array = [0, 0] #[total_letters, correct_count]
var cur_accuracy : Array = []
var tracing_wpm : bool = false
var total_time : float = 0

var fall_speed : float = 100
var additional_fall_speed : float = 25
var fall_speed_time_diff : float = 10
var spawn_timer : float = 2.0
var subtract_spawn_time : float = 0.1
var spawn_time_diff : float = 10

#==========Onready Variables==========#
onready var rand : RandomNumberGenerator = RandomNumberGenerator.new()
onready var platforms : Array = [$Platform1, $Platform2, $Platform3]
onready var player : Area2D = $Player
onready var falling_speed_timer : Timer = $FallingSpeedTimer
onready var spawn_speed_timer : Timer = $SpawnSpeedTimer
onready var gameover_menu : CanvasLayer = $GameOverMenu

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

func _process(delta : float) -> void:
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
		yield(get_tree().create_timer(spawn_timer), "timeout")
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
					break
		else:
			var prompt = target_platform.text
			var next_character = prompt.substr(current_letter_index, 1)
			#print(next_character, "-", key_typed)
			if key_typed == next_character and typed_event.unicode != 0:
				cur_score += 10
				current_letter_index += 1
				target_platform.set_next_character(current_letter_index)
				if current_letter_index == prompt.length():
					#Add and reset score
					add_score_animation(target_platform.get_node("Position2D").global_position, cur_score)
					total_score += cur_score
					cur_score = 0
					
					#get accuracy
					for b in cur_accuracy:
						if b:
							accuracy[1] += 1
						accuracy[0] += 1
					#get wpm
					register_wpm()
					target_platform.set_random_word()
					current_letter_index = -1
					switch_player_platform(next_target_platform_index)
					target_platform = null
			else:
				cur_accuracy[current_letter_index-1] = false
				cur_score -= 2
				if cur_score <= 0:
					cur_score = 0
			
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

func show_gameover_menu() -> void:
	var total_accuracy : float = 0
	var total_wpm : float = 0
	if accuracy[0] > 0:
		total_accuracy = (accuracy[1] / float(accuracy[0])) * 100
	if wpm[1] > 0:
		total_wpm = (wpm[0]/float(wpm[1]))
	gameover_menu.get_node("StatsLabel").text = "Score: " + String(total_score) + "\nTotal Accuracy: " + String(total_accuracy) + "\nTotal WPM: " + String(total_wpm)
	gameover_menu.show()
	
#==========Connected Functions==========#
func _on_Player_body_entered(body):
	if body.type == "FallingObject":
		get_tree().paused = true
		gameover = true
		show_gameover_menu()
		print("GAME OVER")

func _on_FallingSpeedTimer_timeout():
	fall_speed += additional_fall_speed
	print("Difficulty Increased")

func _on_SpawnSpeedTimer_timeout():
	if spawn_timer > 0.5:
		spawn_timer -= subtract_spawn_time

func _on_RestartButton_pressed():
	get_tree().paused = false
	SceneTransition.switch_scene(String(get_tree().current_scene.filename), "Curtain")

func _on_MainMenuButton_pressed():
	pass # Replace with function body.

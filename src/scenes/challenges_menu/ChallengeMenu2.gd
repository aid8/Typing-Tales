extends Node2D
#==========TODO==========#
#POLISH
#ADD SCORE
#ADD GAMEOVER

#==========Variables==========#
var wpm : Array = [0, 0] #[overall, count]
var accuracy : Array = [0, 0] #[total_letters, correct_count]
var cur_accuracy : Array = []
var tracing_wpm : bool = false
var total_time : float = 0

var SCORING : int = 10
var active_enemy
var current_character_index : int = -1
var health : int = 5
var speed_addition : float = 10
var enemy_speed : float = 0
var score : int = 0
var gameover : bool = false

#==========Onready Variables==========#
onready var base : Area2D = $Base
onready var enemy_container : YSort = $EnemyContainer
onready var lives_label : Label = $UI/LivesLabel
onready var health_bar : Node2D = $UI/HealthBar
onready var score_label : Label = $UI/ScoreLabel
onready var gameover_menu : CanvasLayer = $GameOverMenu
onready var enemy_spawn_timer : Timer = $EnemySpawnTimer
onready var difficulty_timer : Timer = $DifficultyTimer

#==========Preload Variables==========#
onready var enemy = preload("res://src/objects/challengemenu2/Enemy.tscn")
onready var score_animation = preload("res://src/objects/ScoreAnimation.tscn")

#==========Functions==========#
func _ready():
	Global.current_menu = self
	randomize()
	spawn_enemy()
	update_ui()
	health_bar.init(health)

func _process(delta : float) -> void:
	if tracing_wpm:
		total_time += delta

func register_wpm() -> void:
	if total_time > 0:
		wpm[0] += (active_enemy.get_prompt().length() * 60) / (5 * total_time)
		wpm[1] += 1
	tracing_wpm = false
	total_time = 0
	
func spawn_enemy() -> void:
	var s = enemy.instance()
	var pos = [-1,1]
	var posX = [-15, 1295]
	var posY = [-15, 735]
	var XY = randi() % 2
	s.MAX_SPEED += enemy_speed
	if XY == 0:
		s.position = Vector2(posX[randi() % 2], rand_range(-15,735))
	elif XY == 1:
		s.position = Vector2(rand_range(-15, 1295), posY[randi() % 2])
	enemy_container.add_child(s)

func get_enemy_starting_letters() -> Array:
	var texts = []
	for enemy in enemy_container.get_children():
		var text = enemy.get_prompt()
		if text.length() > 0:
			texts.append(text[0])
	return texts

func update_ui() -> void:
	lives_label.text = "Lives: " + String(health)

func add_score(s : int) -> void:
	score += s
	score_label.text = String(score)

func show_gameover_menu() -> void:
	var total_accuracy : float = 0
	var total_wpm : float = 0
	if accuracy[0] > 0:
		total_accuracy = (accuracy[1] / float(accuracy[0])) * 100
	if wpm[1] > 0:
		total_wpm = (wpm[0]/float(wpm[1]))
	gameover_menu.init("SCORE: " + String(score) + "\nACCURACY: " + String(stepify(total_accuracy,1)) + "\nWPM: " + String(stepify(total_wpm,1)))
	gameover_menu.show()

func add_score_animation(position : Vector2, score : int) -> void:
	var s = score_animation.instance()
	s.position = position
	add_child(s)
	s.set_score(String(score))

func find_new_active_enemy(typed_character : String):
	for enemy in enemy_container.get_children():
		var prompt = enemy.get_prompt()
		var next_character = prompt.substr(0,1)
		
		if next_character == typed_character:
			#print("found new enemy starting ", next_character)
			active_enemy = enemy
			current_character_index = 1
			active_enemy.set_next_character(current_character_index)
			
			cur_accuracy = []
			for j in range(0, active_enemy.get_prompt().length()):
				cur_accuracy.append(true)
			tracing_wpm = true
			return
			
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		if active_enemy == null:
			find_new_active_enemy(key_typed)
		else:
			var prompt = active_enemy.get_prompt()
			var next_character = prompt.substr(current_character_index, 1)
			if key_typed == next_character and typed_event.unicode != 0:
				current_character_index += 1
				active_enemy.set_next_character(current_character_index)
				#If all is typed
				if current_character_index == prompt.length():
					current_character_index = -1
					#Add Score
					var cur_score = prompt.length() * SCORING
					add_score_animation(active_enemy.position, cur_score)
					add_score(cur_score)
					#Get accuracy
					for b in cur_accuracy:
						if b:
							accuracy[1] += 1
						accuracy[0] += 1
					#Get wpm
					register_wpm()
					#Damage enemy
					active_enemy.damage()
					active_enemy = null
			else:
				cur_accuracy[current_character_index-1] = false
				#if typed_event.scancode != KEY_SHIFT and typed_event.scancode != KEY_ESCAPE: 
					#print("incorrect %s, should be %s" % [key_typed, next_character])
					

#==========Connected Functions==========#
func _on_Base_body_entered(body):
	if body.get("type") == "Enemy":
		body.damage()
		if active_enemy == body:
			active_enemy = null
		health_bar.subtract_life()
		health = health_bar.get_lives()
		update_ui()
		if health <= 0:
			enemy_spawn_timer.stop()
			difficulty_timer.stop()
			get_tree().paused = true
			gameover = true
			show_gameover_menu()
			print("Game Over")

func _on_EnemySpawnTimer_timeout():
	spawn_enemy()

func _on_DifficultyTimer_timeout():
	enemy_speed += speed_addition
	SCORING += 5

#Testing
func _on_TestButton_pressed():
	Global.switch_scene("MainMenu")

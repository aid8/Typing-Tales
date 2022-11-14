extends Node2D
#==========TODO==========#
#POLISH
#ADD SCORE
#ADD GAMEOVER

#==========Variables==========#
var active_enemy
var current_character_index = -1
var health = 10
var speed_addition = 10
var enemy_speed = 0

#==========Onready Variables==========#
onready var base = $Base
onready var enemy_container = $EnemyContainer
onready var lives_label = $UI/LivesLabel

#==========Preload Variables==========#
onready var enemy = preload("res://src/objects/challengemenu2/Enemy.tscn")

#==========Functions==========#
func _ready():
	Global.current_menu = self
	randomize()
	spawn_enemy()
	update_ui()

func spawn_enemy() -> void:
	var s = enemy.instance()
	var pos = [-1,1]
	var posX = [0, 1280]
	s.MAX_SPEED += enemy_speed
	s.position = Vector2(base.global_position.x + (rand_range(200,600)) * pos[randi() % 2], base.global_position.y + (rand_range(450,600)) * pos[randi() % 2])
	enemy_container.add_child(s)

func get_enemy_starting_letters() -> Array:
	var texts = []
	for enemy in enemy_container.get_children():
		var text = enemy.get_prompt()
		if text.length() > 0:
			texts.append(text[0])
	return texts

func update_ui():
	lives_label.text = "Lives: " + String(health)

func find_new_active_enemy(typed_character : String):
	for enemy in enemy_container.get_children():
		var prompt = enemy.get_prompt()
		var next_character = prompt.substr(0,1)
		
		if next_character == typed_character:
			print("found new enemy starting ", next_character)
			active_enemy = enemy
			current_character_index = 1
			active_enemy.set_next_character(current_character_index)
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
				#print("success: ", key_typed)
				current_character_index += 1
				active_enemy.set_next_character(current_character_index)
				if current_character_index == prompt.length():
					#print("done")
					current_character_index = -1
					active_enemy.damage()
					active_enemy = null
			#else:
				#if typed_event.scancode != KEY_SHIFT and typed_event.scancode != KEY_ESCAPE: 
					#print("incorrect %s, should be %s" % [key_typed, next_character])
					

#==========Connected Functions==========#
func _on_Base_body_entered(body):
	if body.get("type") == "Enemy":
		body.damage()
		active_enemy = null
		health -= 1
		update_ui()
		if health <= 0:
			print("Game Over")

func _on_EnemySpawnTimer_timeout():
	spawn_enemy()

func _on_DifficultyTimer_timeout():
	enemy_speed += speed_addition

#Testing
func _on_TestButton_pressed():
	Global.switch_scene("MainMenu")

extends Node2D

#==========TODO==========#
#Add Score
#balance speed of brick depending on bricks stacked
#Increase speed as time passes

#==========Variables==========#
var BRICK_SPAWN_TIME = 2
var BRICK_LIMIT = 9
var SCORE_MULT : float = 1.25

var bricks_stacked = 0
var current_brick
var current_character_index = 0
var score = 0

#==========Onready Variables==========#
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

func update_ui():
	score_label.text = String(score)

func add_score(n : int) -> void:
	score += n
	update_ui()

func spawn_brick():
	var b = brick.instance()
	b.position = spawn_brick_position.global_position
	add_child(b)
	current_brick = b
	spawn_timer.stop()

func reset_brick():
	current_brick = null
	current_character_index = 0
	spawn_timer.start()

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		if current_brick != null:
			var prompt = current_brick.get_prompt()
			var next_character = prompt.substr(current_character_index, 1)
			if key_typed == next_character and typed_event.unicode != 0:
				#print("success: ", key_typed)
				current_character_index += 1
				current_brick.set_next_character(current_character_index)
				if current_character_index == prompt.length():
					#print("done")
					add_score(prompt.length() * SCORE_MULT)
					current_character_index = 0
					current_brick.die()
					spawn_timer.start()

func gameover():
	pass

#==========Connected Functions==========#
func _on_SpawnTimer_timeout():
	spawn_brick()

func _on_StageBottom_body_entered(body):
	if body.get("type") == "Brick":
		body.disable_brick()
		reset_brick()
		bricks_stacked += 1
		if bricks_stacked >= BRICK_LIMIT:
			gameover()

#Testing
func _on_TestButton_pressed():
	Global.switch_scene("MainMenu")

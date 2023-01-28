extends Area2D

#==========TODO==========#

#==========Variables==========#
var SCORES = [10, 20, 30]
var cur_score_index = 0

#==========Onready Variables==========#
onready var anim : AnimatedSprite = $Anim

#==========Preload Variables==========#

#==========Functions==========#
func _ready():
	randomize()
	init()
	
func init():
	cur_score_index = randi() % 3
	randomize_frame()

func randomize_frame() -> void:
	anim.frame =  randi() % anim.frames.get_frame_count("default")
	
func die():
	Global.current_menu.add_score(SCORES[cur_score_index])
	Global.current_menu.add_score_animation(position, SCORES[cur_score_index])
	queue_free()

#==========Connected Functions==========#
func _on_Coins_body_entered(body):
	if body.get("type") == "player":
		die()

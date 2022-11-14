extends Area2D

#==========TODO==========#

#==========Variables==========#
export (Array) var COLORS = [Color("#ADD8E6"), Color("#90EE90"), Color("#FFFFFF")]

var SCORES = [10, 20, 30]
var cur_score_index = 0

#==========Onready Variables==========#
onready var color_rect = $ColorRect

#==========Preload Variables==========#

#==========Functions==========#
func _ready():
	randomize()
	init()
	
func init():
	cur_score_index = randi() % 3
	color_rect.color = COLORS[cur_score_index]

func die():
	Global.current_menu.add_score(SCORES[cur_score_index])
	queue_free()

#==========Connected Functions==========#
func _on_Coins_body_entered(body):
	if body.get("type") == "player":
		die()

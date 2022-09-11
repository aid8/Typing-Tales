extends Node2D

#==========Onready Variables==========#
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var score_label : Label = $ScoreLabel

#==========Functions==========#
func _ready():
	animation_player.play("Up")

func set_score(score : String) -> void:
	score_label.text = "+" + score

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Up":
		queue_free()

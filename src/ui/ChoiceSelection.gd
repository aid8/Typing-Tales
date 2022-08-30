extends Node2D

#==========Onready Variables==========#
onready var choice_text : RichTextLabel = $ChoiceText
onready var background : AnimatedSprite = $Background

#==========Variables==========#
var next_scene_name : String

#==========Functions==========#
func _ready():
	pass # Replace with function body.

func set_choice_text(text : String) -> void:
	choice_text.parse_bbcode("[center]" + text + "[/center]")
	
func set_background(type : String) -> void:
	if type == "idle":
		background.frame = 0
	elif type == "active":
		background.frame = 1
	elif type == "done":
		background.frame = 2

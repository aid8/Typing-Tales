extends Node2D

#==========Onready Variables==========#
onready var choice_text : RichTextLabel = $ChoiceText
onready var background : ColorRect = $Background

#==========Variables==========#
var next_scene_name : String

#==========Functions==========#
func _ready():
	pass # Replace with function body.

func set_choice_text(text) -> void:
	choice_text.text = text
	
#set_background()

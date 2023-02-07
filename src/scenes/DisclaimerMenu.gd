extends Node2D

#==========Variables==========#

#==========Onready Variables==========#
onready var disclaimer_label = $DisclaimerLabel

#==========Functions==========#
func _ready():
	disclaimer_label.text = Data.DISCLAIMER_TEXT

func _on_Timer_timeout():
	if Global.user_data["SchoolID"] == "":
		Global.switch_scene("IDInput")
	else:
		Global.switch_scene("MainMenu")

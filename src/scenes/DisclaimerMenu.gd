extends Node2D

#==========Variables==========#

#==========Onready Variables==========#
onready var disclaimer_label = $DisclaimerLabel
onready var disclaimer_timer = $DisclaimerTimer

#==========Functions==========#
func _ready():
	disclaimer_label.text = Data.DISCLAIMER_TEXT

func _on_Timer_timeout():
	ready_scene()

func _unhandled_input(event):
	if Input.is_action_pressed("ui_cancel"):
		disclaimer_timer.stop()
		ready_scene()

func ready_scene():
	if Global.user_data["SchoolID"] == "":
		Global.switch_scene("IDInput")
	else:
		Global.switch_scene("MainMenu")

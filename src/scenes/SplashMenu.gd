extends Node2D

#==========Onready Variables==========#
onready var barbara = $Barbara
onready var splash_timer = $SplashTimer

#==========Functions==========#
func _ready():
	barbara.play()
	if !Global.user_data.has("Fullscreen"):
		Global.user_data["Fullscreen"] = true
	OS.window_fullscreen = Global.user_data["Fullscreen"]

func _on_SplashTimer_timeout():
	Global.switch_scene("MainMenu")

func _unhandled_input(event):
	if Input.is_action_pressed("ui_cancel"):
		splash_timer.stop()
		Global.switch_scene("MainMenu")

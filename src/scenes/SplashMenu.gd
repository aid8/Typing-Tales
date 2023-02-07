extends Node2D

#==========Onready Variables==========#
onready var barbara = $Barbara

#==========Functions==========#
func _ready():
	barbara.play()

func _on_SplashTimer_timeout():
	Global.switch_scene("Disclaimer")

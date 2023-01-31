extends Node2D
#==========Variables==========#
#==========Onready Variables==========#
#==========Preload Variables==========#

#==========Functions==========#
func _ready():
	pass

func pause() -> void:
	get_tree().paused = true
	self.show()

#==========Connected Functions==========#
func _on_PauseResumeBtn_pressed():
	self.hide()
	get_tree().paused = false

func _on_MainMenuBtn_pressed():
	get_tree().paused = false
	#TODO: Add current session time here
	Global.switch_scene("MainMenu")

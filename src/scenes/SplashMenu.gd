extends Node2D

onready var barbara = $Barbara
#onready var transition_screen = $TransitionScreen

func _ready():
	#transition_screen.start_transition()
	barbara.play()

func _on_SplashTimer_timeout():
	Global.switch_scene("MainMenu")

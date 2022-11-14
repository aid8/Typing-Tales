extends Node2D

var current_tab = "Main"

onready var main = $Main
onready var challenges = $Challenges

func _ready():
	switch_tab(current_tab)

func switch_tab(tab : String):
	challenges.hide()
	main.hide()
	current_tab = tab
	
	if tab == "Main":
		main.show()
	elif tab == "Challenges":
		challenges.show()

#Main Menu Functions
func _on_StoryModeButton_pressed():
	Global.switch_scene("StoryMode")

func _on_ChallengeModeButton_pressed():
	switch_tab("Challenges")

func _on_StatisticsMenuButton_pressed():
	pass

func _on_SettingsMenuButton_pressed():
	pass

func _on_QuitButton_pressed():
	print("Application has been terminated")

#=====Challenges Functions=====#
func _on_Challenge1Button_pressed():
	Global.switch_scene("Challenge1")

func _on_Challenge1Button2_pressed():
	Global.switch_scene("Challenge2")

func _on_Challenge1Button3_pressed():
	Global.switch_scene("Challenge3")

func _on_Challenge1Button4_pressed():
	Global.switch_scene("Challenge4")

func _on_Challenge1Button5_pressed():
	Global.switch_scene("Challenge5")

func _on_BackButton_pressed():
	switch_tab("Main")

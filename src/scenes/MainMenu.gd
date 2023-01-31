extends Node2D

#==========Variables==========#
const white : Color = Color(1, 1, 1)
const purple : Color = Color(0.850507, 0.550386, 0.933105)

var current_tab : String = "Main"

#==========Onready Variables==========#
onready var main : Node2D = $Main
onready var challenges : Node2D = $Challenges
onready var statistics : Node2D = $Statistics
onready var settings : Node2D = $Settings
onready var title : Sprite = $Title
onready var novel_label : RichTextLabel = $NovelLabel
onready var main_buttons : Array = [$Main/StoryModeButton, $Main/ChallengeModeButton, $Main/StatisticsMenuButton, $Main/SettingsMenuButton, $Main/QuitButton]

#==========Functions==========#
func _ready() -> void:
	switch_tab(current_tab)
	for i in range(0, 5):
		main_buttons[i].connect("mouse_entered", self, "change_button_label_color", [main_buttons[i], purple])
		main_buttons[i].connect("mouse_exited", self, "change_button_label_color", [main_buttons[i], white])

func switch_tab(tab : String) -> void:
	challenges.hide()
	main.hide()
	statistics.hide()
	title.show()
	novel_label.show()
	current_tab = tab
	
	if tab == "Main":
		main.show()
	elif tab == "Challenges":
		challenges.show()
	elif tab == "Statistics":
		title.hide()
		novel_label.hide()

		var stats = Global.get_stats()
		statistics.get_node("StatsLabelLeft").text = "OVERALL WPM: " + String(stats.OverallWPM) + "\nOVERALL ACCURACY: " + String(stats.OverallAccuracy) + "\n\nSTORY WPM: " + String(round(stats.StoryWPM)) + "\nSTORY ACCURACY: " + String(round(stats.StoryAccuracy)) + "\n\nTOTAL TIME: " + String(stats.PlayTime)
		statistics.get_node("StatsLabelRight").text = "CHALLENGE STATS\n(#, WPM, ACC, COUNT)\n"
		for i in range(0, 5):
			var x = stats["ChallengeStats" + String(i+1)]
			statistics.get_node("StatsLabelRight").text += String(i+1) + " - " + String(round(x[0])) + ", " + String(round(x[1])) + "%, " + String(x[2]) + "\n"
		statistics.show()
		
	#To fix visual upon changing menus
	for i in range(0, 5):
		change_button_label_color(main_buttons[i], white)

func change_button_label_color(button, color) -> void:
	button.get_node("Label").set("custom_colors/font_color", color)

#==========Connected Functions==========#
#=====Main Menu Functions=====#
func _on_StoryModeButton_pressed():
	Global.switch_scene("StoryMode")

func _on_ChallengeModeButton_pressed():
	switch_tab("Challenges")

func _on_StatisticsMenuButton_pressed():
	switch_tab("Statistics")

func _on_SettingsMenuButton_pressed():
	switch_tab("Settings")

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
